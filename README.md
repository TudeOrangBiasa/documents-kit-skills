# Documents Kit Skills

> Write documents the right way. Pre-writing preparation, smart tool routing, 5-phase workflow, zero AI slop, citations that actually exist, passes AI detectors.

A **curated toolkit** of 3 coupled skills for AI-assisted document creation:

| Skill | Purpose |
|-------|---------|
| **document-writing** | Orchestrator. Workflow, decision rules, 30 anti-slop patterns, AI detection avoidance |
| **drawio** | Diagram generation with style presets, auto-layout, smart routing |
| **humanizer** | 30-pattern anti-AI catalog for prose (general purpose) |

Plus utility tools (scan-assets, fix-pandoc-leaks, detection-audit), templates (IPB/IEEE/ACM/hackathon), and design presets.

## Why this toolkit

These 3 skills are coupled:
- `document-writing` references drawio (for diagrams) and humanizer (for prose rewrite)
- `drawio` produces visuals that `document-writing` integrates
- `humanizer` is the canonical anti-AI catalog that `document-writing` specializes for academic/technical docs

Developing them together keeps references in sync, ensures consistent conventions, and enables end-to-end workflows.

## Quick start

```bash
# Install all 3 skills
./install.sh

# Verify
ls ~/.config/opencode/skills/document-writing ~/.config/opencode/skills/drawio ~/.config/opencode/skills/humanizer
```

Then in any conversation:
- "Write a hackathon proposal for [topic]" → document-writing loads
- "Generate an architecture diagram" → drawio loads
- "Humanize this paragraph" → humanizer loads

## Architecture

```
                document-writing (orchestrator)
                          |
        +-----------------+-----------------+
        |                 |                 |
   humanizer       drawio-skill      officecli
   (prose)         (diagrams)        (docx work)
        |                 |                 |
   +----+----+           |                 |
   |         |           |                 |
   impeccable    pandoc (md→docx)    scout (citations)
   (UI polish)                          |
                                   explore (code)
```

**Why document-writing is the orchestrator** (Hayes 2012 + Scriptorium):
- AI = translator + evaluator + transcriber (NEVER proposer for the author)
- Human owns: research question, argument structure, voice, honesty
- 4-pass review (draft → critique → rewrite → human edit) is non-negotiable for production-grade docs

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for full rationale.

## Repository structure

```
documents-kit-skills/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── install.sh                       # symlink installer
├── skills/
│   ├── document-writing/             # the orchestrator
│   │   ├── SKILL.md
│   │   ├── REFERENCE.md
│   │   └── scripts/
│   │       ├── detection-audit.sh
│   │       ├── scan-assets.sh
│   │       └── fix-pandoc-leaks.sh
│   ├── drawio/                      # the diagram tool
│   │   ├── SKILL.md
│   │   ├── REFERENCE.md
│   │   ├── data/
│   │   ├── references/
│   │   ├── scripts/
│   │   └── styles/
│   └── humanizer/                   # the prose rewriter
│       ├── SKILL.md
│       └── REFERENCE.md
├── tools/                           # cross-skill utilities
│   ├── doc-audit-pipeline.sh        # all audits in one command
│   ├── asset-validator.sh
│   └── pdf-from-docx.sh
├── templates/                        # format templates
│   ├── ipb-ppki.docx
│   ├── ieee-conference.docx
│   ├── acm-template.docx
│   └── hackathon-6slide.pptx
├── presets/                          # design tokens
│   ├── material-light.json
│   ├── ibm-carbon.json
│   └── hackathon-energetic.json
├── diagrams/                         # reusable drawio templates
│   ├── architecture.drawio
│   ├── erd-crows-foot.drawio
│   ├── flow-decision.drawio
│   └── sequence-basic.drawio
├── docs/
│   ├── ARCHITECTURE.md
│   ├── QUICKSTART.md
│   ├── COMMON_TASKS.md
│   ├── STYLE_PRESETS.md
│   └── DECISIONS.md
└── examples/
    ├── hackathon-proposal/
    └── academic-paper/
```

## Common workflows

### 1. Convert hackathon PRD to proposal

```bash
# Phase 0: scan existing assets
./tools/scan-assets.sh /path/to/project

# Build docx skeleton (md → docx)
pandoc proposal.md -o proposal.docx --reference-doc=templates/ipb-ppki.docx

# Post-conversion fixes
./skills/document-writing/scripts/fix-pandoc-leaks.sh proposal.docx --all --validate --screenshot

# Audit
./skills/document-writing/scripts/detection-audit.sh proposal.md

# Visual verify
officecli view proposal.docx screenshot -o verify.png
```

### 2. Generate diagram

See `drawio` skill. Workflow: clarifying questions → XML generation → draft PNG export → self-check with vision → final export with `-e` flag.

### 3. Humanize prose

See `humanizer` skill. Workflow: scan for 30 patterns → rewrite by meaning (not paraphrase) → re-scan.

## Verification

```bash
# Audit document (anti-AI patterns)
./skills/document-writing/scripts/detection-audit.sh your-doc.md

# All audits pipeline
./tools/doc-audit-pipeline.sh your-doc.md
```

## Installation

### Symlink install (development)

```bash
./install.sh
# Creates symlinks in ~/.config/opencode/skills/
# Re-run after changes to pick up updates
```

### Copy install (production)

```bash
SKILLS_TARGET=~/.config/opencode/skills ./install.sh --copy
# Files copied, not symlinked
```

### Verify install

```bash
ls -la ~/.config/opencode/skills/ | grep -E "document-writing|drawio|humanizer"
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Key principles:
- Skills should follow write-a-skill principles (description with triggers, <500 lines for SKILL.md, deterministic work in scripts/)
- Cross-skill references should be by skill name, not absolute path
- New tools should be in `tools/`, not duplicated across skills
- New presets should follow the JSON schema in `presets/`

## License

MIT License. See [LICENSE](LICENSE).

## Acknowledgments

Built on research from:
- Hayes 2012 Cognitive-Process Model
- Scriptorium (seandavi)
- Hutson 2025 Multidimensional Framework
- Knowles 2024 Rhetorical Load Sharing
- Wikipedia:Signs of AI writing
- 12 academic and HCI papers on human-AI co-writing

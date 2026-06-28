# Documents Kit Skills

> Write documents the right way. Pre-writing preparation, smart tool routing, 5-phase workflow, zero AI slop, citations that actually exist, passes AI detectors.

A **curated toolkit** of 5 coupled skills for AI-assisted document creation:

| Skill | Purpose |
|-------|---------|
| **document-writing** | Orchestrator. Workflow, decision rules, 30 anti-slop patterns, AI detection avoidance |
| **drawio** | Diagram generation with 5 style presets (semantic/AWS/Azure/Carbon/Nord) + 5 templates (C4/AWS/microservices/sequence) + routing/layout rules |
| **humanizer** | 30-pattern anti-AI catalog for prose (general purpose) |
| **officecli** | docx/pptx/xlsx manipulation via MCP (used by document-writing for PATH B + post-conversion fixes) |
| **scholar-paper-mcp** | Semantic Scholar citation pipeline — search, track in session, export BibTeX, Pandoc citeproc |

Plus utility tools (scan-assets, fix-pandoc-leaks, detection-audit, asset-validator, pdf-from-docx, doc-audit-pipeline, scholar-bibtex), 5 diagram templates, 5 drawio style presets, and 2 doc-level presets.

## External dependencies

- **officecli** (MCP) — required for `.docx` manipulation, post-conversion fixes, validation. Install: https://github.com/iOfficeAI/officecli
- **scholar-paper-mcp** (MCP) — Semantic Scholar citation pipeline. Installed automatically by `install.sh` as a peer dep.
- **pandoc** — required for `md → docx` conversion. Install: `brew install pandoc` or `apt install pandoc`
- **python3 >=3.13** (with uv) — required for scholar-paper-mcp and glue tools. Auto-installed by `install.sh` if missing.
- **git-lfs** — required for mE5 model bundle in scholar-paper-mcp.

## Why this toolkit

These 5 skills are coupled:
- `document-writing` references drawio (for diagrams), humanizer (for prose rewrite), and scholar-paper-mcp (for citations)
- `drawio` produces visuals that `document-writing` integrates
- `humanizer` is the canonical anti-AI catalog that `document-writing` specializes for academic/technical docs
- `scholar-paper-mcp` provides real citation data that feeds document-writing's citation workflow

Developing them together keeps references in sync, ensures consistent conventions, and enables end-to-end workflows.

## Quick start

```bash
# Install all 5 skills + peer deps + MCP registration + self-verify
./install.sh

# Or step by step:
./install.sh --skills-only   # only local skills
./install.sh --peer-only     # only peer deps + MCP registration
./install.sh --verify        # self-verify

# Verify install
ls ~/.config/opencode/skills/{document-writing,drawio,humanizer,officecli}
ls -d ~/.local/share/documents-kit-skills/peer/scholar-paper-mcp
```

Then in any conversation:
- "Write a hackathon proposal for [topic]" → document-writing loads
- "Generate an architecture diagram" → drawio loads
- "Humanize this paragraph" → humanizer loads
- "Search papers on transformer attention and export BibTeX" → scholar-paper-mcp

## Architecture

```
                document-writing (orchestrator)
                          |
        +-----------------+-----------------+
        |                 |                 |
   humanizer       drawio-skill      officecli
   (prose)         (diagrams)        (docx work)
        |                 |                 |
   +----+----+           |           +-----+-----+
   |         |           |           |           |
   impeccable    pandoc (md→docx)    scout    scholar-paper-mcp
   (UI polish)                  (citations)  (Semantic Scholar)
                                         |
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
├── install.sh                       # agent-friendly installer (--all, --verify, --uninstall)
├── skills/
│   ├── document-writing/             # the orchestrator (5-phase workflow)
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
│   ├── humanizer/                   # the prose rewriter
│   │   ├── SKILL.md
│   │   └── REFERENCE.md
│   └── officecli/                   # the docx/pptx/xlsx tool (PATH B)
├── tools/                           # cross-skill utilities
│   ├── doc-audit-pipeline.sh        # all audits in one command
│   ├── asset-validator.sh
│   ├── pdf-from-docx.sh
│   ├── scholar_bibtex.py            # citation pipeline glue (PEP 723, MCP client)
│   └── tests/
│       └── test_scholar_bibtex.py   # glue tool tests (MCP SDK mocked)
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

### Install for AI agents

Copy-paste this prompt to install from zero:

```
Install documents-kit-skills from https://github.com/TudeOrangBiasa/documents-kit-skills.
Clone the repo, run `./install.sh --all`, then run `./install.sh --verify` to confirm
all 5 skills plus the scholar-bibtex glue tool are working. Use uv for Python management.
```

### Symlink install (development)

```bash
./install.sh --skills-only
# Creates symlinks in ~/.config/opencode/skills/
# Re-run after changes to pick up updates
```

### Full install (all skills + peer deps)

```bash
./install.sh --all
# 1. Prerequisite check (git, uv, git-lfs, python 3.13)
# 2. Install 4 local skills
# 3. Clone + sync scholar-paper-mcp
# 4. Register MCP server in opencode.json
# 5. Self-verify (list tools, export BibTeX)
```

### Copy install (production)

```bash
SKILLS_TARGET=~/.config/opencode/skills ./install.sh --copy
# Files copied, not symlinked
```

### Verify install

```bash
./install.sh --verify
# Or manually:
# 4 local skills
ls ~/.config/opencode/skills/{document-writing,drawio,humanizer,officecli}
# 1 peer dep (MCP server, not a skill per se)
ls -d ~/.local/share/documents-kit-skills/peer/scholar-paper-mcp
```

### Uninstall

```bash
./install.sh --uninstall
# Removes skills symlinks, peer deps, and MCP registration
```

### Peer dependencies

`install.sh --all` installs one peer dependency:

| Peer | Purpose | Cloned to |
|------|---------|-----------|
| **scholar-paper-mcp** | Semantic Scholar MCP server — search, track, export BibTeX | `~/.local/share/documents-kit-skills/peer/scholar-paper-mcp/` |

The glue tool `tools/scholar_bibtex.py` (PEP 723, no shell wrapper) wraps this MCP server for CLI use:

```bash
uv run tools/scholar_bibtex.py add my-session 10.1145/123456
uv run tools/scholar_bibtex.py export my-session refs.bib
uv run tools/scholar_bibtex.py list my-session
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). For **AI agents** working on this codebase, see [AGENTS.md](AGENTS.md) — mandatory rules on architecture (MCP vs CLI), TDD discipline, ponytail constraints, and anti-patterns to avoid. Key principles:
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

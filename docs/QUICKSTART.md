# Quickstart

5 minutes from install to first document.

## Install

```bash
git clone https://github.com/your-org/documents-kit-skills.git
cd documents-kit-skills
./install.sh
```

Restart OpenCode to pick up the new skills.

## Verify

```bash
ls -la ~/.config/opencode/skills/ | grep -E "document-writing|drawio|humanizer"
```

You should see 3 symlinks.

## First conversation

Try this in OpenCode:

> "Convert my hackathon PRD to a 7-chapter proposal. PRD is at /path/to/prd.md."

Expected:
- `document-writing` loads
- Phase 0: scans your project for existing diagrams
- Phase 1: outlines 7 BAB
- Phase 2: gathers assets
- Phase 3: drafts
- Phase 4: 4-pass review
- Output: `proposal.docx`

## Common commands

```bash
# Anti-AI audit
./skills/document-writing/scripts/detection-audit.sh your-doc.md

# Fix pandoc conversion issues
./skills/document-writing/scripts/fix-pandoc-leaks.sh your-doc.docx --all --validate --screenshot

# Scan project for existing assets
./tools/scan-assets.sh /path/to/your/project
```

## Where to go next

- [COMMON_TASKS.md](COMMON_TASKS.md) — specific workflows (PRD to proposal, extend existing, etc.)
- [ARCHITECTURE.md](ARCHITECTURE.md) — how the 3 skills work together
- [DECISIONS.md](DECISIONS.md) — why we made certain choices
- [STYLE_PRESETS.md](STYLE_PRESETS.md) — design tokens for consistent visual identity

## What this does NOT do

- No automatic writing — you must provide the content/intent, AI assists
- No real-time collaboration — workflow is sequential (Phase 0 → 4)
- No version control of drafts — use git externally
- No citation lookup — use `scout` skill or external tools

## Common errors

### "officecli not found"
The toolkit depends on officecli MCP tool. See [ARCHITECTURE.md](ARCHITECTURE.md) for setup.

### "pandoc not found"
```bash
sudo apt install pandoc  # Linux
brew install pandoc      # macOS
```

### "drawio CLI not found"
```bash
brew install --cask drawio  # macOS
# Or download from https://github.com/jgraph/drawio-desktop/releases
```

### "drawio_skill not loading"
The trigger in OpenCode config might be misconfigured. Check `~/.config/opencode/opencode.json`:
```json
{
  "agent": {
    "orchestrator": {
      "skill_triggers": {
        "drawio": ["drawio", "diagram", "flowchart", "erd"]
      }
    }
  }
}
```

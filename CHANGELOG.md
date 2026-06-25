# Changelog

All notable changes to this project will be documented in this file.

Format: [version] - YYYY-MM-DD

## [0.1.0] - 2026-06-25

### Added
- Initial release of documents-kit-skills
- 3 coupled skills:
  - `document-writing` (orchestrator) — 5-phase workflow, 30 anti-slop patterns, AI detection avoidance
  - `drawio` — diagram generation with style presets
  - `humanizer` — 30-pattern anti-AI catalog
- 3 utility scripts:
  - `scan-assets.sh` — JSON manifest of existing project assets
  - `fix-pandoc-leaks.sh` — 6 post-conversion fixes for pandoc output
  - `detection-audit.sh` — 8-check anti-AI pattern audit
- Documentation:
  - `docs/ARCHITECTURE.md` — how the 3 skills work together
  - `docs/QUICKSTART.md` — common workflows
  - `docs/COMMON_TASKS.md` — cookbook
  - `docs/DECISIONS.md` — architectural decision rationale
- Install script (`install.sh`) — symlink or copy to `~/.config/opencode/skills/`

### Known gaps (planned for 0.2.0)
- `presets/` empty — design tokens not yet created
- `templates/` empty — format templates not yet created
- `diagrams/` empty — reusable drawio templates not yet created
- `tools/doc-audit-pipeline.sh` not yet implemented
- `tools/asset-validator.sh` not yet implemented
- `drawio` skill not yet enhanced for smart routing + auto-layout

### Provenance
Skills derived from opencode-workflow/skills/{productivity,misc}/ and OpenViking session learnings (2026-06-23 to 2026-06-25).

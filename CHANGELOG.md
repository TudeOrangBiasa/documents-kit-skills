# Changelog

All notable changes to this project will be documented in this file.

Format: [version] - YYYY-MM-DD

## [0.2.0] - 2026-06-25

### Added — drawio enhancement
- **5 drawio style presets** (`presets/drawio-styles/`):
  - `semantic.json` — de facto standard palette (process/decision/database/etc)
  - `aws.json` — AWS official per-service-category colors
  - `azure.json` — Azure official palette
  - `carbon.json` — IBM Carbon Design (10-step scales)
  - `nord.json` — Nord-inspired cool minimal
- **5 reusable diagram templates** (`diagrams/`):
  - `c4-context.drawio` — C4 Level 1 (System Context) with actors + external systems
  - `aws-3-tier.drawio` — CloudFront → ALB → EC2 → RDS + ElastiCache + S3
  - `microservices.drawio` — API Gateway + 5 services + SNS (sync/async patterns)
  - `sequence-template.drawio` — Generic UML sequence with 4 actors + return messages + notes
  - `architecture.drawio` — (from 0.1.0) 3-tier client/api/db
- **3 patterns to OpenViking**:
  - `drawio-templates` — built-in libraries + palette + XML style format + patterns
  - `diagram-visual-design` — Tufte + Gestalt principles, layout, routing, color, typography rules
  - `diagram-types` — UML/BPMN/ERD/C4/ArchiMate standards + shape conventions

### Rules added
- Routing: orthogonal always, zero crossings, route around nodes
- Layout: single flow direction (L2R or T2D), grid 8-10px, 20% whitespace
- Color: max 3-4 semantic, WCAG 4.5:1, colorblind-safe
- Typography: sans-serif 10pt min, sentence case, no overflow
- Information density: 30-second test, decompose at 15-20 nodes

### Provenance
Scout research 2026-06-25 (3 parallel agents via exa MCP). Sources:
- drawio.com official docs, jgraph/drawio-mcp, github/awesome-copilot
- C4 model (Simon Brown), ArchiMate (Open Group), UML 2.5 (OMG), BPMN 2.0 (ISO/IEC 19510)
- Tufte's "The Visual Display of Quantitative Information", IBM Design Language
- AWS, Azure, GCP, IBM Cloud official icon libraries

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

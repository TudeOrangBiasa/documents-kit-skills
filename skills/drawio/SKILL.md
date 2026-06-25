---
name: drawio
version: 2.0.0
description: Generate `.drawio` diagrams with style presets (semantic, AWS, Azure, Carbon, Nord), reusable templates (C4, AWS 3-tier, microservices, sequence), and routing/layout rules (orthogonal, zero crossings, semantic color). Use when user requests architecture diagrams, flowcharts, ER/UML/BPMN/C4, network topology, or any visualization. Generates .drawio XML and exports to PNG/SVG/PDF via drawio desktop CLI.
license: MIT
homepage: https://github.com/Agents365-ai/drawio-skill
compatibility: Requires draw.io desktop app CLI on PATH. Auto-layout (scripts/autolayout.py) needs Graphviz.
platforms: [macos, linux, windows]
---

# Draw.io Diagrams (Enhanced)

## When to use

- Architecture, ER, UML, BPMN, C4, sequence diagrams, network topology, ML/DL figures
- Anything needing precise styling, 10,000+ stock shapes, swimlanes, custom geometry
- Output as editable PNG/SVG/PDF (use `-e` for embedded XML)

## When NOT to use

- Casual/hand-drawn look → excalidraw or tldraw
- Diagrams-as-code in git/Markdown → mermaid (general) or plantuml (UML)
- Freeform infinite canvas → tldraw

## Quick start

```bash
brew install --cask drawio   # macOS
drawio --version

# Generate .drawio XML (use templates from diagrams/)
cp diagrams/c4-context.drawio my-diagram.drawio
# Edit in drawio or via XML

# Export
drawio -x -f png --width 2000 -o diagram.png diagram.drawio       # draft (no -e)
drawio -x -f png --width 2000 -e -o diagram.drawio.png diagram.drawio  # final (with -e)
```

## Style Presets (5 — `presets/drawio-styles/`)

| Preset | Best for | Apply when |
|--------|----------|-----------|
| `semantic.json` | UML, ER, BPMN, generic | Mixed-notation, no specific platform |
| `aws.json` | AWS architecture | Cloud diagrams with AWS service icons |
| `azure.json` | Azure architecture | Microsoft-centric, Azure services |
| `carbon.json` | Enterprise B2B | IBM-style, restrained, professional |
| `nord.json` | Documentation, dark/light pair | Minimal, open-source projects |

**Use semantic palette by default** (de facto standard). Switch to AWS/Azure/Carbon/Nord when the user has a specific platform or aesthetic need.

## Diagram Templates (5 — `diagrams/`)

| Template | Use when |
|----------|----------|
| `c4-context.drawio` | System as black box + actors + external systems (Level 1) |
| `aws-3-tier.drawio` | CloudFront → ALB → EC2/ECS → RDS pattern |
| `microservices.drawio` | API Gateway + per-service DB + async events via SNS |
| `sequence-template.drawio` | Generic UML sequence with 4 actors + return messages |
| `architecture.drawio` | 3-tier client/API/DB |

**Copy template → edit → export.** Templates have the structure pre-built (groups, edges, style applied). You only fill in names and details.

## Workflow (5 phases)

1. **Clarify** — type, format, location, scope. Pick preset (semantic default).
2. **Pick template** — copy from `diagrams/` if one matches, else generate from scratch.
3. **Generate** — write .drawio XML. Apply style preset colors. Use shape conventions (rectangle=process, cylinder=DB, etc.).
4. **Self-check** — export draft PNG, review with vision (max 2 rounds). Check routing, layout, text.
5. **Final export** — `drawio -x -f png --width 2000 -e -o final.drawio.png final.drawio`

## Diagram Type Decision Tree

| Need | Notation | Template |
|------|----------|----------|
| Process flow with decisions | Flowchart | (generate) |
| Static software structure | UML Class | (generate) |
| Time-ordered messages | UML Sequence | `sequence-template.drawio` |
| Workflow with parallel forks | UML Activity | (generate) |
| State-based behavior | UML State Machine | (generate) |
| User goals + system | UML Use Case | (generate) |
| Deployable modules + interfaces | UML Component | (generate) |
| Physical infrastructure | UML Deployment | (generate) |
| Database schema | ERD (Crow's foot) | (generate) |
| Business process orchestration | BPMN 2.0 | (generate) |
| Software architecture (multi-level) | C4 | `c4-context.drawio` |
| Cloud architecture (AWS) | AWS palette | `aws-3-tier.drawio` |
| Microservices | Custom | `microservices.drawio` |
| Enterprise architecture | ArchiMate | (generate) |

## Core Rules (Quick Ref)

| Rule | Reason |
|------|--------|
| **Orthogonal routing** (90° bends) | Eye follows paths; diagonals break grid flow |
| **Zero crossings** | Every crossing = cognitive overhead |
| **Single flow direction** (L2R or T2D) | Never mix |
| **Grid 8-10px** | Snap all nodes, no stair-stepping |
| **20% whitespace** | Don't cram; breathing room helps comprehension |
| **3-4 semantic colors max** | Color for categorization, not decoration |
| **Sans-serif 10pt min** | Readable when exported/screenshotted |
| **Sentence case labels** | Consistency |
| **30-second test** | Unfamiliar viewer traces path in ≤30s |
| **Decompose at 15-20 nodes** | Sub-diagrams for complex systems |

For full routing, layout, color, typography rules with examples, see [ENHANCEMENTS.md](ENHANCEMENTS.md).

## Output Format Decisions

| Format | Use | Notes |
|--------|-----|-------|
| **PNG** | Documents, slides, web | Use `-e` for editable |
| **SVG** | Web, infinite zoom | Vector, smaller file |
| **PDF** | Print, archive | Vector, high quality |
| **JPG** | Email, small file | Lossy, avoid for diagrams with text |
| **.drawio.png** | Editing + sharing | Embeds XML, double extension signals |

## Common Pitfalls (Avoid)

- ❌ Diagonal connectors → ✅ Orthogonal with `edgeStyle=orthogonalEdgeStyle`
- ❌ Random element placement → ✅ Zone layout (input → process → output)
- ❌ Rainbow colors → ✅ Max 3-4 semantic + legend
- ❌ Vague labels ("Process 1") → ✅ Verb-noun ("Validate Payment")
- ❌ Text overflow → ✅ Word wrap, padding 4-6px
- ❌ Routing through nodes → ✅ Route in open space
- ❌ Mixing flow directions → ✅ Pick L2R or T2D before drawing

## Reference

- [ENHANCEMENTS.md](ENHANCEMENTS.md) — full routing/layout/color/typography rules
- [REFERENCE.md](REFERENCE.md) — XML structure, export commands, bundled resources
- `presets/drawio-styles/` — 5 style presets
- `diagrams/` — 5 reusable templates
- [drawio.com docs](https://www.drawio.com/docs) — official documentation
- [C4 model](https://c4model.com/) — Simon Brown's architecture notation

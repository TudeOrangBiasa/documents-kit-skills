---
name: drawio-skill
version: 1.14.0
description: Use when the user requests diagrams, flowcharts, architecture diagrams, ER diagrams, UML / sequence / class diagrams, network topology, ML/DL model figures (Transformer/CNN/LSTM), mind maps, or any visualization. Also use proactively when explaining systems with 3+ components, complex data flows, or relationships that benefit from visual representation. Best suited when the diagram needs custom styling, rich shape vocabulary, swimlanes, or exportable images (PNG/SVG/PDF/JPG). Generates .drawio XML and exports locally via the native draw.io desktop CLI.
license: MIT
homepage: https://github.com/Agents365-ai/drawio-skill
compatibility: Requires draw.io desktop app CLI on PATH (macOS/Linux/Windows). Self-check step requires a vision-enabled model (e.g., Claude Sonnet/Opus); gracefully skipped if unavailable. Optional auto-layout (scripts/autolayout.py) needs Graphviz (dot).
platforms: [macos, linux, windows]
metadata: {"openclaw":{"requires":{"anyBins":["draw.io","drawio"]},"emoji":"📐","os":["darwin","linux","win32"],"install":[{"id":"brew-drawio","kind":"brew","formula":"drawio","bins":["drawio"],"label":"Install draw.io via Homebrew","os":["darwin"]},{"id":"brew-graphviz","kind":"brew","formula":"graphviz","bins":["dot"],"label":"Install Graphviz for optional autolayout.py","os":["darwin"],"optional":true}]},"hermes":{"tags":["drawio","diagram","flowchart","architecture","visualization","uml"],"category":"design","requires_tools":["drawio","draw.io"],"related_skills":["mermaid","excalidraw","plantuml"]},"author":"Agents365-ai","version":"1.14.0"}
---

# Draw.io Diagrams

## Overview

Generate `.drawio` XML files and export to PNG/SVG/PDF/JPG locally using the native draw.io desktop app CLI.

**Supported formats:** PNG, SVG, PDF, JPG — no browser automation needed.

PNG, SVG, and PDF exports support `--embed-diagram` (`-e`) — the exported file contains the full diagram XML, so opening it in draw.io recovers the editable diagram. Use double extensions (`name.drawio.png`) to signal embedded XML.

## When to use / when NOT to use

**Use this skill for:** polished, precise diagrams (architecture, network, strict UML, ERD), anything needing solid opaque fills, 10,000+ stock/branded shapes, swimlanes, or custom geometry, exported as editable PNG/SVG/PDF.

**Do NOT use it — route elsewhere — for:**
- A casual hand-drawn / whiteboard look → **excalidraw** or **tldraw**.
- Diagrams-as-code that live in git / render in Markdown → **mermaid** (general) or **plantuml** (UML).
- Freeform infinite-canvas sketching or freehand strokes → **tldraw**.

See [REFERENCE.md](REFERENCE.md) for bundled resources table, prerequisites, workflow details (self-check, review loop, final export), XML structure, export commands, style presets, and diagram type presets.

## Prerequisites (Quick)

```bash
brew install --cask drawio   # macOS
drawio --version
```

Install from https://github.com/jgraph/drawio-desktop/releases if missing. Linux: avoid snap (AppArmor issue).

## Workflow

1. Ask clarifying questions (type, format, location, scope)
2. Resolve active preset → check user message, then `~/.drawio-skill/styles/`
3. Check deps → resolve binary name, plan shapes/layout
4. Generate .drawio XML (hand-place or autolayout for >15 nodes)
5. Export draft PNG (`drawio -x -f png --width 2000 -o draft.png input.drawio` — NO `-e`)
6. Self-check with vision (max 2 rounds)
7. Review loop with user (targeted XML edits, re-export)
8. Final export with `-e`, run `repair_png.py` for PNG

See [REFERENCE.md](REFERENCE.md) for full details on self-check tables, review loop rules, XML structure, export commands, style presets, and diagram type presets.

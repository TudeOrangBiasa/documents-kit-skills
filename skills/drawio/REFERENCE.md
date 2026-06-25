# Draw.io Diagrams — Reference

See [SKILL.md](SKILL.md) for workflow overview, prerequisites, and quick start.

## Bundled Resources

| File | Read it when |
|---|---|
| `references/diagram-types.md` | User names a specific diagram type |
| `references/shapes.md` + `scripts/shapesearch.py` | Diagram needs a specific shape |
| `scripts/aiicons.py` | Diagram involves an AI/LLM brand logo |
| `references/style-presets.md` | Style preset management |
| `references/style-extraction.md` | Extraction procedure (inside Learn flow) |
| `references/troubleshooting.md` | Export fails, vision rejects PNG, rendering wrong |
| `scripts/repair_png.py` | After every `-e` PNG export |
| `scripts/encode_drawio_url.py` | CLI unavailable, need browser fallback |
| `references/autolayout.md` | Large/layout-heavy diagrams |
| `scripts/pyimports.py` · `jsimports.py` · `goimports.py` · `rustimports.py` | Visualize project import graph |
| `scripts/pyclasses.py` | Python class hierarchy |
| `scripts/validate.py` | Structural lint before export |

## Workflow Details

### Step 0 — Resolve Active Preset
Scan user message for "use my `<name>` style" → clear match activates that preset.
Else check `~/.drawio-skill/styles/` for `"default": true`.
Else → no preset active.

### Step 5: Self-Check
After exporting draft PNG, use vision capability to check:

| Check | What to look for | Auto-fix |
|-------|-----------------|----------|
| Overlapping shapes | Shapes stacked on each other | Shift apart by ≥200px |
| Clipped labels | Text cut off at shape boundaries | Increase shape width/height |
| Missing connections | Arrows not connecting | Verify source/target ids |
| Off-canvas shapes | Shapes at negative coords | Move to positive coords |
| Edge-shape overlap | Edge through unrelated shape | Add waypoints or increase spacing |
| Stacked edges | Multiple edges same path | Distribute entry/exit points |

Max 2 self-check rounds. Re-export after each fix.

### Step 6: Review Loop
After self-check, show exported image and ask for feedback.

| User request | XML edit action |
|-------------|----------------|
| Change color | Update `fillColor`/`strokeColor` in `style` |
| Add new node | Append new `mxCell` with next available id |
| Remove a node | Delete `mxCell` + edges with matching source/target |
| Move shape | Update `x`/`y` in `mxGeometry` |
| Add arrow | Append new `mxCell` edge with source/target |
| Change label | Update `value` attribute |

For single-element changes: edit existing XML in place.
For layout-wide changes: regenerate full XML.
Loop continues until user says approved. Safety valve: after 5 rounds, suggest draw.io desktop.

### Step 7: Final Export
Export to all requested formats. Report file paths. Offer to open `.drawio` file in draw.io desktop.

## Style Presets

A named JSON file capturing visual preferences. Lookup order:
1. `~/.drawio-skill/styles/<name>.json` (user presets)
2. `<this-skill-dir>/styles/built-in/<name>.json` (built-in: `default`, `corporate`, `handdrawn`)

For Learn flow, management ops, and application rules → read `references/style-presets.md`.

## Draw.io XML Structure

### File Skeleton
```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="drawio" version="26.0.0">
  <diagram name="Page-1">
    <mxGraphModel>
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <!-- user shapes start at id="2" -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

**Rules:** `id="0"` and `id="1"` required. User shapes start at `id="2"`. All shapes have `parent="1"` unless inside a container. Text uses `html=1` in style. Escape special chars: `&amp;`, `&lt;`, `&gt;`, `&quot;`. Multi-line: `&#xa;`.

### Shape Types
| Style keyword | Use for |
|--------------|---------|
| `rounded=0` | Plain rectangle (default) |
| `rounded=1` | Rounded rectangle — services, modules |
| `ellipse;` | Circles/ovals — start/end, databases |
| `rhombus;` | Diamond — decision points |
| `shape=mxgraph.aws4.resourceIcon;` | AWS icons |
| `shape=cylinder3;` | Cylinder — databases |
| `swimlane;` | Group/container with title bar |

For vendor icons → `shapesearch.py "<keywords>"`. For AI brand logos → `aiicons.py "<brand>"`.

### Required Properties
```xml
<!-- Rectangle -->
<mxCell id="2" value="Label" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="160" height="60" as="geometry" />
</mxCell>
```

### Containers and Groups

| Type | Style | When to use |
|------|-------|-------------|
| **Group** (invisible) | `group;pointerEvents=0;` | No visual border needed |
| **Swimlane** (titled) | `swimlane;startSize=30;` | Visible title bar needed |
| **Custom container** | Add `container=1;pointerEvents=0;` | Any shape as container |

Children set `parent="containerId"` and use relative coordinates.

### Connector (Edge)
```xml
<mxCell id="10" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="1" source="2" target="3">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```
**Every edge must have `<mxGeometry relative="1" as="geometry" />`** — self-closing is invalid.

**Animated connectors:** add `flowAnimation=1;` for moving dot animation.

### Entry/Exit Point Distribution

| Position | exitX/entryX | exitY/entryY |
|----------|-------------|-------------|
| Top center | 0.5 | 0 |
| Right center | 1 | 0.5 |
| Bottom center | 0.5 | 1 |
| Left center | 0 | 0.5 |

### Default Color Palette (no preset active)

| Color | fillColor | strokeColor | Use |
|-------|-----------|-------------|-----|
| Blue | `#dae8fc` | `#6c8ebf` | services, clients |
| Green | `#d5e8d4` | `#82b366` | success, databases |
| Yellow | `#fff2cc` | `#d6b656` | queues, decisions |
| Orange | `#ffe6cc` | `#d79b00` | gateways, APIs |
| Red/Pink | `#f8cecc` | `#b85450` | errors, alerts |
| Grey | `#f5f5f5` | `#666666` | external/neutral |
| Purple | `#e1d5e7` | `#9673a6` | security, auth |

### Layout Tips

| Diagram complexity | Nodes | Horizontal gap | Vertical gap |
|-------------------|-------|----------------|--------------|
| Simple | ≤5 | 200px | 150px |
| Medium | 6–10 | 280px | 200px |
| Complex | >10 | 350px | 250px |

Snap to multiples of 10. Leave ~80px routing corridors. Place hubs centrally.

## Export

### Commands
```bash
# Preview PNG (step 4) — NO -e, width-capped
drawio -x -f png --width 2000 -o diagram.png input.drawio

# Final PNG (step 7) — WITH -e, double extension
drawio -x -f png -e -s 2 -o diagram.drawio.png input.drawio

# SVG export
drawio -x -f svg -e -o diagram.svg input.drawio

# PDF export
drawio -x -f pdf -e -o diagram.pdf input.drawio
```

### Post-export PNG Repair (required after `-e` PNG)
```bash
python3 <this-skill-dir>/scripts/repair_png.py diagram.drawio.png
```

### Key Flags
- `-x` — export mode (required)
- `-f` — format: png, svg, pdf, jpg
- `-e` — embed diagram XML (skip for step 5 preview)
- `-s` — scale: 1, 2, 3 (use 2 for final PNG)
- `--width <px>` — target width (use 2000 for preview)
- `-o` — output file path
- `-b` — border width (default 0, recommend 10)
- `-t` — transparent background (PNG only)

### Browser Fallback
```bash
python3 <this-skill-dir>/scripts/encode_drawio_url.py input.drawio
python3 <this-skill-dir>/scripts/encode_drawio_url.py --edit input.drawio
```

### Fallback Chain
| Scenario | Behavior |
|----------|----------|
| drawio CLI missing, Python available | Browser fallback URL |
| drawio CLI & Python missing | .drawio XML only |
| CLI crashes in macOS sandbox | Browser fallback, ask user to export |
| Vision unavailable | Skip self-check |
| Export fails on Linux | xvfb-run → --no-sandbox → Docker |

### Checking PATH
```bash
if command -v drawio &>/dev/null; then DRAWIO="drawio"
elif command -v draw.io &>/dev/null; then DRAWIO="draw.io"
fi
```

## Common Mistakes
See `references/troubleshooting.md` for full mistake → fix table.

## Diagram Type Presets

| User says | Section in `references/diagram-types.md` |
|---|---|
| "ER diagram", "data model" | ERD |
| "UML class diagram" | UML Class |
| "sequence diagram" | Sequence |
| "architecture diagram" | Architecture |
| "neural network", "ML diagram" | ML / Deep Learning Model |
| "flowchart", "process flow" | Flowchart |

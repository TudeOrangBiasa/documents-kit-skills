# Draw.io Enhancements

Detailed rules for routing, layout, color, and typography. Read when generating or reviewing diagrams.

---

## Routing Rules (Critical — Most Common Failure)

### 1. Orthogonal Always (90° Bends)

All connectors use Manhattan routing. No diagonals.

```xml
<!-- WRONG: diagonal -->
<mxCell edge="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>

<!-- RIGHT: orthogonal -->
<mxCell edge="1" style="edgeStyle=orthogonalEdgeStyle;rounded=1;jettySize=auto;orthogonalLoop=1;">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

### 2. Zero Crossings Target

Every crossing = cognitive overhead. Reposition nodes if 2+ crossings in one area.

**Common fix**: Mirror L2R flow direction. Process group on left → decision → outcome on right. Long connectors go around the edges, not through center.

### 3. Edge Convention

- **Input from left edge of process** → output to right edge
- Long edges: route around the diagram perimeter
- Fork/join: bars align perfectly (misalignment implies wrong execution order)

### 4. Bridge for Unavoidable Crossings

Use "over/under" arc symbols or small jump bridges.

---

## Layout Rules

### 1. Single Flow Direction

Pick **L2R** (left-to-right) or **T2D** (top-to-down) before drawing. Never mix.
- L2R mirrors reading order, suits most flows
- T2D suits layered architecture (presentation → business → data)

### 2. Grid Alignment

Snap all nodes to 8px or 10px grid. Stair-stepping = lack of planning.

### 3. 20% White Space Minimum

Microsoft guideline. Separates groups, defines relationships, guides attention.

### 4. Zone Organization

- Input / actors: left edge
- Process / business logic: center
- Storage / output: right edge or bottom

### 5. Chunking Limit (4±1)

Humans hold 4±1 chunks in working memory. Group related nodes. Don't exceed ~7-9 per visual group.

### 6. 30-Second Test

Unfamiliar viewer should trace the primary path in ≤30 seconds. If not, reduce density or decompose.

### 7. Decompose at 15-20 Nodes

When a diagram exceeds 15-20 nodes or 20-25 connectors, split into sub-diagrams. Show overview first, then drill-downs.

---

## Color Rules

### 1. Max 3-4 Semantic Colors

Blue = entities/actors, Green = processes/functions, Yellow/Orange = data stores, Red = critical/error flows. Use one color per concept, not per element.

### 2. Colorblind-Safe

8% of males have red-green deficiency. Never rely on red-green alone. Add patterns, hatching, or text labels. Use these colorblind-safe palettes:
- IBM: don't mix greens with reds/magentas/purples
- ColorBrewer palettes
- Test in grayscale

### 3. WCAG AA Contrast Minimums

- Body text: **4.5:1** (small text < 18pt)
- Large text: **3:1** (≥ 18pt or ≥ 14pt bold)
- Graphical elements: **3:1**

### 4. Grayscale Test

Diagram must remain readable when printed B&W. If meaning depends on color, add text labels or patterns.

### 5. Thicker Lines for Critical Flows

2-3px for critical data paths. Dashed for conditional/optional.

---

## Typography Rules

### 1. Sans-Serif Always

Inter, IBM Plex Sans, Segoe UI, Roboto, or system-ui. Avoid serif (poor screen readability at small sizes).

### 2. Min Size: 10pt

Smaller becomes unreadable when exported/screenshotted. 9pt absolute minimum for inline text.

### 3. Hierarchy Scale

| Element | Size | Weight |
|---------|------|--------|
| Title | 16-20pt | Bold |
| Section header | 14-16pt | Bold |
| Process name | 11-13pt | Regular/Bold |
| Flow label | 9-10pt | Regular |
| Legend | 8-9pt | Regular |

### 4. Sentence Case

"Process order" not "Process Order". Title case OK for titles.

### 5. Bold vs Italic for Differentiation

- **Bold** for process names
- *Italic* for flow labels or descriptions

### 6. No Text Overflow

Never let text overflow shape boundaries. Use word wrap + 4-6px padding.

---

## Shape Conventions (Universal)

| Shape | Meaning | Diagram types |
|-------|---------|---------------|
| Oval/rounded rect | Start/End/State | Flowchart, State machine, Use case |
| Rectangle | Process/Action/Entity | All |
| Diamond | Decision/Gateway/Branch | Flowchart, Activity, BPMN |
| Cylinder | Database/Data store | Flowchart, ERD, Deployment, C4 |
| Parallelogram | Input/Output | Flowchart |
| Document (wavy bottom) | Report/File | Flowchart |
| Circle | Event/Initial state | BPMN, State machine |
| Cloud | External system | C4, Network, ArchiMate |
| Stick figure | Actor/User | Use case, C4 |
| 3D box | Node/Server | Deployment, Network |
| Hollow triangle | Generalization | Class, Component |
| Filled diamond | Composition | Class |
| Dashed arrow | Dependency/Return | Class, Sequence, ERD |

---

## Style XML Format

drawio stores styles in the `style` attribute on `<mxCell>`. Format: `key=value;key=value;bareToken;`

### Process (rounded rect, blue)
```
rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;
```

### Database (cylinder, green)
```
shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#d5e8d4;strokeColor=#82b366;
```

### Decision (diamond, yellow)
```
rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;
```

### External system (dashed border, purple)
```
rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;dashed=1;
```

### Orthogonal connector
```
endArrow=classic;html=1;rounded=1;orthogonalEdgeStyle=1;jettySize=auto;orthogonalLoop=1;
```

### Dashed (async)
```
endArrow=classic;html=1;rounded=1;dashed=1;orthogonalEdgeStyle=1;
```

### Thick (critical path)
```
endArrow=classic;html=1;rounded=1;orthogonalEdgeStyle=1;strokeWidth=3;
```

### AWS icon (lambda example)
```
shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.lambda;strokeColor=#ffffff;
```

---

## C4 Model Quick Reference

| Level | Audience | Shows |
|-------|----------|-------|
| **L1 Context** | Non-technical | System as black box + users + external systems |
| **L2 Container** | Devs/ops | Apps + DBs + queues + microservices |
| **L3 Component** | Developers | Components within single container |
| **L4 Code** | Implementing devs | Class-level (use UML/ERD) |

Title + legend on every C4 diagram. Notation-independent — use simple nested boxes.

---

## Common Mistakes (Avoid)

| Mistake | Fix |
|---------|-----|
| Inconsistent alignment / stair-stepping | Grid snap, align to same gutter |
| < 20% white space | Add margins between groups |
| Connector spaghetti (2+ crossings) | Reposition nodes, route around edges |
| Random element placement | Zone layout (input → process → output) |
| Overuse of color / rainbow effect | Max 3-4 semantic colors + legend |
| Diagonal / zigzag connectors | Force orthogonal with 90° bends |
| Vague labels ("Process 1") | Use verb-noun ("Validate Payment") |
| Overloaded processes (>6 flows) | Decompose into sub-process |
| Treating diagram as flowchart | Use correct notation for diagram type |
| No legend for colors/shapes | Add legend, position at side/bottom |
| No grayscale fallback | Test B&W print, add patterns |
| Color as only differentiator | Add text labels, patterns, dashes |
| Mixing flow directions | Pick L2R or T2D before drawing |
| Routing through nodes | Keep lines in open space |
| Inconsistent symbol shapes | Standardize one library across diagrams |

---

## Tufte Principles (for Information Density)

- **Data-ink ratio**: maximize / erase non-data-ink / if you can erase without losing meaning, delete it
- **Lie factor**: visual proportion must match data magnitude (1:1, never distort)
- **Show the data**: induce viewer to think about substance, not design

---

## Gestalt Principles (for Visual Perception)

- **Proximity**: close = group (1x node-width for related, 2x for unrelated)
- **Similarity**: shared traits = shared meaning (consistent shapes per type)
- **Closure**: humans fill gaps (use region backgrounds to group)
- **Figure/Ground**: contrast separates content (4.5:1 min)
- **Continuity**: eye follows paths (smooth orthogonal, no zigzags)
- **Pragnanz**: humans simplify (use rectangles, circles, diamonds)
- **Common Region**: bounding area = group (wrap subsystems in boundary)
- **Common Fate**: parallel direction = group (fork/join align)
- **Symmetry**: mirror components for organized feel

---

## References

### Standards
- Tufte, E. *The Visual Display of Quantitative Information*. Graphics Press, 2001.
- UML 2.5 Specification (OMG)
- BPMN 2.0 (ISO/IEC 19510)
- C4 Model (Simon Brown) — c4model.com
- ArchiMate 3.1 (Open Group)
- ERD Notations: Crow's foot, Chen, IDEF1X
- ISO 5807 (Flowchart Symbols)
- WCAG 2.1 (Accessibility)

### Tools
- [drawio.com docs](https://www.drawio.com/docs)
- [drawio.com style reference](https://www.drawio.com/docs/reference/diagram-generation/style-reference/)
- [jgraph/drawio-mcp style reference](https://github.com/jgraph/drawio-mcp/blob/main/shared/style-reference.md)
- [IBM Design Language Color](https://www.ibm.com/design/language/color/)
- [WCAG Color Contrast (MDN)](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG/Perceivable/Color_contrast)

### Shape Libraries
- AWS: https://aws.amazon.com/architecture/icons/
- Azure: built-in (azure2)
- GCP: built-in
- IBM Cloud: github.com/IBM-Cloud/architecture-icons
- C4 Model: github.com/kaminzo/c4-draw.io

### Inspiration
- [Tufte CS 7450 notes](https://faculty.cc.gatech.edu/~stasko/7450/12/Notes/tufte.pdf)
- [Gestalt Principles (IDF)](https://www.interaction-design.org/literature/topics/gestalt-principles)
- [Visual Paradigm DFD Guide](https://skills.visual-paradigm.com/docs/common-dfd-mistakes-and-how-to-avoid-them/)

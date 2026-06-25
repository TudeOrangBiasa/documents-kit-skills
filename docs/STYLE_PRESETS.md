# Style Presets

Design tokens for consistent visual identity across documents and diagrams.

## Available presets

| Preset | Best for | Avoid for |
|--------|----------|-----------|
| `hackathon-energetic.json` | Pitch decks, demos | Long-form, academic |
| `material-light.json` | Academic papers, technical docs | Hackathon pitches |
| `ibm-carbon.json` (planned) | Enterprise, B2B proposals | Casual, creative |
| `linear-style.json` (planned) | Software product docs | Print-first |
| `callout-boxes.json` (planned) | All docs with metrics | — |

## Schema

```json
{
  "name": "preset-name",
  "description": "What this preset is for",
  "version": "1.0.0",
  "colors": {
    "primary": "#...",
    "accent": "#...",
    "background": "#...",
    "text_primary": "#...",
    "text_secondary": "#...",
    "success": "#...",
    "warning": "#...",
    "danger": "#..."
  },
  "callouts": {
    "key_metrics": { "background": "#...", "border": "#...", "text": "#...", "use": "..." },
    "warning": { "...": "..." },
    "success": { "...": "..." },
    "info": { "...": "..." }
  },
  "typography": {
    "heading_font": "...",
    "body_font": "...",
    "code_font": "...",
    "title_size": "24pt",
    "h1_size": "20pt",
    "h2_size": "16pt",
    "h3_size": "14pt",
    "body_size": "11pt",
    "code_size": "10pt"
  },
  "spacing": {
    "paragraph": "1.15-1.5",
    "heading_top": "16-20px",
    "heading_bottom": "8-10px",
    "section_gap": "24-30px"
  },
  "diagrams": {
    "shape_fill": "#...",
    "shape_text": "#...",
    "edge_color": "#...",
    "edge_width": "1.5-2px"
  },
  "best_for": ["use case 1", "use case 2"],
  "avoid_for": ["anti-pattern 1"]
}
```

## Usage

In a document or diagram, reference the preset's tokens:
- "Use the `hackathon-energetic` preset: primary #1E3A5F, accent #FF6B35"
- "For callouts, use key_metrics: bg #EFF6FF, border #1E3A5F"

When generating a new diagram with drawio, the LLM should:
1. Pick a preset based on document context (hackathon → energetic, academic → material-light)
2. Apply preset tokens to shape fills, edges, text colors
3. Maintain consistent spacing from preset

## Adding a new preset

1. Copy an existing JSON
2. Adjust colors, typography, spacing
3. Add to this doc
4. Reference in drawio or document-writing skill if needed

## Color theory for documents

- **Primary**: dominant brand color, used for headings, primary CTAs
- **Accent**: attention-grabber, used sparingly (1-2 elements per page max)
- **Background**: page color, usually white #FFFFFF
- **Surface**: card/box background, slightly off-white
- **Text primary**: body text, near-black
- **Text secondary**: captions, metadata, lighter
- **Semantic**: success/warning/danger for status indicators

For 2-color palettes (academic, formal): use primary + text only.
For 3-color palettes (general, business): add accent.
For 4+ color palettes (creative, marketing): add semantic colors.

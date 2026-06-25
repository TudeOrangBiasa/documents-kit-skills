---
name: officecli
description: Create, analyze, proofread, and modify Office documents (.docx, .xlsx, .pptx) using the officecli CLI tool. Use when the user wants to create, inspect, check formatting, find issues, add charts, or modify Office documents.
---

# officecli

AI-friendly CLI for .docx, .xlsx, .pptx. Single binary, no dependencies, no Office installation needed.

## Install

```bash
curl -fsSL https://d.officecli.ai/install.sh | bash  # macOS/Linux
irm https://d.officecli.ai/install.ps1 | iex          # Windows
```

Verify: `officecli --version`

## Strategy

**L1 (read) → L2 (DOM edit) → L3 (raw XML)**. Always prefer higher layers. Check **Specialized Skills** section before doc work.

## Help System

Run `officecli help <format> <element>` instead of guessing properties.
Format aliases: `word`→`docx`, `excel`→`xlsx`, `ppt`/`powerpoint`→`pptx`.

## Performance

Auto-resident (60s idle timeout). Explicit open/close for longer sessions:
```bash
officecli open report.docx       # explicitly keep in memory
officecli close report.docx      # save and release
```

## Quick Start

```bash
# PPT
officecli create slides.pptx
officecli add slides.pptx / --type slide --prop title="Q4 Report"
officecli add slides.pptx '/slide[1]' --type shape --prop text="Revenue grew 25%"

# Word
officecli create report.docx
officecli add report.docx /body --type paragraph --prop text="Executive Summary" --prop style=Heading1

# Excel
officecli create data.xlsx
officecli set data.xlsx /Sheet1/A1 --prop value="Name" --prop bold=true
```

See [REFERENCE.md](REFERENCE.md) for full L1 (view, get, query, stable IDs), Watch & Interactive Selection, full L2 (set, find, add, pivottables, sort, batch, move/swap/remove), and L3 (raw XML).

## Common Pitfalls

| Pitfall | Correct Approach |
|---------|-----------------|
| `--name "foo"` | Use `--prop name="foo"` — all attributes go through `--prop` |
| Unquoted `[N]` paths in zsh/bash | Always quote: `'/slide[1]'` or `"/slide[1]"` (shell glob-expands brackets) |
| PPT `shape[1]` for content | `shape[1]` is typically the title placeholder. Use `shape[2]+` for content shapes |
| `/shape[myname]` | Name indexing not supported. Use numeric index or `@name=` (PPT only) |
| Guessing property names | Run `officecli help <format> <element>` to see exact names |
| Modifying an open file | Close the file in PowerPoint/WPS first |
| `\n` in shell strings | Use `\\n` for newlines in `--prop text="..."` |
| `$` in shell text | `--prop text="$15M"` strips `$15`. Use single quotes: `--prop text='$15M'`, or heredoc batch |

---

## Specialized Skills

`officecli load_skill <name>` — load one skill per artifact, never stack.

| Format | Skills |
|--------|--------|
| Word | `word` (general), `academic-paper` (journal/thesis) |
| PPT | `pptx` (general), `pitch-deck` (fundraising), `morph-ppt`, `morph-ppt-3d` |
| Excel | `excel` (general), `financial-model`, `data-dashboard` |

## Notes

- Paths are **1-based**: `'/body/p[3]'` = third paragraph
- `--index` is **0-based** (except Excel row/col add = 1-based)
- Verify with `validate` and/or `view issues` after modifications

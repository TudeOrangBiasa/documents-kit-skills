# Office CLI — Reference

See [SKILL.md](SKILL.md) for install, quick start, strategy, help system, common pitfalls, and specialized skills.

## L1: Create, Read & Inspect

```bash
officecli create <file>               # Create blank .docx/.xlsx/.pptx
officecli view <file> <mode>          # outline | stats | issues | text | annotated | html
officecli get <file> <path> --depth N # Get a node and its children [--json]
officecli query <file> <selector>     # CSS-like query
officecli validate <file>             # Validate against OpenXML schema
```

### view modes

| Mode | Description | Useful flags |
|------|-------------|-------------|
| `outline` | Document structure | |
| `stats` | Statistics (pages, words, shapes) | |
| `issues` | Formatting/content/structure problems | `--type format\|content\|structure`, `-limit N` |
| `text` | Plain text extraction | `--start N --end N`, `--max-lines N` |
| `annotated` | Text with formatting annotations | |
| `html` | Static HTML snapshot | `--browser`, `--page N` (docx) |
| `screenshot` | PNG via headless browser | `-o`, `--screenshot-width/-height` |

### get
```bash
officecli get report.docx '/body/p[3]' --depth 2 --json
officecli get slides.pptx '/slide[1]' --depth 1
officecli get data.xlsx '/Sheet1/B2' --json
```

### Stable ID Addressing
```
/slide[1]/shape[@id=550950021]                    # PPT shape
/slide[1]/table[@id=1388430425]/tr[1]/tc[2]       # PPT table
/body/p[@paraId=1A2B3C4D]                         # Word paragraph
/comments/comment[@commentId=1]                    # Word comment
```

PPT also accepts `@name=` (e.g. `shape[@name=Title 1]`).

### query
CSS-like selectors: `[attr=value]`, `[attr!=value]`, `:contains("text")`, `:empty`, `:has(formula)`.
Boolean `and`/`or` supported: `cell[value>5000 or value<100]`, `cell[(type=Number or type=Date) and value>0]`.

```bash
officecli query report.docx 'paragraph[style=Normal] > run[font!=Arial]'
officecli query slides.pptx 'shape[fill=FF0000]'
```

## Watch & Interactive Selection

```bash
officecli watch <file> [--port N]      # Start preview server
officecli unwatch <file>               # Stop
officecli goto <file> <path>           # Scroll to element
officecli get <file> selected [--json] # Read user's clicked selection
```

Key properties: selection survives file edits, paths use stable `@id=`. Marks enable edit proposals waiting for review.

## L2: DOM Operations

### set — modify properties
```bash
officecli set <file> <path> --prop key=value [--prop ...]
```

Value formats: Colors (hex/named/RGB/theme), Spacing (12pt/0.5cm/150%), Dimensions (EMU or suffixed).

Dotted-attr aliases: `font.color=red`, `font.bold=true`, `font.size=14pt`.

### find — format or replace matched text
```bash
officecli set doc.docx '/body/p[1]' --find weather --prop bold=true --prop color=red
officecli set doc.docx / --find draft --replace final
officecli set slides.pptx / --find draft --replace final
```

### add — add elements or clone
```bash
officecli add <file> <parent> --type <type> [--prop ...]
officecli add <file> <parent> --type <type> --after <path> [--prop ...]
officecli add <file> <parent> --type <type> --before <path> [--prop ...]
officecli add <file> <parent> --from <path>         # clone existing
```

### Pivot tables (xlsx)
```bash
officecli add data.xlsx /Sheet1 --type pivottable \
  --prop source="Sheet1!A1:E100" --prop rows=Region,Category \
  --prop cols=Year --prop values="Sales:sum,Qty:count"
```

### Sort (xlsx)
```bash
officecli set data.xlsx /Sheet1 --prop sort="C desc" --prop sortHeader=true
```

### Text-anchored insert
```bash
officecli add doc.docx '/body/p[1]' --type run --after find:weather --prop text=" (sunny)"
```

### move, swap, remove
```bash
officecli move <file> <path> [--to <parent>] [--index N] [--after <path>] [--before <path>]
officecli swap <file> <path1> <path2>
officecli remove <file> '/body/p[4]'
```

### batch
```bash
echo '[
  {"command":"set","path":"/Sheet1/A1","props":{"value":"Name","bold":"true"}},
  {"command":"set","path":"/Sheet1/B1","props":{"value":"Score","bold":"true"}}
]' | officecli batch data.xlsx --json
```

`officecli dump <file> [<path>]` emits replayable batch JSON. `officecli refresh <file.docx>` recalculates TOC/page numbers.

## L3: Raw XML

```bash
officecli raw <file> <part>                          # view raw XML
officecli raw-set <file> <part> --xpath "..." --action replace --xml '<w:p>...</w:p>'
officecli add-part <file> <parent>                   # create new document part
```

`raw-set` actions: `append`, `prepend`, `insertbefore`, `insertafter`, `replace`, `remove`, `setattr`.

## Resident Mode

Every command auto-starts a resident on first access (60s idle timeout). Explicit open/close recommended for longer sessions:
```bash
officecli open report.docx
officecli set report.docx ...
officecli close report.docx
```
Opt out: `OFFICECLI_NO_AUTO_RESIDENT=1`.

## Help System
```bash
officecli help                                  # All commands + options
officecli help docx                             # List all docx elements
officecli help docx paragraph                   # Full schema
officecli help docx set paragraph               # Verb-filtered
```
Format aliases: `word`→`docx`, `excel`→`xlsx`, `ppt`/`powerpoint`→`pptx`.

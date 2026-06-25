# Common Tasks Cookbook

7 most common document tasks. Each task has a step-by-step recipe.

---

## Task 1: Convert hackathon PRD to proposal

**When**: User has a PRD/markdown and wants a polished proposal.

```bash
# Step 1: Phase 0 — scan existing assets
./tools/scan-assets.sh /path/to/project > assets.json
# Review: what diagrams/data/citations already exist?

# Step 2: Phase 1 — outline 1 claim per BAB
# (Agent does this based on user instructions)

# Step 3: Phase 2 — collect/create needed assets
# Use existing diagrams from docs/diagrams/
# Need new one? → spawn drawio

# Step 4: Phase 3 — draft per BAB, no editing
# (Agent writes to proposal.md, one BAB at a time)

# Step 5: pandoc skeleton
pandoc proposal.md \
  -o proposal.docx \
  --reference-doc=templates/ipb-ppki.docx \
  --toc --toc-depth=2

# Step 6: PATH C — post-conversion fixes
./skills/document-writing/scripts/fix-pandoc-leaks.sh proposal.docx --all --validate --screenshot

# Step 7: Phase 4 — 4-pass review
./skills/document-writing/scripts/detection-audit.sh proposal.md

# Step 8: visual verify
officecli view proposal.docx screenshot -o .scratch/proposal-page1.png
```

**Common gaps**:
- 0 images in final despite diagrams available → check Phase 0 scan
- 28+ missing indents → run fix-pandoc-leaks.sh with --first-line-indent
- Curly quotes in body → fix-pandoc-leaks.sh handles this

---

## Task 2: Extend existing BAB (PATH B)

**When**: User has existing .docx with custom styling and wants to add a section.

```bash
# Step 1: Read existing BEFORE writing
officecli view existing.docx outline
officecli view existing.docx text --max-lines 500
officecli query existing.docx "heading" --json

# Step 2: Discover styleId + numId
officecli query existing.docx "style[name=Heading 1]" --json
officecli query existing.docx "num" --json
# Cache to design.md for future reference

# Step 3: Snapshot
cp existing.docx .scratch/snapshot-$(date +%s).docx

# Step 4: Add (NOT raw-set)
officecli add existing.docx /body --type paragraph \
  --prop styleId=779 \
  --prop text="BAB VIII: ..." \
  --prop num-id=23

# Step 5: Validate
officecli validate existing.docx
# If fails: cp .scratch/snapshot-*.docx existing.docx
```

**Common mistakes**:
- raw-set on numbering.xml (corrupts numbering)
- Wrong styleId (use styleId not name)
- Same numId as another BAB (causes numbering conflicts)

---

## Task 3: Add cover page

**When**: Document needs branded cover (hackathon, IPB, IEEE).

### IPB PPKI style

```bash
# Logo 5.5×5.5cm top center
officecli add doc.docx /body --type picture \
  --prop src=logo.png \
  --prop width=5.5cm \
  --index 0

# Title 14pt bold TNR (max 20 words)
officecli add doc.docx /body --type paragraph \
  --prop text="Project Title" \
  --prop styleId=Title \
  --index 1

# Subtitle
officecli add doc.docx /body --type paragraph \
  --prop text="Tagline" \
  --prop styleId=Subtitle \
  --index 2

# Team info
officecli add doc.docx /body --type paragraph \
  --prop text="Tim Pengembang — Institut Pertanian Bogor" \
  --prop styleId=Normal \
  --index 3
```

### Hackathon style

```bash
# Logo top
officecli add doc.docx /body --type picture \
  --prop src=project-logo.png \
  --prop width=4cm \
  --index 0

# Project name (large)
officecli add doc.docx /body --type paragraph \
  --prop text="PanganTrace v2" \
  --prop styleId=Title \
  --prop color=1E3A5F \
  --index 1

# Tagline
officecli add doc.docx /body --type paragraph \
  --prop text="B2B Verifiable Claim Marketplace" \
  --prop styleId=Subtitle \
  --index 2

# Event + date
officecli add doc.docx /body --type paragraph \
  --prop text="IT Festival 2026 — IPB University" \
  --prop styleId=Normal \
  --index 3
```

---

## Task 4: Insert existing diagram

**When**: User has PNG/SVG diagram in repo that needs to go into the doc.

```bash
# Step 1: Confirm diagram exists
ls docs/diagrams/architecture.png

# Step 2: Insert as picture, full page width (15cm = 8505 twips)
officecli add doc.docx /body/p[N] --type picture \
  --prop src=docs/diagrams/architecture.png \
  --prop width=15cm

# Step 3: Add caption
officecli add doc.docx /body/p[N+1] --type paragraph \
  --prop text="Gambar 1. Arsitektur sistem PanganTrace v2." \
  --prop styleId=Caption

# Step 4: Reference in text BEFORE figure
# Find the paragraph that should reference the figure
# Add: "Gambar 1 menunjukkan arsitektur sistem dengan 8 modul utama."
```

**Best practice**:
- Reference in text BEFORE the figure (readers know what to look for)
- Caption format: "Gambar N. <description>." (Indonesian) or "Figure N. <description>." (English)
- Caption should be self-explanatory (not "Architecture")

---

## Task 5: Apply anti-slop rewrite

**When**: Existing doc has AI patterns that need cleanup.

```bash
# Pass 1: Run detection-audit
./skills/document-writing/scripts/detection-audit.sh doc.md
# Review output: list of issues

# Pass 2: Identify structural issues
# - Uniform cadence (low burstiness)
# - Formulaic openers
# - Summary closers
# - Negative parallelisms

# Pass 3: Rewrite with hard constraints
# - Replace 3 abstractions with specifics (number/name/date)
# - Include one <6-word + one >25-word sentence per page
# - Cut opening if setup, cut closing if summary
# - Cardinal rule: NEVER paraphrase a pattern. Fix by deciding what the sentence actually asserts.

# Pass 4: Voice injection
# - 1-2 first-person opinions per 500 words
# - Concrete friction (e.g., "The RPC kept timing out at 3am")

# Verify
./skills/document-writing/scripts/detection-audit.sh doc.md
# Target: 0 issues (or only minor false positives)
```

**Cardinal rule** (from humanizer / Scriptorium):
> "Never fix a pattern by paraphrasing the pattern. Fix by deciding what the sentence actually asserts."

If a sentence has "delve" → don't replace with "explore". Replace with the actual claim. If the claim is empty, delete the sentence.

---

## Task 6: Generate new diagram

**When**: User needs a new architecture/flow/ERD/sequence diagram.

```bash
# Step 1: Clarify (do this in conversation, not shell)
# - Type: architecture / flow / ERD / sequence / class / network
# - Format: PNG / SVG / PDF
# - Location: where to save
# - Scope: what's in, what's out

# Step 2: Load drawio skill (in conversation)
# Agent will generate .drawio XML

# Step 3: Export draft (NO -e flag, so we can iterate)
drawio -x -f png --width 2000 \
  -o /tmp/draft.png \
  architecture.drawio

# Step 4: Self-check with vision
# Agent reviews draft.png against requirements
# Iterate up to 2 rounds

# Step 5: Final export with -e (embeddable for editing)
drawio -x -f png --width 2000 -e \
  -o architecture.drawio.png \
  architecture.drawio
```

**Common pitfalls**:
- Routing through shapes (need smart routing)
- Text overflowing shapes
- Inconsistent spacing
- No style preset applied (looks generic)

If these happen, regenerate the .drawio XML with better positioning, or use a style preset.

---

## Task 7: Citation discovery

**When**: User needs citations for academic paper.

```bash
# Step 1: Check existing
ls references.bib refs.bib 2>/dev/null
# If exists, use it

# Step 2: Spawn scout (in conversation)
# scout searches Google Scholar + SINTA + Crossref
# Returns BibTeX entries

# Step 3: Append to references.bib
# Agent formats entries correctly

# Step 4: Validate
pandoc-citeproc --check references.bib  # if available
# Or just visual review

# Step 5: Use in document
pandoc paper.md --citeproc --bibliography=references.bib -o paper.docx
```

**Common mistakes**:
- Hallucinated author/year/title (always verify with source)
- Wrong citation style (APA vs IEEE vs Chicago)
- Missing DOI/URL
- Outdated (prefer last 5 years)

---

## Tips

- **Save snapshots before destructive operations** (PATH B, post-conversion)
- **Run audit after every phase** (Phase 0, 2, 3, 4)
- **Take screenshots for visual docs** (not just text review)
- **Use Officecli's `view issues`** to find structural problems
- **Read aloud** the final doc — anything you wouldn't say, rewrite

# Document Writing — Reference

Comprehensive catalog for [SKILL.md](SKILL.md). The skill dispatches; this file is the catalog.

## §0. Phase 0: Preparation Checklist

Before drafting, confirm all items. Missing any leads to rework.

### Pre-Writing Checklist

- [ ] **Purpose statement** — one sentence: what doc is for, what problem it solves
- [ ] **Target audience** — who reads it, what they know, what they need
- [ ] **Scope boundaries** — what is explicitly NOT covered
- [ ] **Project milestones** — reverse-planning from final deadline
- [ ] **SME/resource access** — interviews scheduled, source material collected
- [ ] **Success criteria** — how you know doc is done
- [ ] **Style guide / template** — IPB PPKI, IEEE, ACM, hackathon, etc.
- [ ] **Citation style** — APA, IEEE, Chicago, etc.
- [ ] **Page limit + deadline**
- [ ] **Format constraints** — file type, deliverable channels

### Asset Inventory

| Asset Type | Items | Source | Status |
|------------|-------|--------|--------|
| **Visual** | diagrams (architecture/flow/ERD), screenshots, mockups, charts | existing repo / drawio-skill / impeccable | □ ready □ need create |
| **Data** | statistics with sources, raw data, benchmark figures | references.bib / research / scout | □ ready □ need collect |
| **Code** | key snippets, API examples, output samples | explore / repo | □ ready □ need extract |
| **Reference** | previous docs, templates, brand guidelines, citations | repo / scout | □ ready □ need gather |

If visual assets need creation, route to:
- **drawio-skill** — architecture, flow, ERD, network diagrams (PNG/SVG/PDF export)
- **impeccable** — UI mockup, screenshot, design polish

If code assets need extraction, route to **explore** (find code in repo).

## §0.5. Visual Decision Rules

### Decision Tree

```
Is the content topology or flow? ─Yes→ Diagram
  │                                  No→ continue
  ↓
Is exact syntax needed to understand? ─Yes→ Code
  │                                      No→ continue
  ↓
Is it rationale, impact, or "why"? ─Yes→ Text
                                       No→ Diagram or skip
```

### When to Use Each

| Content type | Use | Why |
|--------------|-----|-----|
| Architecture / system topology | **Diagram** | Readers recall design 2× better than text (Jolak et al. 2020) |
| Data flow / sequence / state | **Diagram** | Topology + flow impossible in prose |
| DB relationships / ERD | **Diagram** | Schema clarity |
| Algorithm logic (non-obvious) | **Code** (5-15 lines) | Pseudocode for logic, real code for API |
| API endpoint / interface | **Code** (signature only) | Exact syntax needed |
| "Why" / rationale / impact | **Text** | Sequential reasoning |
| Lit review / research gap | **Text** | Critical synthesis |
| Process steps with branching | **Diagram** (flowchart) | Decisions need visual |
| Statistical comparison | **Table** or **Chart** | Numbers need layout |

### Density Targets

| Item | Recommendation |
|------|---------------|
| **Diagrams per page** | 1 per 2-3 pages |
| **Diagrams per 10-page proposal** | 3-5 max |
| **Code snippets per proposal** | 0-3 |
| **Lines per snippet** | ≤15 inline, ≤25 in figure |
| **Total code in body** | ≤3 pages |
| **Code as % of doc** | <5% (thesis), <3% (conference), <10% (hackathon) |

### Code Inclusion Decision Tree

```
Is the code the contribution? ─Yes→ Include full key snippet
  │                              No→ Pseudocode or text description
  ↓
Is the algorithm non-obvious? ─Yes→ 5-15 line snippet
  │                              No→ Skip, reference repo
  ↓
Does a 3-line example clarify? ─Yes→ Inline monospace
                               No→ Don't include
```

### Anti-Patterns

- **Code dump** — 100+ lines without annotation
- **No syntax highlighting** — black monospace blobs indistinguishable from body
- **No line numbers** on >5 line snippets
- **Forgotten imports / boilerplate** distracts from contribution
- **No caption** — code block floating without context
- **Code ≠ contribution** — CRUD routes in a thesis about distributed consensus
- **Too many snippets** — >10 looks like code review
- **Wrong font size** — 8pt unreadable, 12pt wastes pages
- **Stale repo reference** — linking a dead repo

## §0.6. Color & Style Conventions

### By Context

| Context | Heading color | Body font | Body size | Line spacing | Margins |
|---------|--------------|-----------|-----------|--------------|---------|
| **Indonesian academic (IPB/ITS/UI)** | Black bold | Times New Roman | 12pt | 1.5 | Left 4cm, others 3cm |
| **International (IEEE/ACM)** | Black or dark gray | TNR | 10pt | single | IEEE: 1.9cm |
| **Hackathon/business** | Dark blue (#1E3A5F) or brand | Sans-serif (Inter, Arial) | 11pt | 1.15-1.5 | 2.5cm uniform |
| **Indonesian thesis (IPB PPKI Edisi 4)** | Black bold 14pt BAB, 12pt sub | TNR | 12pt | 1.5 (1.0 for abstract/quotes) | Left 4cm, top/right/bottom 3cm |

### Indonesian Academic Standard (IPB PPKI Edisi 4)

```markdown
Paper: A4 80g, 1-sided
Font: Times New Roman 12pt
Line spacing: 1.5 body, 1.0 abstract/quotes
Margins: Left 4cm, Top/Right/Bottom 3cm
BAB heading: "BAB I" 14pt bold, center, all caps
Subheading: 12pt bold, left-aligned, sentence case
Cover: Logo 5.5×5.5cm, title 14pt bold TNR
Page numbers: Roman (preface), Arabic (body), bottom-right
Max title: 20 words
Citation: APA (IPB mod) or IEEE
```

### Heading Color Rules

- **Indonesian academic (IPB/ITS/UI)**: BAB headings BLACK bold 14pt, subheadings BLACK 12pt bold. NEVER use color for headings in formal proposals. Accent colors only on cover.
- **International (IEEE/ACM)**: black or dark gray. ACM uses black bold serif. IEEE uses black 10pt bold L1, italic L2.
- **Hackathon/business**: dark blue (#2563EB or #1E3A5F) for section heads is standard. Use one accent color consistently.
- **Never**: rainbow headings, red headings, colored headings in academic body.

### Callout Box Conventions

Use sparingly (1 per 2-3 pages max, ≤4 per doc).

| Type | Background | Border | Use case |
|------|-----------|--------|----------|
| **Key metrics/data** | `#EFF6FF` (light blue) | `#3B82F6` (dark blue) | "87% petani tidak punya akses kredit" |
| **Warning/risk** | `#FEF2F2` (light red) | `#EF4444` (red, left only) | Risk assessment, limitations |
| **Success/impact** | `#F0FDF4` (light green) | `#22C55E` (green) | Expected outcomes |
| **Info/definition** | `#F9FAFB` (light gray) | `#9CA3AF` (gray) | Methodology notes |
| **Callout placement** | Section start, after first reference | — | — |

### Whitespace Ratios

| Context | Whitespace | Density |
|---------|-----------|---------|
| Academic proposal | 10-20% | dense, 1.5 spacing, justified |
| Hackathon pitch | 25-35% | generous, 1.15 spacing, ample margins |
| Business proposal | 30-40% | spacious, 1.0-1.15 spacing |

### Cover Page Standards

| Type | Logo | Title | Team | Other |
|------|------|-------|------|-------|
| **IPB** | 5.5×5.5cm top center | 14pt bold, max 20 words | Name, NIM, dosen pembimbing | "PROPOSAL" label, year |
| **Hackathon** | Project logo top center | 18-24pt bold + tagline | Member names + emails | Event name, date |
| **IEEE/ACM conference** | Optional | 24pt bold | Authors, affiliation | Single column |

### Accent Color Rules

- Use accent color SPARINGLY: headings, callout borders, cover elements only
- NEVER use accent for body text
- NEVER use >2 colors in a document (black + 1 accent + white)
- Colorblind-safe: avoid red-green combinations; use patterns/shapes too

## §0.7. Code Formatting

### When to Include Code

Include code only if the reader needs exact syntax to understand the contribution. If you can describe the logic in 2 sentences of prose, do that instead.

### Formatting Rules

| Property | Convention | Source |
|----------|-----------|--------|
| **Font (listings)** | Monospace: Courier New, Lucida Console, `\ttfamily`. 9-10pt for listings, 11pt body | IEEEtran, NSF PAPPG |
| **Line numbers** | Always for >3 lines. Left-aligned, tiny font, 5pt separation | listings pkg defaults |
| **Highlighting** | Colored syntax recommended: keywords blue, strings red, comments green. Black-only OK for print | minted/pkg docs |
| **Indentation** | Spaces, 2-4 per level. Never tabs in academic docs | listings pkg default |
| **Max line** | 80 chars. Break at 75 with `\`, indent continuation +2 | NASA LaTeX docs |
| **Background** | Light gray (#F2F2F2) or 10% gray. Avoid pure white | SO/inscrive.io |
| **Frame** | Single thin border, or no frame. Avoid double/triple | IEEEtran examples |

### Code Placement

- **Inline** (` `` `): ≤3 lines, single function calls, variable names, short expressions. Monospace within prose.
- **Listing block**: 4-25 lines. Primary placement for readable snippets. Float or inline. Always captioned.
- **Appendix**: Complete source files, full classes, multi-file projects. Reference from body.
- **GitHub reference**: Prefer over appendix for repos >100 lines or >3 files. Link in text + footnote.

### Code Length by Context

| Context | Per snippet | Total per doc | % of doc |
|---------|-------------|---------------|----------|
| Hackathon pitch | 3-10 lines | 0-2 snippets | <10% |
| Conference paper | 5-15 lines | 1-3 snippets | <3% |
| Thesis (MS/PhD) | 10-25 lines | 2-6 snippets | <5% |
| NSF proposal | 5-15 lines | 0-3 snippets | <2% |

### Captioning

```
Listing 1. Dijkstra's algorithm in TypeScript with path reconstruction.
```

- Format: `Listing N. <Title sentence>.` NOT "Figure"
- Numbering: sequential per chapter (Listing 3.1, 3.2) or globally
- Title: describes what code does, not "Code snippet" or filename
- Reference in text: "Listing 1 shows..."
- Location: top of listing (table-style) or bottom (figure-style)
- Cross-reference with `\label{lstlisting:label}` + `\ref{lstlisting:label}`

### Hackathon Proposal (6 slides) — Specific

- Slide 3-4 (architecture / implementation): 1 code snippet max, 3-10 lines
- Show interface signature or one API endpoint, not implementation details
- Use pseudo-code or TypeScript interface over full logic
- Prefer diagram of data flow over code blocks
- Goal: judges grasp architecture in 5 seconds
- Code is evidence, not narrative
- Font: 10-11pt code in slides (smaller than body 18-24pt). Monospace only

### Full Academic Proposal (7 chapters) — Specific

- Ch. 1-3 (intro, lit review, methodology): zero code. Prose + diagrams.
- Ch. 4 (approach/design): 2-4 snippets of 10-20 lines each. Core algorithms, key interfaces, data structures.
- Ch. 5 (implementation): 3-6 snippets, 10-25 lines each. Show the challenging 20%, skip CRUD 80%.
- Ch. 6 (evaluation): zero code. Graphs, tables, metrics.
- Appendices: full code (≤15 pages) OR GitHub link
- Total code in body: ≤3 pages
- Each snippet linked to appendix or repo for full context

## §1. PATH A — From Scratch (use pandoc)

Use when: creating new docx/pptx/xlsx with no existing content.

### Phase 1: Setup
```bash
sudo apt install pandoc
ls *.csl                       # citation style
ls template.docx ref.docx      # reference template
ls references.bib refs.bib     # bibliography
```

### Phase 2: Write Markdown
Set `lang:` in frontmatter for script intrusion detection (check #9):
```markdown
---
lang: id
---

# Title
Author Name. 2026. Paper Title. *Journal Name*.

## Section 1
Cite like this [@doi:10.1145/xxxxxxx]. Multiple citations [@smith2020; @jones2021].
```

### Phase 3: Convert via pandoc
```bash
# Basic md → docx with citations
pandoc paper.md --citeproc --bibliography=references.bib -o paper.docx

# With citation style
pandoc paper.md --citeproc --csl=ieee.csl --bibliography=references.bib -o paper.docx

# With reference template
pandoc paper.md --citeproc --reference-doc=template.docx -o paper.docx

# With metadata
pandoc paper.md --citeproc \
  --metadata=title:"Paper Title" --metadata=author:"Name" --metadata=date:"2026" \
  -o paper.docx
```

### Phase 4: Verify
```bash
pandoc paper.docx -o check.md
diff paper.md check.md  # should be minimal diff
```

### Phase 5: Snapshot
```bash
cp paper.docx .scratch/snapshot-$(date +%s).docx
```

## §2. PATH B — Extend Existing (use officecli)

Use when: continuing UTS, adding BAB X, fixing existing docx.

### Phase 1: Read existing BEFORE writing
```bash
officecli view existing.docx outline
officecli view existing.docx text --max-lines 500
officecli query existing.docx "heading" --json
```

### Phase 2: Discover styleId + numbering scheme
```bash
officecli query existing.docx "style[name=Heading 1]" --json
officecli query existing.docx "style[name=Heading 2]" --json
officecli query existing.docx "style[name=Normal]" --json
officecli query existing.docx "num" --json
```

Cache to `design.md`:
```markdown
## StyleId Mapping (cached YYYY-MM-DD)
- Heading 1 → styleId 779
- Heading 2 → styleId 778
- Normal → styleId 937

## Numbering (cached YYYY-MM-DD)
- BAB I: numId=10
- BAB II: numId=11
```

### Phase 3: Plan the new content
State: BAB number, sub-bab count, styleId to use, page break before/after, reference to existing BAB X-1.

### Phase 4: Edit safely
```bash
# 1. Snapshot first
cp existing.docx .scratch/snapshot-$(date +%s).docx

# 2. Use add (NOT raw-set on numbering.xml)
officecli add existing.docx /body --type paragraph --prop styleId=779 --prop text="BAB VIII" --prop num-id=23
officecli add existing.docx /body --type paragraph --prop styleId=778 --prop text="Sub-bab title" --prop num-id=23
officecli add existing.docx /body --type paragraph --prop styleId=937 --prop text="Body content..."

# 3. Validate after every edit
officecli validate existing.docx

# 4. If validate fails, restore from snapshot
cp .scratch/snapshot-*.docx existing.docx
```

### Phase 5: Verify
```bash
officecli view existing.docx outline | head -50
officecli view existing.docx text | grep -E "^[0-9]+\.[0-9]+" | head -20
officecli view existing.docx screenshot -o .scratch/verification/<date>-<intent>/page1.png
```

## §3. Citation Discovery (scout)

When the user needs citations but doesn't have a `.bib` file, spawn scout.

### When to spawn scout
- User says "cari paper X", "find citation for Y", "butuh referensi"
- User mentions Google Scholar, SINTA, DOI, Scopus, journal/conference name
- User asks for recent papers on a topic

### What scout does
```bash
Scout searches Google Scholar + SINTA + Crossref,
returns BibTeX entries ready for references.bib.
DO NOT hallucinate authors/years/titles. If not findable, say so.
Prefer recent (last 5 years) over old.
```

### Mendeley/Zotero integration
User manages their own library. Agent reads the `.bib` export:
```bash
# User exports BibTeX from Mendeley/Zotero → references.bib
# Agent uses pandoc with --bibliography=references.bib
```

## §4. Quick Reference (Pandoc / Officecli / Scout)

### Pandoc
```bash
sudo apt install pandoc
pandoc paper.md --citeproc --bibliography=references.bib -o paper.docx
pandoc paper.md --citeproc --csl=ieee.csl --bibliography=references.bib -o paper.docx
pandoc paper.md --citeproc --reference-doc=template.docx -o paper.docx
pandoc paper.md --citeproc --metadata=title:"Title" --metadata=author:"Name" -o paper.docx
pandoc paper.docx -o check.md  # docx → md for inspection
```

### Officecli
```bash
officecli view doc.docx outline              # structure
officecli view doc.docx text                 # all text
officecli view doc.docx issues               # format problems
officecli view doc.docx screenshot -o img.png # visual
officecli query doc.docx "heading" --json    # all headings
officecli query doc.docx "style[name=X]" --json  # styleId lookup

officecli create doc.docx
officecli add doc.docx /body --type paragraph --prop text="..." --prop styleId=937
officecli add doc.docx /body --type table --prop rows=3 --prop cols=3

officecli set doc.docx /body/p[1] --prop text="new text" --prop bold=true
officecli remove doc.docx /body/p[1]
officecli move doc.docx /body/p[1] --to /body --index 5

officecli validate doc.docx

# SAFETY: NEVER do this
officecli raw-set doc.docx numbering --xpath "..." --xml "..."
```

### Scout
```bash
# Triggered via orchestrator delegation, NOT direct call.
# Searches Google Scholar + SINTA + Crossref.
```

## §5. Anti-Slop Catalog (30+ Patterns)

Full catalog of patterns AI generates and how to rewrite them. Apply before writing. Audit after.

### §5.1 Content Patterns

**1. Undue Emphasis on Significance / Legacy / Broader Trends**
- Words: stands/serves as, testament, vital/significant/crucial/pivotal/key role, underscores/highlights importance, reflects broader, symbolizes, enduring/lasting, contributing to, setting the stage, marks/shapes, key turning point, evolving landscape, focal point, indelible mark, deeply rooted
- Fix: state what it IS and what it DOES. Drop the "importance" framing.

> ❌ "The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain."
> ✅ "The Statistical Institute of Catalonia was established in 1989 to collect and publish regional statistics independently from Spain's national statistics office."

**2. Undue Emphasis on Notability / Media Coverage**
- Words: independent coverage, media outlets, written by a leading expert, active social media presence
- Fix: cite one specific source with date.

> ❌ "Her views have been cited in The New York Times, BBC, Financial Times, and The Hindu."
> ✅ "In a 2024 New York Times interview, she argued that AI regulation should focus on outcomes rather than methods."

**3. Superficial Analyses with -ing Endings**
- Words: highlighting/underscoring/emphasizing, ensuring, reflecting/symbolizing, contributing to, cultivating/fostering, encompassing, showcasing
- Fix: end the sentence at the main clause.

> ❌ "The temple's color palette of blue, green, and gold resonates with the region's natural beauty, symbolizing Texas bluebonnets..."
> ✅ "The temple uses blue, green, and gold colors. The architect said these were chosen to reference local bluebonnets."

**4. Promotional / Advertisement-like Language**
- Words: boasts a, vibrant, rich (figurative), profound, enhancing, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking (figurative), renowned, breathtaking, must-visit, stunning
- Fix: describe what is actually there. No adjectives without facts.

> ❌ "Nestled within the breathtaking region of Gonder in Ethiopia..."
> ✅ "Alamata Raya Kobo is a town in the Gonder region of Ethiopia, known for its weekly market."

**5. Vague Attributions / Weasel Words**
- Words: Industry reports, Observers have cited, Experts argue, Some critics argue, several sources (when few cited)
- Fix: name the source. One specific citation beats three vague ones.

> ❌ "Experts believe it plays a crucial role in the regional ecosystem."
> ✅ "The Haolai River supports several endemic fish species, according to a 2019 survey by the Chinese Academy of Sciences."

**6. Outline-like "Challenges and Future Prospects" Sections**
- Words: Despite its... faces several challenges, Despite these challenges, Challenges and Legacy, Future Outlook
- Fix: state one specific challenge with one specific data point.

> ❌ "Despite its industrial prosperity, Korattur faces challenges typical of urban areas... Despite these challenges... Korattur continues to thrive."
> ✅ "Traffic congestion increased after 2015 when three new IT parks opened."

### §5.2 Language & Grammar Patterns

**7. Overused "AI Vocabulary" Words**
- High-frequency AI words: Actually, additionally, align with, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract), pivotal, showcase, tapestry (abstract), testament, underscore (verb), valuable, vibrant
- See §6.1 for full Tier 1/2 list with AI/human ratios.

> ❌ "Additionally, a distinctive feature of Somali cuisine is the incorporation of camel meat. An enduring testament to Italian colonial influence is the widespread adoption of pasta..."
> ✅ "Somali cuisine also includes camel meat, which is considered a delicacy."

**8. Avoidance of "is"/"are" (Copula Avoidance)**
- Words: serves as / stands as / marks / represents [a], boasts / features / offers [a]
- Fix: use "is" / "has". Always.

> ❌ "Gallery 825 serves as LAAA's exhibition space... features four separate spaces and boasts over 3,000 square feet."
> ✅ "Gallery 825 is LAAA's exhibition space. The gallery has four rooms totaling 3,000 square feet."

**9. Negative Parallelisms and Tailing Negations**
- Patterns: "Not just X, but Y" / "It's not X, it's Y" / "It's not about X, it's about Y"
- Fix: state the affirmative directly.

> ❌ "It's not just about the beat... it's part of the aggression. It's not merely a song, it's a statement."
> ✅ "The heavy beat adds to the aggressive tone."

**10. Rule of Three Overuse**
- Fix: use 2, 4, or irregular counts. Three only when the content is genuinely three.

> ❌ "The event features keynote sessions, panel discussions, and networking opportunities."
> ✅ "The event includes talks and panels. There's also time for informal networking."

**11. Elegant Variation (Synonym Cycling)**
- Fix: pick one name/term and use it consistently. Stop cycling through synonyms.

> ❌ "The protagonist faces many challenges. The main character must overcome obstacles. The central figure eventually triumphs."
> ✅ "The protagonist faces many challenges but eventually triumphs and returns home."

**12. False Ranges**
- Pattern: "From X to Y" without real spectrum endpoints
- Fix: name what you mean. Skip the range.

> ❌ "from the singularity of the Big Bang to the grand cosmic web, from the birth and death of stars to the enigmatic dance of dark matter"
> ✅ "The book covers the Big Bang, star formation, and current theories about dark matter."

**13. Passive Voice and Subjectless Fragments**
- Fix: name the actor. "The system does X" not "X is done".

> ❌ "No configuration file needed. The results are preserved automatically."
> ✅ "You do not need a configuration file. The system preserves the results automatically."

### §5.3 Style Patterns

**14. Em Dashes: Cut Them**
- Rule: max 1 per 500 words. AI uses em-dashes at 3-10× human rate (~73% of GPT-4 long-form vs ~12% human). Replace with: period, comma, colon, parentheses, semicolon, or restructure.
- Model signatures: spaced em-dash (` — `) = Claude; unspaced (`—`) = OpenAI; spaced en-dash (` – `) = Gemini/Mistral.

**15. Overuse of Boldface**
- Rule: do not mechanically bold key phrases. Use bold for terms being defined, not emphasis crutch.

**16. Inline-Header Vertical Lists**
- Pattern: bold header + colon + bullet, repeated identically
- Fix: rewrite as prose. Lists are for genuine enumeration.

**17. Title Case in Headings**
- Rule: use sentence case, not title case. "How to write a paper", not "How to Write a Paper".

**18. Emojis**
- Rule: do not decorate headings or bullets with emojis. Exception: open-source/community tone.

**19. Curly Quotation Marks**
- Rule: use straight quotes (`"..."`) in academic/technical writing. macOS/Word curl by default — disable.

### §5.4 Communication Patterns

**20. Collaborative Communication Artifacts**
- Words: I hope this helps, Of course!, Certainly!, You're absolutely right!, Would you like..., let me know, here is a...
- Fix: cut entirely. The user did not ask for pleasantries.

**21. Knowledge-Cutoff Disclaimers**
- Words: as of [date], Up to my last training update, While specific details are limited, based on available information, not publicly available
- Fix: state what you know. "I don't know" beats "based on available information".

**22. Sycophantic / Servile Tone**
> ❌ "Great question! You're absolutely right that this is a complex topic."
> ✅ "The economic factors you mentioned are relevant here."

### §5.5 Filler & Hedging

**23. Filler Phrases**
- "In order to achieve this goal" → "To achieve this"
- "Due to the fact that it was raining" → "Because it was raining"
- "At this point in time" → "Now"
- "The system has the ability to process" → "The system can process"
- "It is important to note that the data shows" → "The data shows"

**24. Excessive Hedging**
- Fix: one hedge per claim max. Cut generic hedges. Keep specific hedges.

> ❌ "It could potentially possibly be argued that the policy might have some effect."
> ✅ "The policy may affect outcomes."

**25. Generic Positive Conclusions**
> ❌ "The future looks bright... Exciting times lie ahead..."
> ✅ "The company plans to open two more locations next year."

**26. Hyphenated Word Pair Overuse**
- Rule: keep attributive-position hyphens (high-quality report); drop when compound follows noun (the report is high quality).

**27. Persuasive Authority Tropes**
- Phrases: The real question is, at its core, in reality, what really matters, fundamentally, the deeper issue, the heart of the matter
- Fix: delete. State the actual point.

**28. Signposting and Announcements**
- Phrases: Let's dive in, let's explore, let's break this down, here's what you need to know
- Fix: just start. No meta-announcement.

**29. Fragmented Headers**
- Rule: a heading followed by a one-line restatement = padding. Delete the restatement.

**30. Diff-Anchored Writing**
- Rule: unless the document is version-scoped, describe the thing as it IS, not how it CHANGED.

> ❌ "We have updated the API. The new API now uses REST instead of SOAP."
> ✅ "The API uses REST. Endpoints are at /v2/."

### §5.6 Repetition Check

The 30 patterns miss a common AI tell: re-stating the same idea in slightly different words.

Detection:
```bash
sed 's/[.!?]/\n/g' file.md | sort | uniq -d
```

Fix rule: keep the clearest version, delete the rest. Don't rephrase — rephrase is just another form of repetition.

## §6. AI Detection Rules

If the document will face AI detection (Turnitin, GPTZero, Originality.ai, Copyleaks), apply these rules.

### §6.1 Target Scores

| Detector | Target | Method |
|----------|--------|--------|
| GPTZero | < 15% AI | Perplexity + burstiness + classifier |
| Originality.ai | < 10% AI | Lexical fingerprint + transition frequency |
| Turnitin AIR-1 | Human verdict | Lexical + paraphraser-pattern recognition |
| Copyleaks | Human verdict | Frequency ratios + POS + syllable dispersion |
| Winston AI | < 20% AI | Perplexity + burstiness + classifier |

### §6.2 Tier 1 Banned Vocabulary (10-200× AI/Human Ratio)

| Word | AI/Human Ratio | Replacement |
|------|----------------|-------------|
| delve | 28-50× | examine, look at, study |
| tapestry (metaphorical) | 35× | range, span |
| crucial role in shaping | 182× | (cut) |
| multifaceted | 28× | complex, layered |
| nuanced | 22× | detailed |
| underscores (verb) | 13.8× | shows, demonstrates |
| showcasing | 10.7× | showing, displaying |
| pivotal | 16× | central, key |
| comprehensive | 17× | complete, full |
| paramount | 9× | main, primary |
| leverage (verb) | 13× | use, apply |
| robust | 12× | (cut or "strong") |
| utilize | 10× | use |
| intricate | 15× | complex, detailed |
| meticulously | 10× | carefully, thoroughly |
| testament | 11× | (cut) |
| embark | high | start, begin |
| foster | high | support, build |

### §6.3 Tier 2 Banned Vocabulary (cumulative effect)

foster, empower, resonate, elevate, streamline, aforementioned, heretofore, whilst, elucidate, notwithstanding, ever-evolving, cutting-edge, transformative, dynamic, innovative, game-changer, journey, navigate, enhance, ensure, facilitate, explore, significantly, realm, landscape (metaphorical), plays a crucial role, sheds light on, a testament to, in the realm of, in today's digital age, it is worth noting that, it is important to note, this highlights the importance of

### §6.4 Banned Transitions (per-paragraph openers)

Furthermore | Moreover | Additionally | In conclusion | In summary | It is important to note | It is worth noting | Consequently | Hence | Thus | Nevertheless | Nonetheless | Certainly | As previously mentioned

### §6.5 Banned Sentence Constructions

- Negative parallelism: "Not X, but Y" / "It's not X, it's Y"
- Tricolon default: Three parallel items when 2 or 4 work
- Staccato burst: 3+ consecutive short sentences
- Colon elaboration: Short setup + colon + long expansion
- Rhetorical Q → answer: Q immediately self-answered
- Hedge stack: 3+ epistemic hedges in one sentence
- False range: "From X to Y" without real spectrum
- Formulaic opener: "In an era of..." / "In today's rapidly evolving..."
- Resolution closer: Tension → synthesis → wrap-up
- Fortune cookie closer: Abstract universal-scope single sentence
- Self-reference: "This guide explores..." / "In this paper we..."

### §6.6 Punctuation Discipline

- Em dashes: max 1 per 500 words
- Exclamation marks: max 1 per 1,000 words
- Ellipses: only when genuinely trailing off
- Curly quotes: avoid in academic (use straight `"`)
- Semicolons: use naturally (AI underuses them)

### §6.7 Structural Patterns Detectors Flag

- Uniform paragraph length (AI clusters within ±15%) → vary
- Uniform sentence length (low burstiness) → vary 5-40 words
- Topic-term even distribution → cluster terms in relevant sections
- Hedging clusters (5× human rate) → commit to claims
- Repetition of n-grams → reword or cut
- Readability consistency (Flesch flat) → fluctuate, technical sections denser

## §7. Anti-Detection Workflow

### Step 1: Draft with constraints
- Set persona: "experienced researcher with 10+ years in the field who has strong opinions"
- Ban Tier 1 vocab in the prompt
- Request: "No transitions, no summaries, no rule of three, vary sentence length"
- Target: Flesch 50-70 academic, 60-80 general

### Step 2: Self-audit
Run [scripts/detection-audit.sh](scripts/detection-audit.sh) on the draft. All checks should pass.

### Step 3: Manual rewrite of intro + conclusion
- GPTZero weights first 150 and last 150 words 2×. Rewrite from scratch.

### Step 4: Specificity injection
- Every claim with no number/name/date → add one.
- "Studies show" → "Smith et al. (2024) at Stanford showed"
- "Fast" → "p99 < 200ms at 1k req/s"
- "Many users" → "1,247 of 2,000 beta users (62%)"

### Step 5: Voice injection (1-2 per 500 words)
- First-person opinion: "I think" / "from what I've seen" / "I'd push back on X"
- Concrete friction: "The RPC kept timing out at 3am"
- Hedged uncertainty where genuine: "We didn't test this"
- Real specific name: "Cloudflare Workers" not "edge functions"
- Time/place anchor: "In 2024" / "at the offsite"

### Step 6: Verify
- Test with GPTZero (free tier) + 1 other detector
- Target < 15% / < 10% respectively

### Detector-Tested Before/After

**Before (~94% GPTZero):**
> "In the rapidly evolving landscape of modern business, effective leadership serves as a cornerstone of organizational success. It is crucial to understand that leadership styles have a significant impact on employee engagement and productivity. This proposal explores the key principles that distinguish exceptional leaders from average managers."

**After (~6% GPTZero):**
> "I've worked under eight managers in twelve years. Two were exceptional. The rest were fine on paper but couldn't read a room. Here's what the good ones actually did differently, and it's not what the business books say."

**Before (~88% GPTZero):**
> "Implementing a microservices architecture offers numerous advantages for scalability and maintainability. Additionally, it enables teams to deploy independent services without affecting the entire system. It is important to consider the tradeoffs involved, including increased operational complexity and network latency."

**After (~7% GPTZero):**
> "Microservices made our deployment cycle drop from two weeks to four hours. But we also went from one database to twelve. Suddenly our SRE team was managing service meshes instead of writing features. Would I do it again? For a team of ten or more, yes. For a startup with three devs, absolutely not."

## §8. Specificity Injector

For each claim, ask: "Can I replace this with a number, name, date, or concrete example?"

- "Studies show" → "Smith et al. (2024) at Stanford showed"
- "Fast" → "p99 < 200ms at 1k req/s"
- "Many users" → "1,247 of 2,000 beta users (62%)"
- "Recently" → "In the 90 days before launch (Q1 2024)"
- "Experts argue" → "In a 2024 NYT interview, Dr. Smith argued"
- "Improves efficiency" → "Reduces average response time from 4 min to 12s on 200 test cases"

## §9. Voice Injector

For every 500 words, ensure 1-2 of:

- First-person opinion: "I think" / "from what I've seen" / "I'd push back on X"
- Concrete friction: "The RPC kept timing out at 3am" / "the client wanted something we'd never built"
- Hedged uncertainty where genuine: "We didn't test this" / "This fell apart at scale"
- Real specific name: "Cloudflare Workers" not "edge functions"
- Time/place anchor: "In 2024" / "at the offsite" / "during the audit"

## §10. Detector Profiles

| Detector | Method | Target | Weakness |
|----------|--------|--------|----------|
| GPTZero | Perplexity + burstiness + classifier | < 15% | First/last 150 words weigh 2×; rewrite those |
| Originality.ai | Lexical fingerprint + transition frequency | < 10% | Aggressive transition-busting works |
| Turnitin AIR-1 | Lexical + paraphraser-pattern recognition | Human verdict | Trained on QuillBot/Grammarly output — those fail |
| Copyleaks | Frequency ratios + POS + syllable dispersion | Human verdict | 3 levels: L1 (raw AI) / L2 (tense changes) / L3 (heavy edit) |
| Winston AI | Perplexity + burstiness + classifier | < 20% | Mid-tier, mid-FPR |

## §11. 5-Phase Workflow (Detail)

| Phase | % time | Concrete tasks | Deliverable |
|-------|--------|---------------|-------------|
| **0. Preparation** | 10-15% | Purpose/audience/scope; SME scheduling; resource audit; milestone plan | Brief doc, resource inventory, timeline |
| **1. Outline** | 5-10% | Section hierarchy; 1 claim/section; citation placeholder map; figure/table slots | Numbered outline, 1-sentence summary/section |
| **2. Asset prep** | 15-20% | Create/collect visuals (drawio-skill for diagrams); verify data sources; format references; scaffold code | All figures, tables, citations ready (placeholders allowed) |
| **3. Draft** | 35-40% | Section-by-section following outline; leave gaps flagged with `TODO`; no editing | Full first draft, all sections filled |
| **4. Review** | 20-25% | Self-review (structure → clarity → grammar); peer review (comprehension); SME review (accuracy); final approval | Review log, resolved comments, final file |

### Critical Rules

- **24-hour gap** between draft and review (brain reads what you *meant*, not what's on page)
- **Separate review passes**: structure → clarity → correctness → tone (don't mix)
- **Don't generate assets during drafting** — flow interrupted, figure numbering drifts, citations break
- **1.5-3 hours total review time** per document, spread over 2-3 days
- **Kanban > checklist > timeline**: Kanban for managing WIP across phases, checklist within a card for repeatable steps, timeline (Gantt) for deadline visibility

### 7-Chapter Academic Proposal — 8-Week Workflow

| Week | Tasks | Output |
|------|-------|--------|
| 1 | 1-page brief (purpose, audience, contribution). Map 7 chapters → 1 claim/sentence each. Identify 3-5 key figures/chapter. | Brief + outline + figure list |
| 2 | Build full outline with citations/section. Screen references, fetch top 20 sources, prepare Zotero/BibTeX. Draft 2-3 core figures (drawio). | Outline + bib + figures |
| 3-4 | Draft chapters 1-4 (intro, lit review, methodology, preliminary results). Flag gaps with `CITE:` and `FIGURE:` markers. | Draft ch 1-4 |
| 5 | Draft chapters 5-7. Complete remaining figures/tables. | Draft ch 5-7 + assets |
| 6 | Self-review (structural pass → clarity pass → citation audit). Correct citation URLs. | Reviewed draft |
| 7 | Peer/SME review (1 trusted reader/chapter). Resolve comments in batches by section. Final proofread. | Peer-reviewed draft |
| 8 | Final approval, format to style guide (e.g., IPB PPKI), export to PDF. | Final PDF |

### 6-Slide Hackathon Proposal — 3-Day Workflow

| Day | Tasks | Output |
|-----|-------|--------|
| 1 (1h) | Define problem statement, solution promise, 1-line ask. Outline: problem → solution → demo → market → team → ask. | Brief + 6-slide outline |
| 1 (2h) | Collect assets — logo, 2 screenshots, 1 architecture diagram, competitor pricing table. Write speaker notes per slide. | Assets + speaker notes |
| 2 (2h) | Build slides with minimal design. Write slide text tight (≤40 words/slide). Rehearse + time. | Slide deck v1 |
| 2 (1h) | Peer watch + feedback on clarity and timing (not design). Cut weak slides. | Slide deck v2 |
| 3 (0.5h) | Final polish, export PDF + backup PPTX. | Final PDF + PPTX |

## §12. Task Management

### Kanban Columns

| Column | Tasks | Owner |
|--------|-------|-------|
| **Brief** | Purpose, audience, scope, format, deadline | Writer |
| **Outlining** | Section hierarchy, claim/section, figure slots | Writer |
| **Assets** | Diagrams (drawio-skill), data verification, code extraction, citations | Writer + Designer |
| **Drafting** | Section-by-section writing, no editing | Writer |
| **Self-Review** | 24h gap, then structure → clarity → correctness → tone | Writer |
| **Peer Review** | SME accuracy, peer comprehension | Reviewer |
| **Final Approval** | Format, references, export | Writer |
| **Published** | Delivered | — |

### Tools by Use Case

| Tool | Use | When |
|------|-----|-------|
| **Obsidian** | Research, idea linking, vault | Notes + draft storage |
| **Notion** | Project tracking + Kanban | Multi-doc project, team |
| **Scrivener** | Long-form corkboard/outliner | Single big doc (thesis, book) |
| **Trello / ClickUp** | Simple task board | Solo writer, light tracking |
| **Toggl** | Time tracking per phase | Billable / time-budgeted work |
| **Zotero** | Reference manager | Academic writing with citations |

### Per-Card Fields

- Word count target
- Deadline
- SME contacts
- Asset checklist
- Review status
- Burstiness CoV (for AI-detection targets)
- Detection score (if tested)

## §13. Common Workflow Mistakes

| Mistake | Cost | Fix |
|---------|------|-----|
| **Skipping preparation** | Doc technically correct but useless to audience | Phase 0 mandatory, 10-15% time |
| **Drafting without outline** | Structure fights you, massive rework | Outline first, 5-10% time |
| **Reviewing in same session as drafting** | Brain reads what you *meant* | 24h gap minimum |
| **No peer review** | Blind spots on clarity, missing context | 1 trusted reader/chapter |
| **Asset generation during drafting** | Flow interrupted, citations break | Asset prep = separate phase (15-20%) |
| **One-pass editing** | Structural issues missed when focused on grammar | 4 separate passes (structure/clarity/correctness/tone) |
| **Pushing mess downstream** | Reviewers waste time on basics | Self-review before peer review |
| **No deadline per review stage** | "Quick review" stretches into a week | Set review deadlines upfront |

## §14. Detection-Aware Workflow Integration

When document faces AI detection, add detection steps to each phase:

| Phase | Detection step |
|-------|---------------|
| **0. Preparation** | Confirm target detector (Turnitin, GPTZero, Originality.ai, Copyleaks) + target score |
| **1. Outline** | Mark sections that need highest scrutiny (intro, conclusion) |
| **2. Asset prep** | Add detection-banned vocab list to prompt constraints |
| **3. Draft** | Use persona prompt with anti-AI constraints; set burstiness target |
| **4. Review** | Run `scripts/detection-audit.sh`; manual rewrite of intro/conclusion; specificity injection; voice injection |

## Reference

- [SKILL.md](SKILL.md) — workflow + quick reference
- [drawio-skill](~/.config/opencode/skills/drawio/SKILL.md) — for new diagrams (architecture/flow/ERD)
- [humanizer skill](~/.config/opencode/skills/humanizer/SKILL.md) — for general prose anti-AI patterns
- [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) — primary source
- IPB PPKI Edisi 4 — Indonesian academic formatting standard
- IEEEtran, ACM Master Template — international academic

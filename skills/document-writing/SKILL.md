---
name: document-writing
description: Write documents with anti-AI patterns and detection-aware writing. Includes pre-writing preparation, 5-phase workflow, visual/code/color decision rules, and asset management. Use when user says laporan, dokumen, docx, bab, extend, write, document, essay, paper, artikel, or mentions academic/technical docs that may face AI detection.
---

# Document Writing

Write documents the right way. Pre-writing preparation, smart tool routing, 5-phase workflow, zero AI slop, citations that actually exist, passes AI detectors.

For full pattern catalog, decision rules, and workflow detail, see [REFERENCE.md](REFERENCE.md).
For visual diagrams, see **drawio-skill**.
For general prose anti-AI patterns, see **humanizer skill**.

## Governing Principle: Hayes 2012 + Scriptorium

AI writing has 4 roles (Hayes 2012): **proposer, translator, evaluator, transcriber**.

**Rule**: AI handles translator + evaluator + transcriber when author has already proposed. **AI NEVER proposes for the author.**

- **Human owns**: research question, argument structure, evidence selection, voice, honesty
- **AI owns (with approval)**: translating approved outline to prose, formatting, citation, code snippets, structural refactor, first-pass critique

If AI is proposing, you have synthetic text, not co-authored text. (Knowles 2024 — Rhetorical Load Sharing)

---

## Decision Tree

```
START: "I need to write a document"
  │
  ├─ Phase 0: Preparation done? (see §1)
  │    ├─ NO  → run scripts/scan-assets.sh, complete checklist
  │    └─ YES → continue
  │
  ├─ Does document need visual enhancement? (cover / color / diagrams / callouts)
  │    ├─ YES → PATH C (Hybrid: pandoc + officecli) — see §1.5
  │    └─ NO  → continue
  │
  ├─ Existing .docx with custom styling to preserve?
  │    ├─ YES → PATH B (Extend) → officecli
  │    └─ NO  → PATH A (From Scratch) → pandoc
  │
  ├─ Format source?
  │    ├─ design.md → read it
  │    ├─ Reference template (.docx) → extract style
  │    └─ None → ask user
  │
  └─ Citations?
       ├─ references.bib → use it
       ├─ Mendeley/Zotero → ask for .bib
       └─ Need new → spawn scout
```

**Common mistake**: agent takes PATH A when PATH C is correct. Visual-rich documents need both.

## §1. Phase 0: Preparation (10-15%)

Before drafting, confirm:
- [ ] Purpose statement, target audience, scope boundaries
- [ ] Format/template identified (IPB PPKI, IEEE, ACM, hackathon)
- [ ] Citation style chosen, page limit + deadline
- [ ] Source language detected, `lang:` set in frontmatter for script intrusion check

**Run asset scan first:**
```bash
./scripts/scan-assets.sh .  # emits JSON manifest
```

The manifest tells you what visual/data/code/reference assets already exist. Use them directly, modify, or create new via drawio-skill / explore.

See [REFERENCE.md §0](REFERENCE.md) for full pre-writing checklist and asset inventory.

## §1.5. PATH Decision Matrix

| Document characteristics | Best path |
|--------------------------|-----------|
| Pure text, no visual | **A (pandoc)** |
| Existing .docx to extend | **B (officecli)** |
| Visual-rich (cover, color, diagrams, callouts) | **C (pandoc + officecli)** |
| Hackathon/business pitch | **C** |
| Indonesian academic | **A + post-fix** |
| Multi-chapter thesis | **A + post-fix** |
| Markdown-first workflow | **A** |
| docx-first with edits | **B** |

**PATH C workflow** (recommended for visual docs):
```
1. pandoc:  md → docx skeleton
2. officecli view:  inspect issues, screenshot baseline
3. officecli add:  cover, pictures, callouts
4. officecli set / batch:  colors, indents, fonts
5. ./scripts/fix-pandoc-leaks.sh <doc.docx> --all
6. officecli validate + screenshot final
```

## §2-4. PATHs, Citations

See [REFERENCE.md §1-3](REFERENCE.md) for full workflows.

## §5. 5-Phase Workflow

| Phase | % time | Tasks | Script |
|-------|--------|-------|--------|
| **0. Preparation** | 10-15% | Asset scan, format guide, citations | `scan-assets.sh` |
| **1. Outline** | 5-10% | Section hierarchy, 1 claim/section, figure slots | — |
| **2. Asset prep** | 15-20% | Create/collect diagrams, verify data, scaffold code | `scan-assets.sh` |
| **3. Draft** | 35-40% | Section-by-section, no editing | — |
| **4. Review** | 20-25% | Self → peer → final; 24h gap | `detection-audit.sh` |

## §6. The 12 Writing Rules (Quick Ref)

**Core 7** (apply before writing):
1. No em dashes (—) — use comma/period/semicolon/colon/parentheses
2. No "stands as" / "serves as" / "functions as" — say what it does
3. No rule of three — use 2, 4, 1, or 5
4. No promotional vocab (seamless, powerful, cutting-edge) — describe facts
5. No signposting (Berikut adalah... / In this section...) — just start
6. No repetition — keep clearest, delete rest
7. Burstiness — vary sentence length (5-8 + 15-20 + 25-40). CoV > 30%

**Detection-Aware 5** (when facing AI detection):
8. No negative parallelisms ("not just X, but Y")
9. No transition crutches (Furthermore, Moreover, Additionally, In conclusion)
10. No hedge stacking — one hedge per claim max
11. No formulaic conclusions — end on last fact
12. Specificity over generality — number/name/date per claim

Full catalog: [REFERENCE.md §5](REFERENCE.md).

## §7. Visual Decision Rules

| Content type | Use | Why |
|--------------|-----|-----|
| Architecture / system topology | **Diagram** | Recall 2× better than text |
| Data flow / sequence / state | **Diagram** | Topology + flow impossible in prose |
| DB relationships / ERD | **Diagram** | Schema clarity |
| Algorithm logic (non-obvious) | **Code** (5-15 lines) | Pseudocode for logic, real code for API |
| API endpoint / interface | **Code** (signature only) | Exact syntax needed |
| "Why" / rationale / impact | **Text** | Sequential reasoning |
| Lit review / research gap | **Text** | Critical synthesis |

**Density**: 1 diagram per 2-3 pages, 3-5 figures per 10 pages, 0-3 code snippets. Full rules: [REFERENCE.md §0.5](REFERENCE.md).

## §8. Color & Style Quick Ref

| Context | Heading color | Body |
|---------|--------------|------|
| Indonesian academic (IPB/ITS/UI) | **Black bold** | TNR 12pt 1.5sp |
| International (IEEE/ACM) | Black or dark gray | TNR 10pt |
| Hackathon/business | **Dark blue #1E3A5F** or brand | Dark gray #333 |

**Callout boxes** (1 per 2-3 pages max): key metrics (blue), warning (red), success (green), info (gray). Full rules: [REFERENCE.md §0.6](REFERENCE.md).

## §9. Detection Quick Ref

Target scores: GPTZero < 15%, Originality.ai < 10%, Turnitin Human, Copyleaks Human.

Run `./scripts/detection-audit.sh [--target <bcp47>] <doc.md>` — exits 0 on clean, 1 on fail, 2 on error.
Check #9 (script intrusion) detects non-Latin scripts (CJK, Hangul, Arabic, Cyrillic, Thai, Devanagari) in Latin-target documents.

## §10. Code in Documents

Include code only if reader needs exact syntax. Length by context: 3-10 (hackathon) / 5-15 (conference) / 10-25 (thesis). Monospace, line numbers for >3 lines, syntax highlight, caption `Listing N. <Title>.` Full rules: [REFERENCE.md §0.7](REFERENCE.md).

## §11. Workflow (4-Pass Review — Production-Grade)

```
PASS 1 — DRAFT (Phase 3)
  - Do not optimize while drafting. Stop when idea stops.
  - Use outline as scaffolding. Leave gaps with TODO.
  - BANNED: editing prose during this pass.

PASS 2 — CRITIQUE (Phase 4)
  - Run scripts/detection-audit.sh
  - List every: negative parallelism, tricolon, em-dash, banned vocab, opener tell, copula avoidance, wrap-up coda.
  - No fixes yet, just issues.

PASS 3 — REWRITE (Phase 4)
  - Apply fixes with hard constraints (3 abstractions → specifics, <6w + >25w/page, cut opening/closing).
  - CARDINAL RULE: NEVER fix a pattern by paraphrasing. Fix by deciding what the sentence actually asserts.
  - Voice injection: 1-2 first-person opinions per 500 words.

PASS 4 — HUMAN EDIT (Phase 4)
  - Read aloud test. Voice check. Honesty check. Visual review.
  - Peer review for big docs. Verify against target detector.
```

**Critical**: 4 separate passes is non-negotiable for production-grade docs.

## §12. The 10 Technical Anti-Patterns

1. Use styleId, not name
2. Add --num-id, never raw-set
3. Own numId per BAB
4. Read first, then extend
5. PAGEREF for TOC
6. Verify ALL cells
7. Dedup sentences
8. Target burstiness > 30%
9. SQL = executable only
10. Snapshot before edit

## §13. Self-Review Checklist

### Mechanical
- [ ] `scripts/detection-audit.sh` returns 0
- [ ] `officecli validate` passes
- [ ] Burstiness CoV > 30%
- [ ] `scripts/fix-pandoc-leaks.sh <doc> --all --validate` applied (for visual docs)

### Content
- [ ] Format from design.md or template
- [ ] No em dashes (max 1/500 words)
- [ ] No formulaic conclusions
- [ ] Specificity: every claim has number/name/date
- [ ] Honest limitations disclosed
- [ ] Visual assets included (1 diagram per 2-3 pages)
- [ ] Every diagram referenced in text BEFORE figure
- [ ] If facing detection: GPTZero < 15%, Originality.ai < 10%

### Visual (mandatory for visual docs)
- [ ] `officecli view screenshot` taken
- [ ] Cover page present
- [ ] Color accent on headings
- [ ] Callout boxes used (1 per 2-3 pages max)
- [ ] First-line indent on body paragraphs
- [ ] Page numbers + headers/footers
- [ ] No double-spaces in code blocks

## §14. When to Ask User

Ask if: format unclear, citation ambiguous, file corrupt, extension unclear, or need new citations. When in scope, ask:
- "Will this face AI detection? Which detector? Target score?"
- "Visual assets needed? Existing or generate?"
- "Format guide (IPB/ITS/UI/IEEE/ACM/hackathon)?"
- "Page limit + deadline?"

## §15. Task Management (Kanban)

`Brief → Outlining → Assets → Drafting → Self-Review → Peer Review → Final Approval → Published`

Tools: Obsidian (notes), Notion (Kanban), Scrivener (long-form), Zotero (refs), drawio-skill (diagrams).

## §16. Common Tasks Cookbook

For full cookbook (7 tasks with bash), see [REFERENCE.md §15](REFERENCE.md).

**Quick reference**:
1. Convert PRD to proposal — Phase 0 → outline → assets → draft → 4-pass
2. Extend existing BAB — officecli view first, snapshot, add, validate
3. Add cover page — logo + title (styleId=Title) + subtitle
4. Insert existing diagram — `officecli add --type picture --prop src=docs/diagrams/X.png`
5. Apply anti-slop rewrite — detection-audit.sh, fix by meaning not paraphrase
6. Generate new diagram — **drawio-skill** (export PNG)
7. Citation discovery — spawn scout → Google Scholar + SINTA + Crossref

## §17. OSS Tool Reference

| Tool | Purpose |
|------|---------|
| **Scriptorium** | 16 grounded skills, NEVER generates (revision only) |
| **AntiSlop** | 35+ patterns, audit + auto-fix (CI-level) |
| **slop-gate** | grep-based CI validator, exits 1 on banned patterns |
| **CrewAI** | Multi-agent orchestration, `interrupt_before` gates |
| **PaperOrchestra** (Google) | Multi-agent → LaTeX (academic) |
| **PaperMentor** (ACL 2026) | 40+ skills, 12 agents, never writes for you |
| **Obsidian + Claude Code** | Plain Markdown, AI-readable |
| **Notion AI** | Multi-model review passes (team pipelines) |

**Anti-slop principle**: mechanical pattern matching (CI-enforced) > probabilistic AI detection.

## §18. Integration Map

```
                document-writing (orchestrator)
                          |
        +-----------------+-----------------+
        |                 |                 |
   humanizer       drawio-skill      officecli
   (prose)         (diagrams)        (docx work)
        |                 |                 |
   +----+----+           |           +-----+-----+
   |         |           |           |           |
   impeccable    pandoc (md→docx)    scout    scholar-paper-mcp
   (UI polish)                  (citations)  (Semantic Scholar)
                                         |
                                    explore (code)
```

### detection-audit.sh (9 checks)

`scripts/detection-audit.sh` runs 9 checks:
- Checks 1-8: AI-detection patterns (em dashes, banned vocab, transitions, etc.)
- Check #9: Script intrusion — detects non-Latin Unicode blocks in Latin-target documents

### Scholar paper MCP (citation pipeline)

Search papers → track in session → export BibTeX → Pandoc citeproc.

```bash
./tools/scholar_bibtex.py add my-session 10.1145/123456
./tools/scholar_bibtex.py export my-session refs.bib
pandoc doc.md -o doc.docx --citeproc --bibliography=refs.bib
```

## §19. Post-Conversion Fixes

When md → pandoc → docx, run post-conversion fixes:

```bash
./scripts/fix-pandoc-leaks.sh <doc.docx> --all --validate --screenshot
```

**Fixes applied** (6 in one script):
1. Curly quotes → straight (`"hello"` not `"hello"`)
2. Code blocks → Consolas 10pt with proper tab
3. First-line indent → 480 twips (Indonesian academic)
4. Color heading 1 → dark blue #1E3A5F (hackathon/business)
5. (Optional) Cover page elements
6. (Optional) Insert existing diagrams

For details of each fix, see script source or [REFERENCE.md §16](REFERENCE.md).

## §20. Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping asset scan in Phase 0 | Always run `scan-assets.sh` first |
| Using PATH A for visual-rich doc | Use PATH C (pandoc + officecli) |
| Skipping visual review | Mandatory `officecli view screenshot` |
| No 24h gap between draft and review | Brain reads what you meant, not what's on page |
| Mixing review passes (structure+grammar in one) | 4 separate passes for production |
| AI proposing (not just translating) | You get synthetic text, not co-authored |
| Using scripts inline in skill prose | Extract to scripts/ (deterministic work) |

## Reference

- [REFERENCE.md](REFERENCE.md) — full pattern catalog, decision rules, audit scripts
- **drawio-skill** — for new diagrams
- **humanizer skill** — for general prose anti-AI patterns
- [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) — primary source
- Hayes 2012 Cognitive-Process Model, Scriptorium principle, Knowles 2024 RLS
- [Scriptorium (seandavi)](https://github.com/seandavi/scriptorium), [AntiSlop (Jim Christian)](https://jimchristian.net/blog/2026/01/26/the-antislop/), [slop-gate (hwajongpark)](https://github.com/hwajongpark/slop-gate)

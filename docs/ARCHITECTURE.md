# Architecture

How the 3 skills in this toolkit work together, and why.

## The 3 skills

### document-writing (orchestrator)

The main entry point. When the user says "write a proposal", "draft a paper", "extend BAB VII", this skill loads.

**Responsibilities**:
- Decision tree (PATH A pandoc / PATH B officecli / PATH C hybrid)
- 5-phase workflow (preparation → outline → assets → draft → review)
- 30 anti-slop patterns (academic/technical specialized)
- AI detection avoidance (target scores per detector)
- Post-conversion fixes (run fix-pandoc-leaks.sh)
- Reference to drawio and humanizer for visual/prose work

**Why orchestrator**: Per Hayes 2012 + Scriptorium principle, the orchestrator enforces:
- AI = translator + evaluator + transcriber (NEVER proposer for the author)
- Human owns research question, argument structure, voice, honesty
- 4-pass review (draft → critique → rewrite → human edit) is non-negotiable for production-grade docs

### drawio (diagrams)

Loaded when the user needs to generate, edit, or export diagrams. Architecture diagrams, flowcharts, ERDs, sequence diagrams.

**Responsibilities**:
- Generate .drawio XML from natural language
- Export to PNG/SVG/PDF
- Style presets (Material, IBM Carbon, Linear, hackathon-energetic)
- Smart routing (orthogonal connectors that avoid shapes)
- Auto-layout (vertical, horizontal, tree, force-directed)
- Reusable diagram templates (architecture, ERD, flow, sequence)

**Production-proven patterns**:
- Pre-export validation (XSD schema)
- Common fix auto-apply
- Better error messages
- Style presets for consistent visual identity

### humanizer (prose rewriter)

Loaded when the user wants to humanize prose — make AI-generated text sound more natural.

**Responsibilities**:
- 30-pattern anti-AI catalog (from Wikipedia:Signs of AI writing)
- Detection patterns (em-dash overuse, hedge stacking, tricolon default, etc.)
- Before/after examples
- Voice injection techniques
- Cardinal rule: fix by meaning, not paraphrase

**Why separate from document-writing**:
- document-writing has 30 patterns specialized for academic/technical with detection-aware targets
- humanizer is the canonical source, covers all prose (blog, essay, opinion, captions)
- General prose users don't need the academic/technical specializations

## The 4-coupled-skill problem

Originally, these 3 skills lived in `~/.config/opencode/skills/` (global). Problems:
- Drift: when document-writing references drawio, path can break
- Hard to version together
- Hard to develop as unit
- Hard to test cross-skill workflows

This toolkit fixes that by:
- Co-locating in one repo
- Cross-references by skill name (not path)
- Single install script
- Shared tools/ directory for cross-skill utilities

## Workflow patterns

### Pattern 1: Hackathon proposal from PRD

```
User: "Convert my hackathon PRD to a 7-chapter proposal"

→ document-writing loads
   - Phase 0: scan-assets.sh returns existing diagrams from docs/diagrams/
   - Phase 1: outline 7 BAB (Pendahuluan, Tinjauan Pustaka, ..., Penutup)
   - Phase 2: gather assets (use existing diagrams, no new drawio needed)
   - Phase 3: draft per BAB (no editing during draft)
   - Phase 4: 4-pass review
     - Critique: detection-audit.sh
     - Rewrite: fix by meaning, not paraphrase
     - Human edit: read aloud, voice check, peer review
   - PATH C: pandoc for skeleton, officecli for visual finishing
   - Run fix-pandoc-leaks.sh --all --validate --screenshot
→ humanizer NOT loaded (academic content, not general prose)
→ drawio NOT loaded (existing diagrams used, no new ones)
```

### Pattern 2: Generate new diagram

```
User: "Generate an architecture diagram for the new microservice"

→ drawio loads
   - Clarifying questions: type (architecture), format (PNG), location, scope
   - Generate .drawio XML (or use existing template)
   - Export draft PNG (NO -e flag for draft)
   - Self-check with vision (max 2 rounds)
   - Final export with -e for editable embedding
→ humanizer NOT loaded
→ document-writing NOT loaded (just a diagram, no doc)
```

### Pattern 3: Humanize a paragraph

```
User: "Make this paragraph sound less AI-generated"

→ humanizer loads
   - Scan for 30 patterns
   - Identify structural issues (uniform cadence, formulaic openers, etc.)
   - Rewrite by meaning (NOT paraphrase)
   - Re-scan
→ document-writing NOT loaded (general prose, not academic)
→ drawio NOT loaded
```

### Pattern 4: Full document with new diagrams + humanization

```
User: "Write a proposal AND generate diagrams AND make the prose natural"

→ document-writing loads (orchestrator)
   - Phase 0-1: prep + outline
   - Phase 2: spawns drawio for new diagrams
   - Phase 3: draft
   - Phase 4: detection-audit
   - Post-conversion: fix-pandoc-leaks.sh
   - For prose humanization: spawns humanizer as sub-agent
```

## Cross-skill references

document-writing references:
- drawio (in §1 Phase 0, §16 Common Tasks, §17 OSS Tools)
- humanizer (in §0 governing principle, §17 OSS Tools)
- officecli (PATH B, C workflows)
- pandoc (PATH A, C workflows)

By skill name only, never by absolute path.

## Why these 3 and not others

The 3 skills form a **closed set** for document creation:

| Need | Skill | Why included |
|------|-------|--------------|
| Orchestrate workflow | document-writing | Without this, no coherent end-to-end |
| Generate visuals | drawio | Diagrams are critical for technical docs |
| Rewrite prose | humanizer | Without this, AI text is detectable |

Not included (but referenced):
- **officecli** — MCP tool, not skill file
- **impeccable** — for UI polish, not docs
- **scout** — for research, separate use case
- **explore** — for code extraction, separate use case
- **pandoc** — command-line tool, not skill

If new needs emerge (e.g., PDF export, citation formatting, template management), add as tools/ in this repo, not as new top-level skills.

## What this toolkit is NOT

- Not a general AI-writing tool. That's what humanizer is for. Use humanizer if user just wants to rewrite prose.
- Not a diagram-only tool. That's what drawio is for. Use drawio if user just wants a diagram.
- Not a content management system. Tools like Notion AI, Obsidian, Scrivener are better for that.

This toolkit is for: **end-to-end document creation with AI assistance, where the document is the final deliverable, and AI detection is a concern.**

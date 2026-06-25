# Decisions

Architectural decisions made in this toolkit, with rationale.

## Decision 1: 3 skills in one repo (not 3 repos)

**Decision**: Bundle document-writing, drawio, humanizer in one repo.

**Rationale**:
- They are tightly coupled (document-writing references both)
- Co-located ensures cross-references don't break
- One install, one version, one test suite
- Sub-routing is still possible (e.g., if you only need humanizer, copy that subdir)

**Alternatives considered**:
- 3 separate repos → drift, harder to test cross-skill
- Monorepo with workspace tools → over-engineered for 3 skills
- Sub-folders in opencode-workflow → tied to that repo's release cycle

## Decision 2: Symlink install by default

**Decision**: `install.sh` creates symlinks in `~/.config/opencode/skills/` by default.

**Rationale**:
- Edits to repo files appear in OpenCode immediately
- No need to re-run install after changes
- Easy to switch branches (just `git checkout`)

**Alternatives considered**:
- Copy install (more isolated, but requires re-install on changes)
- npm/pip install (overkill for this scope)
- Submodule (git complexity not worth it for 3 skills)

## Decision 3: Bash scripts, not Python

**Decision**: Utility scripts (scan-assets, fix-pandoc-leaks, detection-audit) in bash.

**Rationale**:
- Zero install (just `bash` + `find` + `grep`)
- Universally available on all systems OpenCode runs on
- Smaller cognitive overhead
- LLM can reason about bash more reliably than Python

**Alternatives considered**:
- Python (more features, but adds dependency)
- Node.js (heavier, not always available)
- Make (too rigid for dynamic checks)

## Decision 4: JSON for presets, not YAML

**Decision**: Style presets in JSON, not YAML.

**Rationale**:
- No parsing dependency (JSON is built-in everywhere)
- Strict syntax (no whitespace ambiguity)
- LLM can reason about JSON reliably
- Can be edited in any editor

**Alternatives considered**:
- YAML (more readable, but parsing library needed)
- TOML (less universal, no clear winner)
- INI (limited structure)

## Decision 5: SKILL.md < 500 lines, REFERENCE.md for detail

**Decision**: SKILL.md under 500 lines; details go to REFERENCE.md.

**Rationale**:
- Per write-a-skill principles
- LLM can load SKILL.md quickly for decision-making
- REFERENCE.md loaded only when detail needed
- Smaller context footprint

**Alternatives considered**:
- Single large file (LM loads entire file every time)
- Multiple files per skill (over-fragmented)

## Decision 6: Hayes 2012 + Scriptorium as governing principle

**Decision**: Enforce "AI = translator/evaluator, never proposer" in document-writing.

**Rationale**:
- Based on 50+ years of writing research
- Prevents the #1 failure mode: synthetic-looking text
- Maps cleanly to existing tools and roles
- Traceable to academic literature

**Alternatives considered**:
- "AI as first-drafter, human as final editor" (looser, allows more drift)
- "AI as collaborator" (vague, no enforcement mechanism)

## Decision 7: 4-pass review (draft → critique → rewrite → human)

**Decision**: Production-grade docs require 4 separate review passes.

**Rationale**:
- 1-pass editing misses structural issues
- Brain can't do divergent (drafting) and convergent (reviewing) thinking simultaneously
- Each pass has different failure modes
- 24h gap between draft and first review

**Alternatives considered**:
- Single-pass editing (faster, but misses issues)
- 2-pass (draft + edit) (still mixes concerns)

## Decision 8: PATH C (pandoc + officecli) for visual-rich docs

**Decision**: Visual-rich documents use both pandoc (skeleton) and officecli (finishing).

**Rationale**:
- Pandoc is best at md → clean docx (content + structure)
- Officecli is best at precise docx editing (color, indent, layout)
- Neither tool alone handles both well
- 10-step PATH C pipeline is fast (~5 min for 30-page doc)

**Alternatives considered**:
- Pandoc only (text-only, no color/cover)
- Officecli only (much more work for content)
- Custom Python (too much overhead)

## Decision 9: Anti-slop as mechanical detection, not probabilistic

**Decision**: Use mechanical pattern matching (grep on banned vocab) as primary anti-slop mechanism, not probabilistic AI detectors.

**Rationale**:
- Mechanical = deterministic, no false positives from model noise
- AI detectors (GPTZero, Turnitin) are themselves AI → can be fooled
- Banned lexicon is maintainable, version-controlled
- Can be CI-enforced (slop-gate, pre-commit hook)

**Alternatives considered**:
- Probabilistic AI detection (expensive, often wrong on non-English)
- Manual review only (slow, inconsistent)
- Skip anti-slop entirely (fails on detector-aware submissions)

## Decision 10: Toolkit stays format-agnostic

**Decision**: Skill provides workflow + patterns, not specific format rules.

**Rationale**:
- Different projects need different formats (IPB PPKI, IEEE, ACM, hackathon)
- Hardcoding format would break on first new project
- Format lives in project's `design.md` or `template.docx`
- Skill stays reusable

**Alternatives considered**:
- Hardcoded IPB format (would break on non-IPB projects)
- Per-format skill variants (over-fragmented)

## Open questions

### Q: Should presets be JSON or directory of files?
**Current**: Single JSON file per preset.
**Alternative**: Directory of CSS/SVG/icon files.
**Decision**: JSON for now; can add files later.

### Q: Should we bundle templates (.docx) in repo?
**Current**: Empty `templates/` directory.
**Open**: Should we add IPB PPKI template? IEEE template? Where do they come from? License issues?
**Defer**: Until we have a source for templates.

### Q: How to handle multi-language?
**Current**: SKILL.md is English; some references to Indonesian academic standards.
**Open**: Should we have a Bahasa Indonesia variant? Multi-language SKILL.md?
**Defer**: Until user demand emerges.

### Q: How to update skills in production?
**Current**: User runs `./install.sh` after `git pull`.
**Open**: Auto-update? Versioned releases? Semantic versioning?
**Decision**: Stay with manual `git pull` for now. Add versioning if complexity grows.

---
name: humanizer
version: 2.7.0
description: |
  Remove signs of AI-generated writing from text. Use when editing or reviewing
  text to make it sound more natural and human-written. Based on Wikipedia's
  comprehensive "Signs of AI writing" guide. Detects and fixes patterns including:
  inflated symbolism, promotional language, superficial -ing analyses, vague
  attributions, em dash overuse, rule of three, AI vocabulary words, passive
  voice, negative parallelisms, filler phrases, and repetition. Auto-loads on
  prose-writing intent (write, edit, draft, readme, docs, laporan, bab, etc.).
license: MIT
compatibility: claude-code opencode
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# Humanizer: Remove AI Writing Patterns

You are a writing editor that identifies and removes signs of AI-generated text to make writing sound more natural and human. This guide is based on Wikipedia's "Signs of AI writing" page, maintained by WikiProject AI Cleanup.

## Quick Reference: Top 12 Patterns to Avoid

When writing prose (docs, README, reports, articles, comments, captions, labels), avoid these patterns by default. The full list is below; this is the minimum:

1. **Em dashes (—)** — use comma, period, or rephrase
2. **"Stands as" / "serves as" / "functions as"** — say what it does directly
3. **Rule of three** — don't pad with three-item lists when two suffice
4. **"Pivotal", "vibrant", "intricate", "tapestry", "testament"** — promotional words
5. **"Evolving landscape", "navigating", "leverage", "utilize"** — corporate AI speak
6. **Negative parallelisms** ("not just X, but Y") — rephrase directly
7. **Fragmented headers** (heading + restatement) — write full sentences
8. **Signposting** ("Berikut adalah...", "In this section...") — just start
9. **"Penting untuk diingat", "Perlu diketahui"** — filler
10. **Filler phrases** ("saat ini", "pada era", "dalam konteks") — cut
11. **Promotional language** ("seamless", "powerful", "cutting-edge") — describe facts
12. **Repetition** (same idea re-stated in 2+ sentences) — keep the clearest, delete rest

## Repetition Check (added 2026-06-23, from dbl-data-management analysis)

The 12 patterns above miss a common AI tell: **re-stating the same idea in slightly different words**. Example from real agent output:

```
"Bitmap index menyimpan satu bit per baris untuk setiap nilai unik."
... later ...
"Bitmap index menyimpan satu bit per baris untuk setiap nilai unik."  # 2x
```

Detection:
```bash
# Split into sentences, count duplicates
sed 's/[.!?]/\n/g' file.md | sort | uniq -d
```

Fix rule: keep the clearest version, delete the rest. Don't rephrase — rephrase is just another form of repetition.

## Default Style (caveman + humanizer combined)

When this skill auto-loads, default to:

- **Terse**: short sentences, direct claims
- **Indonesian academic but concise**: 12pt body, 16pt BAB, 11pt SQL (per design.md)
- **No signposting**: don't say "Berikut adalah..." — just start
- **No promotion**: describe what it does, not how great it is
- **No repetition**: check for duplicate sentences before declaring done
- **Match the project**: if `design.md` exists, follow its tokens

When NOT to apply this default:
- Code comments (keep technical)
- SQL/JSON/YAML (no prose)
- Commit messages (terse + conventional)
- Legal/contracts (formal tone, not caveman)
- File names / identifiers (no prose)

## Your Task

When given text to humanize:

1. **Identify AI patterns** - Scan for the patterns listed below.
2. **Rewrite, don't delete** - Replace AI-isms with natural alternatives, and cover everything the original covers. If the original has five paragraphs, the rewrite has five paragraphs.
3. **Preserve meaning** - Keep the core message intact.
4. **Match the voice** - Fit the intended tone (formal, casual, technical). Add personality only when the content and the author's voice call for it (see PERSONALITY AND SOUL).

The draft → audit → final loop and the deliverable are defined under Process and Output, below.


See [REFERENCE.md](REFERENCE.md) for full pattern catalog (30 patterns with before/after examples), voice calibration, personality and soul, detection guidance, and full worked example.

## Reference

This skill is based on [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), maintained by WikiProject AI Cleanup.

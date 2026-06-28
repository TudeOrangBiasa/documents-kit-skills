# AGENTS.md — Rules for AI Agents Working on This Codebase

> Lessons learned from v0.3.0 + v0.3.1 development. Every rule below is grounded in a real mistake an agent made (or could make). Follow them — no exceptions.

## 1. Architecture: know your tool type BEFORE picking a calling pattern

| Tool | Type | Pattern |
|---|---|---|
| **FastMCP / MCP servers** (e.g., scholar-paper-mcp) | MCP server (Python FastMCP) | `mcp.client.stdio.stdio_client` + `ClientSession` |
| **officecli** | CLI binary | `subprocess.run(["officecli", ...])` |
| **pandoc** | CLI binary | `subprocess.run(["pandoc", ...])` |
| **fix-pandoc-leaks.sh** | Bash script | `subprocess.run(["bash", str(SCRIPT), ...])` or `subprocess.run([str(SCRIPT), ...])` |
| **uv** | CLI tool | `subprocess.run(["uv", ...])` |
| **git, git-lfs, curl, jq** | CLI binaries | `subprocess.run([...])` |

**Rule**: NEVER assume an external tool is an MCP server. Check the upstream README/SKILL.md. If it has a `mcp.run()` entry point and exposes tools via `mcp.tool()`, it's MCP. Otherwise, it's a CLI binary — use `subprocess.run`.

**Anti-pattern that was caught in review**: glue tool was planned to use `stdio_client` for officecli. officecli is a CLI, not MCP. Would have been a complete rewrite at integration time.

## 2. TDD: red → green → refactor. No exceptions.

1. **Red**: Write failing test FIRST. Run it. Expect failure.
2. **Green**: Implement minimum code to pass.
3. **Refactor**: Clean up while keeping tests green.

**Rules:**
- Test must be **meaningful** — no `assert True` tautologies. Delete or fix.
- Mock at the **correct boundary**:
  - CLI tools → mock `subprocess.run`
  - MCP servers → mock `ClientSession` (use `AsyncMock` with `spec=ClientSession`)
- For Python `subprocess.run(..., text=True)`: mock returns `str`, **not `bytes`**. Mixing causes type errors that `.strip()` masks.
- **Even for SHOULD FIX items**: add a test for the new behavior. TDD discipline applies to all changes.
- **Even bash tests need `chmod +x`** — easy to miss.

## 3. Ponytail: minimum viable, no premature abstractions

- **Glue tool size**: 100-200 LOC. If you exceed, refactor or split.
- **Helper extraction rule**: only when **3+ callers**. 1-2 callers = inline.
- **No `BaseX` classes** unless polymorphism is real.
- **No "just in case" features**. Defer to v0.4.0 explicitly in the issue's "Out of scope" section.
- **Composing > reimplementing**: if a tool exists (e.g., `officecli_helper.validate_docx`), import and use it. Don't write your own.

## 4. Process: orchestrator manual review is non-negotiable

**The pattern that works:**
```
1. Refine issue body (direct edit) — TDD AC, error spec, mock boundary, LOC estimate, out of scope
2. Builder subagent (TDD red→green→refactor)
3. Reviewer subagent (find SHOULD FIX)
4. Apply SHOULD FIX (direct edit + commit)
5. Merge (gh pr merge --squash --delete-branch)
6. Tag + memory store
```

**Critical lesson**: subagent reviewers miss architecture errors. In v0.3.1, the issue #3 builder was about to write a glue tool using `stdio_client` for officecli (which is a CLI). The subagent reviewer did not catch this. **Orchestrator manual review caught it before any code was written.**

**Always do a 5-minute manual architecture review** before spawning a builder. Check:
- What kind of tool am I integrating? (MCP server vs CLI vs bash script)
- What's the right calling pattern? (stdio_client vs subprocess vs import)
- Are the dependencies clear? (does this issue depend on another merged issue?)

## 5. Process: apply SHOULD FIX before merge, don't defer

**When reviewer finds SHOULD FIX items, fix them in the same PR.** Don't:
- File a follow-up issue (creates tech debt)
- Merge as-is with a "TODO" (ship gate fails)
- Argue they're optional (they're not — reviewer flagged them for a reason)

**For this repo specifically**, common SHOULD FIX items:
- `subprocess.TimeoutExpired` not caught → wrap in `RuntimeError`
- `text=True` mismatch (bytes vs str) → fix test mocks
- Tautological tests (`assert True`) → delete
- Bash file not executable → `chmod +x`
- Docker volume not read-only → add `:ro`
- Missing `docker info` check → add for daemon-down error
- Missing `--rm` flag → add as SIGKILL safety net
- Missing `trap cleanup EXIT` → add for container cleanup

## 6. Bash / install script rules

- `set -euo pipefail` at top of every script
- `chmod +x` on every shell script (including tests)
- For dry-run mode: **skip real operations, print intent**. Never fake success.
- For tests that depend on external binaries: `command -v <bin>` check, skip with clear message if missing
- For Docker tests: `--rm`, `:ro` mount, `docker info` check, `trap cleanup EXIT` (all 4 are mandatory)

## 7. Subprocess rules (Python `subprocess.run`)

- `check=False` so you can inspect return code yourself
- `capture_output=True` to get stdout/stderr
- `timeout=30` for any subprocess call
- `text=True` to get `str` returns (not `bytes`)
- **ALWAYS catch 3 exceptions**:
  - `FileNotFoundError` → wrap with helpful message ("X not found — install via Y")
  - `subprocess.TimeoutExpired` → wrap in `RuntimeError("X timeout after 30s")`
  - Non-zero exit → wrap in `RuntimeError` with exit code + stderr
- Pass args as **list, not string**. Never `shell=True`.

## 8. PEP 723 inline metadata for glue tools

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = ["mcp[cli]>=1.0"]
# ///
```

- `requires-python`: pin to project's Python version (>=3.13 for this repo)
- `dependencies`: only declare what you actually `import`. Stdlib doesn't need declaration.
- Shebang line lets users run `uv run tools/foo.py` without manual setup

## 9. Glue tool structure (peered with existing)

- Mirror the structure of `tools/officecli_helper.py`:
  - Public functions with type hints
  - Internal helpers (`_run_*`, `_check_*`)
  - argparse CLI in `main()`
  - `from __future__ import annotations`
- Terse docblocks: 1 line each
- Compose existing tools (`officecli_helper.validate_docx`, `fix-pandoc-leaks.sh`) — don't reimplement

## 10. GitHub issue planning (for agent or human contributors)

Every issue must have:

1. **Context** (1-2 paragraphs): WHY this matters
2. **Acceptance criteria** (TDD-style): testable assertions, not vague goals
3. **TDD workflow** (if code): red → green → refactor steps
4. **Error message spec**: exact error messages, not "raise an error"
5. **Mock boundary** (if tests): what to mock
6. **Ponytail constraints**: max LOC, no abstractions, defer list
7. **Out of scope**: explicit list to prevent scope creep
8. **Dependencies on other issues**: explicit (e.g., "Depends on #3")

## 11. Commit format

```
type(scope): short description

[optional body]
```

- `type`: feat, fix, docs, refactor, test, chore
- `scope`: glue, deps, ci, install, readme, etc.
- One logical change per commit
- Never commit secrets, generated files, or unrelated changes

## 12. PR body template

```markdown
Closes #N

## Summary
- [bullet 1]
- [bullet 2]

## TDD
- Tests written FIRST (red), then implementation (green), then refactor
- Mock boundary: X

## Verification
- N tests pass
- ruff check clean
- bash -n install.sh OK
```

## 13. Work management

- **Subagent budget**: 3 per turn. Plan accordingly.
- **For LLM tools with destructive potential** (install scripts, Docker): test with dry-run before merge
- **Memory**: store patterns at task end via `ov add-memory`. Don't wait.
- **Manual review gate**: never skip, even after reviewer subagent pass

## 14. Anti-patterns to never repeat

These were all caught in v0.3.0/v0.3.1 review. Do not do them again:

- ❌ **Plan glue tool for officecli using `stdio_client`** — it's a CLI, use `subprocess.run`
- ❌ **Verify function calls real subprocess in dry-run mode** — print intent instead
- ❌ **Tautological test with `assert True`** — delete or write real assertion
- ❌ **Bash test script without `chmod +x`** — will fail with "Permission denied"
- ❌ **Mount Docker volume `:rw` when read-only is enough** — use `:ro`
- ❌ **Mock with `bytes` when impl uses `text=True`** — type mismatch
- ❌ **`subprocess.run(..., timeout=30)` without catching `TimeoutExpired`** — uncaught exception leaks
- ❌ **FileNotFoundError from subprocess with cryptic errno** — wrap with helpful "install via X" message
- ❌ **MCP `isError=True` swallowed silently** — check `result.isError` first
- ❌ **`verify || true` in install script** — masks verify failure, defeats self-verify purpose
- ❌ **`peer_clone` without checking `.git/HEAD`** — broken clone passes check
- ❌ **opencode.json edit without atomic write** — corruption on kill/disk-full
- ❌ **Hardcoded `>=15` tool count check** — fragile to upstream tool changes
- ❌ **Issue body without "Out of scope"** — scope creep guaranteed
- ❌ **PR with mixed concerns (feat + unrelated fix)** — split commits
- ❌ **Merge without `delete-branch`** — leaves stale branches
- ❌ **Skip manual architecture review after subagent reviewer pass** — subagents miss architecture errors
- ❌ **TDD violation: implement without failing test first** — even for "tiny" SHOULD FIX

## 15. When in doubt, ask

If you're unsure about:
- Tool type (MCP vs CLI) — check upstream README
- Calling pattern — see rule #1 table
- Whether to extract a helper — wait for 3+ callers
- Whether to defer to v0.4.0 — yes, defer
- Issue scope — write tighter AC + longer "Out of scope"

Don't guess. Don't assume. Check the rules first.

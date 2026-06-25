# Contributing

Thanks for considering a contribution to documents-kit-skills. This toolkit helps people write documents with AI assistance while avoiding AI slop.

## Principles

1. **Skills follow write-a-skill principles**:
   - Description includes triggers ("Use when [specific keywords]")
   - SKILL.md under 500 lines (split into REFERENCE.md if larger)
   - No time-sensitive info
   - Consistent terminology
   - Concrete examples
   - References one level deep
   - Deterministic work in `scripts/`, not in skill prose

2. **Cross-skill references by name, not path**:
   ```markdown
   See **drawio-skill** for diagram generation
   ```
   NOT
   ```markdown
   See [drawio-skill](~/.config/opencode/skills/drawio/SKILL.md)
   ```

3. **Cross-skill utility tools in `tools/`**:
   - `doc-audit-pipeline.sh` — all audits
   - `asset-validator.sh` — check referenced assets
   - `pdf-from-docx.sh` — proper PDF export
   - If a script is used by 2+ skills, it goes in `tools/`

4. **Skill-specific utility scripts in `skills/<name>/scripts/`**:
   - `skills/document-writing/scripts/detection-audit.sh` — anti-AI check
   - `skills/drawio/scripts/` — diagram-related

5. **Presets and templates are data, not code**:
   - `presets/material-light.json` — design tokens
   - `templates/ipb-ppki.docx` — format template
   - Update without touching skill logic

## Adding a new skill

1. Create `skills/<name>/` with `SKILL.md` and `REFERENCE.md`
2. Add to `install.sh` SKILLS array
3. Update `README.md` skills table
4. Document cross-skill references in `docs/ARCHITECTURE.md`
5. Test with `opencode run` in a real conversation

## Adding a new tool

1. Create `tools/<tool>.sh` with proper shebang and `set -euo pipefail`
2. Make executable: `chmod +x tools/<tool>.sh`
3. Add to `README.md` if user-facing
4. Document in `docs/QUICKSTART.md` or `docs/COMMON_TASKS.md`
5. Add to `install.sh` if it should be globally available

## Adding a new preset

1. Create `presets/<name>.json` with the schema from existing presets
2. Document in `docs/STYLE_PRESETS.md`
3. Reference in `drawio` or `document-writing` skill if used

## Testing

Before submitting a PR:
```bash
# Test install
./install.sh --dry-run

# Test detection-audit
./skills/document-writing/scripts/detection-audit.sh examples/hackathon-proposal/proposal.md

# Test fix-pandoc-leaks (use a copy of test docx)
cp examples/test.docx /tmp/test.docx
./skills/document-writing/scripts/fix-pandoc-leaks.sh /tmp/test.docx --all
```

## Style

- Code: 2-space indent, no tabs
- Markdown: ATX headings (`#`), not Setext (`===`)
- Bash: `set -euo pipefail`, descriptive variable names
- Comments: only when explaining WHY, not WHAT

## License

By contributing, you agree that your contributions will be licensed under MIT License.

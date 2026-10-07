## Atomic Commit Spec

**Intent:** Create `.claude/docs/behaviour-context.md` and wire it into apply.md, trimming the inline behaviour format block.

**Changes:**
- [ ] Create `.claude/docs/behaviour-context.md` covering: `behaviours/` directory structure (feature-scoped, one file per domain); `## Behaviour: <feature name>` header format; scenario structure (`### <scenario name>` with `**Given:**`, `**When:**`, `**Then:**` lines); read existing file before writing to avoid duplicates
- [ ] Add `@.claude/docs/behaviour-context.md` to `apply.md` alongside the existing `@.claude/docs/spec-context.md` reference, before `## Entry`
- [ ] Remove the fenced behaviour format template from `apply.md` step 2 (the markdown block showing `## Behaviour:` / Given/When/Then) — keep the procedural instruction to create or update files for each feature touched

**Out of scope:**
- stack-context.md (separate proposal)
- Any changes to propose.md, merge.md, or stack.md
- Changes to behaviours/ files themselves

**Done when:**
- `.claude/docs/behaviour-context.md` exists and covers the full format
- `apply.md` has the `@` reference before `## Entry`
- The fenced behaviour format block is gone from `apply.md` step 2
- `/at:apply` still produces correctly-formatted behaviour files

**Assumptions:**
- `.claude/docs/` already exists from the previous commit
- apply.md currently has `@.claude/docs/spec-context.md` before `## Entry` — behaviour-context goes on the line after it

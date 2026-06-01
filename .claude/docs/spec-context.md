`atomic/spec.md` is the ephemeral commit plan — it is never committed to git and is removed by `atomic commit` at merge time.

**Format:**

```markdown
## Atomic Commit Spec

**Intent:** one sentence describing what this commit does

**Changes:**
- [ ] specific thing to change
- [ ] specific thing to change

**Out of scope:**
- things explicitly not being touched

**Done when:**
- acceptance criteria (testable)

**Assumptions:**
- what this commit assumes about current codebase state
```

**Pipeline state** is derived from spec.md and read via `atomic status`:

| State | Condition |
|-------|-----------|
| `none` | spec.md does not exist |
| `proposed` | spec.md exists, all items are `[ ]` |
| `applying` | spec.md exists, some items are `[X]` |
| `ready` | spec.md exists, all items are `[X]` |

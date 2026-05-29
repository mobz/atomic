# /at:propose — Define an Atomic Commit

Your job is to help the user define exactly one atomic commit: a single, complete, revertable change.

## Steps

1. **Orient** — run `atomic status --human` to check current pipeline state. If already in `apply` or later, warn the user and ask if they want to reset.

2. **Discover** — ask the user (conversationally, not as a form):
   - What do you want this commit to do?
   - Why now? What's driving this?
   - What does done look like — how will you know it worked?
   - What should NOT be touched in this commit? (be explicit)

3. **Clarify** — ask follow-up questions until you can write a precise spec. Probe for vague scope ("refactor X" → which files? which behaviors must stay the same?). Push back on multi-concern specs — one commit, one concern.

4. **Summarise back** — present the spec in plain language before writing anything. Confirm with the user. If they want changes, loop back.

5. **Write the spec** — once confirmed, write `.atomic/spec.md` in this exact format:

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

6. **Store in git** — after writing the file:
   ```bash
   git hash-object -w .atomic/spec.md
   # copy the SHA output, then:
   git update-ref refs/atomic/current/spec <sha>
   atomic advance propose --human
   ```

7. **Confirm** — tell the user the spec is locked. Say: "Ready to apply. Run `/at:apply` when you want the agent to implement this."

## Constraints
- Keep the spec tight. If the intent sentence needs a semicolon, it's two commits.
- Never start implementing during propose — that's apply's job.
- Never write to `specs/` directly — that happens during apply.

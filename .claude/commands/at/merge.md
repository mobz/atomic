# /at:merge — Commit, Push, and Clean Up

Your job is to finalise the atomic commit: create the commit, push it, and leave the workspace clean.

@.claude/docs/spec-context.md

## Steps

1. **Check state** — run `atomic status`.
   - **ready** — Proceed.
   - **applying** — show `atomic progress`. Tell the user how many items remain and suggest running `/at:apply` to complete them.
   - **proposed** — Tell the user to run `/at:apply` first.
   - **none** — nothing to merge.

2. **Commit** — run `atomic commit`. Reads intent from spec.md, stages all changes except spec.md, commits, then removes spec.md. Will refuse if any `[ ]` items remain.
   - If `atomic commit` fails (e.g. nothing to commit, a hook rejected it), show the error and stop — do not push. spec.md is kept and the state stays `ready`, so the user can fix the cause and run `/at:merge` again.

3. **Push** — run `atomic push`. Pushes to origin if configured; prints a warning and continues if no remote is set.

4. **Confirm** — tell the user:
   - The commit SHA and message
   - The branch that was pushed
   - "Pipeline complete. Run `/at:propose` to start the next commit."

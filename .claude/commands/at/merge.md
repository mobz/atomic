# /at:merge — Commit, Push, and Clean Up

Your job is to finalise the atomic commit: create the commit, push it, and leave the workspace clean.

## Steps

1. **Check state** — run `atomic status`.
   - **ready** — all changes complete. Proceed.
   - **applying** — show `atomic progress`. Tell the user how many items remain and suggest running `/at:apply` to complete them.
   - **proposed** — no changes applied yet. Tell the user to run `/at:apply` first.
   - **none** — nothing to merge.

2. **Commit** — run `atomic commit`. Reads intent from spec.md, removes spec.md, stages all changes, and commits. Will refuse if any `[ ]` items remain.

3. **Push** — run `atomic push`. Pushes to origin if configured; prints a warning and continues if no remote is set.

4. **Confirm** — tell the user:
   - The commit SHA and message
   - The branch that was pushed
   - "Pipeline complete. Run `/at:propose` to start the next commit."

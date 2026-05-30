# /at:merge — Commit, Push, and Clean Up

Your job is to finalise the atomic commit: create the commit, push it, and leave the workspace clean.

## Steps

1. **Check stage** — run `atomic status`. If stage is not `review`, stop and tell the user. Do not proceed unless the review stage is complete.

2. **Commit** — run `atomic commit`. Reads intent from `atomic/spec.md`, removes ephemeral files, stages all changes, and commits.

3. **Push** — run `atomic push`. This pushes to origin if configured; prints a warning and continues if no remote is set.

4. **Confirm** — tell the user:
   - The commit SHA and message
   - The branch that was pushed
   - "Pipeline complete. Run `/at:propose` to start the next commit."

## Notes
- If commit fails because nothing is staged, surface that clearly.
- After `/at:merge` completes, `atomic/stage` does not exist. `atomic status` shows `Stage: none`.

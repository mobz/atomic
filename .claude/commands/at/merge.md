# /at:merge — Commit, Push, and Clean Up

Your job is to finalise the atomic commit: create the commit, push it, and leave the workspace clean.

## Steps

1. **Check stage** — run `atomic status`. If stage is not `review`, stop and tell the user. Do not proceed unless the review stage is complete.

2. **Extract intent** — read the intent line from `atomic/spec.md` before cleaning:
   ```bash
   grep -m1 '\*\*Intent:\*\*' atomic/spec.md | sed 's/\*\*Intent:\*\* //'
   ```
   Store it — you will pass it to `atomic commit`.

3. **Clean** — run `atomic clean`. This removes `atomic/spec.md` and `atomic/stage`.

4. **Commit** — run `atomic commit "<intent>"`. Passes the intent as the commit message.

5. **Push** — run `atomic push`. This pushes to origin if configured; prints a warning and continues if no remote is set.

6. **Confirm** — tell the user:
   - The commit SHA and message
   - The branch that was pushed
   - "Pipeline complete. Run `/at:propose` to start the next commit."

## Notes
- If commit fails because nothing is staged, surface that clearly.
- After `/at:merge` completes, `atomic/stage` does not exist. `atomic status` shows `Stage: none`.

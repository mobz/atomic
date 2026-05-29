# /merge — Commit, Push, and Clean Up

Your job is to finalise the atomic commit: create the commit, push it, and leave the workspace clean.

## Steps

1. **Check stage** — run `atomic status --human`. If stage is not `review`, stop and tell the user. Do not proceed unless the review stage is complete.

2. **Commit** — run `atomic commit --human`. This stages all changes and creates a commit whose message is the **Intent** line from `.atomic/spec.md`.

3. **Push** — run `atomic push --human`. This pushes the current branch to origin.
   - If the push fails (no remote, no upstream): tell the user clearly — don't silently fail. Suggest: `git remote add origin <url>` and then run `/merge` again.

4. **Clean** — run `atomic clean --human`. This clears `.atomic/` working state.

5. **Advance** — run `atomic advance merge --human`.

6. **Confirm** — tell the user:
   - The commit SHA and message
   - The branch that was pushed
   - "Pipeline complete. Run `/propose` to start the next commit."

## Notes
- If commit fails because there's nothing to commit, surface that clearly — the user may have forgotten to make changes, or changes may already be committed.
- Never amend commits — always create new ones.
- After `/merge` completes, the pipeline is in a clean state ready for the next `/propose`.

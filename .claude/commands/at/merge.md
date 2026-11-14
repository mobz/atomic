# /at:merge — Commit, Push, and Clean Up

Your job is to finalise the atomic commit: create the commit, push it, and leave the workspace clean.

@.claude/docs/spec-context.md
@.claude/docs/interaction-context.md

## Steps

1. **Check state** — run `atomic status`.
   - **ready** — Proceed.
   - **applying** — show `atomic progress` and how many items remain, then end with `Next: /at:apply — complete the remaining items`.
   - **proposed** — nothing is implemented yet. End with `Next: /at:apply — implement this spec`.
   - **none** — nothing to merge. End with `Next: /at:propose — define the next commit`.

2. **Commit** — run `atomic commit`. Reads intent from spec.md, stages all changes except spec.md, commits, then removes spec.md. Will refuse if any `[ ]` items remain.
   - If `atomic commit` fails (e.g. nothing to commit, a hook rejected it), show the error and stop — do not push. spec.md is kept and the state stays `ready`. End with `Next: /at:merge — retry once the cause is fixed`.

3. **Push** — run `atomic push`. Pushes to origin if configured; prints a warning and continues if no remote is set.

4. **Hand off** — tell the user:
   - The commit SHA and message
   - The branch that was pushed
   - Then end with `Next: /at:propose — define the next commit`.

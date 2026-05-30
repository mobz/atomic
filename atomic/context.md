## Codebase Context

**State after "spec.md state machine" commit:**

- Pipeline state is derived entirely from spec.md checkbox state: no file=none, all [ ]=proposed, mixed=applying, all [X]=ready.
- `atomic advance` command removed entirely — no stage file.
- `spec_state()` and `spec_counts()` in helpers.sh derive state from spec.md.
- `atomic status` shows State + Intent + Progress (M/N changes complete).
- `atomic progress` prints M/N changes complete (or "No active spec").
- `atomic commit` refuses if any [ ] items remain in spec.md.
- `atomic clean` removes only spec.md (no stage file).
- `atomic reset` deletes all files except .gitkeep via find.
- `/at:apply` marks items [X] as implemented; triggers summary when all [X]; rollback resets [X]→[ ] and does git reset --hard HEAD.
- `/at:propose` handles all four states (none/proposed/applying/ready) gracefully.
- `/at:merge` checks state before proceeding; simplified to commit + push.
- Each command in bin/lib/atomic-{status,progress,reset,show-spec,show-context,merge-specs,commit,push,clean,help}.
- atomic push degrades gracefully — no origin = warning + exit 0.
- No real test suite yet — npm test is a placeholder.

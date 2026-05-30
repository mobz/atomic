## Codebase Context

**State after "self-contained atomic commit" commit:**

- `atomic commit` is self-contained: reads intent from spec.md, removes spec.md + stage, git add -A, git commit.
- No external intent extraction or separate clean step needed in any merge path.
- Approve path in /at:apply: `atomic commit && atomic push` — two commands.
- `atomic clean` still exists for clearing state without committing.
- `bin/atomic` dispatch: `commit) cmd_commit ;;` — no args passed.
- `/at:apply` owns the full loop: implement → specs → test → inline review → merge or loop.
- `/at:review` does not exist.
- `atomic/` is tracked in git. Ephemeral: spec.md, stage. Persistent: context.md, delta.md.
- `atomic/spec.md` and `atomic/stage` are untracked (never committed), so `git reset --hard HEAD` preserves them.
- Each command in `bin/lib/atomic-{status,advance,reset,show-spec,show-context,merge-specs,commit,push,clean,help}`.
- `atomic push` degrades gracefully — no origin = warning + exit 0.
- No real test suite yet — `npm test` is a placeholder.

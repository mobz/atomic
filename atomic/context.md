## Codebase Context

**State after "apply loop + inline review" commit:**

- `/at:apply` owns the full loop: implement → specs → test → inline review → merge or loop.
- `/at:review` no longer exists — review is integrated into `/at:apply`.
- `/at:merge` still exists as a standalone command but is called inline by `/at:apply` on approve.
- The loop advances internally: "apply" during implementation, "review" before showing summary. This satisfies `/at:merge`'s stage precondition.
- On approve: extract intent from spec.md → `atomic clean` → `atomic commit "$intent"` → `atomic push`.
- On rollback: `git reset --hard HEAD` + `atomic reset`.
- On "start over": `git reset --hard HEAD` + `atomic advance apply` (spec survives — untracked).
- On discuss: adjust in place, update spec if scope changes, `atomic advance apply`, loop.
- `atomic/spec.md` and `atomic/stage` are untracked (never committed), so `git reset --hard HEAD` preserves them.
- `atomic/` is tracked in git. Ephemeral: spec.md, stage. Persistent: context.md, delta.md.
- `atomic commit "<message>"` takes message as first argument; refuses if spec.md or stage exist.
- `bin/atomic` dispatch: `commit) cmd_commit "${ARGS[@]:-}" ;;`
- Each command in `bin/lib/atomic-{status,advance,reset,show-spec,show-context,merge-specs,commit,push,clean,help}`.
- No real test suite yet — `npm test` is a placeholder.

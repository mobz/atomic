## Codebase Context

**State after "tracked atomic/ directory" commit:**

- `atomic/` is tracked in git (no leading dot, not gitignored). Contains `.gitkeep`.
- **Ephemeral files (never committed):** `atomic/spec.md`, `atomic/stage` — `atomic clean` removes only these.
- **Persistent files (committed):** `atomic/context.md`, `atomic/delta.md` — part of every commit.
- `atomic reset` removes all files except `.gitkeep` using `find -mindepth 1 -not -name .gitkeep -delete`.
- `atomic commit "<message>"` — takes message as first argument; refuses if spec.md or stage exist.
- Merge flow: read intent from spec → `atomic clean` → `atomic commit "<intent>"` → `atomic push`.
- `bin/atomic` dispatch passes `"${ARGS[@]:-}"` to `cmd_commit` for the message argument.
- `bin/lib/helpers.sh` — `current_stage`, `output_json`, `require_git`, `require_atomic_dir`.
- Each command in `bin/lib/atomic-{status,advance,reset,show-spec,show-context,merge-specs,commit,push,clean,help}`.
- `atomic push` degrades gracefully — no origin = warning + exit 0.
- Slash commands in `.claude/commands/at/` as `/at:propose`, `/at:apply`, `/at:review`, `/at:merge`.
- `/at:propose` accepts optional `$ARGUMENTS` to skip discovery.
- No real test suite yet — `npm test` is a placeholder.

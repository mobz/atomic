# Commit consistency

Every artefact that must agree with the code at every commit. `/at:apply` checks each change against this list.

- `atomic/consistency.md` — this file; maintained as commands, components, docs, and artefacts are added, renamed, or removed
- `bin/atomic` + `bin/lib/atomic-*` — every command file is sourced and dispatched in `bin/atomic`
- `bin/lib/atomic-help` — one line per dispatched command
- `bin/lib/atomic-init` — the manifest template matches the format in `.claude/docs/consistency-context.md`
- `README.md` — Pipeline table matches `.claude/commands/at/`; CLI reference matches `atomic help`; Structure tree matches the layout; Behaviours and State sections match `.claude/docs/behaviour-context.md` and `.claude/docs/spec-context.md`
- `CLAUDE.md` — pipeline stages and Slash Commands table match `.claude/commands/at/`; Key Paths match `atomic/` and `behaviours/`; hard rules match the commands' constraints
- `.claude/docs/*-context.md` — each format matches what the commands and CLI read and write (e.g. `spec-context.md` states match `spec_state` in `bin/lib/helpers.sh`)
- `.claude/commands/at/*.md` — "Step N" references point at the right steps; `@` includes point at existing files; CLI commands they call exist
- `behaviours/*.md` — scenarios describe the current behaviour of every touched command and feature
- `package.json` — description matches the pipeline; `test` script (no test suite yet — list tests here when added)

# atomic — notes for developing atomic itself

`CLAUDE.md` is generic: it is what `atomic init` copies into other repos. Guidance that only applies to this repo — atomic's own source — lives here. `atomic init` never copies this file.

- **This repo dogfoods itself** — `atomic` is built using `atomic`. The `/at:*` commands, `.claude/docs/`, and `CLAUDE.md` are both the pipeline this repo runs on and the starting point `atomic init` installs elsewhere. Keep them free of text specific to this repo; put that here instead.
- **Running the CLI** — `atomic` on PATH, or `bin/atomic` from the repo root.
- **Portability** — the CLI must run on macOS's Bash 3.2 and BSD tools: no `readlink -f`, no `mapfile`, `sed -i ''`, and guard empty arrays under `set -u` (`${arr[@]+"${arr[@]}"}`).
- **Testing** — there is no test suite yet (`npm test` prints a placeholder). Verify CLI changes by hand in scratch git repos (fresh, re-run, mid-apply), and never in this repo's own working tree.
- **Plan commits ahead of tooling** — planning edits the CLI can't yet commit (anything but a plain append via `atomic stack-add`) may be committed by hand as `Plan: <summary>`, only after the user has reviewed the exact change and approved it. This exception exists because this repo is ahead of its own tooling.

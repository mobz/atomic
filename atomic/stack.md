Stack: Pipeline cleanup and hardening
As a developer using atomic, I want the docs, CLI, and /at:* commands to match how the pipeline actually works — shared format context, accurate entry states and behaviours, safe failure paths, and clear rules for how the stack is committed — so that each command can be followed exactly without hitting stale or contradictory instructions.

===========
Proposal: Install atomic's Claude Code files into a repo — `.claude/commands/at/`, `.claude/docs/`, and a CLAUDE.md section
Deferred from propose: split off from `atomic init` (the scaffold of `atomic/`). This is the distribution question: how a repo gets the `/at:*` commands and their `@`-included docs from atomic's install directory (`$SCRIPT_DIR/..`). Decide copy vs symlink, how updates reach an installed repo (re-run overwrites atomic-owned files only? version stamp?), and how the CLAUDE.md section is added without clobbering an existing CLAUDE.md (append a marked block, skip if present). Likely an `atomic init` extension or flag. Behaviours, README Quick Start, help.

===========
Proposal: Add `/at:init` — run `atomic init`, survey the repo, and propose the real `atomic/consistency.md` entries for approval
Deferred from propose: split off from `atomic init`. Bash writes only the manifest template; listing a repo's real artefacts (README, docs, tests, CI, infra, schemas, migrations, generated files) needs judgement. The command surveys the repo, drafts one bullet per artefact in the format of `.claude/docs/consistency-context.md`, shows them, and writes only what the user approves. Depends on the install proposal above (the command must exist in the target repo). Behaviours: a new `pipeline-init.md`; CLAUDE.md and README command tables.

===========
Proposal: Make CLI error output follow `--json` consistently
Deferred from apply: while making `atomic commit` keep spec.md on a failed commit, found that no command switches its error output on `--json`, so errors are inconsistent — plain text regardless of `--json` (`atomic commit` incomplete spec and the new "commit failed — atomic/spec.md kept" error, `atomic start-over` no active spec) vs always-JSON regardless of `--json` (`atomic show-spec` no spec, `require_git` in `helpers.sh`, unknown command in `bin/atomic`). The README promises "Add --json to any command for machine-readable output".

Approach: one shared helper in `bin/lib/helpers.sh` (e.g. `die <message>`) that prints `{"ok":false,"error":"<message>"}` when `--json` is set and `error: <message>` otherwise, both to stderr, then exits 1; replace the five error sites above with it. Note `require_git` and the unknown-command path may run before or regardless of `--json` parsing — check ordering in `bin/atomic`.

Consistency: update the error scenarios in `behaviours/cli-atomic.md` (reset/show-context removed, show-spec no spec, commit incomplete / failed, start-over no spec) and the README's `--json` note.

===========
Proposal: Standardise the user interaction pattern — every formal review point ends with a fixed, specifically worded choice
Today the commands hand control back to the user in inconsistent ways: `/at:apply`'s summary ends with a fixed block (**Approve** / **Rollback** / "Or tell me what to change"), but `/at:propose` step 4 just says "Confirm with the user" (in practice a free-form "Should I write it?"), the propose entry states use inline lists ("Ask: proceed with this, modify it, or start fresh…", "review it, change it, or start fresh?"), `/at:stack` step 6 ends "Stack written. Run `/at:propose`… or ask me to make an adjustment", the rollback deferral re-add is "ask whether to add any back", and wrong-state handoffs either "tell the user to run" or "suggest running" a command. The user cannot tell at a glance whether they are at a gate, what words the agent will act on, or what each choice does.

Design:
- Distinguish three kinds of hand-back and give each one fixed shape:
  - **Review point** (a gate: the agent will act on the answer — write the spec, write the stack, merge, roll back, re-add deferrals, resume an in-progress pipeline): ends with a choice block in the same form as apply's —
    ```
    > **<Verb>** — <what happens>
    > **<Verb>** — <what happens>
    > Or tell me what to change
    ```
    Bold single-word verbs the user can type back; each line says exactly what the agent will do; "Or tell me what to change" (discuss) is always last and always implied. The agent acts only on a clear choice; anything else is discuss.
  - **Handoff** (the stage is done, or the state is wrong for this command): one fixed line, e.g. `Next: /at:apply — implement this spec`; no question.
  - **Clarifying question** (during discovery/explore): free-form, but never used for a gate.
- Candidate review points and verbs (decide during propose):
  - `/at:propose` entry from the stack: **Proceed** / **Modify** / **Fresh**; entry in `proposed` / `applying` / `ready`: e.g. **Review** / **Continue** / **Fresh** (with `atomic clean`).
  - `/at:propose` step 4 (summarise back): **Write** — write the spec and pop the stack.
  - `/at:apply` step 5: **Approve** / **Rollback** (unchanged — the reference pattern).
  - `/at:apply` rollback: deferral re-add — **Re-add** <which> / **Drop**.
  - `/at:stack` entry (stack exists): **Extend** / **Fresh**; step 6: **Write** — write `atomic/stack.md`.
  - Stack-only "Plan:" commits made outside the pipeline (current practice in this repo): **Commit** — commit and push the stack change — after showing the diff.
- Handoffs to convert: propose step 7, merge step 4 and its wrong-state branches, apply `none` entry and rollback's "Run `/at:propose`", stack step 6's tail.
- Put the pattern in a shared doc (e.g. `.claude/docs/interaction-context.md`) injected into all four commands, so each command lists only its own choices; add the doc to `atomic/consistency.md` and add a manifest entry that every review point uses the choice block.
- Behaviours: update the scenarios that quote today's wording (`pipeline-propose.md` entry/summarise/confirm, `pipeline-stack.md`, `pipeline-apply.md` rollback re-add, `pipeline-merge.md` wrong-state entries) and add a `command-context.md` scenario for the injected doc.
- Possible split: (1) the shared doc + `/at:propose`, the most-used gate; (2) `/at:stack`, `/at:merge`, rollback re-add, and handoffs. Decide during propose.

===========
Proposal: Decide whether `atomic commit` refuses when there is no `atomic/spec.md`
Deferred from propose: split off from wiring `atomic stack-add` into `/at:stack` and CLAUDE.md (a CLI behaviour change, a separate concern). With no spec, `atomic commit` falls back to message "atomic commit" and `git add -A` — the path that sweeps stray edits (e.g. hand-edited stack additions) into vague commits. Options: refuse with an error pointing at `/at:propose` or `atomic stack-add`; or keep the fallback. Update `cli-atomic.md` "commit — no spec", help, README, and `merge.md` if it changes.

===========
Proposal: Decide how planning edits other than a plain append are committed — rewriting, reordering, removing, and moving proposals between `atomic/stack.md` and `atomic/stacks/*`
Deferred from propose: split off from wiring `atomic stack-add` into `/at:stack`. `atomic stack-add` only appends one block to the end of `atomic/stack.md`; every other planning edit has no committed path. A `/at:stack` "start fresh" or "replace" rewrite in state `none` currently rides along with the first spec's commit (via `git add -A`), mixing planning into that commit; moving a proposal to a parked stack (e.g. the critic spike to `atomic/stacks/research.md`) needed a one-off hand `Plan:` commit. Options: an `atomic stack-replace` CLI that commits a new file as `Plan: <stack name>` (state `none` only); a general `atomic plan-commit` that commits only `atomic/stack.md` and `atomic/stacks/*` from a reviewed working-tree change (state `none` only, since mid-apply the stack also holds the pop and deferrals); or `stack-move`/`stack-remove` commands built like `stack-add` (from HEAD in a temporary index). Keep the review step: show the exact change and get approval before committing.

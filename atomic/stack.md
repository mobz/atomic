Stack: Pipeline cleanup and hardening
As a developer using atomic, I want the docs, CLI, and /at:* commands to match how the pipeline actually works — shared format context, accurate entry states and behaviours, safe failure paths, and clear rules for how the stack is committed — so that each command can be followed exactly without hitting stale or contradictory instructions.

===========
Proposal: Measure whether an adversarial diff critic, steered by a per-repo commit-consistency manifest, closes the "ticked but not done" gap in `/at:apply`
**Not ready for implementation — a spike.** Harness: `../atomic-experiments/preamble` (fixture, scenarios, variants, runners, judge, `analyze.py`; results in `runs/`).

**Findings so far (atomic df6d3bf, Opus, ~5 runs per cell, headless `claude -p`):**
- `/at:propose` is at ceiling. Baseline judged good on 30/30 across six scenarios (explicit bundle, implicit bundle, horizontal-slice trap, storage migration, breaking rename, single-concern control) — hand-checked: splits are vertical, the control is not split, migration risks are raised, incidental issues are deferred. A preamble ("senior engineer who ships atomic commits…") made no measurable difference. A propose-stage adversarial critic (`spec-critic` agent) made no measurable difference at ~1.8x cost, and tended to write split-offs into the spec instead of the stack. The preamble hypothesis is dropped.
- `/at:apply` scope is fine after the df6d3bf rule rewording: unstated README/test/behaviour updates are made 5/5, planted incidental issues (help typo, duplicated helper) are left alone 5/5.
- The remaining failure is **ticked but not done**: in `apply-title-length` the baseline raises the limit and ticks the item, but the planted `truncate` off-by-one makes titles 61 characters, failing Done-when — 0/5. An adversarial `diff-critic` agent run before the summary (unrelated change / stale or untested / not done, incl. edge cases) fixed it 3/5, never hurt precision, at ~1.7x cost ($0.50 vs $0.30 API-equivalent per run).

**New idea to test — a commit-consistency manifest as steering.** A committed, per-repo file (`atomic/consistency.md`, format in `.claude/docs/consistency-context.md`) itemising every artefact that must stay consistent with the code at every commit: README, docs, help text, tests, behaviours, infra, CI, DB schema/migrations, generated files, examples, changelog — whatever the repo has, with what in each must agree (e.g. "README CLI reference must match `atomic help`"). **The first item is the file itself:** it must be updated when a change adds a new command, component, function family, doc, or artefact that must stay in step (and entries removed when the thing goes). The critic checks the diff against each item instead of guessing what "stale" means in this repo; apply itself may read it too.

**Harness work needed (the fixture is too simple to show a manifest's value):**
- Add non-obvious consistency artefacts to the fixture that a generic "tests/README/behaviours" reading misses: e.g. a shell completion file listing commands, a `docs/` man-style page, a JSON schema for `todo.json`, a CHANGELOG, an example config, a data-format version/migration step.
- New apply scenarios where a reasonable spec silently invalidates one of them (add a command → completions + man page; add a field → schema + migration; rename a flag → completions, docs, changelog), plus at least one more edge-case Done-when trap like `title-length`, so "not done" isn't measured on a single bug.
- A manifest-maintenance scenario: the change adds a new artefact (e.g. a new docs page or a new subcommand family) — does the manifest get its own entry updated?
- Keep a control where the manifest lists items the change does not touch — check it doesn't cause drive-by edits.

**Variants (apply):** baseline; manifest only (apply step reads it); verify wording only ("before ticking, check each Done-when with an actual command, including boundaries"); `diff-critic`; `diff-critic` + manifest; verify wording + manifest. Score stale-artefact misses, Done-when failures, unrelated changes, manifest self-update, and cost. Drop `title-length`/`newest` cells already at ceiling once the new scenarios exist. Headless runs use the claude.ai plan's 5-hour limit (~60–100 runs per window) — batch per scenario, runners skip valid runs and stop on the limit.

**Decision this spike feeds:** whether atomic adds the critic, the verify wording, or both on top of the manifest (`atomic/consistency.md`, now in atomic — refresh the fixture to pick up its format doc and apply wiring), and whether the manifest's wiring needs changing.

===========
Proposal: Add `atomic init` to set up atomic in a repo, including a template `atomic/consistency.md`
Deferred from propose: while specifying the commit-consistency manifest, found that a repo gets a manifest only by someone writing one. No init or install mechanism exists today (the CLI, README, and commands have none; the experiment fixture was set up by copying files in by hand).

Design considerations:
- What else init creates: `atomic/` (with `.gitkeep`), a `stack.md` header, possibly `.claude/commands/at/`, `.claude/docs/`, and a starting CLAUDE.md — i.e. this is the question of how atomic is installed into another repo.
- Bash can write only the manifest template (header + self-entry, per `.claude/docs/consistency-context.md`). Listing the repo's real artefacts (README, tests, infra, schemas, CI) needs judgement — the agent fills it in afterwards, or init is (partly) a `/at:init` slash command.
- Re-running init on an initialised repo must not clobber an existing manifest or stack.
- Behaviours: `cli-atomic.md` scenarios for a fresh repo and a re-run; README CLI reference and Quick Start; `atomic help`.

===========
Proposal: Have `/at:propose` read `atomic/consistency.md` when writing a spec's Changes list
Deferred from propose: while specifying the commit-consistency manifest, `/at:propose` reading it was considered and left out. Propose was already at ceiling in the preamble spike (complete specs, unstated docs/tests included), and `/at:apply` completes the concern from the manifest regardless. Revisit after the critic spike: add it only if specs that omit manifest artefacts cause problems apply does not catch (e.g. a Done-when that misses a listed artefact).

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
Proposal: Decide how a `/at:stack` "start fresh" or "replace" rewrite of `atomic/stack.md` is committed
Deferred from propose: split off from wiring `atomic stack-add` into `/at:stack`. A rewritten stack in state `none` currently rides along with the first spec's commit (via `git add -A`), mixing planning into that commit. Options: an `atomic stack-replace` CLI that commits the new file as `Plan: <stack name>` (state `none` only); or have `/at:stack` require committing the rewrite immediately via an existing command. Keep the review step: show the full stack and get approval before committing.

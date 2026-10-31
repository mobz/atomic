Stack: Pipeline cleanup and hardening
As a developer using atomic, I want the docs, CLI, and /at:* commands to match how the pipeline actually works — shared format context, accurate entry states and behaviours, safe failure paths, and clear rules for how the stack is committed — so that each command can be followed exactly without hitting stale or contradictory instructions.

===========
Proposal: State that stack additions discovered during a commit's work are committed with that commit
Deferred from discussion of stack-commit semantics. Rule: a commit = stack removals (the pop) + stack additions discovered while doing that commit's work + behaviour changes + code changes. Today this is implicit for apply deferrals (they ride along via `git add -A`) and undefined for propose splits.

Definition to introduce (the term is used in apply.md — "Deferred items", "Deferred from apply:" — but never defined):

> **Deferral:** a Proposal block for work discovered while preparing or doing the active spec (during `/at:propose` or `/at:apply`) that is outside its scope. Deferrals are part of that spec's story and are committed with the spec's commit. A proposal **unrelated** to the active spec's work is not a deferral — it is **planning**, and is committed on its own via the stack-add path, whatever the pipeline state.

The boundary is "did this come out of the active spec's work?", not "is a spec active?" — you can add unrelated items mid-apply without them riding along in the spec's commit. Widen the block format's source line to `Deferred from propose:` / `Deferred from apply:`. Decide where the definition lives: `CLAUDE.md`, or the planned `.claude/docs/stack-context.md` if that has landed by then (it is the natural home for stack format and semantics).

- `apply.md` step 1: state that deferred Proposal blocks are part of this apply's commit (and are listed in the summary's Deferred items, which already exists).
- `propose.md` step 3 says "suggest adding them to the stack" without saying who writes them or when. Define it: when the user accepts a split, step 6 writes the split-off proposals to the stack alongside the pop (immediately after the Stack: header, i.e. as the next proposals), so they land in this spec's commit.
- Update `CLAUDE.md` Key Paths entry for `atomic/stack.md` to reflect the rule.
- Behaviours: add a propose scenario for "split accepted — split-off proposals written to stack with the pop"; note in pipeline-apply that deferrals are committed with the apply.
- Wording-only for apply; propose gains a defined write. Does not cover `/at:stack` or ad-hoc additions — see the stack-only commit proposal.

===========
Proposal: Add a CLI command that appends an unrelated proposal to the stack and commits it on its own, in any pipeline state
Deferred from discussion of stack-commit semantics. Unrelated stack additions (planning, not deferrals — see the deferral definition proposal) currently get swept into whatever `atomic commit` runs next via `git add -A`. Observed in this repo: `6017fcc` (behaviour-context) also carries four unrelated README/behaviour proposals. You should be able to add an unrelated item at any time — including mid-propose or mid-apply — without it touching the in-progress work, and without the in-progress work leaking into it.

**The command is about adding an item, not committing whatever is in stack.md.** It takes the proposal (intent + body) as input, appends it, and commits only that. Name it for what it does, e.g. `atomic stack-add` (working name `commit-stack` from discussion).

**Why not commit the working-tree stack.md:** mid-apply the working tree's stack.md also contains the pop (top proposal removed) and any deferrals — both belong to the spec's commit, not this one.

**Why not stash → append → commit → stash pop:** tested on a scratch clone. When the in-progress work has also appended a deferral at the end of stack.md, `git stash pop` conflicts on stack.md (both sides append at EOF). It also briefly removes the user's in-progress changes from the working tree.

**Approach (tested on a scratch clone mid-apply — popped top proposal, a deferral at the end, a code change, spec.md present):** build the commit from HEAD without touching the working tree or real index:
```
export GIT_INDEX_FILE=$(mktemp -u); git read-tree HEAD
blob=$( { git show HEAD:atomic/stack.md; printf '%s' "$BLOCK"; } | git hash-object -w --stdin )
git update-index --cacheinfo 100644,$blob,atomic/stack.md
tree=$(git write-tree); rm -f "$GIT_INDEX_FILE"; unset GIT_INDEX_FILE
c=$(git commit-tree "$tree" -p HEAD -m "Plan: <intent>"); git update-ref HEAD "$c"
git reset -q -- atomic/stack.md        # real index entry follows new HEAD
printf '%s' "$BLOCK" >> atomic/stack.md  # mirror the append in the working tree
```
Result: the new commit contains only the appended block (+4 lines); the remaining working-tree diff is exactly the pop + deferral + code change; spec.md untouched.

Design considerations:
- Placement: always the end of the stack (the user's "add to end of stack"). Urgent/prerequisite items are deferrals and go through apply's top-of-stack path instead.
- Input: intent as an argument, body via stdin (or `--body-file`); validate the block (`===========` / `Proposal:` lines) before committing.
- If `atomic/stack.md` does not exist in HEAD: create it from the block (no Stack: header — or require one; decide).
- `atomic/stacks/*` (parked stacks): out of scope unless a `--stack <name>` target is cheap.
- Push: decide whether `stack-add` pushes immediately (via `atomic push`) or leaves it for the next merge. Note that a mid-apply `stack-add` puts a commit between the spec's base and its eventual commit — fine for linear history, but rollback/start-over (`git reset --hard HEAD`) now resets to the plan commit, which is what we want.
- Wiring: `/at:stack` "extend" could append each new proposal via this command; "replace/start fresh" rewrites the whole file and should require no active spec (it would conflict with the pop). Document ad-hoc use in CLAUDE.md.
- Consider whether `atomic commit` with no spec.md should keep its fallback (message "atomic commit", `git add -A`) or refuse — it is the path that currently sweeps stray stack edits into vague commits.
- Expand/contract: adding the CLI command is additive; wiring it into `/at:stack` and CLAUDE.md is the switch. Propose as two commits.
- Behaviours: `cli-atomic.md` scenarios — adds in state `none`; adds mid-apply leaving pop/deferrals/code uncommitted; rejects a malformed block.

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

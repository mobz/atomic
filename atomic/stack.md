Stack: Pipeline cleanup and hardening
As a developer using atomic, I want the docs, CLI, and /at:* commands to match how the pipeline actually works — shared format context, accurate entry states and behaviours, safe failure paths, and clear rules for how the stack is committed — so that each command can be followed exactly without hitting stale or contradictory instructions.

===========
Proposal: Remove `atomic/context.md` from the repository

`atomic/context.md` is a hand-maintained codebase summary updated during each apply. Its purpose — giving Claude orientation at the start of a session — is better served by Claude reading the actual codebase and git history directly. The file is easy to get out of sync, adds a maintenance burden to every apply, and may give Claude false confidence in stale information.

Design considerations:
- The file is currently referenced by `atomic show-context` and read at the start of `/at:apply`. Both references need to be removed or redirected.
- `atomic show-context` command (`bin/lib/atomic-show-context`) would need to be removed or repurposed.
- The dispatch entry in `bin/atomic` for `show-context` would be removed.
- `/at:apply` currently runs `atomic show-context` on entry — this instruction would be replaced with guidance to orient via `git log`, `bin/atomic status`, and direct file reading.
- `atomic/context.md` itself is committed and tracked — removal requires a `git rm`.
- Consider whether `atomic/.gitkeep` needs updating if context.md was the only non-ephemeral content driving the directory's existence (stack.md also lives there, so .gitkeep remains necessary).

This is an expand/contract candidate: the switch proposal removes the `show-context` call from apply.md and the remove proposal deletes the file and command — but given there is no parallel implementation to migrate to, a single commit removing the file, command, and apply.md reference is probably appropriate.

Why remove rather than formalise: every other atomic artefact has a defined format and purpose (`spec-context.md`, `stack-context.md`, `behaviour-context.md`); `context.md` has neither, and its "update with anything learned" rule makes it an append-only log. The current file is already partly wrong ("State after 'direct-to-specs' commit"; start over "uses python3" — it uses sed; `atomic/stacks/stack-awareness.md`), partly history ("removed entirely", "now clean"), and mostly duplicates the format docs, README, help, or the code itself. Decisions and their reasons belong in commit messages and specs; gotchas belong as comments next to the code they affect. The formal "what must stay in step" role is taken by the commit-consistency manifest (next proposal).

- Before deleting, move any fact that is still true and not recorded elsewhere to its proper home — e.g. the experiment harness pointer (`../atomic-experiments/preamble`) into CLAUDE.md or the README.
- Remove apply.md step 5 ("Update context") and renumber: the summary becomes step 5, which makes the `ready` entry's "Skip straight to **Step 5** (show summary)" correct. This absorbs the "Fix the `ready` entry in `/at:apply` pointing at the wrong step" proposal — delete that proposal from the stack in this commit.
- Update everything that mentions it: CLAUDE.md Key Paths, README (CLI reference `show-context`, Structure tree), `atomic help`, `behaviours/` (e.g. the test-loop scenario "updates `atomic/context.md`", `cli-atomic.md` show-context scenarios), `/at:apply` entry ("Read context").

===========
Proposal: Add a commit-consistency manifest (`atomic/consistency.md`) and check every apply against it
Lands before the critic spike (end of stack): the manifest is useful to `/at:apply` on its own; the spike then measures whether a `diff-critic` agent or verify wording adds anything on top.

Design (from discussion):
- A committed file listing every artefact in this repo that must be consistent with the code at every commit, each with what must agree. First entry is the file itself, maintained as commands, components, docs, and artefacts are added or removed.
- Seed for this repo: `atomic/consistency.md` (itself); `README.md` (pipeline/commands table, CLI reference matches `atomic help`, Structure tree, State table); `bin/lib/atomic-help` (one line per command, matches `bin/atomic` dispatch); `CLAUDE.md` (pipeline stages, slash commands table, key paths, hard rules); `.claude/docs/*-context.md` (formats the commands rely on); `.claude/commands/at/*.md` (step numbers and cross-references, `@` includes); `behaviours/*.md` (scenarios for every touched feature); `package.json` (description; `test` script — atomic has no test suite yet).
- Format: a short header saying what the file is for, then one bullet per artefact: path or glob — what must agree with what. Keep it a checklist, not docs.
- Wiring: `/at:apply` reads it (and the critic, if adopted) — every listed item is part of the concern when the change makes it stale (CLAUDE.md rule 5 already makes those in scope; the manifest makes them concrete). The summary's "What changed" covers manifest items touched. `/at:propose` may use it to write complete Changes lists.
- Repos without one: decide whether apply creates it on first run (a deferral at top of stack, or part of an `atomic init`), or just falls back to the generic rule.
- Shared format doc: `.claude/docs/consistency-context.md`, injected where the manifest is used — like the stack and spec formats.
- Behaviours: `pipeline-apply.md` scenarios — change makes a listed artefact stale → updated in the same commit; change adds a new command/artefact → manifest entry added; listed artefact untouched by the change → left alone.

===========
Proposal: Add behaviour scenarios for uncovered `/at:apply` and `/at:merge` entry states
Deferred from propose: while specifying the stale-behaviours rewrite, found that `behaviours/pipeline-apply.md` has no scenarios for `/at:apply` entered in state `none` (tell user to run `/at:propose`), `applying` (re-entry: show progress, list remaining items, continue), or `ready` (skip to summary); and `behaviours/pipeline-merge.md` has no scenarios for `/at:merge` entered in `applying` (show progress, suggest `/at:apply`), `proposed` (tell user to run `/at:apply`), or `none` (nothing to merge). Adding coverage is a separate concern from correcting stale scenarios.

===========
Proposal: Make `atomic commit` keep spec.md when the git commit fails
Deferred from propose: `bin/lib/atomic-commit` runs `rm -f "$ATOMIC_DIR/spec.md"` before `git add -A` / `git commit`. If the commit fails (nothing to commit, hook failure, etc.) the script exits non-zero under `set -e` but the spec is already gone and the pipeline drops to state `none`. Fix: remove spec.md only after `git commit` succeeds — e.g. `git add -A -- . ':!atomic/spec.md'`, commit, then `rm -f` (or remove first but restore on failure). Must still ensure spec.md is never committed. Update the "nothing to commit" scenario in `behaviours/pipeline-merge.md` and the commit scenarios in `behaviours/cli-atomic.md`.

===========
Proposal: Fix the `ready` entry in `/at:apply` pointing at the wrong step
`.claude/commands/at/apply.md` line 14 says "**ready** — all items done. Skip straight to **Step 5** (show summary)." but step 5 is "Update context" and the summary is "### 6. Show summary and ask". Change it to "Skip straight to **Step 6** (show summary)." — resuming an interrupted apply should re-show the summary for approval without re-running the context update. Line 54 ("proceed to Step 5") is correct and stays: on first completion, context is updated before the summary.

Consider adding a `/at:apply` entered-in-`ready` scenario to `behaviours/pipeline-apply.md` — or leave it to the "Add behaviour scenarios for uncovered `/at:apply` and `/at:merge` entry states" proposal above.

Note: `ready` means all items are ticked, not that the user approved — the summary/approve step (Review 3) is the only code review, so the `ready` entry must land on it.

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

**New idea to test — a commit-consistency manifest as steering.** A committed, per-repo file (working name `atomic/consistency.md`) itemising every artefact that must stay consistent with the code at every commit: README, docs, help text, tests, behaviours, infra, CI, DB schema/migrations, generated files, examples, changelog — whatever the repo has, with what in each must agree (e.g. "README CLI reference must match `atomic help`"). **The first item is the file itself:** it must be updated when a change adds a new command, component, function family, doc, or artefact that must stay in step (and entries removed when the thing goes). The critic checks the diff against each item instead of guessing what "stale" means in this repo; apply itself may read it too.

**Harness work needed (the fixture is too simple to show a manifest's value):**
- Add non-obvious consistency artefacts to the fixture that a generic "tests/README/behaviours" reading misses: e.g. a shell completion file listing commands, a `docs/` man-style page, a JSON schema for `todo.json`, a CHANGELOG, an example config, a data-format version/migration step.
- New apply scenarios where a reasonable spec silently invalidates one of them (add a command → completions + man page; add a field → schema + migration; rename a flag → completions, docs, changelog), plus at least one more edge-case Done-when trap like `title-length`, so "not done" isn't measured on a single bug.
- A manifest-maintenance scenario: the change adds a new artefact (e.g. a new docs page or a new subcommand family) — does the manifest get its own entry updated?
- Keep a control where the manifest lists items the change does not touch — check it doesn't cause drive-by edits.

**Variants (apply):** baseline; manifest only (apply step reads it); verify wording only ("before ticking, check each Done-when with an actual command, including boundaries"); `diff-critic`; `diff-critic` + manifest; verify wording + manifest. Score stale-artefact misses, Done-when failures, unrelated changes, manifest self-update, and cost. Drop `title-length`/`newest` cells already at ceiling once the new scenarios exist. Headless runs use the claude.ai plan's 5-hour limit (~60–100 runs per window) — batch per scenario, runners skip valid runs and stop on the limit.

**Decision this spike feeds:** whether atomic adds the critic, the verify wording, or both on top of the manifest (added by the consistency-manifest proposal earlier in the stack), and whether the manifest's wiring needs changing.

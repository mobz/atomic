Stack: Research — measuring how well the pipeline holds the line
As the maintainer of atomic, I want experiments that measure whether pipeline changes (critics, verify wording, the consistency manifest) actually improve commit quality, so that I only add prompt or agent cost where it pays off — run when credit usage doesn't matter, separately from core work.
Harness: `../atomic-experiments/preamble`. Spikes here are not ready for implementation; each ends in a decision, and any resulting change is proposed onto the active stack.

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
Proposal: Have `/at:propose` read `atomic/consistency.md` when writing a spec's Changes list
Deferred from propose: while specifying the commit-consistency manifest, `/at:propose` reading it was considered and left out. Propose was already at ceiling in the preamble spike (complete specs, unstated docs/tests included), and `/at:apply` completes the concern from the manifest regardless. Revisit after the critic spike: add it only if specs that omit manifest artefacts cause problems apply does not catch (e.g. a Done-when that misses a listed artefact).

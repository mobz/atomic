## Behaviour: Pipeline — Apply Stage

### entering apply
- **Given:** state is `proposed` (`atomic/spec.md` exists, all items `[ ]`)
- **When:** user runs `/at:apply`
- **Then:** Claude reads the spec and `atomic/consistency.md`, then begins the implementation loop

### entering apply — no spec
- **Given:** state is `none` (`atomic/spec.md` does not exist)
- **When:** user runs `/at:apply`
- **Then:** Claude tells the user there is no spec to apply and to run `/at:propose` first; nothing is implemented

### entering apply — re-entry while applying
- **Given:** state is `applying` (some items `[X]`, some `[ ]`)
- **When:** user runs `/at:apply`
- **Then:** Claude shows `atomic progress`, lists the remaining `[ ]` items, and continues the loop from where it left off; `[X]` items are not redone

### entering apply — ready
- **Given:** state is `ready` (all items `[X]`)
- **When:** user runs `/at:apply`
- **Then:** Claude skips straight to step 5 — shows the summary and asks approve, rollback, or discuss — without re-implementing or re-running the loop

### implement loop — first entry
- **Given:** state is `proposed`
- **When:** Claude starts the implement step
- **Then:** Claude implements all changes in the spec's Changes list, marking each `[X]` as it is completed; out-of-scope items are added to `atomic/stack.md` as a new Proposal block only

### implement loop — re-entry after discuss
- **Given:** state is `applying` after a discuss round
- **When:** Claude re-enters the implement step
- **Then:** Claude adjusts existing work based on user feedback; does not reset or start from scratch

### implement loop — completes the concern
- **Given:** the spec's change makes tests, docs (README, help text), or behaviours stale or untested, and the spec's Changes do not list them
- **When:** Claude implements the change
- **Then:** Claude updates them in this commit so the codebase is releasable; unrelated issues it notices along the way are still deferred to `atomic/stack.md`, not fixed

### implement loop — deferrals committed with the apply
- **Given:** Claude notices out-of-scope work while implementing the spec
- **When:** Claude defers it
- **Then:** it is added to `atomic/stack.md` as a `Deferred from apply:` Proposal block, listed under Deferred items in the summary, and committed with this apply's commit on approve (or dropped by `atomic rollback`)

### implement loop — manifest artefact made stale
- **Given:** `atomic/consistency.md` exists and lists an artefact the change makes stale (e.g. `README.md` — CLI reference matches `atomic help`, and the change adds a command)
- **When:** Claude implements the change
- **Then:** Claude updates that artefact in this commit, even if the spec's Changes do not list it

### implement loop — manifest maintained
- **Given:** `atomic/consistency.md` exists and the change adds, renames, or removes an artefact or kind of component that must stay in step (e.g. a new doc the commands rely on)
- **When:** Claude implements the change
- **Then:** Claude adds, updates, or removes the matching entry in `atomic/consistency.md` in this commit

### implement loop — manifest artefact unaffected
- **Given:** `atomic/consistency.md` lists an artefact the change does not make stale
- **When:** Claude implements the change
- **Then:** Claude leaves that artefact untouched; the manifest does not prompt drive-by edits

### scope enforcement — future work
- **Given:** Claude notices a clearly out-of-scope item unrelated to the concern (future work, unrelated improvement) during implementation
- **When:** during any implement step
- **Then:** Claude appends a new Proposal block at the end of `atomic/stack.md` and does not implement it

### scope enforcement — urgent or prerequisite
- **Given:** Claude notices an urgent bug or required prerequisite during implementation
- **When:** during any implement step
- **Then:** Claude inserts a new Proposal block at the top of the proposal list in `atomic/stack.md` (after the Stack: header if present) and does not implement it

### scope enforcement — stack.md does not exist
- **Given:** Claude notices an out-of-scope item and `atomic/stack.md` does not exist
- **When:** during any implement step
- **Then:** Claude creates `atomic/stack.md` with the new Proposal block

### test loop — passing
- **Given:** implementation is complete and behaviour files in `behaviours/` have been created or updated for each feature touched
- **When:** test suite is run
- **Then:** if tests pass, Claude checks `atomic progress`; if items remain it returns to the implement step, otherwise it shows the summary

### test loop — failing
- **Given:** tests fail after implementation
- **When:** Claude has made up to 3 fix attempts
- **Then:** if still failing, Claude surfaces the failure and waits for user direction

### inline review — summary shown
- **Given:** implement, behaviours, and tests are complete and state is `ready`
- **When:** Claude shows the summary
- **Then:** a structured checklist is presented — what changed (with inline test mentions), manual verification note if needed, deferred stack items if any, anything worth double-checking; no diff output; user is asked to approve, rollback, or discuss

### inline review — approve
- **Given:** user approves the implementation
- **When:** user says approve (or equivalent)
- **Then:** Claude invokes `/at:merge`, which runs `atomic commit` (intent read from spec.md) and `atomic push`; Claude does not commit or push itself

### inline review — rollback, no deferrals
- **Given:** user wants to abandon the work; no proposals were added to `atomic/stack.md` during this apply
- **When:** user says rollback or abandon
- **Then:** Claude runs `atomic rollback` — everything is snapshotted to an unreferenced commit, then all tracked changes are reverted to HEAD, including `atomic/stack.md` (the popped proposal is back at the top), and untracked files created during the apply, including `atomic/spec.md`, are removed; Claude confirms the pipeline is cleared, relays the snapshot SHA and restore command, and tells the user to run `/at:propose`

### inline review — rollback, with deferrals
- **Given:** user wants to abandon the work; deferrals were added to `atomic/stack.md` during this apply
- **When:** user says rollback or abandon
- **Then:** Claude runs `atomic rollback` — everything is snapshotted to an unreferenced commit, then all tracked changes are reverted to HEAD, including `atomic/stack.md` (the popped proposal is back at the top, the deferrals are dropped), and untracked files created during the apply, including `atomic/spec.md`, are removed; Claude confirms the pipeline is cleared, relays the snapshot SHA and restore command, lists the discarded deferrals by intent, and asks whether to add any back to the end of the stack — without assuming yes, since a rollback is often a change of direction

### inline review — rollback, deferrals re-added
- **Given:** a rollback discarded deferrals and Claude has offered them back
- **When:** the user picks some or all of them
- **Then:** Claude appends only the picked blocks, verbatim from the `atomic rollback` output, to the end of `atomic/stack.md`

### inline review — discuss
- **Given:** the summary has been shown
- **When:** the user responds with anything other than approve or rollback (a correction, question, change request, or "start over")
- **Then:** Claude records any change of scope or approach in `atomic/spec.md` (adding, changing, or removing `[ ]` items, or an Assumptions note), acts on it, and re-enters the implement loop

### inline review — discuss, unclear feedback
- **Given:** the user's discuss feedback does not say what should change (e.g. a bare "start over")
- **When:** Claude reads the feedback
- **Then:** Claude asks what was wrong and waits before changing anything

### inline review — discuss, adjust in place
- **Given:** the new information can be applied to the current implementation
- **When:** Claude acts on discuss feedback (the default)
- **Then:** Claude changes the code directly; marks newly completed items `[X]` and unchecks items that need rework

### inline review — discuss, agent chooses to start over
- **Given:** Claude judges the new information makes the current implementation the wrong base to build on (wrong approach, tangled changes, easier to redo than fix)
- **When:** Claude acts on discuss feedback
- **Then:** Claude tells the user it is starting over and why and runs `atomic start-over` — the previous attempt is snapshotted to an unreferenced commit, then all tracked changes except `atomic/stack.md` are reverted and untracked files created during the attempt are removed; `atomic/spec.md` (now including the new information) is kept with every `[X]` reset to `[ ]` (state `proposed`); `atomic/stack.md` is left exactly as it was (popped proposal stays popped, deferrals kept); Claude relays the snapshot SHA and restore command and re-enters the implement loop from scratch

## Behaviour: Pipeline — Apply Stage

### entering apply
- **Given:** state is `proposed` (`atomic/spec.md` exists, all items `[ ]`)
- **When:** user runs `/at:apply`
- **Then:** Claude reads spec and context, begins the implementation loop

### implement loop — first entry
- **Given:** state is `proposed`
- **When:** Claude starts the implement step
- **Then:** Claude implements all changes in the spec's Changes list, marking each `[X]` as it is completed; out-of-scope items are added to `atomic/stack.md` as a new Proposal block only

### implement loop — re-entry after discuss
- **Given:** state is `applying` after a discuss round
- **When:** Claude re-enters the implement step
- **Then:** Claude adjusts existing work based on user feedback; does not reset or start from scratch

### scope enforcement — future work
- **Given:** Claude notices a clearly out-of-scope item (future work, unrelated improvement) during implementation
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
- **Then:** if tests pass, Claude checks `atomic progress`; if items remain it returns to the implement step, otherwise it updates `atomic/context.md` and shows the summary

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

### inline review — rollback
- **Given:** user wants to abandon the work
- **When:** user says rollback or abandon
- **Then:** Claude runs `git reset --hard HEAD` and `atomic clean`; confirms pipeline is cleared

### inline review — start over
- **Given:** user wants to reimplement from scratch with the current spec
- **When:** user says "start over" or "reimplement from scratch"
- **Then:** Claude runs `git reset --hard HEAD`, keeps `atomic/spec.md` but resets every `[X]` to `[ ]` (state returns to `proposed`), and re-enters the implement loop from scratch

### inline review — discuss
- **Given:** user provides feedback that is not approve, rollback, or start over
- **When:** user responds with a correction, question, or change request
- **Then:** Claude makes the adjustment directly; updates `atomic/spec.md` if scope changes (adding or removing `[ ]` items); marks newly completed items `[X]` and unchecks items that need rework; re-enters the implement loop

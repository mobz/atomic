## Spec: Pipeline — Apply Stage

### entering apply
- **Given:** pipeline is in `propose` stage and `atomic/spec.md` exists
- **When:** user runs `/at:apply`
- **Then:** Claude reads spec and context, advances to apply stage, begins implementation loop

### implement loop — first entry
- **Given:** pipeline is in `apply` stage
- **When:** Claude starts the implement step
- **Then:** Claude implements all changes in the spec's Changes list; out-of-scope items are noted in `atomic/delta.md` only

### implement loop — re-entry after discuss
- **Given:** pipeline is in `apply` stage after a discuss round
- **When:** Claude re-enters the implement step
- **Then:** Claude adjusts existing work based on user feedback; does not reset or start from scratch

### scope enforcement
- **Given:** Claude notices something out of scope during implementation
- **When:** during any implement step
- **Then:** Claude adds it to `atomic/delta.md` and does not implement it

### test loop — passing
- **Given:** implementation is complete
- **When:** test suite is run
- **Then:** if tests pass, Claude proceeds to write/update domain specs directly in `specs/` and show summary

### test loop — failing
- **Given:** tests fail after implementation
- **When:** Claude has made up to 3 fix attempts
- **Then:** if still failing, Claude surfaces the failure and waits for user direction

### inline review — summary shown
- **Given:** implement, specs, and tests are complete
- **When:** Claude shows the summary
- **Then:** a structured checklist is presented — what changed (with inline test mentions), manual verification note if needed, deferred delta items if any, anything worth double-checking; no diff output; user is asked to approve, rollback, or discuss

### inline review — approve
- **Given:** user approves the implementation
- **When:** user says approve (or equivalent)
- **Then:** Claude extracts intent, runs `atomic clean`, `atomic commit "<intent>"`, `atomic push`; confirms commit SHA, message, branch; pipeline is complete

### inline review — rollback
- **Given:** user wants to abandon the work
- **When:** user says rollback or abandon
- **Then:** Claude runs `git reset --hard HEAD` and `atomic reset`; confirms pipeline is cleared

### inline review — start over
- **Given:** user wants to reimplement from scratch with the current spec
- **When:** user says "start over" or "reimplement from scratch"
- **Then:** Claude runs `git reset --hard HEAD`, advances to apply stage, re-enters the implement loop from scratch

### inline review — discuss
- **Given:** user provides feedback that is not approve, rollback, or start over
- **When:** user responds with a correction, question, or change request
- **Then:** Claude makes the adjustment directly; updates `atomic/spec.md` if scope changes; advances to apply stage and re-enters the implement loop

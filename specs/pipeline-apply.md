## Spec: Pipeline — Apply Stage

### entering apply
- **Given:** pipeline is in `propose` stage and `.atomic/spec.md` exists
- **When:** user runs `/apply`
- **Then:** Claude reads spec and context, implements only the listed Changes, nothing more

### scope enforcement
- **Given:** Claude notices something out of scope that should be fixed
- **When:** during implementation
- **Then:** Claude adds it to `.atomic/delta.md` and does not implement it

### test loop — passing
- **Given:** implementation is complete
- **When:** test suite is run
- **Then:** if tests pass, Claude proceeds to write domain specs and merge

### test loop — failing
- **Given:** tests fail after implementation
- **When:** Claude has made up to 3 fix attempts
- **Then:** if still failing, Claude stops and surfaces the failure to the user with a clear description

### domain specs written
- **Given:** implementation is complete and tests pass
- **When:** Claude writes behavioral specs for features touched
- **Then:** named domain spec files exist in `.atomic/` (not spec.md), covering every feature changed

### specs merged
- **Given:** domain spec files exist in `.atomic/`
- **When:** `atomic merge-specs` is run
- **Then:** domain spec files appear in `specs/`, spec.md is not copied

### stage advanced
- **Given:** tests pass, specs merged, context updated
- **When:** `atomic advance apply` is run
- **Then:** `refs/atomic/current/stage` is `apply`, ready for `/review`

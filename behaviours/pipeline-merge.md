## Behaviour: Pipeline — Merge Stage

### entering merge
- **Given:** state is `ready` (all spec items `[X]`)
- **When:** user runs `/at:merge`
- **Then:** Claude runs `atomic status` and proceeds to commit only because the state is `ready`

### entering merge — applying
- **Given:** state is `applying` (some items still `[ ]`)
- **When:** user runs `/at:merge`
- **Then:** Claude shows `atomic progress`, tells the user how many items remain, and suggests running `/at:apply` to complete them; no commit is made

### entering merge — proposed
- **Given:** state is `proposed` (no items `[X]` yet)
- **When:** user runs `/at:merge`
- **Then:** Claude tells the user to run `/at:apply` first; no commit is made

### entering merge — no spec
- **Given:** state is `none`
- **When:** user runs `/at:merge`
- **Then:** Claude tells the user there is nothing to merge; no commit is made

### commit created
- **Given:** `atomic/spec.md` exists with all items `[X]`; changes are present
- **When:** `atomic commit` is run (no argument)
- **Then:** the intent is read from spec.md; spec.md is removed; all changes are staged (`git add -A`) and committed with the intent as the message — including code and `behaviours/` changes, never spec.md

### push succeeds
- **Given:** a remote named `origin` is configured
- **When:** `atomic push` is run
- **Then:** the commit is pushed to origin on the current branch

### push skipped — no remote
- **Given:** no remote named `origin` is configured
- **When:** `atomic push` is run
- **Then:** prints a warning with instructions to add a remote and exits 0; merge continues and completes

### clean state after merge
- **Given:** commit and push succeeded
- **When:** merge completes
- **Then:** `atomic/spec.md` does not exist, `atomic status` shows `State: none`, user is told the commit SHA, message, and branch, that the pipeline is complete, and to run `/at:propose` for the next commit

### nothing to commit
- **Given:** `atomic/spec.md` exists with all items `[X]`; no other changes exist in the working tree
- **When:** `atomic commit` is run
- **Then:** spec.md is removed, `git commit` reports nothing to commit, and the command exits non-zero; no empty commit is created

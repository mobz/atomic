## Behaviour: Pipeline — Merge Stage

### entering merge
- **Given:** state is `ready` (all spec items `[X]`)
- **When:** user runs `/at:merge`
- **Then:** Claude runs `atomic status` and proceeds to commit only because the state is `ready`

### entering merge — applying
- **Given:** state is `applying` (some items still `[ ]`)
- **When:** user runs `/at:merge`
- **Then:** Claude shows `atomic progress` and how many items remain, and ends with `Next: /at:apply — complete the remaining items`; no commit is made

### entering merge — proposed
- **Given:** state is `proposed` (no items `[X]` yet)
- **When:** user runs `/at:merge`
- **Then:** Claude ends with `Next: /at:apply — implement this spec`; no commit is made

### entering merge — no spec
- **Given:** state is `none`
- **When:** user runs `/at:merge`
- **Then:** Claude says there is nothing to merge and ends with `Next: /at:propose — define the next commit`; no commit is made

### commit created
- **Given:** `atomic/spec.md` exists with all items `[X]`; changes are present
- **When:** `atomic commit` is run (no argument)
- **Then:** the intent is read from spec.md; all changes except spec.md are staged (`git add -A`, spec.md unstaged) and committed with the intent as the message — including code and `behaviours/` changes, never spec.md; spec.md is removed only after the commit succeeds

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
- **Then:** `atomic/spec.md` does not exist, `atomic status` shows `State: none`, user is told the commit SHA, message, and branch, and Claude ends with `Next: /at:propose — define the next commit`

### nothing to commit
- **Given:** `atomic/spec.md` exists with all items `[X]`; no other changes exist in the working tree
- **When:** `atomic commit` is run
- **Then:** `git commit` reports nothing to commit; `atomic commit` prints `error: commit failed — atomic/spec.md kept; fix the cause and run atomic commit again` and exits non-zero; spec.md is kept and `atomic status` shows `ready`; no empty commit is created

### commit fails
- **Given:** state is `ready` and `atomic commit` fails (nothing to commit, or a hook rejects the commit)
- **When:** `/at:merge` runs step 2
- **Then:** Claude shows the error and stops without running `atomic push`; spec.md is kept and the state stays `ready`; Claude ends with `Next: /at:merge — retry once the cause is fixed`

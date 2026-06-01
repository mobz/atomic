## Behaviour: Pipeline — Merge Stage

### entering merge
- **Given:** pipeline is in `review` stage
- **When:** user runs `/merge`
- **Then:** Claude confirms stage before proceeding

### commit created
- **Given:** `atomic/spec.md` and `atomic/stage` do not exist; changes are present
- **When:** `atomic commit "<intent>"` is run
- **Then:** a git commit exists with the intent as the message, containing all code and specs/ changes

### push succeeds
- **Given:** a remote named `origin` is configured
- **When:** `atomic push` is run
- **Then:** the commit is pushed to origin on the current branch

### push fails — no remote
- **Given:** no remote named `origin` is configured
- **When:** `atomic push` is run
- **Then:** Claude surfaces the error clearly and tells the user to add a remote before retrying

### clean state after merge
- **Given:** commit and push succeeded
- **When:** merge completes
- **Then:** `atomic/stage` does not exist, `atomic status` shows `Stage: none`, user is told pipeline is complete and to run `/at:propose` for the next commit

### nothing to commit
- **Given:** no changes exist in the working tree
- **When:** `atomic commit` is run
- **Then:** Claude surfaces this clearly — does not create an empty commit

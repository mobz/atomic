## Spec: Pipeline — Review Stage

### entering review
- **Given:** pipeline is in `apply` stage
- **When:** user runs `/review`
- **Then:** Claude confirms stage, shows git diff, shows updated specs/ files, summarises changes

### approve
- **Given:** user approves the implementation
- **When:** user says approve (or equivalent)
- **Then:** Claude runs `atomic advance review`, pipeline moves to `review` stage, user is told to run `/merge`

### request changes
- **Given:** user wants something different
- **When:** user requests changes
- **Then:** Claude appends revision notes to `.atomic/spec.md`, runs `atomic advance propose`, tells user to run `/apply` again

### abandon
- **Given:** user wants to scrap the work
- **When:** user says abandon
- **Then:** Claude runs `atomic reset`, confirms `.atomic/` is cleared and refs are gone, tells user to run `/propose` to start fresh

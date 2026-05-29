## Spec: Pipeline — Propose Stage

### entering propose — no argument
- **Given:** pipeline is in `none` or `merge` stage
- **When:** user runs `/at:propose` with no arguments
- **Then:** Claude checks `atomic status --human`, confirms clean state, begins discovery conversation

### entering propose — with argument
- **Given:** pipeline is in `none` or `merge` stage
- **When:** user runs `/at:propose <intent>` with an argument
- **Then:** Claude checks `atomic status --human`, skips discovery, uses the argument as the starting intent and goes straight to clarify/confirm

### spec written and locked
- **Given:** user has confirmed the spec intent and changes
- **When:** Claude writes `.atomic/spec.md` and runs `atomic advance propose`
- **Then:** `.atomic/spec.md` exists with Intent, Changes, Out of scope, Done when, Assumptions sections; `refs/atomic/current/stage` is `propose`; `refs/atomic/current/spec` points to the spec blob

### spec format — intent
- **Given:** a spec is being written
- **When:** the Intent line is authored
- **Then:** it is a single sentence with no semicolons (if a semicolon is needed, it is two commits)

### propose on dirty pipeline
- **Given:** pipeline is already in `apply` or `review` stage
- **When:** user runs `/propose`
- **Then:** Claude warns the user and asks if they want to reset before proceeding

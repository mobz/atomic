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

### propose — stack proposal surfaced
- **Given:** pipeline state is `none`, no `$ARGUMENTS` provided, and `atomic/stack.md` has at least one Proposal block
- **When:** user runs `/at:propose`
- **Then:** Claude runs `atomic show-stack`, surfaces the top proposal's intent and context, and asks: proceed with this, modify it, or start fresh?

### propose — stack proposal accepted
- **Given:** user confirms they want to proceed with the top stack proposal
- **When:** user says proceed or equivalent
- **Then:** Claude uses the proposal's intent as the starting point, skips discovery questions, and goes straight to clarify; stack.md is not modified

### propose — stack proposal modified
- **Given:** user wants to adjust the top stack proposal before proceeding
- **When:** user says modify or equivalent
- **Then:** Claude uses the proposal's intent as a starting point, asks clarifying questions to refine it, then proceeds to summarise and write spec; stack.md is not modified

### propose — stack proposal ignored
- **Given:** user does not want to use the top stack proposal
- **When:** user says start fresh or equivalent
- **Then:** Claude ignores the stack entry, proceeds with normal discovery conversation; stack.md is not modified

### propose — no stack, no arguments
- **Given:** pipeline state is `none`, no `$ARGUMENTS` provided, and `atomic/stack.md` does not exist or has no Proposal blocks
- **When:** user runs `/at:propose`
- **Then:** Claude proceeds with the normal discovery conversation

### propose — arguments bypass stack
- **Given:** pipeline state is `none` and `$ARGUMENTS` are provided
- **When:** user runs `/at:propose <intent>`
- **Then:** Claude skips stack check entirely and uses the argument as the starting intent

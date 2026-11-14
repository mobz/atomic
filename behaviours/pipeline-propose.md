## Behaviour: Pipeline — Propose Stage

### spec format — intent
- **Given:** a spec is being written
- **When:** the Intent line is authored
- **Then:** it is a single sentence with no semicolons (if a semicolon is needed, it is two commits)

### propose — spec already proposed
- **Given:** pipeline state is `proposed`
- **When:** user runs `/at:propose`
- **Then:** Claude shows the spec's intent and ends with the choice block **Review** / **Change** / **Fresh** / "Or tell me what to change"

### propose — apply in progress
- **Given:** pipeline state is `applying`
- **When:** user runs `/at:propose`
- **Then:** Claude shows `atomic progress` and ends with **Continue** / **Change** / **Fresh** / "Or tell me what to change"; on **Continue** it ends with `Next: /at:apply — resume implementing this spec`

### propose — spec ready to merge
- **Given:** pipeline state is `ready`
- **When:** user runs `/at:propose`
- **Then:** Claude shows the intent and ends with **Apply** / **Fresh** / "Or tell me what to change"; on **Apply** it ends with `Next: /at:apply — review the summary and merge`

### propose — fresh over an active spec
- **Given:** pipeline state is `proposed`, `applying`, or `ready`
- **When:** user picks **Fresh**
- **Then:** Claude runs `atomic clean`, then continues as for state `none`

### propose — stack proposal surfaced
- **Given:** pipeline state is `none`, no `$ARGUMENTS` provided, and `atomic/stack.md` has at least one Proposal block
- **When:** user runs `/at:propose`
- **Then:** Claude runs `atomic show-stack`, surfaces the top proposal's intent and context, and ends with **Proceed** / **Modify** / **Fresh** / "Or tell me what to change"

### propose — stack proposal accepted
- **Given:** the top stack proposal was surfaced
- **When:** user picks **Proceed**
- **Then:** Claude uses the proposal's intent as the starting point, skips discovery questions, and goes straight to clarify; stack.md is not modified yet

### propose — stack proposal modified
- **Given:** the top stack proposal was surfaced
- **When:** user picks **Modify**
- **Then:** Claude uses the proposal's intent as a starting point, asks clarifying questions to refine it, then proceeds to summarise and write spec; stack.md is not modified yet

### propose — stack proposal ignored
- **Given:** the top stack proposal was surfaced
- **When:** user picks **Fresh**
- **Then:** Claude ignores the stack entry, proceeds with normal discovery conversation; stack.md is not modified

### propose — summarise back
- **Given:** clarify has gathered enough for a precise spec
- **When:** Claude summarises the spec in plain language
- **Then:** nothing is written yet; the summary ends with **Write** / "Or tell me what to change"; any other reply loops back to clarify

### propose — hand off after writing
- **Given:** user picked **Write**
- **When:** Claude has written `atomic/spec.md` and updated the stack
- **Then:** Claude says the spec is written and ends with `Next: /at:apply — implement this spec`

### propose — spec written from stack proposal, proposal popped
- **Given:** user picked **Write** on a spec sourced from the top stack proposal (accepted or modified)
- **When:** Claude writes `atomic/spec.md`
- **Then:** the top Proposal block is removed from `atomic/stack.md` in the same step (from its `## Proposal:` line to, but not including, the next `## Proposal:` line); the Stack: header block is preserved; spec.md and stack.md are written together

### propose — spec written from arguments or fresh discovery
- **Given:** spec was sourced from `$ARGUMENTS` or a fresh discovery conversation, and no deferrals came out of the conversation
- **When:** Claude writes `atomic/spec.md`
- **Then:** `atomic/stack.md` is not modified

### propose — split accepted
- **Given:** Claude proposed splitting the work into several commits and the user accepted the split
- **When:** Claude writes `atomic/spec.md` for the first of them
- **Then:** in the same step, the split-off proposals are written to `atomic/stack.md` immediately after the `Stack:` header block (as the next proposals), alongside the pop if the spec came from the stack; they are deferrals, so they are committed with this spec's commit

### propose — out-of-scope finding
- **Given:** during the propose conversation, Claude or the user noticed work outside the spec's scope that is not a split-off
- **When:** Claude writes `atomic/spec.md`
- **Then:** in the same step, the finding is written to `atomic/stack.md` as a `Deferred from propose:` Proposal block — at the end of the stack, or the top if it is an urgent bug or prerequisite — whether or not the spec came from the stack; it is committed with this spec's commit

### propose — no stack, no arguments
- **Given:** pipeline state is `none`, no `$ARGUMENTS` provided, and `atomic/stack.md` does not exist or has no Proposal blocks
- **When:** user runs `/at:propose`
- **Then:** Claude proceeds with the normal discovery conversation

### propose — arguments bypass stack
- **Given:** pipeline state is `none` and `$ARGUMENTS` are provided
- **When:** user runs `/at:propose <intent>`
- **Then:** Claude skips stack check entirely and uses the argument as the starting intent

### propose — spec preserves proposal detail verbatim
- **Given:** the proposal (from stack or `$ARGUMENTS`) contains detailed design notes — steps, rules, examples, format definitions, or implementation approach
- **When:** Claude writes `atomic/spec.md`
- **Then:** that detail is carried forward verbatim into the spec (in Changes items or as a context block); it is not compressed into one-line summaries; the spec is fully self-contained without reference to the original proposal

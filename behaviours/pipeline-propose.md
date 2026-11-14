## Behaviour: Pipeline — Propose Command

### propose — no existing stack
- **Given:** `atomic/stack.md` does not exist
- **When:** user runs `/at:propose`
- **Then:** Claude proceeds directly to eliciting the feature user story

### propose — existing stack
- **Given:** `atomic/stack.md` exists with a Stack: header and at least one Proposal block
- **When:** user runs `/at:propose`
- **Then:** Claude shows the current stack and ends with **Extend** / **Fresh** / "Or tell me what to change"

### propose — extend existing
- **Given:** an existing stack was shown
- **When:** user picks **Extend**
- **Then:** Claude brainstorms additions, shows each new proposal as the exact block to be appended, and ends with **Add** / "Or tell me what to change"; on **Add**, each is appended to the end of the stack with `atomic stack-add`, one `Propose: <intent>` commit per proposal; `atomic/stack.md` is not hand-edited; Stack: header and existing proposals are preserved; an in-progress spec's changes (pop, deferrals, code) are left uncommitted

### propose — replace existing
- **Given:** an existing stack was shown; `atomic status` is `none`
- **When:** user picks **Fresh** (or asks to replace it)
- **Then:** Claude proceeds with a new user story and overwrites `atomic/stack.md` entirely

### propose — replace refused while a spec is active
- **Given:** `atomic status` is `proposed`, `applying`, or `ready`
- **When:** user picks **Fresh** (or asks to replace the stack)
- **Then:** Claude refuses — rewriting the stack would clobber the proposal `/at:spec` popped — and ends with `Next: /at:apply — finish the active spec, or roll it back, before replacing the stack`; `atomic/stack.md` is not modified

### propose — exploration to drafting
- **Given:** Claude and the user are exploring a feature
- **When:** the problem space feels understood and Claude offers a summary
- **Then:** the summary ends with **Draft** / "Or tell me what to change"; Claude keeps exploring until the user picks **Draft**, then moves on to the user story and proposals

### propose — user story elicitation
- **Given:** Claude is defining a new stack
- **When:** the user describes the feature
- **Then:** Claude reframes it as "As a <persona> I want <feature> so that <goal>"; pushes back on vague stories; requires the story to be specific enough to scope proposals

### propose — atomicity enforcement
- **Given:** a candidate proposal has multiple concerns
- **When:** Claude is grouping changes into proposals
- **Then:** Claude names the split explicitly and proposes separate proposals; does not accept a bundled proposal

### propose — expand/contract enforcement
- **Given:** a candidate proposal involves replacing an existing file, command, or behaviour
- **When:** Claude is grouping changes into proposals
- **Then:** Claude decomposes it into three separate proposals: Add (purely additive), Switch (migration, old thing dormant), Remove (cleanup only)

### propose — stability check
- **Given:** a candidate proposal produces no usable or observable output without the next proposal
- **When:** Claude is ordering proposals
- **Then:** Claude flags the dependency and either merges the proposals or restructures so each one is independently shippable

### propose — written output
- **Given:** Claude has ordered and reviewed the proposals for a new (or replaced) stack
- **When:** Claude writes `atomic/stack.md`
- **Then:** the file starts with `# Stack: <name>` on the first line, followed by the user story and optional context, then `## Proposal: <intent>` blocks in order; each proposal block contains enough detail for apply to implement without re-deriving the design; Claude says the stack is written and ends with `Next: /at:spec — spec the top proposal` followed by "Or tell me what to change"

### propose — Stack: header required
- **Given:** any stack.md being written by `/at:propose`
- **When:** the file is created or replaced
- **Then:** the first line is always `# Stack: <name>`; a stack.md without this header is invalid

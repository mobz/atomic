## Behaviour: Pipeline — Stack Command

### stack — no existing stack
- **Given:** `atomic/stack.md` does not exist
- **When:** user runs `/at:stack`
- **Then:** Claude proceeds directly to eliciting the feature user story

### stack — existing stack
- **Given:** `atomic/stack.md` exists with a Stack: header and at least one Proposal block
- **When:** user runs `/at:stack`
- **Then:** Claude shows the current stack and asks: extend it, replace it, or start fresh?

### stack — extend existing
- **Given:** user chooses to extend the existing stack
- **When:** user says extend or equivalent
- **Then:** Claude brainstorms additions and appends new proposals to the bottom of the existing stack; Stack: header and existing proposals are preserved

### stack — replace existing
- **Given:** user chooses to replace the existing stack
- **When:** user says replace or start fresh
- **Then:** Claude proceeds with a new user story and overwrites `atomic/stack.md` entirely

### stack — user story elicitation
- **Given:** Claude is defining a new stack
- **When:** the user describes the feature
- **Then:** Claude reframes it as "As a <persona> I want <feature> so that <goal>"; pushes back on vague stories; requires the story to be specific enough to scope proposals

### stack — atomicity enforcement
- **Given:** a candidate proposal has multiple concerns
- **When:** Claude is grouping changes into proposals
- **Then:** Claude names the split explicitly and proposes separate proposals; does not accept a bundled proposal

### stack — expand/contract enforcement
- **Given:** a candidate proposal involves replacing an existing file, command, or behaviour
- **When:** Claude is grouping changes into proposals
- **Then:** Claude decomposes it into three separate proposals: Add (purely additive), Switch (migration, old thing dormant), Remove (cleanup only)

### stack — stability check
- **Given:** a candidate proposal produces no usable or observable output without the next proposal
- **When:** Claude is ordering proposals
- **Then:** Claude flags the dependency and either merges the proposals or restructures so each one is independently shippable

### stack — written output
- **Given:** user confirms the full proposal sequence
- **When:** Claude writes `atomic/stack.md`
- **Then:** the file starts with `Stack: <name>` on the first line, followed by the user story and optional context, then `===========` / `Proposal:` blocks in order; each proposal block contains enough detail for apply to implement without re-deriving the design

### stack — Stack: header required
- **Given:** any stack.md being written by `/at:stack`
- **When:** the file is created or replaced
- **Then:** the first line is always `Stack: <name>`; a stack.md without this header is invalid

## Codebase Context

**State after "direct-to-specs" commit:**

- `/at:apply` scope: implement → test → inline review. Stops at user approval.
- `/at:merge` scope: commit + push. Invoked by apply on approve.
- Behaviour files (BDD scenarios) written directly to `behaviours/` during apply. Headers use `## Behaviour:` format.
- `atomic merge-specs` command removed entirely (`bin/lib/atomic-merge-specs` deleted, dispatch entry gone).
- `atomic/` reserved for: `spec.md` (ephemeral), `context.md`, `stack.md`, `.gitkeep` only.
- "start over" path uses python3 to reset [X]→[ ] checkboxes (sed -i '' is broken on macOS for bracket patterns).
- Pipeline state derived from spec.md checkboxes: none/proposed/applying/ready.
- `atomic progress` prints M/N changes complete.
- `atomic commit` refuses if any [ ] items remain.
- Each command in bin/lib/atomic-{status,progress,reset,show-spec,show-context,show-stack,commit,push,clean,help}.
- atomic/ tracked: .gitkeep, context.md, stack.md committed; spec.md ephemeral.
- stack.md format: `Stack: <name>` header block, then `===========\nProposal: <intent>` blocks in order; top proposal = next commit.
- `/at:propose` is stack-aware: on entry with no args, surfaces top stack proposal as default intent; when spec.md is written from a stack proposal, that proposal is popped from stack.md in the same step (state moves from queued → active); `$ARGUMENTS` or fresh discovery never touches stack.md.
- `behaviours/pipeline-propose.md` is now clean — stale old-pipeline scenarios removed.
- When writing spec.md, detailed design notes from the proposal (steps, rules, examples, implementation approach) must be carried forward verbatim — not compressed. The spec is the only record once the proposal is popped.
- `/at:stack` guides feature decomposition into a proposal stack: enforces atomicity, stability, expand/contract pattern, and testability rules; writes `atomic/stack.md` with Stack: header + user story + ordered Proposal blocks.
- `atomic/stack.md` is the single active stack; future multi-stack support is a separate concern.
- No real test suite — npm test is a placeholder.
- `.claude/docs/` directory introduced for shared context files injected into commands via `@` references.
- `.claude/docs/spec-context.md` covers spec.md format and pipeline state semantics; injected near top of propose.md, apply.md, merge.md.
- Inline spec format template removed from propose.md step 5; inline state parentheticals removed from all three commands — these now live in spec-context.md.
- `atomic/stacks/` directory introduced for archiving named stacks; `atomic/stacks/stack-awareness.md` holds the in-progress stack-awareness feature proposals.

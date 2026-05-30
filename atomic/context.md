## Codebase Context

**State after "direct-to-specs" commit:**

- `/at:apply` scope: implement → test → inline review. Stops at user approval.
- `/at:merge` scope: commit + push. Invoked by apply on approve.
- Domain specs written directly to `specs/` during apply — no `atomic/` staging, no `merge-specs` step.
- `atomic merge-specs` command removed entirely (`bin/lib/atomic-merge-specs` deleted, dispatch entry gone).
- `atomic/` reserved for: `spec.md` (ephemeral), `context.md`, `stack.md`, `.gitkeep` only.
- "start over" path uses python3 to reset [X]→[ ] checkboxes (sed -i '' is broken on macOS for bracket patterns).
- Pipeline state derived from spec.md checkboxes: none/proposed/applying/ready.
- `atomic progress` prints M/N changes complete.
- `atomic commit` refuses if any [ ] items remain.
- Each command in bin/lib/atomic-{status,progress,reset,show-spec,show-context,show-stack,commit,push,clean,help}.
- atomic/ tracked: .gitkeep, context.md, stack.md committed; spec.md ephemeral.
- stack.md format: `Stack: <name>` header block, then `===========\nProposal: <intent>` blocks in order; top proposal = next commit.
- `/at:propose` is stack-aware: on entry with no args, surfaces top stack proposal as default intent; stack is never modified by propose (merge pops it).
- No real test suite — npm test is a placeholder.

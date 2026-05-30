## Codebase Context

**State after "apply stops at review" commit:**

- `/at:apply` scope: implement → test → inline review. Stops at user approval.
- `/at:merge` scope: commit + push. Called by user after approving in apply.
- Approve path in apply.md says "Implementation complete. Run `/at:merge` to commit and push."
- "start over" path uses python3 to reset [X]→[ ] checkboxes (sed -i '' is broken on macOS for bracket patterns).
- Pipeline state derived from spec.md checkboxes: none/proposed/applying/ready.
- `atomic progress` prints M/N changes complete.
- `atomic commit` refuses if any [ ] items remain.
- Each command in bin/lib/atomic-{status,progress,reset,show-spec,show-context,merge-specs,commit,push,clean,help}.
- atomic/ tracked: .gitkeep, context.md, delta.md committed; spec.md ephemeral.
- No real test suite — npm test is a placeholder.

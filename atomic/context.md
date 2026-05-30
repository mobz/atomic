## Codebase Context

**State after "PR-quality review summary" commit:**

- `/at:apply` step 5 produces a structured checklist summary, not a raw diff.
- Summary format: What changed (tests inline), Manual verification (only if needed), Deferred items (delta.md callout), Worth double-checking. No git diff output.
- Decision prompt: Approve / Rollback / tell me what to change.
- `atomic commit` is self-contained: reads intent from spec.md, removes spec.md + stage, git add -A, git commit.
- `/at:apply` owns the full loop: implement → specs → test → inline review → merge or loop.
- `/at:review` does not exist.
- `atomic/` is tracked in git. Ephemeral: spec.md, stage. Persistent: context.md, delta.md.
- Each command in `bin/lib/atomic-{status,advance,reset,show-spec,show-context,merge-specs,commit,push,clean,help}`.
- `atomic push` degrades gracefully — no origin = warning + exit 0.
- No real test suite yet — `npm test` is a placeholder.

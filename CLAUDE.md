# atomic — Claude Code Instructions

## What This Project Is

`atomic` is a CLI tool that implements a lightweight atomic commit pipeline. Every unit of work moves through an explicit pipeline:

```
propose → apply (loop: implement → specs → test → review) → merge
```

This repo dogfoods itself — `atomic` is built using `atomic`.

## Start of Every Session

**Always run this first:**
```bash
bin/atomic status
```

This tells you the current pipeline stage and the active spec intent. Orient yourself before doing anything else.

## Pipeline Stages

| Stage | Who | What happens |
|-------|-----|--------------|
| **propose** | User + Claude | Define what the commit will do. Produces `atomic/spec.md`. |
| **apply** | Claude + User | Implement → specs → test loop. User reviews inline: approve, rollback, or discuss. Discuss re-enters the loop. Approve auto-merges. |

## Hard Rules

1. **Never implement changes outside the `apply` stage.** If someone asks you to "just fix this quickly" outside of apply, decline and suggest running `/propose` first.

2. **Never commit code directly.** All commits go through `atomic commit` in the merge stage. No `git commit` by hand.

3. **Never push directly.** All pushes go through `atomic push` in the merge stage.

4. **Stay in scope.** During apply, implement only what `atomic/spec.md` describes. If you notice something out of scope, add it to `atomic/stack.md` as a new Proposal block.

5. **The spec is the contract.** If you're unsure whether something is in scope, re-read the spec. If it's not explicitly listed in **Changes**, it's out of scope.

## Slash Commands

| Command | Stage | Description |
|---------|-------|-------------|
| `/at:propose` | → propose | Define the next atomic commit interactively |
| `/at:apply` | → apply | Implement, review inline, and merge — full loop |
| `/at:stack` | → stack | Design a feature as an incremental proposal stack |

## Key Paths

- `atomic/spec.md` — active commit plan (ephemeral, never committed); pipeline state is derived from its checkbox state: no file=none, all `[ ]`=proposed, mixed=applying, all `[X]`=ready
- `atomic/context.md` — evolving codebase understanding, committed with each atomic commit
- `atomic/stack.md` — ordered proposal queue; out-of-scope items from apply land here; top proposal feeds the next `/at:propose`
- `specs/` — committed spec store, always in sync with code
- `bin/atomic` — the CLI (use it, don't work around it)

## Behavioral Spec Format

Files in `specs/` are feature-scoped behavioral specs — not commit history. Each file covers one domain (e.g. `cli-atomic-status.md`, `pipeline-propose.md`) and uses this format:

```markdown
## Spec: <feature name>

### <scenario name>
- **Given:** system state / preconditions
- **When:** action or event
- **Then:** observable outcome(s)
```

Scenarios should be concrete and testable. During `apply`, Claude creates or updates these files in `atomic/` for every feature touched, then `atomic merge-specs` copies them into `specs/`.

`atomic/spec.md` is the commit plan (ephemeral) — it is separate from behavioral specs and is never copied into `specs/`.


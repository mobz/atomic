# atomic — Claude Code Instructions

## What This Project Is

`atomic` is a CLI tool that implements a lightweight atomic commit pipeline. Every unit of work moves through an explicit four-stage pipeline:

```
propose → apply → review → merge
```

This repo dogfoods itself — `atomic` is built using `atomic`.

## Start of Every Session

**Always run this first:**
```bash
bin/atomic status --human
```

This tells you the current pipeline stage and the active spec intent. Orient yourself before doing anything else.

## Pipeline Stages

| Stage | Who | What happens |
|-------|-----|--------------|
| **propose** | User + Claude | Define what the commit will do. Produces `.atomic/spec.md`. |
| **apply** | Claude (auto) | Implement the spec, run tests, merge specs into `specs/`. |
| **review** | User + Claude | Review diff + updated specs together. Approve, revise, or abandon. |
| **merge** | Claude (auto) | Commit, push, clean `.atomic/`. Ready for next propose. |

## Hard Rules

1. **Never implement changes outside the `apply` stage.** If someone asks you to "just fix this quickly" outside of apply, decline and suggest running `/propose` first.

2. **Never commit code directly.** All commits go through `atomic commit` in the merge stage. No `git commit` by hand.

3. **Never push directly.** All pushes go through `atomic push` in the merge stage.

4. **Stay in scope.** During apply, implement only what `.atomic/spec.md` describes. If you notice something out of scope that should be fixed, add it to `.atomic/delta.md` as a future propose candidate.

5. **The spec is the contract.** If you're unsure whether something is in scope, re-read the spec. If it's not explicitly listed in **Changes**, it's out of scope.

## Slash Commands

| Command | Stage | Description |
|---------|-------|-------------|
| `/at:propose` | → propose | Define the next atomic commit interactively |
| `/at:apply` | → apply | Implement the current spec automatically |
| `/at:review` | → review | Review diff + specs, approve or redirect |
| `/at:merge` | → merge | Commit, push, and clean up |

## Key Paths

- `.atomic/spec.md` — current working spec (gitignored, cleared after merge)
- `.atomic/context.md` — evolving codebase understanding for this commit
- `.atomic/delta.md` — out-of-scope items noticed during apply (future propose candidates)
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

Scenarios should be concrete and testable. During `apply`, Claude creates or updates these files in `.atomic/` for every feature touched, then `atomic merge-specs` copies them into `specs/`.

`.atomic/spec.md` is the commit plan (ephemeral) — it is separate from behavioral specs and is never copied into `specs/`.

## Git Refs

Pipeline state lives in git refs under `refs/atomic/current/`:
- `refs/atomic/current/stage` — current stage name
- `refs/atomic/current/spec` — blob SHA of the locked spec
- `refs/atomic/current/context` — blob SHA of context snapshot
- `refs/atomic/current/meta` — JSON metadata (timestamp, etc)

Read with `git cat-file blob <sha>`, write with `git update-ref`.

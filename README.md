# atomic

atomic explores agentic development with a focus on value for money. It breaks engineering work into small packets using tried and tested agile methods — user stories, vertical slicing, expand/contract, one concern per commit — so that every SDLC step on each packet (development, code review, quality control, and to some extent planning) can be done by smaller, more efficient models, faster and more reliably, and each change is small enough for a human to review in one pass. The goal is to run full cycles on laptop-sized models, getting better value and performance by running multiple stacks in parallel rather than one large model on one large task.

A lightweight atomic commit pipeline for AI-assisted development. Every change is planned as one small, revertable commit, implemented by Claude Code against that plan, reviewed inline, and merged:

```
spec → apply (implement → behaviours → test → inline review) → merge
```

Larger features are broken down up front into a stack of proposals, each of which becomes one commit.

This repo dogfoods itself — `atomic` is built using `atomic`.

## Pipeline

| Command | Who | What happens |
|---------|-----|--------------|
| `/at:init` | User + Claude | Set up atomic in a repo: run `atomic init`, then draft `atomic/consistency.md` from the repo's real artefacts — and merge atomic's rules into an existing `CLAUDE.md` — for approval |
| `/at:stack` | User + Claude | Design a feature as an ordered stack of proposals in `atomic/stack.md` |
| `/at:spec` | User + Claude | Define exactly one atomic commit, usually from the top of the stack. Writes `atomic/spec.md` |
| `/at:apply` | Claude + User | Implement the spec, update behaviours, run tests, then show a summary. The user approves, rolls back, or discusses (which re-enters the loop) |
| `/at:merge` | Claude | Commit with the spec's intent as the message and push. Runs automatically on approve |

Out-of-scope work noticed along the way is added to the stack rather than implemented, and committed with the change it came out of.

## Install

Get `atomic` on your PATH — the `/at:*` commands call it directly. Any of:

```bash
# from a clone: link it with npm…
git clone git@github.com:mobz/atomic.git ~/src/atomic
cd ~/src/atomic && npm link

# …or put its bin/ on PATH
export PATH="$HOME/src/atomic/bin:$PATH"

# or install it globally without a clone
npm install -g git+ssh://git@github.com/mobz/atomic.git
```

Then, in the repo you want to use it in, run `atomic init`. It creates `atomic/` with a starting `atomic/consistency.md` and copies the `/at:*` commands (`.claude/commands/at/`), their shared docs (`.claude/docs/`), and — if the repo has none — a starting `CLAUDE.md` into the repo. If the repo already has a `CLAUDE.md`, init leaves it alone, and `/at:init` merges atomic's rules into it.

Then, in Claude Code, run `/at:init`. It re-runs `atomic init` (harmless), surveys the repo for artefacts that must agree with the code — README, docs, tests, CI, schemas, and so on — and drafts an `atomic/consistency.md` entry for each. If the repo had its own `CLAUDE.md`, it also drafts a merge of atomic's rules into it, fitted to the file's structure and flagging any rule that conflicts. It writes only what you approve. Neither step commits; review and commit the installed files yourself.

Init installs a one-off starting point. From then on the repo owns those files and evolves its pipeline on its own — atomic does not update them, and re-running `atomic init` only fills in files that are missing, never overwriting one that exists.

## Quick Start

```bash
# Set up atomic in a repo
bin/atomic init
# …then /at:init in Claude Code to draft the manifest

# Check current pipeline state
bin/atomic status

# In Claude Code:
#   /at:spec      define the next commit
#   /at:apply     implement it, review inline, approve to merge
```

## CLI Reference

```bash
atomic init          # scaffold atomic
atomic status        # pipeline state derived from spec.md (none/proposed/applying/ready)
atomic progress      # M/N changes complete
atomic show-spec     # print atomic/spec.md
atomic show-stack    # print atomic/stack.md
atomic commit        # create git commit (refuses with no spec, or if any [ ] items remain)
atomic push          # push current branch to origin
atomic clean         # remove spec.md (clear active pipeline)
atomic rollback      # abandon the active spec and revert all changes
atomic start-over    # revert all changes but keep the spec and stack, unticking every item
atomic stack-add "<intent>"  # append a planning proposal (body on stdin) to the stack and commit only that

# Add --json to any command for machine-readable output; errors then print
# {"ok":false,"error":"…"} to stderr instead of "error: …"
atomic status --json
```

`rollback` and `start-over` save the discarded work as an unreferenced commit and print its SHA, so it can be restored with `git restore --source=<sha> -- .`.

## Structure

```
.claude/commands/at/  ← pipeline slash commands for Claude Code
.claude/docs/         ← shared format and interaction context injected into the commands
atomic/spec.md        ← active commit plan (ephemeral, never committed)
atomic/consistency.md ← artefacts that must agree with the code at every commit (committed)
atomic/stack.md       ← ordered proposal queue (committed)
behaviours/           ← BDD scenarios, always in sync with the code (committed)
bin/atomic            ← the CLI
CLAUDE.md             ← instructions for Claude Code sessions (generic; copied by `atomic init`)
CLAUDE.local.md       ← notes for developing atomic itself (not copied)
```

`atomic/consistency.md` is the repo's commit-consistency manifest: one entry per artefact (README, help text, docs, behaviours, …) saying what must agree with what. `/at:apply` checks every change against it and updates the manifest when the change adds or removes something it should list. Its format lives in `.claude/docs/consistency-context.md`; `atomic init` writes a starting manifest holding just its own entry.

## Behaviours

`behaviours/` holds feature-scoped BDD scenarios describing what the system observably does — one file per domain (e.g. `cli-atomic.md`, `pipeline-apply.md`), not one per commit:

```markdown
## Behaviour: <feature name>

### <scenario name>
- **Given:** system state / preconditions
- **When:** action or event
- **Then:** observable outcome(s)
```

During `/at:apply`, after implementing, Claude creates or updates the scenarios for every feature the commit touched — adding new ones, changing ones whose behaviour changed, removing ones that no longer hold. They are committed alongside the code in the same atomic commit, so the behaviour store always matches the code at every commit. The format and rules live in `.claude/docs/behaviour-context.md`, which is injected into `/at:apply`.

## State

Pipeline state is derived from the checkboxes in `atomic/spec.md`:

| State | Condition |
|-------|-----------|
| `none` | spec.md does not exist |
| `proposed` | all items are `[ ]` |
| `applying` | some items are `[X]` |
| `ready` | all items are `[X]` |

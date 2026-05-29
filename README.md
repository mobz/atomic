# atomic

A lightweight atomic commit pipeline CLI. Every change moves through an explicit four-stage workflow:

```
propose → apply → review → merge
```

Built for single-dev use today, designed to extend to multi-agent stacked commits later.

## Pipeline

| Stage | Command | Who |
|-------|---------|-----|
| Define the commit | `/propose` | User + Claude |
| Implement + test | `/apply` | Claude (automatic) |
| Review diff + specs | `/review` | User + Claude |
| Commit + push | `/merge` | Claude (automatic) |

## Quick Start

```bash
# Check current pipeline state
bin/atomic status --human

# Start a new commit
# In Claude Code: /propose

# Implement it
# In Claude Code: /apply

# Review it
# In Claude Code: /review

# Ship it
# In Claude Code: /merge
```

## CLI Reference

```bash
atomic status           # current stage + spec summary (JSON by default)
atomic advance <stage>  # move to named stage
atomic reset            # clear .atomic/ and remove pipeline refs
atomic show-spec        # print .atomic/spec.md
atomic show-context     # print .atomic/context.md
atomic merge-specs      # merge .atomic/ domain specs into specs/
atomic commit           # create git commit from current changes
atomic push             # push current branch to origin
atomic clean            # clear .atomic/ working state

# Add --human to any command for readable output
atomic status --human
```

## Structure

```
.claude/commands/   ← pipeline slash commands for Claude Code
.atomic/            ← gitignored pipeline working state
specs/              ← committed spec store (always in sync with code)
bin/atomic          ← the CLI
CLAUDE.md           ← instructions for Claude Code sessions
```

## State Storage

Pipeline state lives in git refs (`refs/atomic/current/`) — concurrent-safe, pushed with the repo, visible via `git for-each-ref`.

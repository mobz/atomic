Stack: Add stack awareness to the atomic pipeline
As a developer I want the atomic pipeline to maintain an ordered proposal queue so that I can decompose a feature into atomic commits upfront, capture out-of-scope discoveries without losing focus, and always know what comes next.

===========
Proposal: Rename spec.md to something better

spec.md is ambiguous — the word "spec" is overloaded (it also describes the behavioral specs in specs/). The file is really the active commit plan / work order for the current pipeline run.

Candidate names: plan.md, commit.md, work.md, intent.md, current.md — not decided yet.

Touches: all references in bin/atomic, bin/lib/*, .claude/commands/at/*, CLAUDE.md, specs/, context.md.

===========
Proposal: Fix stale `atomic merge-specs` reference in CLAUDE.md

Deferred from apply: CLAUDE.md line 69 still says "During `apply`, Claude creates or updates these files in `atomic/` for every feature touched, then `atomic merge-specs` copies them into `specs/`." — merge-specs was removed; specs are now written directly to `specs/` during apply.

- Update the Behavioral Spec Format section in CLAUDE.md to remove the merge-specs sentence

===========
Proposal: Add `/at:fix` command for surgical bug fixes in git history

When a bug is discovered, the atomic commit philosophy says: fix it in the commit that introduced it so every commit is always complete. This requires a different workflow from a standard proposal — you're not writing new code, you're correcting history.

The command needs to handle two distinct cases:
1. **Bug is in HEAD** — amend the most recent commit. Simpler path: fix the code, `git add`, `git commit --amend`.
2. **Bug is in an older commit** — create a fixup commit targeting that SHA, then rebase it in with `git rebase -i --autosquash`. This rewrites history from that commit forward.

Key design challenges:
- Finding the culprit commit: guide Claude through `git log`, `git blame`, and `git show` to identify where the bug was introduced — do not assume the user knows the SHA
- Scoping the fix: a history rewrite must be surgical. The fix should touch only what the bug requires — no scope creep into the target commit
- Safety: before any rebase, check for pushed commits and warn the user. Rewriting published history requires a force push and coordination with collaborators
- Conflict handling: a fixup rebase can produce conflicts if subsequent commits touched the same code — the command must guide through resolution or surface clearly when manual intervention is needed
- Spec handling: a simple one-line bug fix may not need a full spec; a complex fix might. The command should judge this and either proceed directly or invoke a lightweight spec flow

Consider whether this is one command (`/at:fix`) or a sub-path within `/at:propose` triggered by a "this is a bug" signal. Either way, the output is a clean git history where the bug never existed.

This is a large command — consider decomposing into its own stack when the time comes.

===========
Proposal: Clean up stale content in specs/pipeline-propose.md

Deferred from apply: scenarios in this file reference the old pipeline (git refs, `atomic advance propose`, `refs/atomic/current/stage`) that were removed several commits ago. The new stack-aware scenarios were added correctly but the stale ones remain.

- Remove or rewrite: "entering propose — no argument", "entering propose — with argument", "spec written and locked", "propose on dirty pipeline" to reflect the current pipeline

===========
Proposal: Add portable orientation context for stack awareness and file formats

Each `/at:*` command currently re-derives pipeline concepts from scratch — Claude has no pre-loaded understanding of stack.md format, the Proposal block separator syntax, what atomic/ contains, or pipeline state semantics. This works but is fragile: commands are verbose because they must re-explain context inline, and a new command written without that context will behave inconsistently.

Goal: a single portable context source that all at: commands can reference, covering:
- stack.md format (Stack: header, =========== separator, Proposal: blocks, ordering)
- atomic/ reserved files and their roles (spec.md ephemeral, context.md, stack.md persistent)
- Pipeline state semantics (none / proposed / applying / ready)
- The expand/contract principle for proposals
- Atomic commit philosophy (one concern, stable at every commit)

Options to explore:
- A `.claude/commands/at/context.md` file that is loaded implicitly by Claude Code for all commands in the `at/` namespace (if Claude Code supports this)
- A shared preamble block that is `include`d or referenced at the top of each command file
- A `AGENTS.md` or similar convention supported by Claude Code for subdirectory agent context
- An `atomic orientation` CLI command that prints machine-readable context for Claude to ingest at session start

Whichever approach: the format and pipeline knowledge should live in one place, not be duplicated across propose.md, apply.md, merge.md, and stack.md.

===========
Proposal: Support multiple named stacks

Currently `atomic/stack.md` is the single active stack. As work grows across multiple concurrent features or workstreams, a single file becomes a bottleneck — unrelated proposals accumulate in one queue and the stack loses its focus.

Design considerations:
- Named stacks stored alongside the active one (e.g. `atomic/stacks/auth-rewrite.md`, `atomic/stacks/payments.md`) with `atomic/stack.md` remaining the active/checked-out stack
- OR a `stacks/` directory with `atomic/stack.md` as a symlink or pointer to the active one
- `atomic show-stack` continues to work against the active stack without changes
- New commands needed: `atomic stack list`, `atomic stack switch <name>`, `atomic stack new <name>`
- `/at:stack` needs to know whether to create a new named stack or replace the active one
- The active stack concept must remain stable — all existing pipeline behaviour (propose popping from top, apply writing to stack, show-stack) works against whichever stack is currently active
- Consider whether stack.md in the repo root atomic/ dir should always be the active one (symlink pattern) or whether a separate pointer file tracks which is active

This is a significant change — decompose into its own stack when the time comes.

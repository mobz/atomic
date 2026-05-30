Stack: Add stack awareness to the atomic pipeline
As a developer I want the atomic pipeline to maintain an ordered proposal queue so that I can decompose a feature into atomic commits upfront, capture out-of-scope discoveries without losing focus, and always know what comes next.

===========
Proposal: Add `/at:stack` command to guide creation of a well-designed incremental proposal stack

Create a slash command that leads the user through decomposing a feature into atomic, safely-shippable proposals. The command should produce stacks of the same quality as a senior engineer applying the expand/contract (parallel change) pattern — not just a flat list of "things to do."

The command must embed the following design constraints so it reasons about them actively, not just prompts the user:

**Atomicity rule**: each proposal must have a single concern. If the intent sentence needs a semicolon, it is two proposals. Push back on bundled proposals.

**Stability rule**: every proposal must leave the system in a working, non-broken state without the ones that follow it. A proposal that only makes sense once the next one lands is incomplete — it must be merged with its dependency or restructured.

**Expand/contract pattern**: when introducing a replacement for something that already exists, decompose it into three phases:
1. **Add** — introduce the new thing alongside the old. Purely additive, no removals. Safe to ship immediately.
2. **Switch** — migrate behaviour to use the new thing. Old thing still exists but is now dormant. System fully functional.
3. **Remove** — delete the old thing and all references to it. Pure cleanup, zero behaviour change.

Apply this pattern when a proposal involves replacing a file, a command, or a behaviour.

**Testability rule**: each proposal should add capability that can be verified independently — by running the CLI, reading a file, or observing a behaviour change. If a proposal produces no observable output until a later proposal lands, reconsider the split.

Steps for the command:
1. Check for an existing stack. If one exists, show it and ask: extend it, replace it, or start fresh?
2. Elicit the feature as a user story: "As a \<persona\> I want \<feature\> so that \<goal\>." This becomes the Stack: header. Push back on vague stories.
3. Brainstorm all the things that need to change to deliver the feature — files, commands, slash commands, specs, docs.
4. Group changes into candidate proposals. Apply the expand/contract pattern to any proposal that involves replacing something. Challenge any proposal with more than one concern.
5. Order proposals so each one builds cleanly on the last. No proposal should assume a future one.
6. Walk through each proposal with the user, stating explicitly: what the system can do after this commit that it couldn't before, and what is deliberately left for later.
7. Write `atomic/stack.md` in the standard format once the user confirms the sequence.

- Write `.claude/commands/at/stack.md` implementing the above
- Write behavioral spec for the `/at:stack` command
- Update context.md

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

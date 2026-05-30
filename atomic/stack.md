Stack: Add stack awareness to the atomic pipeline
As a developer I want the atomic pipeline to maintain an ordered proposal queue so that I can decompose a feature into atomic commits upfront, capture out-of-scope discoveries without losing focus, and always know what comes next.

===========
Proposal: Remove delta.md and all pipeline references to it

Pure cleanup — no behaviour changes. Everything that used delta.md already points to stack.md.

- Delete `atomic/delta.md` from the repo
- Remove delta.md from `CLAUDE.md` key paths section
- Remove any remaining delta.md mentions in `apply.md`
- Update context.md

===========
Proposal: Make `/at:propose` stack-aware (read-only)

Wire propose to surface the top stack proposal as the default intent. Propose reads the stack — it does not modify it.

- Update `propose.md`: on entry, if stack.md exists and has at least one Proposal block, surface the top proposal's intent as the default (user can confirm, modify, or ignore it)
- The proposal stays in stack.md while work is in progress — it is removed only when the commit lands (see next proposal)
- Write behavioral spec for propose + stack interaction
- Update context.md

===========
Proposal: Update `/at:merge` to pop the top stack proposal after a successful commit

Merge is where work is confirmed done — the right place to remove the completed proposal from the stack.

- Update `merge.md`: after `atomic commit` succeeds, if stack.md exists and has at least one Proposal block, remove the top Proposal block (from the `===========` separator down to, but not including, the next `===========`)
- If stack.md has no proposals remaining after the pop (only the Stack: header or empty), leave the file intact — the Stack: header is still useful context
- Write behavioral spec for merge + stack pop behaviour
- Update context.md

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

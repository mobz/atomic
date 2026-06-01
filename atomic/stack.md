Stack: Shared pipeline context docs
As a developer writing /at:* commands, I want pipeline file formats (spec, behaviour, stack) documented as shared context files injected into each command so that commands don't re-derive format knowledge inline, stay concise, and load only what they need.

===========
Proposal: Create behaviour-context.md and wire it into apply

Create `.claude/docs/behaviour-context.md` covering the behaviours/ BDD format. Wire it into apply.md, the only command that creates or updates behaviour files. Trim the inline format block.

**What the file covers:**
- `behaviours/` directory: feature-scoped scenario files, one file per domain (e.g. `pipeline-apply.md`)
- `## Behaviour: <feature name>` header format
- Scenario structure: `### <scenario name>` with `**Given:**`, `**When:**`, `**Then:**` lines
- Read existing file before writing — don't duplicate scenarios

**Wiring — add `@.claude/docs/behaviour-context.md` after the opening direction line in `apply.md`, before `## Entry`**

**Trim from apply.md:** remove the behaviour format block in step 2 (the fenced markdown template showing `## Behaviour:` / Given/When/Then) — keep the procedural instruction to create or update files for each feature touched

**Done when:** `/at:apply` on a commit that touches features still produces correctly-formatted behaviour files; the format block no longer appears inline in apply.md

===========
Proposal: Create stack-context.md and wire it into propose, apply, and stack

Create `.claude/docs/stack-context.md` covering the stack.md format. Wire it into the three commands that read from or write to the stack. Trim the inline format explanations.

**What the file covers:**
- stack.md format: `Stack:` header line, user story, `===========` separator, `Proposal:` blocks
- Ordering: top proposal = next commit; top-to-bottom = chronological work order
- The `Stack:` header block is always preserved — never removed
- How to add a deferred item from apply: `===========` then `Proposal:` then `Deferred from apply:` line
- How to pop the top proposal: remove from the proposal's `===========` line down to (not including) the next `===========`

**Wiring — add `@.claude/docs/stack-context.md` after the opening direction line, before the first section header:**
- `propose.md` (alongside spec-context, before `## Steps`)
- `apply.md` (alongside spec-context and behaviour-context, before `## Entry`)
- `stack.md` (before `## Steps`)

**Trim from each file:**
- `propose.md`: remove the inline stack format explanation in the pop step (step 6) — keep the procedural "remove that Proposal block" instruction
- `apply.md`: remove the fenced stack Proposal block format example in step 1 — keep the procedural instruction about where deferred items go (end vs top of stack)
- `stack.md`: remove the stack.md write format block in step 6 — keep the Rules list

**Done when:** `/at:propose` correctly surfaces and pops top proposals; `/at:apply` correctly appends deferred items; `/at:stack` writes correctly-formatted stack.md; format blocks no longer appear inline in those files

===========
Proposal: Explore preamble design for proactive atomicity challenge

**Not ready for implementation. This proposal captures a design direction that needs experimentation before it can be specified.**

**Root cause identified:** The existing commands embed atomicity rules as procedural checklist items in the steps section. Claude reads them as instructions to follow, not as a first-order instinct. The result: atomicity is applied when triggered (e.g. "the intent sentence needs a semicolon") but not proactively volunteered as a posture throughout the interaction.

**Hypothesis:** A short preamble paragraph, placed before the direction and steps, would set Claude's stance before it forms its working posture. Early tokens shape how later instructions are interpreted — a preamble stating the engineering identity ("you are an engineer who refuses vague proposals") makes the subsequent rules feel like expressions of that identity rather than an external checklist.

**Proposed command structure:**
```
# /at:command — Title

<preamble: 1 short paragraph — who you are, your non-negotiables, your stance>
<direction: "Your job is to...">
@.claude/docs/spec-context.md
@.claude/docs/stack-context.md   ← only what this command needs
<steps>
```

The injected context docs (from proposals 1–3) slot in between direction and steps — after Claude knows its role, but before the procedural detail. This keeps the preamble clean and lets format knowledge load in a position where it informs step execution.

**Open design questions:**
- What does the preamble actually say? One shared paragraph across all commands, or per-command variants? `/at:merge` probably doesn't need an atomicity stance; `/at:stack` and `/at:propose` need it most
- How opinionated can it be before it starts fighting the steps? There is a tension between a strong identity statement and a command that also needs to follow a specific procedure
- Does the attention management benefit hold across different context window sizes? Needs empirical testing — run the commands with and without the preamble, compare behaviour on ambiguous inputs
- Is "proactively challenge atomicity" best expressed in the preamble, or in the exploration phase of stack.md where it's structurally enforced by the Design Constraints section?

**Spike before implementing:** write two versions of the stack.md preamble and test against real feature explorations. Measure whether Claude volunteers splits unprompted vs waiting to be asked.

===========
Proposal: Remove `atomic/context.md` from the repository

`atomic/context.md` is a hand-maintained codebase summary updated during each apply. Its purpose — giving Claude orientation at the start of a session — is better served by Claude reading the actual codebase and git history directly. The file is easy to get out of sync, adds a maintenance burden to every apply, and may give Claude false confidence in stale information.

Design considerations:
- The file is currently referenced by `atomic show-context` and read at the start of `/at:apply`. Both references need to be removed or redirected.
- `atomic show-context` command (`bin/lib/atomic-show-context`) would need to be removed or repurposed.
- The dispatch entry in `bin/atomic` for `show-context` would be removed.
- `/at:apply` currently runs `atomic show-context` on entry — this instruction would be replaced with guidance to orient via `git log`, `bin/atomic status`, and direct file reading.
- `atomic/context.md` itself is committed and tracked — removal requires a `git rm`.
- Consider whether `atomic/.gitkeep` needs updating if context.md was the only non-ephemeral content driving the directory's existence (stack.md also lives there, so .gitkeep remains necessary).

This is an expand/contract candidate: the switch proposal removes the `show-context` call from apply.md and the remove proposal deletes the file and command — but given there is no parallel implementation to migrate to, a single commit removing the file, command, and apply.md reference is probably appropriate.

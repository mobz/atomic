Stack: Shared pipeline context docs
As a developer writing /at:* commands, I want pipeline file formats (spec, behaviour, stack) documented as shared context files injected into each command so that commands don't re-derive format knowledge inline, stay concise, and load only what they need.

===========
Proposal: Make `/at:apply` rollback restore the popped proposal and keep deferrals
Deferred from propose: split from "Make rollback and start over in `/at:apply` reset code without clobbering the stack" — the start-over half is the current spec.

Rollback runs `git reset --hard HEAD` then `atomic clean`. The reset also reverts `atomic/stack.md` to HEAD. **Rollback (data loss):** restoring the popped proposal is correct (the spec is discarded), but any deferrals added during the apply are silently lost.

Intended semantics:
- **Rollback** — revert code; the popped proposal returns to the top of the stack; deferrals added during the apply are kept.

Design considerations:
- Rollback: needs to know which block was popped. Options: diff HEAD's stack.md against the working tree (removed block = popped, added blocks = deferrals); or have propose record the popped block (spec.md already carries its content verbatim). Pick the simplest that is deterministic.
- This logic is too much for inline bash in apply.md — likely a new `atomic rollback` CLI command (revert code except stack.md, rebuild stack.md, `atomic clean`).
- Open decision: if apply also inserted an urgent deferral at the top of the stack, where does the restored popped proposal go? Leaning: after the urgent deferral ("urgent" means it must land before what follows).
- Update the "inline review — rollback" scenario in `behaviours/pipeline-apply.md`.

===========
Proposal: Make `/at:apply` rollback and start over remove untracked files created during the apply
Deferred from propose: split from "Make rollback and start over in `/at:apply` reset code without clobbering the stack".

Related gap noticed: `git reset --hard` (rollback) and `git restore` (start over) do not remove untracked files, so new files created during apply (e.g. a new `behaviours/*.md` or `.claude/docs/*.md`) survive both rollback and start over.

Design considerations:
- e.g. `git clean` scoped to exclude `atomic/spec.md` — but it must never delete untracked files the user created outside this apply. Options: record untracked files present when apply starts and only remove new ones; or have apply list files it creates.
- Update the "inline review — rollback" and "inline review — start over" scenarios in `behaviours/pipeline-apply.md`.

===========
Proposal: Rewrite README.md and update CLAUDE.md to describe the current pipeline

`README.md` still describes the original design: four stages (`propose → apply → review → merge`), `/propose` `/review` `/merge` without the `at:` namespace, `atomic advance`, `atomic merge-specs`, `--human`, `.atomic/`, `specs/`, and state stored in git refs.

Rewrite it to match current reality:
- Pipeline: `propose → apply → merge`, plus `/at:stack` for decomposing a feature into a proposal stack
- Commands: `/at:propose`, `/at:apply`, `/at:merge`, `/at:stack`
- CLI reference from `bin/lib/atomic-help` (status, progress, reset, show-spec, show-context, show-stack, commit, push, clean; `--json`)
- Structure: `.claude/commands/at/`, `.claude/docs/`, `atomic/` (spec.md ephemeral; context.md, stack.md committed), `behaviours/`, `bin/`
- State: derived from spec.md checkbox state (none/proposed/applying/ready)

CLAUDE.md: add `/at:merge` to the Slash Commands table (it is missing) and replace "Implement → specs → test loop" with "behaviours" in the Pipeline Stages table.

**Done when:** README.md contains no reference to `advance`, `merge-specs`, `/review`, `.atomic/`, `specs/`, `--human` or git-ref state; CLAUDE.md lists all four `/at:*` commands.

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

===========
Proposal: Add behaviour scenarios for uncovered `/at:apply` and `/at:merge` entry states
Deferred from propose: while specifying the stale-behaviours rewrite, found that `behaviours/pipeline-apply.md` has no scenarios for `/at:apply` entered in state `none` (tell user to run `/at:propose`), `applying` (re-entry: show progress, list remaining items, continue), or `ready` (skip to summary); and `behaviours/pipeline-merge.md` has no scenarios for `/at:merge` entered in `applying` (show progress, suggest `/at:apply`), `proposed` (tell user to run `/at:apply`), or `none` (nothing to merge). Adding coverage is a separate concern from correcting stale scenarios.

===========
Proposal: Make `atomic commit` keep spec.md when the git commit fails
Deferred from propose: `bin/lib/atomic-commit` runs `rm -f "$ATOMIC_DIR/spec.md"` before `git add -A` / `git commit`. If the commit fails (nothing to commit, hook failure, etc.) the script exits non-zero under `set -e` but the spec is already gone and the pipeline drops to state `none`. Fix: remove spec.md only after `git commit` succeeds — e.g. `git add -A -- . ':!atomic/spec.md'`, commit, then `rm -f` (or remove first but restore on failure). Must still ensure spec.md is never committed. Update the "nothing to commit" scenario in `behaviours/pipeline-merge.md` and the commit scenarios in `behaviours/cli-atomic.md`.

===========
Proposal: Fix the `ready` entry in `/at:apply` pointing at the wrong step
`.claude/commands/at/apply.md` line 14 says "**ready** — all items done. Skip straight to **Step 5** (show summary)." but step 5 is "Update context" and the summary is "### 6. Show summary and ask". Change it to "Skip straight to **Step 6** (show summary)." — resuming an interrupted apply should re-show the summary for approval without re-running the context update. Line 54 ("proceed to Step 5") is correct and stays: on first completion, context is updated before the summary.

Consider adding a `/at:apply` entered-in-`ready` scenario to `behaviours/pipeline-apply.md` — or leave it to the "Add behaviour scenarios for uncovered `/at:apply` and `/at:merge` entry states" proposal above.

Note: `ready` means all items are ticked, not that the user approved — the summary/approve step (Review 3) is the only code review, so the `ready` entry must land on it.

===========
Proposal: State that stack additions discovered during a commit's work are committed with that commit
Deferred from discussion of stack-commit semantics. Rule: a commit = stack removals (the pop) + stack additions discovered while doing that commit's work + behaviour changes + code changes. Today this is implicit for apply deferrals (they ride along via `git add -A`) and undefined for propose splits.

Definition to introduce (the term is used in apply.md — "Deferred items", "Deferred from apply:" — but never defined):

> **Deferral:** a Proposal block for work discovered while preparing or doing the active spec (during `/at:propose` or `/at:apply`) that is outside its scope. Deferrals are part of that spec's story and are committed with the spec's commit. A proposal **unrelated** to the active spec's work is not a deferral — it is **planning**, and is committed on its own via the stack-add path, whatever the pipeline state.

The boundary is "did this come out of the active spec's work?", not "is a spec active?" — you can add unrelated items mid-apply without them riding along in the spec's commit. Widen the block format's source line to `Deferred from propose:` / `Deferred from apply:`. Decide where the definition lives: `CLAUDE.md`, or the planned `.claude/docs/stack-context.md` if that has landed by then (it is the natural home for stack format and semantics).

- `apply.md` step 1: state that deferred Proposal blocks are part of this apply's commit (and are listed in the summary's Deferred items, which already exists).
- `propose.md` step 3 says "suggest adding them to the stack" without saying who writes them or when. Define it: when the user accepts a split, step 6 writes the split-off proposals to the stack alongside the pop (immediately after the Stack: header, i.e. as the next proposals), so they land in this spec's commit.
- Update `CLAUDE.md` Key Paths entry for `atomic/stack.md` to reflect the rule.
- Behaviours: add a propose scenario for "split accepted — split-off proposals written to stack with the pop"; note in pipeline-apply that deferrals are committed with the apply.
- Wording-only for apply; propose gains a defined write. Does not cover `/at:stack` or ad-hoc additions — see the stack-only commit proposal.

===========
Proposal: Add a CLI command that appends an unrelated proposal to the stack and commits it on its own, in any pipeline state
Deferred from discussion of stack-commit semantics. Unrelated stack additions (planning, not deferrals — see the deferral definition proposal) currently get swept into whatever `atomic commit` runs next via `git add -A`. Observed in this repo: `6017fcc` (behaviour-context) also carries four unrelated README/behaviour proposals. You should be able to add an unrelated item at any time — including mid-propose or mid-apply — without it touching the in-progress work, and without the in-progress work leaking into it.

**The command is about adding an item, not committing whatever is in stack.md.** It takes the proposal (intent + body) as input, appends it, and commits only that. Name it for what it does, e.g. `atomic stack-add` (working name `commit-stack` from discussion).

**Why not commit the working-tree stack.md:** mid-apply the working tree's stack.md also contains the pop (top proposal removed) and any deferrals — both belong to the spec's commit, not this one.

**Why not stash → append → commit → stash pop:** tested on a scratch clone. When the in-progress work has also appended a deferral at the end of stack.md, `git stash pop` conflicts on stack.md (both sides append at EOF). It also briefly removes the user's in-progress changes from the working tree.

**Approach (tested on a scratch clone mid-apply — popped top proposal, a deferral at the end, a code change, spec.md present):** build the commit from HEAD without touching the working tree or real index:
```
export GIT_INDEX_FILE=$(mktemp -u); git read-tree HEAD
blob=$( { git show HEAD:atomic/stack.md; printf '%s' "$BLOCK"; } | git hash-object -w --stdin )
git update-index --cacheinfo 100644,$blob,atomic/stack.md
tree=$(git write-tree); rm -f "$GIT_INDEX_FILE"; unset GIT_INDEX_FILE
c=$(git commit-tree "$tree" -p HEAD -m "Plan: <intent>"); git update-ref HEAD "$c"
git reset -q -- atomic/stack.md        # real index entry follows new HEAD
printf '%s' "$BLOCK" >> atomic/stack.md  # mirror the append in the working tree
```
Result: the new commit contains only the appended block (+4 lines); the remaining working-tree diff is exactly the pop + deferral + code change; spec.md untouched.

Design considerations:
- Placement: always the end of the stack (the user's "add to end of stack"). Urgent/prerequisite items are deferrals and go through apply's top-of-stack path instead.
- Input: intent as an argument, body via stdin (or `--body-file`); validate the block (`===========` / `Proposal:` lines) before committing.
- If `atomic/stack.md` does not exist in HEAD: create it from the block (no Stack: header — or require one; decide).
- `atomic/stacks/*` (parked stacks): out of scope unless a `--stack <name>` target is cheap.
- Push: decide whether `stack-add` pushes immediately (via `atomic push`) or leaves it for the next merge. Note that a mid-apply `stack-add` puts a commit between the spec's base and its eventual commit — fine for linear history, but rollback/start-over (`git reset --hard HEAD`) now resets to the plan commit, which is what we want.
- Wiring: `/at:stack` "extend" could append each new proposal via this command; "replace/start fresh" rewrites the whole file and should require no active spec (it would conflict with the pop). Document ad-hoc use in CLAUDE.md.
- Consider whether `atomic commit` with no spec.md should keep its fallback (message "atomic commit", `git add -A`) or refuse — it is the path that currently sweeps stray stack edits into vague commits.
- Expand/contract: adding the CLI command is additive; wiring it into `/at:stack` and CLAUDE.md is the switch. Propose as two commits.
- Behaviours: `cli-atomic.md` scenarios — adds in state `none`; adds mid-apply leaving pop/deferrals/code uncommitted; rejects a malformed block.

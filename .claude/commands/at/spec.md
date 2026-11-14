# /at:spec — Define an Atomic Commit

Your job is to help the user define exactly one atomic commit: a single, complete, revertable change.

If invoked with arguments (`$ARGUMENTS`), use them as the starting intent — skip the discovery questions and go straight to step 3.

@.claude/docs/spec-context.md
@.claude/docs/stack-context.md
@.claude/docs/interaction-context.md

## Steps

1. **Orient** — run `atomic status` to check the current state:
   - **State: proposed** — there's an existing spec. Show its intent, then:

     > **Review** — walk through the current spec
     > **Change** — revise it; go to **Step 3** with it as the starting point
     > **Fresh** — discard it (`atomic clean`) and start a new one
     > Or tell me what to change

   - **State: applying** — an apply is in progress. Show `atomic progress`, then:

     > **Continue** — stop here and resume the apply
     > **Change** — revise the spec; go to **Step 3** with it as the starting point
     > **Fresh** — discard the spec (`atomic clean`) and start a new one
     > Or tell me what to change

     On **Continue**, end with `Next: /at:apply — resume implementing this spec`.
   - **State: ready** — all changes are complete. Show the intent, then:

     > **Apply** — stop here so you can merge it
     > **Fresh** — discard the spec (`atomic clean`) and start a new one
     > Or tell me what to change

     On **Apply**, end with `Next: /at:apply — review the summary and merge`.
   - **Fresh** in any of these states: run `atomic clean` first, then continue as for **State: none**.
   - **State: none** and `$ARGUMENTS` provided — proceed directly to **Step 3**.
   - **State: none** and no `$ARGUMENTS` — run `atomic show-stack`. If a Proposal block exists, surface the top proposal:
     - Show its intent and context to the user.
     - If the proposal contains technical detail (implementation notes, architectural decisions, edge cases), note that this was captured during exploration and may be stale — the codebase may have changed since. Flag it as a starting point to verify during apply, not ground truth.
     - Then:

       > **Proceed** — spec this proposal as written
       > **Modify** — use it as a starting point, with follow-up questions
       > **Fresh** — ignore it and start from something else
       > Or tell me what to change

     - **Proceed** — use the proposal's intent as the starting point; go to **Step 3** (skip Discover).
     - **Modify** — use the proposal's intent as a starting point but ask follow-up questions; go to **Step 3**.
     - **Fresh** — ignore the stack entry and go to **Step 2**.
     - The stack is not modified at this point — if a spec is written from this proposal, step 6 pops it.
   - If no stack proposal exists: proceed to **Step 2**.

2. **Discover** — *(skip if `$ARGUMENTS` provided or user is proceeding with a stack proposal)* ask the user conversationally:
   - What do you want this commit to do?
   - Why now? What's driving this?
   - What does done look like — how will you know it worked?
   - What should NOT be touched in this commit? (be explicit)

3. **Clarify** — ask follow-up questions until you can write a precise spec. If `$ARGUMENTS` was provided or a stack proposal is being used, treat its intent as the starting point and probe for anything missing (scope, out-of-scope, done criteria).

   Actively challenge scope creep. A good atomic commit is small enough that a reviewer can hold the entire change in their head and verify its correctness in one pass. If the spec has more than one concern, a reviewer cannot confirm that concern A is correct without also reasoning about concern B — and bugs hide in that interaction. Signs a spec needs splitting:
   - The intent sentence needs a semicolon or "and"
   - The Changes list mixes unrelated files or subsystems
   - Some changes would still make sense to ship without the others
   - It would be hard to write a focused "Done when" that covers all the changes precisely

   When you spot these signs, don't just flag it — propose the split. Name the two (or three) commits it should become: one becomes this spec, and if the user accepts the split, the split-off proposals are deferrals that step 6 writes to the stack. Refuse to write a spec you wouldn't be confident reviewing yourself.

4. **Summarise back** — present the spec in plain language before writing anything, then:

   > **Write** — write `atomic/spec.md` and update the stack
   > Or tell me what to change

   If they want changes, loop back.

5. **Write the spec** — on **Write**, write `atomic/spec.md` using the spec.md format. If the proposal (from the stack or from `$ARGUMENTS`) contained detailed design notes — steps, rules, examples, format definitions, implementation approach — carry them forward verbatim into the relevant Changes items or as an additional context block. Do not compress them into one-line summaries. The spec must be fully self-contained; once the proposal is popped from the stack, it is gone.

6. **Update the stack** — in the same step as writing the spec, update `atomic/stack.md` (see the stack format):
   - **Pop** — if this spec was sourced from the top stack proposal, pop that Proposal block. If the spec came from `$ARGUMENTS` or a fresh discovery, there is nothing to pop.
   - **Split-offs** — write the proposals from an accepted split immediately after the `Stack:` header block, so they are the next proposals.
   - **Other deferrals** — write any other out-of-scope findings from this conversation as `Deferred from propose:` blocks, placed at the end or top of the stack by urgency.

   These deferrals are committed with this spec's commit.

7. **Hand off** — tell the user the spec is written, then end with `Next: /at:apply — implement this spec`.

## Constraints
- Keep the spec tight. If the intent sentence needs a semicolon, it's two commits.
- Never start implementing during spec — that's apply's job.
- Never write to `behaviours/` directly — that happens during apply.

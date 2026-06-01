# /at:propose — Define an Atomic Commit

Your job is to help the user define exactly one atomic commit: a single, complete, revertable change.

If invoked with arguments (`$ARGUMENTS`), use them as the starting intent — skip the discovery questions and go straight to step 3.

@.claude/docs/spec-context.md

## Steps

1. **Orient** — run `atomic status` to check the current state:
   - **State: proposed** — tell the user there's an existing proposal and show the intent. Ask: review it, change it, or start fresh?
   - **State: applying** — warn that an apply is in progress. Show `atomic progress`. Ask: continue the apply, change the spec, or start fresh?
   - **State: ready** — tell the user all changes are complete. Suggest running `/at:apply` to merge, or confirm if they want to start a new proposal.
   - If user wants to start fresh: run `atomic reset` first, then proceed.
   - **State: none** and `$ARGUMENTS` provided — proceed directly to **Step 3**.
   - **State: none** and no `$ARGUMENTS` — run `atomic show-stack`. If a Proposal block exists, surface the top proposal:
     - Show its intent and context to the user.
     - If the proposal contains technical detail (implementation notes, architectural decisions, edge cases), note that this was captured during exploration and may be stale — the codebase may have changed since. Flag it as a starting point to verify during apply, not ground truth.
     - Ask: proceed with this, modify it, or start fresh with something else?
     - **Proceed** — use the proposal's intent as the starting point; go to **Step 3** (skip Discover).
     - **Modify** — use the proposal's intent as a starting point but ask follow-up questions; go to **Step 3**.
     - **Start fresh** — ignore the stack entry and go to **Step 2**.
     - The stack is not modified regardless of what the user chooses — that is `/at:merge`'s job.
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

   When you spot these signs, don't just flag it — propose the split. Name the two (or three) commits it should become and suggest adding them to the stack. Refuse to write a spec you wouldn't be confident reviewing yourself.

4. **Summarise back** — present the spec in plain language before writing anything. Confirm with the user. If they want changes, loop back.

5. **Write the spec** — once confirmed, write `atomic/spec.md` using the spec.md format. If the proposal (from the stack or from `$ARGUMENTS`) contained detailed design notes — steps, rules, examples, format definitions, implementation approach — carry them forward verbatim into the relevant Changes items or as an additional context block. Do not compress them into one-line summaries. The spec must be fully self-contained; once the proposal is popped from the stack, it is gone.

6. **Pop the stack** — if this spec was sourced from the top stack proposal, remove that Proposal block from `atomic/stack.md` (from its `===========` line down to, but not including, the next `===========`). The Stack: header block is always preserved. If the spec came from `$ARGUMENTS` or a fresh discovery, skip this step.

7. **Confirm** — tell the user the spec is written. Say: "Ready to apply. Run `/at:apply` when you want the agent to implement this."

## Constraints
- Keep the spec tight. If the intent sentence needs a semicolon, it's two commits.
- Never start implementing during propose — that's apply's job.
- Never write to `behaviours/` directly — that happens during apply.

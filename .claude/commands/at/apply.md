# /at:apply — Implement and Review

Your job is to implement the spec, run tests, and get user sign-off. Committing and pushing is handled by `/at:merge`.

@.claude/docs/spec-context.md
@.claude/docs/behaviour-context.md
@.claude/docs/stack-context.md

## Entry

Run `atomic status`. Check the state:
- **none** — no spec to apply. Tell the user to run `/at:propose` first.
- **proposed** — Begin the loop.
- **applying** — re-entry. Show `atomic progress`, list remaining `[ ]` items, continue from where left off.
- **ready** — all items done. Skip straight to **Step 5** (show summary).

Read the spec: `atomic show-spec`.  
Read context: `atomic show-context`.

---

## The Loop

### 1. Implement

Work through the unchecked `- [ ]` items in the spec. As each change is made, update the checkbox in `atomic/spec.md` from `- [ ]` to `- [X]`. Be precise — mark an item `[X]` only when it is fully implemented.

Complete the concern: also update everything the change makes stale or untested — tests, README and other docs, help text, behaviours — even if the spec does not list it, so the codebase is releasable after this commit.

If anything is clearly out of scope (unrelated to the concern), do not implement it. Add it to `atomic/stack.md` as a deferred Proposal block (see the stack format). Where it goes depends on urgency:

- **End of stack** — for clearly out-of-scope items (future work, nice-to-haves, unrelated improvements). Append after the last `===========` block.
- **Top of stack** — for urgent bugs or required prerequisites that must land before subsequent proposals can work. Insert after the Stack: header block, before the first `===========`.

### 2. Update behavioral domain specs

For each feature touched, create or update the corresponding behaviour file directly in `behaviours/`. Name files by domain (e.g. `pipeline-apply.md`). Read the existing file first if one exists — don't duplicate.

### 3. Run tests

Run the project test suite. Fix failures and re-run. If stuck after 3 attempts, surface the failure clearly and wait for direction.

### 4. Check progress

Run `atomic progress`. If any `[ ]` items remain, go back to **Step 1**.

When `atomic progress` shows all items complete (e.g. `5/5 changes complete`), proceed to Step 5.

### 5. Update context

Update `atomic/context.md` with anything learned during this iteration.

### 6. Show summary and ask

Write a PR-quality summary with no diff output. Structure it as:

**What changed**
A checklist of every meaningful change. Mention tests inline where they were written (e.g. "added `foo` parameter to `xyz` + unit test"). Be specific — file and function names, not vague descriptions.

**Manual verification needed** *(only if applicable)*
Call this section out only when something cannot be automatically tested — e.g. no test suite exists, a UI interaction, an external integration. Skip this section entirely if full test coverage exists.

**Deferred items** *(only if applicable)*
List anything added to `atomic/stack.md` during this apply, so the user knows what was intentionally left out.

**Worth double-checking** *(only if applicable)*
Flag non-obvious decisions, assumptions made, or edge cases the user should eyeball.

Then present the decision:

> **Approve** — merge now (commit + push)  
> **Rollback** — revert all changes and clear pipeline  
> Or tell me what to change

---

## Decisions

### Approve

The user says approve (or equivalent).

Invoke the `/at:merge` skill to commit and push.

### Rollback

The user says rollback or abandon — snapshot everything to an unreferenced commit, then revert everything to HEAD: tracked files including the stack (the popped proposal returns; deferrals added during this apply are dropped), untracked files created during the apply, and the spec:

```bash
atomic rollback
```

Confirm: "Changes reverted. Pipeline cleared." and relay the snapshot line from the output — the SHA the discarded changes are available at and the restore command — so the user can get them back if needed.

If `atomic rollback` printed discarded deferrals, list them by intent and ask whether to add any back to the end of the stack. Don't assume yes — a rollback is often a change of direction, and deferrals found while on the wrong track may be wrong too. Re-add only the ones the user picks, verbatim from the rollback output.

Then: "Run `/at:propose` to start fresh."

### Discuss

Anything else is a discuss round — a correction, missing test, scope adjustment, or "start over".

1. If the feedback doesn't tell you what should change (e.g. a bare "start over"), ask what was wrong and wait.
2. If the feedback changes scope or approach, update `atomic/spec.md` to reflect it — add, change, or remove `[ ]` items, or add a note under **Assumptions** — so the new information is recorded.
3. Decide how to act on it:
   - **Adjust in place** (default) — make the change directly. Mark newly completed items `[X]`, uncheck items that need rework.
   - **Start over** — if the new information means the current implementation is the wrong base to build on (wrong approach, tangled changes, easier to redo than to fix), tell the user you are starting over and why, then snapshot the previous attempt and revert everything except the spec and the stack, unticking every checkbox:

     ```bash
     atomic start-over
     ```

     Relay the snapshot line from the output — the SHA the previous attempt is available at and the restore command.
4. Go back to **Step 1**.

---

## Hard constraints
- Never implement anything unrelated to the spec's concern — add out-of-scope items to `atomic/stack.md` as a new Proposal block. Updates the change makes necessary (tests, docs, behaviours) are part of the concern, not out of scope.
- Never commit or push — that is `/at:merge`'s job.
- Never mark `[X]` until the change is fully implemented and tested.

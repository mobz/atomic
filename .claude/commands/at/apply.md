# /at:apply — Implement and Review

Your job is to implement the spec, run tests, and get user sign-off. Committing and pushing is handled by `/at:merge`.

@.claude/docs/spec-context.md

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

If anything is clearly out of scope, do not implement it. Add it to `atomic/stack.md` as a new Proposal block. Where it goes depends on urgency:

- **End of stack** — for clearly out-of-scope items (future work, nice-to-haves, unrelated improvements). Append after the last `===========` block.
- **Top of stack** — for urgent bugs or required prerequisites that must land before subsequent proposals can work. Insert after the Stack: header block, before the first `===========`.

Format:

```
===========
Proposal: <brief description of the deferred item>
Deferred from apply: <what was noticed and why it's out of scope>
```

If `atomic/stack.md` does not exist, create it with just the Proposal block.

### 2. Update behavioral domain specs

For each feature touched, create or update the corresponding behaviour file directly in `behaviours/` using the behavioural format:

```markdown
## Behaviour: <feature name>

### <scenario name>
- **Given:** system state / preconditions
- **When:** action or event
- **Then:** observable outcome(s)
```

Name files by domain (e.g. `pipeline-apply.md`). Read the existing file first if one exists — don't duplicate.

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

The user says rollback or abandon — revert code and delete the spec:

```bash
git reset --hard HEAD
atomic reset
```

Confirm: "Changes reverted. Pipeline cleared. Run `/at:propose` to start fresh."

### Start over / reimplement from scratch

The user says "start over" or "reimplement from scratch" — revert code but keep the spec, reset checkboxes:

```bash
git reset --hard HEAD
python3 -c "
import re, sys
content = open('atomic/spec.md').read()
content = re.sub(r'^- \[X\]', '- [ ]', content, flags=re.MULTILINE)
open('atomic/spec.md', 'w').write(content)
"
```

Go back to **Step 1** and implement from scratch.

### Discuss

Anything else is a discuss round — a correction, missing test, scope adjustment.

1. Make the code change directly if it's clear.
2. If the feedback changes scope, update `atomic/spec.md` to reflect it (add/remove `[ ]` items as needed).
3. Update checkboxes — mark newly completed items `[X]`, uncheck items that need rework.
4. Go back to **Step 1**.

---

## Hard constraints
- Never implement anything not in the spec's **Changes** list — add out-of-scope items to `atomic/stack.md` as a new Proposal block.
- Never commit or push — that is `/at:merge`'s job.
- Never mark `[X]` until the change is fully implemented and tested.

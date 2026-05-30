# /at:apply — Implement, Review, and Merge

You own the full loop from implementation through to a committed, pushed result. You do not stop until the user approves or rolls back.

## Entry

Run `atomic status`. If stage is not `propose`, stop and tell the user to run `/at:propose` first.

Read the spec: `atomic show-spec`.  
Read context: `atomic show-context`.

---

## The Loop

Advance to apply stage: `atomic advance apply`

### 1. Implement

Make the changes described in the spec's **Changes** list. If this is a re-entry after a discuss round, read the user's feedback and adjust the existing work — do not start from scratch unless the user said "start over" or "reimplement from scratch" (see Rollback below).

If anything is clearly out of scope, note it in `atomic/delta.md` and do not implement it.

### 2. Update behavioral domain specs

For each feature touched, create or update the corresponding spec file in `atomic/` using the behavioral format:

```markdown
## Spec: <feature name>

### <scenario name>
- **Given:** system state / preconditions
- **When:** action or event
- **Then:** observable outcome(s)
```

Name files by domain (e.g. `pipeline-apply.md`). If a spec exists in `specs/`, copy it to `atomic/` first — don't duplicate.

### 3. Run tests

Run the project test suite. Fix failures and re-run. If stuck after 3 attempts, surface the failure clearly and wait for direction.

### 4. Merge specs and update context

```bash
atomic merge-specs
```

Update `atomic/context.md` with anything learned during this iteration.

### 5. Show summary and ask

Write a PR-quality summary with no diff output. Structure it as:

**What changed**
A checklist of every meaningful change. Mention tests inline where they were written (e.g. "added `foo` parameter to `xyz` + unit test"). Be specific — file and function names, not vague descriptions.

**Manual verification needed** *(only if applicable)*
Call this section out only when something cannot be automatically tested — e.g. no test suite exists, a UI interaction, an external integration. Skip this section entirely if full test coverage exists.

**Deferred items** *(only if applicable)*
List anything added to `atomic/delta.md` during this apply, so the user knows what was intentionally left out.

**Worth double-checking** *(only if applicable)*
Flag non-obvious decisions, assumptions made, or edge cases the user should eyeball.

Then present the decision:

> **Approve** — commit and push  
> **Rollback** — revert all changes and clear pipeline  
> Or tell me what to change

---

## Decisions

### Approve

The user says approve (or equivalent).

Commit and push:

```bash
atomic commit
atomic push
```

Confirm: commit SHA, message, branch. Say "Pipeline complete. Run `/at:propose` to start the next commit."

### Rollback

The user says rollback or abandon:

```bash
git reset --hard HEAD
atomic reset
```

Confirm: "Changes reverted. Pipeline cleared. Run `/at:propose` to start fresh."

### Start over / reimplement from scratch

The user says "start over" or "reimplement from scratch" — revert code but keep the spec, then loop:

```bash
git reset --hard HEAD
atomic advance apply
```

Go back to **Step 1** and implement from scratch.

### Discuss

Anything else is a discuss round — a correction, missing test, scope adjustment.

1. Make the code change directly if it's clear.
2. If the feedback changes scope, update `atomic/spec.md` to reflect it.
3. `atomic advance apply`
4. Go back to **Step 1** — adjust existing work, do not reset.

---

## Hard constraints
- Never implement anything not in the spec's **Changes** list — add out-of-scope items to `atomic/delta.md`.
- Never commit or push directly — only through the Approve path above.

# /at:review — Review the Implementation

Your job is to help the user review what was implemented and decide: approve, request changes, or abandon.

## Steps

1. **Check stage** — run `atomic status`. If stage is not `apply`, tell the user and stop.

2. **Show the diff** — run `git diff HEAD` (or `git diff --staged` if changes are staged). Display it clearly.

3. **Show updated specs** — run `ls specs/` and display any spec files that were added or modified as part of this commit. Show the spec content alongside the diff so the user can see spec and code together.

4. **Summarise** — in plain language (not bullet soup), explain:
   - What changed and why
   - What was explicitly left alone (per the out-of-scope list)
   - Anything notable that came up during implementation (from `atomic/context.md`)

5. **Ask explicitly** — present three options:
   - **Approve** — implementation looks good, proceed to merge
   - **Request changes** — something needs to be different (ask what)
   - **Abandon** — scrap this and start over

6. **Handle the decision:**
   - **Approve**: run `atomic advance review`. Say "Ready to merge. Run `/at:merge` to commit and push."
   - **Request changes**: append the user's notes to `atomic/spec.md` under a `**Revision notes:**` section. Run `atomic advance propose`. Say "Spec updated. Run `/at:apply` again when ready."
   - **Abandon**: run `atomic reset`. Confirm that `atomic/` ephemeral files are cleared. Say "Clean slate — run `/at:propose` to start fresh."

## Tone
Be direct. The user is reviewing their own work — don't over-explain the diff, but do flag anything surprising or worth double-checking.

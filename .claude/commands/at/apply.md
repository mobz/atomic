# /at:apply — Implement the Spec

You are the implementation agent. Your job is to faithfully implement what the spec describes — nothing more, nothing adjacent.

## Steps

1. **Check stage** — run `atomic status`. If stage is not `propose`, stop and tell the user to run `/at:propose` first.

2. **Read the spec** — run `atomic show-spec`. Read it carefully. You are allowed to implement ONLY what is listed in **Changes**. The **Out of scope** section is a hard boundary.

3. **Read context** — run `atomic show-context`. If it exists, use it to understand the current codebase state before starting.

4. **Implement** — make the changes described in the spec. Work through the checklist items one by one. Stay in scope.

5. **Run tests** — after implementation, run the project test suite. Check `package.json` for a test script, or look for a `Makefile`, `pytest`, etc.
   - If tests pass: proceed.
   - If tests fail: diagnose, fix, re-run. Loop until passing.
   - If stuck after 3 attempts: stop, surface the failure to the user with a clear description of what's failing and why you're stuck. Wait for direction.

6. **Write behavioral domain specs** — for each feature or system touched by this commit, create or update the corresponding spec file in `.atomic/` using the behavioral format:

   ```markdown
   ## Spec: <feature name>

   ### <scenario name>
   - **Given:** system state / preconditions
   - **When:** action or event
   - **Then:** observable outcome(s)

   ### <another scenario>
   ...
   ```

   Name files by feature domain, not by commit (e.g. `cli-atomic-status.md`, `pipeline-propose.md`).
   If a domain spec already exists in `specs/`, copy it to `.atomic/` first and update it — don't create a duplicate.

7. **Merge specs** — run `atomic merge-specs`. This copies the named domain spec files from `.atomic/` into `specs/`.

8. **Update context** — update `.atomic/context.md` with anything learned during implementation that future commits should know:
   - Key architectural decisions made
   - Non-obvious constraints encountered
   - Files that are particularly sensitive or complex
9. **Advance stage** — run `atomic advance apply`.

10. **Confirm** — tell the user implementation is complete and tests pass. Say: "Ready to review. Run `/at:review` to inspect the changes."

## Hard constraints
- Never implement anything not in the spec's **Changes** list.
- If you notice something out of scope that should be fixed, add it to `.atomic/delta.md` as a future propose candidate — do not fix it now.
- Never commit directly — that happens in `/at:merge`.
- Never push directly — that happens in `/at:merge`.

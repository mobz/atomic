`atomic/consistency.md` is the repo's commit-consistency manifest — committed, and maintained alongside the code. It lists every artefact that must agree with the code at every commit (README, docs, help text, tests, behaviours, infra, CI, schemas, migrations, generated files, examples — whatever the repo has) and what in each must agree.

**Format:**

```markdown
# Commit consistency

<one or two lines: what this file is for>

- `atomic/consistency.md` — this file; add, update, or remove entries as artefacts that must stay in step are added, renamed, or removed
- `<path or glob>` — <what must agree with what>
```

- A checklist, not documentation: one bullet per artefact, each naming a real path or glob and what must agree with what (e.g. "`README.md` — CLI reference matches `atomic help`").
- The first entry is always the file itself.

**Rules:**

- Every listed artefact the change makes stale is part of the concern — update it in the same commit.
- Listed artefacts the change does not affect are left alone; the manifest is not a licence for drive-by edits.
- When the change adds, renames, or removes an artefact or kind of component that must stay in step (a new command, a new doc, a new generated file), add, update, or remove its manifest entry in the same commit.

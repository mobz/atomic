## Behaviour: Pipeline — Init Command

### init — fresh repo
- **Given:** a git repo with a README, a test directory, and a CI workflow, where `atomic init` has just copied the commands in (or has not yet been run)
- **When:** user runs `/at:init`
- **Then:** Claude runs `atomic init` and relays its `created` / `exists` list; surveys the repo; shows one drafted manifest bullet per artefact (README, tests, CI, …), each naming a real path or glob and what must agree with what, with the manifest's own entry first; ends with **Write** / "Or tell me what to change"

### init — entries approved
- **Given:** Claude has shown the drafted manifest entries
- **When:** the user approves (all, or a subset after discussion)
- **Then:** only the approved entries are written to `atomic/consistency.md`; nothing else is edited

### init — nothing approved
- **Given:** Claude has shown the drafted manifest entries
- **When:** the user approves none of them
- **Then:** `atomic/consistency.md` is left unchanged

### init — manifest already has entries
- **Given:** `atomic/consistency.md` already lists artefacts beyond its self-entry
- **When:** user runs `/at:init`
- **Then:** Claude drafts only additions — artefacts the manifest does not yet cover — and leaves existing entries as they are

### init — CLAUDE.md merge drafted
- **Given:** the repo already had its own `CLAUDE.md`, so `atomic init` left it alone and printed the merge hint naming atomic's `CLAUDE.md`
- **When:** user runs `/at:init` and the manifest step is done
- **Then:** Claude reads both files and drafts the sections of atomic's that the repo's file is missing (pipeline, start-of-session check, stages, hard rules, slash commands, key paths, behaviour format), placed to fit the repo's headings and order rather than appended as one block; shows the exact changes, not the whole file, ending with **Write** / "Or tell me what to change"

### init — CLAUDE.md merge approved
- **Given:** Claude has shown the drafted CLAUDE.md changes
- **When:** the user approves (after any discussion)
- **Then:** only the approved changes are written to `CLAUDE.md`; if the user approves none, `CLAUDE.md` is unchanged

### init — CLAUDE.md conflict flagged
- **Given:** the repo's `CLAUDE.md` has a rule that contradicts atomic's (e.g. "use conventional commits", "push to a feature branch")
- **When:** Claude drafts the merge
- **Then:** the conflict is called out for the user to decide; neither rule is dropped or rewritten silently

### init — CLAUDE.md already merged
- **Given:** the repo's `CLAUDE.md` already holds every section of atomic's (e.g. `/at:init` was run before)
- **When:** user runs `/at:init`
- **Then:** Claude says `CLAUDE.md` is already up to date and drafts no changes

### init — no CLAUDE.md of its own
- **Given:** the repo had no `CLAUDE.md`, so `atomic init` copied atomic's
- **When:** user runs `/at:init`
- **Then:** the CLAUDE.md step is skipped

### init — hand off
- **Given:** the review step is done
- **When:** `/at:init` finishes
- **Then:** Claude lists the files `atomic init` created, and the manifest and `CLAUDE.md` if they were edited, tells the user to review and commit them, and says "atomic is set up. Run `/at:propose` to define your first commit."; nothing is committed or pushed

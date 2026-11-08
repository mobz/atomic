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

### init — existing CLAUDE.md
- **Given:** the repo already had its own `CLAUDE.md`, so `atomic init` left it alone and printed a merge hint
- **When:** user runs `/at:init`
- **Then:** Claude says the CLAUDE.md merge is not automated yet and relays the hint (merge atomic's rules in by hand from the path it names); `CLAUDE.md` is not edited

### init — hand off
- **Given:** the review step is done
- **When:** `/at:init` finishes
- **Then:** Claude lists the files `atomic init` created and the manifest if it was edited, tells the user to review and commit them, and says "atomic is set up. Run `/at:propose` to define your first commit."; nothing is committed or pushed

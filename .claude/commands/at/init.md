# /at:init — Set Up atomic in a Repo

Your job is to finish installing atomic in this repo: run `atomic init`, then draft the repo's commit-consistency manifest from what is actually in it, writing only the entries the user approves.

@.claude/docs/consistency-context.md

## Steps

1. **Install** — run `atomic init`. It never overwrites a file and commits nothing, so it is safe to re-run. Relay its `created` / `exists` list.

2. **Survey** — look at what the repo actually holds: `git ls-files` and the top-level layout. Find every artefact that must agree with the code at every commit — README, docs, CLI help or usage text, tests, CI, infra, DB schemas and migrations, generated files, examples, changelog — whatever this repo has. Read enough of each to say what in it must agree with what (e.g. "README usage section matches `--help`"), not just that it exists.

3. **Draft** — write one manifest bullet per artefact, in the manifest format: a real path or glob, then what must agree with what. The manifest's own entry comes first. If `atomic/consistency.md` already has entries beyond the self-entry, draft only additions — artefacts it does not yet cover.

4. **Review** — show the drafted bullets exactly as they will be written, then:

   > **Write** — add these entries to `atomic/consistency.md`
   > Or tell me what to change

   Write only what the user approves. If they approve none, leave the manifest as it is.

5. **CLAUDE.md** — if `atomic init` reported that `CLAUDE.md` was left as is, tell the user the merge is not automated yet and relay its hint: merge atomic's rules into the repo's `CLAUDE.md` by hand from the path it named.

6. **Hand off** — list the files `atomic init` created and the manifest if it was edited, and tell the user to review and commit them. `/at:init` commits nothing. Then: "atomic is set up. Run `/at:propose` to define your first commit."

## Constraints
- Never edit anything except `atomic/consistency.md` — `atomic init` writes the rest.
- Never commit or push.
- Never write a manifest entry the user has not approved.

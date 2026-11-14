# /at:init — Set Up atomic in a Repo

Your job is to finish installing atomic in this repo: run `atomic init`, then draft the repo's commit-consistency manifest from what is actually in it and, if the repo already had a CLAUDE.md, merge atomic's rules into it — writing only what the user approves.

@.claude/docs/consistency-context.md
@.claude/docs/interaction-context.md

## Steps

1. **Install** — run `atomic init`. It never overwrites a file and commits nothing, so it is safe to re-run. Relay its `created` / `exists` list.

2. **Survey** — look at what the repo actually holds: `git ls-files` and the top-level layout. Find every artefact that must agree with the code at every commit — README, docs, CLI help or usage text, tests, CI, infra, DB schemas and migrations, generated files, examples, changelog — whatever this repo has. Read enough of each to say what in it must agree with what (e.g. "README usage section matches `--help`"), not just that it exists.

3. **Draft** — write one manifest bullet per artefact, in the manifest format: a real path or glob, then what must agree with what. The manifest's own entry comes first. If `atomic/consistency.md` already has entries beyond the self-entry, draft only additions — artefacts it does not yet cover.

4. **Review** — show the drafted bullets exactly as they will be written, then:

   > **Write** — add these entries to `atomic/consistency.md`
   > Or tell me what to change

   Write only what the user approves. If they approve none, leave the manifest as it is.

5. **CLAUDE.md** — skip this step unless `atomic init` reported that `CLAUDE.md` was left as is (the repo had its own). Then merge atomic's rules into it:
   - Read atomic's `CLAUDE.md` from the path named in that hint, and the repo's `CLAUDE.md`.
   - Compare them section by section. Every section of atomic's file is needed — the pipeline, the start-of-session check, pipeline stages, hard rules, slash commands, key paths, and the behaviour file format — because the commands rely on all of them. Draft only what the repo's file is missing or has out of date; if nothing is, say `CLAUDE.md` is already up to date and go to step 6.
   - Fit the draft to the repo's file: its headings, order, and voice. Place each addition where it belongs rather than appending one block; keep atomic's rules intact in meaning.
   - Flag any rule in the repo's file that contradicts atomic's (e.g. "use conventional commits", "push to a feature branch") for the user to decide. Never resolve a conflict silently.
   - Show the exact changes — each section added and each line changed, with where it goes — not the whole merged file, then:

     > **Write** — apply these changes to `CLAUDE.md`
     > Or tell me what to change

   Write only the merge the user approves.

6. **Hand off** — list the files `atomic init` created, and the manifest and `CLAUDE.md` if they were edited, and tell the user to review and commit them. `/at:init` commits nothing. Then say atomic is set up, and end with `Next: /at:propose — define your first commit`.

## Constraints
- Never edit anything except `atomic/consistency.md` and `CLAUDE.md` — `atomic init` writes the rest.
- Never commit or push.
- Never write a manifest entry or `CLAUDE.md` change the user has not approved.

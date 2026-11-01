## Behaviour: atomic CLI

### invocation — through a symlink
- **Given:** `atomic` on PATH is a symlink to atomic's `bin/atomic` (as `npm link` or `npm install -g` create)
- **When:** any command is run, e.g. `atomic status`
- **Then:** the link is followed to the real script and `lib/` is found next to it; the command behaves exactly as when `bin/atomic` is run directly

### invocation — through a relative symlink chain
- **Given:** `atomic` on PATH is a relative symlink to another relative symlink that points at `bin/atomic`
- **When:** any command is run
- **Then:** each relative target is resolved against its own link's directory, and the command works

### init — through a symlink
- **Given:** `atomic` on PATH is a symlink to atomic's `bin/atomic`
- **When:** `atomic init` is run in a fresh git repo
- **Then:** the commands and docs are copied from atomic's real checkout, not from the symlink's directory

### init — fresh repo
- **Given:** a git repo with no `atomic/` directory and no `.claude/commands/at/` or `.claude/docs/`
- **When:** atomic's `bin/atomic init` is run from the repo root
- **Then:** creates `atomic/` and `atomic/consistency.md` containing the template (header, one-line purpose, and the self-entry, per `.claude/docs/consistency-context.md`); copies every `.claude/commands/at/*.md` and `.claude/docs/*.md` from atomic's checkout, byte-identical; does not copy `.claude/settings.local.json`; prints `created` for each path, then a hint to add an entry for each artefact that must agree with the code; does not create `atomic/stack.md` or CLAUDE.md; commits nothing; exits 0

### init — re-run
- **Given:** a repo `atomic init` has already been run in, where a copied command has since been edited
- **When:** `atomic init` is run again
- **Then:** nothing is written — every path is reported `exists`, the edited command and the manifest are unchanged, no hint is printed; exits 0

### init — partial setup
- **Given:** some of the paths init writes exist and some do not (e.g. `atomic/` exists but the manifest does not, or one copied doc was deleted)
- **When:** `atomic init` is run
- **Then:** only the missing files are created; existing ones are reported `exists` and left as they are; the hint is printed only if the manifest was created

### init — atomic's own repo
- **Given:** `atomic init` is run in atomic's own checkout (source and target are the same files)
- **When:** `atomic init` is run
- **Then:** every path is reported `exists` and nothing changes

### init — not a git repo
- **Given:** the current directory is not inside a git repository
- **When:** `atomic init` is run
- **Then:** prints `{"error":"not in a git repository"}` to stderr, creates nothing, exits non-zero

### init — JSON output
- **When:** `atomic init --json` is run
- **Then:** prints `{"ok":true,"created":[…],"existing":[…]}` listing `atomic/`, `atomic/consistency.md`, and every copied command and doc path under whichever applies

### status — no active pipeline
- **Given:** `atomic/spec.md` does not exist
- **When:** `atomic status` is run
- **Then:** prints `State: none` and exits 0

### status — proposed
- **Given:** `atomic/spec.md` exists with all `[ ]` items
- **When:** `atomic status` is run
- **Then:** prints `State: proposed`, the Intent line, and `Progress: 0/N changes complete`

### status — applying
- **Given:** `atomic/spec.md` exists with a mix of `[X]` and `[ ]` items
- **When:** `atomic status` is run
- **Then:** prints `State: applying`, the Intent line, and the current progress count

### status — ready
- **Given:** `atomic/spec.md` exists with all `[X]` items
- **When:** `atomic status` is run
- **Then:** prints `State: ready`, the Intent line, and `Progress: N/N changes complete`

### status — JSON output
- **Given:** any pipeline state
- **When:** `atomic status --json` is run
- **Then:** prints a JSON object with `state`, `spec_intent`, `progress`, `atomic_dir`, `behaviours_dir` keys

### progress — active spec
- **Given:** `atomic/spec.md` exists with checkbox items
- **When:** `atomic progress` is run
- **Then:** prints `M/N changes complete`

### progress — no spec
- **Given:** `atomic/spec.md` does not exist
- **When:** `atomic progress` is run
- **Then:** prints `No active spec`

### reset — removed
- **Given:** any pipeline state
- **When:** `atomic reset` is run
- **Then:** prints `{"error":"unknown command: reset"}` to stderr, exits non-zero; no files in `atomic/` are touched (use `atomic clean` to discard the spec)

### show-spec — file exists
- **Given:** `atomic/spec.md` exists
- **When:** `atomic show-spec` is run
- **Then:** prints contents of `atomic/spec.md` to stdout

### show-spec — no spec
- **Given:** `atomic/spec.md` does not exist
- **When:** `atomic show-spec` is run
- **Then:** prints error to stderr and exits non-zero

### show-context — removed
- **Given:** any pipeline state
- **When:** `atomic show-context` is run
- **Then:** prints `{"error":"unknown command: show-context"}` to stderr, exits non-zero

### commit — all complete
- **Given:** `atomic/spec.md` exists with all `[X]` items; changes are present
- **When:** `atomic commit` is run
- **Then:** intent is read from spec.md; all changes except spec.md are staged and committed with the intent as message; spec.md is then removed, exits 0

### commit — git commit fails
- **Given:** `atomic/spec.md` exists with all `[X]` items; `git commit` fails (nothing to commit, or e.g. a pre-commit hook rejects it)
- **When:** `atomic commit` is run
- **Then:** prints `error: commit failed — atomic/spec.md kept; fix the cause and run atomic commit again` to stderr, exits non-zero; spec.md is kept and `atomic status` shows `ready`

### commit — spec.md staged by hand
- **Given:** `atomic/spec.md` has been added to the index
- **When:** `atomic commit` is run
- **Then:** spec.md is unstaged before committing and is not part of the commit

### commit — incomplete spec
- **Given:** `atomic/spec.md` exists with one or more `[ ]` items
- **When:** `atomic commit` is run
- **Then:** prints error indicating how many items remain, exits non-zero

### commit — no spec
- **Given:** `atomic/spec.md` does not exist; changes are present
- **When:** `atomic commit` is run
- **Then:** all changes are staged and committed with "atomic commit" as the fallback message, exits 0

### push — origin configured
- **Given:** a remote named `origin` exists
- **When:** `atomic push` is run
- **Then:** the current branch is pushed to origin, exits 0

### push — no origin configured
- **Given:** no remote named `origin` exists
- **When:** `atomic push` is run
- **Then:** prints a warning with instructions to add a remote, exits 0 (does not fail)

### rollback — reverts code and stack
- **Given:** `atomic/spec.md` exists; tracked files are modified, staged, or deleted; untracked files were created during the apply; `atomic/stack.md` has had its top proposal popped and/or deferrals added
- **When:** `atomic rollback` is run
- **Then:** all tracked changes are reverted to HEAD, including `atomic/stack.md` (the popped proposal returns, deferrals are dropped); untracked files (including `atomic/spec.md`) are removed, along with directories left empty; `.gitignore`d files are untouched; `git status` is clean; `atomic status` reports `none`; exits 0

### rollback — snapshot of discarded changes
- **Given:** the working tree differs from HEAD
- **When:** `atomic rollback` is run
- **Then:** before reverting, the whole working tree (tracked changes, untracked files, spec.md; `.gitignore` respected) is saved as a commit on top of HEAD that no branch, tag, or stash references, with message `atomic rollback: <spec intent>`; prints "Rolled back. Discarded changes are available at <short-sha> (restore with: git restore --source=<short-sha> -- .)"; running that command restores the discarded content (staged/unstaged distinction is not preserved)

### rollback — nothing to discard
- **Given:** the working tree matches HEAD
- **When:** `atomic rollback` is run
- **Then:** no snapshot commit is created; prints "Rolled back. Nothing to discard."

### rollback — discarded deferrals reported
- **Given:** the working-tree `atomic/stack.md` contains Proposal blocks that are not in HEAD's stack
- **When:** `atomic rollback` is run
- **Then:** prints the count and each discarded block in full (from its `===========` line), so they can be re-added verbatim

### rollback — no deferrals
- **Given:** every Proposal block in the working-tree `atomic/stack.md` is also in HEAD's stack
- **When:** `atomic rollback` is run
- **Then:** prints only the snapshot line; no deferral output

### rollback — stack.md created during the apply
- **Given:** HEAD has no `atomic/stack.md`; one was created during the apply
- **When:** `atomic rollback` is run
- **Then:** its blocks are reported as discarded deferrals and the file is removed (it is held in the snapshot)

### rollback — JSON output
- **Given:** any state
- **When:** `atomic rollback --json` is run
- **Then:** prints `{"ok":true,"snapshot":"<sha or empty>","discarded":["<intent>", ...]}` (`snapshot` empty when nothing changed; `discarded` empty when there were no deferrals)

### start-over — reverts code, keeps spec and stack
- **Given:** `atomic/spec.md` exists; tracked files are modified, staged, or deleted; untracked files were created during the attempt; `atomic/stack.md` may have been popped or had deferrals added
- **When:** `atomic start-over` is run
- **Then:** all tracked changes except `atomic/stack.md` are reverted to HEAD; untracked files other than `atomic/spec.md` are removed, along with directories left empty; `.gitignore`d files are untouched; `atomic/stack.md` and `atomic/spec.md` keep their content; exits 0

### start-over — checkboxes unticked
- **Given:** `atomic/spec.md` has `[X]` items
- **When:** `atomic start-over` is run
- **Then:** every `- [X]` becomes `- [ ]`; nothing else in spec.md changes; `atomic status` reports `proposed`

### start-over — snapshot of the previous attempt
- **Given:** the working tree differs from HEAD outside `atomic/spec.md` and `atomic/stack.md`
- **When:** `atomic start-over` is run
- **Then:** before reverting, the whole working tree is saved as a commit on top of HEAD that no branch, tag, or stash references, with message `atomic start over: <spec intent>`; prints "Started over. Previous attempt is available at <short-sha> (restore with: git restore --source=<short-sha> -- .)"; running that command restores the previous attempt

### start-over — nothing to discard
- **Given:** the working tree differs from HEAD only in `atomic/spec.md` and `atomic/stack.md`
- **When:** `atomic start-over` is run
- **Then:** checkboxes are unticked; prints "Started over. Nothing to discard."

### start-over — no spec
- **Given:** `atomic/spec.md` does not exist
- **When:** `atomic start-over` is run
- **Then:** prints "error: no active spec — nothing to start over" to stderr, changes nothing, exits non-zero

### start-over — JSON output
- **Given:** `atomic/spec.md` exists
- **When:** `atomic start-over --json` is run
- **Then:** prints `{"ok":true,"snapshot":"<sha or empty>"}` (`snapshot` empty when nothing was discarded)

### stack-add — state none
- **Given:** no active spec; `atomic/stack.md` is committed in HEAD and unchanged
- **When:** `atomic stack-add "<intent>"` is run with the proposal body on stdin
- **Then:** a `===========` / `Proposal: <intent>` / body block is appended to the end of the stack, with exactly one blank line before it; a new commit `Plan: <intent>` is created whose diff is only that block; the working tree is clean afterwards; prints `Added to stack: <intent>` and the commit line; does not push; exits 0

### stack-add — mid-apply
- **Given:** an active `atomic/spec.md`; the working-tree `atomic/stack.md` has its top proposal popped and a deferral appended; code files are modified
- **When:** `atomic stack-add "<intent>"` is run
- **Then:** the `Plan: <intent>` commit contains only the appended block (built from HEAD's stack, not the working tree's); the block is also appended to the working-tree stack; the remaining working-tree diff is exactly the pop, the deferral, and the code changes, all uncommitted; `atomic/spec.md` is untouched

### stack-add — invalid input
- **Given:** the intent is empty or spans more than one line, or the body contains a `===========` line
- **When:** `atomic stack-add` is run
- **Then:** prints an error to stderr, creates no commit, changes nothing, exits non-zero

### stack-add — no stack in HEAD
- **Given:** `atomic/stack.md` is not committed in HEAD
- **When:** `atomic stack-add "<intent>"` is run
- **Then:** prints "error: atomic/stack.md is not committed in HEAD — create the stack first" to stderr, creates no commit, exits non-zero

### stack-add — JSON output
- **When:** `atomic stack-add --json "<intent>"` succeeds
- **Then:** prints `{"ok":true,"sha":"<sha>","message":"Plan: <intent>"}`

### clean
- **Given:** any state
- **When:** `atomic clean` is run
- **Then:** `atomic/spec.md` is deleted; `atomic/stack.md` and `atomic/stacks/` are preserved, exits 0

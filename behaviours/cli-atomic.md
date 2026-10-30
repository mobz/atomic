## Behaviour: atomic CLI

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

### show-context — file exists
- **Given:** `atomic/context.md` exists
- **When:** `atomic show-context` is run
- **Then:** prints contents of `atomic/context.md` to stdout

### show-context — no context
- **Given:** `atomic/context.md` does not exist
- **When:** `atomic show-context` is run
- **Then:** prints nothing and exits 0

### commit — all complete
- **Given:** `atomic/spec.md` exists with all `[X]` items; changes are present
- **When:** `atomic commit` is run
- **Then:** intent is read from spec.md; spec.md is removed; all changes are staged and committed with the intent as message, exits 0

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

### clean
- **Given:** any state
- **When:** `atomic clean` is run
- **Then:** `atomic/spec.md` is deleted; `atomic/context.md`, `atomic/stack.md`, and `atomic/stacks/` are preserved, exits 0

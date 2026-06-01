Stack: Add stack awareness to the atomic pipeline
As a developer I want the atomic pipeline to maintain an ordered proposal queue so that I can decompose a feature into atomic commits upfront, capture out-of-scope discoveries without losing focus, and always know what comes next.

===========
Proposal: Support multiple named stacks

Currently `atomic/stack.md` is the single active stack. As work grows across multiple concurrent features or workstreams, a single file becomes a bottleneck — unrelated proposals accumulate in one queue and the stack loses its focus.

Design considerations:
- Named stacks stored alongside the active one (e.g. `atomic/stacks/auth-rewrite.md`, `atomic/stacks/payments.md`) with `atomic/stack.md` remaining the active/checked-out stack
- OR a `stacks/` directory with `atomic/stack.md` as a symlink or pointer to the active one
- `atomic show-stack` continues to work against the active stack without changes
- New commands needed: `atomic stack list`, `atomic stack switch <name>`, `atomic stack new <name>`
- `/at:stack` needs to know whether to create a new named stack or replace the active one
- The active stack concept must remain stable — all existing pipeline behaviour (propose popping from top, apply writing to stack, show-stack) works against whichever stack is currently active
- Consider whether stack.md in the repo root atomic/ dir should always be the active one (symlink pattern) or whether a separate pointer file tracks which is active

This is a significant change — decompose into its own stack when the time comes.

===========
Proposal: Associate each stack with a dedicated feature branch

Currently all commits land on whatever branch is checked out — there's no connection between a stack and a branch. In a stacked diffs workflow, each stack represents a feature being built incrementally and should own a dedicated branch separate from the integration branch (main).

Design considerations:
- The Stack: header should declare a target branch, e.g. `Branch: feature/auth-rewrite`
- `/at:stack` should create or checkout the declared branch when writing stack.md
- `atomic push` should push to the stack's declared branch, not blindly to current branch
- `atomic status` should surface the active branch alongside pipeline state
- When all proposals in a stack are done, the workflow should guide opening a PR from the feature branch to the integration branch
- The integration branch (main/master) should be configurable — not hardcoded
- Consider: what happens when proposals from two different stacks are interleaved? The branch association makes this explicit and prevents accidental cross-contamination
- `atomic show-stack` could show the branch status (ahead/behind integration branch)

This ties into multi-stack support — each stack lives on its own branch, switching stacks means switching branches. Coordinate with the multiple named stacks proposal.

===========
Proposal: Add `/at:fix` command for surgical bug fixes in git history

When a bug is discovered, the atomic commit philosophy says: fix it in the commit that introduced it so every commit is always complete. This requires a different workflow from a standard proposal — you're not writing new code, you're correcting history.

The command needs to handle two distinct cases:
1. **Bug is in HEAD** — amend the most recent commit. Simpler path: fix the code, `git add`, `git commit --amend`.
2. **Bug is in an older commit** — create a fixup commit targeting that SHA, then rebase it in with `git rebase -i --autosquash`. This rewrites history from that commit forward.

Key design challenges:
- Finding the culprit commit: guide Claude through `git log`, `git blame`, and `git show` to identify where the bug was introduced — do not assume the user knows the SHA
- Scoping the fix: a history rewrite must be surgical. The fix should touch only what the bug requires — no scope creep into the target commit
- Safety: before any rebase, check for pushed commits and warn the user. Rewriting published history requires a force push and coordination with collaborators
- Conflict handling: a fixup rebase can produce conflicts if subsequent commits touched the same code — the command must guide through resolution or surface clearly when manual intervention is needed
- Spec handling: a simple one-line bug fix may not need a full spec; a complex fix might. The command should judge this and either proceed directly or invoke a lightweight spec flow

Consider whether this is one command (`/at:fix`) or a sub-path within `/at:propose` triggered by a "this is a bug" signal. Either way, the output is a clean git history where the bug never existed.

This is a large command — consider decomposing into its own stack when the time comes.

===========
Proposal: Fix `atomic reset` deleting committed files

`atomic reset` uses `find atomic/ -mindepth 1 -not -name '.gitkeep' -delete` which deletes ALL files in atomic/ including committed ones (context.md, stack.md). It should only delete ephemeral files — specifically spec.md.

Fix: change the command to only delete `atomic/spec.md` (like `atomic clean` does), or whitelist the files to preserve: context.md, stack.md, .gitkeep.

Current behaviour of `atomic clean` (correct pattern): `rm -f "$ATOMIC_DIR/spec.md"` — only removes spec.md.
Current behaviour of `atomic reset` (broken): deletes everything except .gitkeep, including committed context.md and stack.md.

The fix should make reset delete only spec.md, or at most any non-committed files in atomic/ (using `git ls-files` to distinguish tracked from untracked).

===========
Proposal: Migrate `/at:*` commands from `.claude/commands/` to `.claude/skills/`

Claude Code's `.claude/skills/` interface combines slash commands and executable scripts in one definition — a skill can include both natural language instructions (like a command file) and shell scripts that run as part of the skill. This is a richer model than commands alone.

Current state: all `/at:*` commands live in `.claude/commands/at/` as plain markdown files.

Migration goal: move them to `.claude/skills/` to take advantage of the unified command+script interface. This may allow the `bin/atomic` CLI calls (currently embedded as bash instructions in the command prose) to be expressed as proper script hooks within the skill definition, making the pipeline more robust and less dependent on Claude interpreting bash correctly.

Research needed before implementing:
- Exact `.claude/skills/` file format and directory structure
- How skills define both the prompt/instructions and the executable steps
- Whether the `@file` injection convention still works in skills
- Migration path: can skills live alongside commands, or is it a full replace?
- Whether namespacing (at:propose vs propose) works the same way

This is likely a significant restructure — consider decomposing into its own stack once the skills format is fully understood.

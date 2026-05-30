## Spec: atomic CLI

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
- **Then:** prints a JSON object with `state`, `spec_intent`, `progress`, `atomic_dir`, `specs_dir` keys

### progress — active spec
- **Given:** `atomic/spec.md` exists with checkbox items
- **When:** `atomic progress` is run
- **Then:** prints `M/N changes complete`

### progress — no spec
- **Given:** `atomic/spec.md` does not exist
- **When:** `atomic progress` is run
- **Then:** prints `No active spec`

### reset
- **Given:** any pipeline state
- **When:** `atomic reset` is run
- **Then:** all files in `atomic/` except `.gitkeep` are deleted, exits 0

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

### merge-specs — domain files present
- **Given:** `atomic/` contains one or more `.md` files that are not `spec.md`, `context.md`, `delta.md`, or `assumptions.md`
- **When:** `atomic merge-specs` is run
- **Then:** those files are copied into `specs/`, count is reported, exits 0

### merge-specs — no domain files
- **Given:** `atomic/` contains only reserved files (spec.md, context.md, etc.)
- **When:** `atomic merge-specs` is run
- **Then:** reports `0` files merged, exits 0

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

### clean
- **Given:** any state
- **When:** `atomic clean` is run
- **Then:** `atomic/spec.md` is deleted; `atomic/context.md` and `atomic/delta.md` are preserved, exits 0

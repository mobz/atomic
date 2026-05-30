## Spec: atomic CLI

### status — no active pipeline
- **Given:** no `atomic/stage` file exists
- **When:** `atomic status` is run
- **Then:** prints `Stage: none` and exits 0

### status — active pipeline with spec
- **Given:** `atomic/stage` exists and `atomic/spec.md` exists with an Intent line
- **When:** `atomic status` is run
- **Then:** prints current stage and the Intent line

### status — JSON output
- **Given:** any pipeline state
- **When:** `atomic status --json` is run
- **Then:** prints a JSON object with `stage`, `spec_intent`, `atomic_dir`, `specs_dir` keys

### advance
- **Given:** a git repository
- **When:** `atomic advance <stage>` is run
- **Then:** `atomic/stage` is written with the stage name, exits 0

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

### commit — clean state
- **Given:** `atomic/spec.md` and `atomic/stage` do not exist; changes are present
- **When:** `atomic commit "<message>"` is run
- **Then:** all changes are staged and a git commit is created with the given message, exits 0

### commit — dirty state
- **Given:** `atomic/spec.md` or `atomic/stage` exists
- **When:** `atomic commit` is run
- **Then:** prints error "pipeline is not clean", exits non-zero

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
- **Then:** `atomic/spec.md` and `atomic/stage` are deleted; `atomic/context.md` and `atomic/delta.md` are preserved, exits 0

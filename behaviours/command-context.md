## Behaviour: Command shared context injection

### spec-context loaded in spec, apply, and merge
- **Given:** `.claude/docs/spec-context.md` exists and is referenced via `@` in spec.md, apply.md, and merge.md
- **When:** any of those commands are invoked
- **Then:** the spec.md format and pipeline state semantics are available to Claude without being restated inline in the command file

### spec format not duplicated in the /at:spec command
- **Given:** spec-context.md carries the canonical spec.md format definition
- **When:** `/at:spec` writes a spec
- **Then:** the command file contains no inline fenced template for spec.md; the format reference is the shared context doc

### pipeline state semantics not duplicated in command files
- **Given:** spec-context.md defines the pipeline state mapping (none / proposed / applying / ready)
- **When:** spec.md, apply.md, or merge.md refer to pipeline states
- **Then:** state labels appear without inline parenthetical definitions (e.g. `**State: proposed**` not `**State: proposed** (spec exists, all [ ])`)

### behaviour-context loaded in apply
- **Given:** `.claude/docs/behaviour-context.md` exists and is referenced via `@` in apply.md, directly after the spec-context reference and before `## Entry`
- **When:** `/at:apply` is invoked
- **Then:** the `behaviours/` structure, `## Behaviour:` / Given/When/Then scenario format, and read-before-write rule are available to Claude without being restated inline

### behaviour format not duplicated in apply.md
- **Given:** behaviour-context.md carries the canonical behaviour file format
- **When:** `/at:apply` updates behaviour files in step 2
- **Then:** the command file contains no inline fenced behaviour template; step 2 keeps only the procedural instruction to create or update a file per feature touched

### consistency-context loaded in apply
- **Given:** `.claude/docs/consistency-context.md` exists and is referenced via `@` in apply.md alongside the other context docs, before `## Entry`
- **When:** `/at:apply` is invoked
- **Then:** the `atomic/consistency.md` manifest format and rules (self-entry first, stale entries are in scope, unaffected entries left alone, manifest maintained in the same commit) are available to Claude without being restated inline

### consistency-context loaded in init
- **Given:** `.claude/docs/consistency-context.md` is referenced via `@` in init.md, before `## Steps`
- **When:** `/at:init` is invoked
- **Then:** the manifest format and rules are available to Claude when drafting entries, without being restated inline

### interaction-context loaded in every command
- **Given:** `.claude/docs/interaction-context.md` exists and is referenced via `@` in spec.md, apply.md, propose.md, merge.md, and init.md, after the other context docs
- **When:** any `/at:*` command hands control back to the user
- **Then:** it uses one of the doc's shapes — a gate ends with a choice block of bold verbs and "Or tell me what to change" last; a stage-end or wrong-state exit ends with one `Next: /at:<command> — …` line; clarifying questions are free-form and never gates — and each command lists only its own verbs, without restating the pattern

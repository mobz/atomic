## Behaviour: Command shared context injection

### spec-context loaded in propose, apply, and merge
- **Given:** `.claude/docs/spec-context.md` exists and is referenced via `@` in propose.md, apply.md, and merge.md
- **When:** any of those commands are invoked
- **Then:** the spec.md format and pipeline state semantics are available to Claude without being restated inline in the command file

### spec format not duplicated in propose.md
- **Given:** spec-context.md carries the canonical spec.md format definition
- **When:** `/at:propose` writes a spec
- **Then:** the command file contains no inline fenced template for spec.md; the format reference is the shared context doc

### pipeline state semantics not duplicated in command files
- **Given:** spec-context.md defines the pipeline state mapping (none / proposed / applying / ready)
- **When:** propose.md, apply.md, or merge.md refer to pipeline states
- **Then:** state labels appear without inline parenthetical definitions (e.g. `**State: proposed**` not `**State: proposed** (spec exists, all [ ])`)

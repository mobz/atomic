Every time a command hands control back to the user, it uses one of three fixed shapes, so the user can tell at a glance whether they are at a gate and which words the agent will act on.

**Gate** — the agent will act on the answer (write a file, merge, roll back, resume, re-add). End with a choice block:

```markdown
> **<Verb>** — <exactly what the agent will do>
> **<Verb>** — <exactly what the agent will do>
> Or tell me what to change
```

- Each choice is one bold verb the user can type back, and its line says exactly what happens.
- "Or tell me what to change" is always the last line.
- Act only on a clear choice. Anything else is feedback: act on it, then show the gate again.
- Each command lists its own gates and their verbs; use those verbs as written.

**Handoff** — the stage is done, or the state is wrong for this command. End with one line and no question:

```markdown
Next: /at:<command> — <what it does from here>
```

When the command has just written something the user can still revise (e.g. a new stack), add `Or tell me what to change` on the line after.

**Clarifying question** — while discovering or exploring. Free-form, but never used as a gate.

`atomic/stack.md` is the ordered proposal queue — committed, and fed one proposal at a time into `/at:propose`.

**Format:**

```
Stack: <short feature name>
<user story — "As a <persona> I want <feature> so that <goal>">
<optional: additional context about scope, constraints, or motivation>

===========
Proposal: <intent sentence for the next commit>
<detail: what changes, design and implementation notes, why this order>

===========
Proposal: <intent sentence for the commit after that>
<detail>
```

- The `Stack:` header block (header line, user story, optional context) always comes first. It is mandatory and is never removed.
- Each proposal block starts with `===========` on its own line, immediately followed by `Proposal: <intent>`, then any detail.
- **Ordering:** the top proposal is the next commit to work on; top-to-bottom is the order work will be done in.

**Adding a deferred item** (out-of-scope work noticed during apply):

```
===========
Proposal: <brief description of the deferred item>
Deferred from apply: <what was noticed and why it's out of scope>
```

- **End of stack** — for clearly out-of-scope items (future work, nice-to-haves, unrelated improvements): append after the last block.
- **Top of stack** — for urgent bugs or required prerequisites: insert directly after the `Stack:` header block, before the first `===========`.
- If `atomic/stack.md` does not exist, create it with just the Proposal block.

**Popping the top proposal:** remove from the top proposal's `===========` line down to, but not including, the next `===========` (or to the end of the file if it is the last). The `Stack:` header block is preserved.

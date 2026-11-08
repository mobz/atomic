## Behaviour: atomic show-stack

### show-stack — stack exists
- **Given:** `atomic/stack.md` exists
- **When:** `atomic show-stack` is run
- **Then:** prints the full contents of `atomic/stack.md` to stdout and exits 0

### show-stack — no stack
- **Given:** `atomic/stack.md` does not exist
- **When:** `atomic show-stack` is run
- **Then:** prints `No active stack` and exits 0

## Spec: stack.md format

### stack header
- **Given:** a stack.md file
- **When:** the file is read
- **Then:** the first line is the heading `# Stack: <short feature name>`; optional free-text context follows on subsequent lines (user story, goals, scope)

### proposal block
- **Given:** a stack.md file with one or more proposals
- **When:** the file is read
- **Then:** each proposal begins with a `## Proposal: <intent>` heading, preceded by one blank line, and runs to the next `## Proposal:` heading or the end of the file; free-text context may follow, using only `###` or deeper headings; proposals are ordered top-to-bottom with the next commit at the top

### renders as markdown
- **Given:** a stack.md file
- **When:** it is viewed in a markdown renderer (e.g. on GitHub)
- **Then:** the stack name is the top-level heading and each proposal is a second-level section titled `Proposal: <intent>`

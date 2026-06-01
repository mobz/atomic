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
- **Then:** the first line is `Stack: <short feature name>`; optional free-text context follows on subsequent lines (user story, goals, scope)

### proposal block
- **Given:** a stack.md file with one or more proposals
- **When:** the file is read
- **Then:** each proposal begins with a `===========` separator line followed by `Proposal: <intent>`; free-text context may follow; proposals are ordered top-to-bottom with the next commit at the top

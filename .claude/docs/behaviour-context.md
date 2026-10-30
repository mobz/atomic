`behaviours/` is the committed behaviour store — BDD scenarios describing what the system observably does. It is always kept in sync with the code and committed alongside it.

**Structure:** files are feature-scoped, not commit history. One file per domain, named by domain (e.g. `pipeline-apply.md`, `cli-atomic.md`). A file may hold several `## Behaviour:` sections for related features in that domain.

**Format:**

```markdown
## Behaviour: <feature name>

### <scenario name>
- **Given:** system state / preconditions
- **When:** action or event
- **Then:** observable outcome(s)
```

Scenarios should be concrete and testable — describe observable outcomes, not implementation.

**Before writing:** read the existing file for the domain if one exists. Update scenarios whose behaviour changed, add new ones for new behaviour, remove ones that no longer hold — never duplicate an existing scenario.

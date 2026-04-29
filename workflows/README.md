# Workflow Specs

These files describe the intended n8n flows before implementation.

Recommended implementation order:

1. `01-intake-and-generation.md`
2. `02-review-and-revision.md`
3. `03-packaging.md`
4. `04-distribution-hand-off.md`

Keep workflows thin and state-driven. If a node depends on hidden human context, the workflow is too fragile.

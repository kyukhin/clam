# Architect templates

## Epic spec: docs/specs/E-NN-<slug>.md

The template and the rules are in `docs/specs/README.md`. They are not
duplicated here.

## ADR: docs/architecture/adr/NNNN-<slug>.md

```markdown
# ADR-NNNN: <the decision in one sentence>

Status: proposed | accepted (YYYY-MM-DD) | superseded by ADR-MMMM
Needs the kyukhin gate: yes/no (yes if it changes the stack, the modules or the contract)

## Context
What forces the decision. Links to the PRD and other ADRs.

## Options
| Option | Pros | Cons |
|---|---|---|

## Decision
What was chosen and why, briefly.

## Consequences
What becomes easier, what becomes harder, which tasks appear.

## History
- YYYY-MM-DD: proposed.
- YYYY-MM-DD: accepted by kyukhin ("kyukhin's words, translated").
```

## Task: docs/tasks/TASK-NNN-<slug>.md

```markdown
# TASK-NNN: <verb + result>

Epic: E-NN | Milestone: MN | Status: draft
Depends on: TASK-MMM (or "none")
Complexity: normal | high
Spec: docs/specs/E-NN-<slug>.md § … (approved YYYY-MM-DD)
Basis: ADR-NNNN, CONTRACTS.md § …

## Goal
One or two sentences: what changes for the system or the user.

## Context
What the developer needs to know that is not in the spec and the ADRs. Links, not retelling.

## Change scope
Modules and directories that MAY be changed: …
Must not be touched: the contracts in source-api (unless the task is about them), …

## Acceptance criteria
- [ ] AC1 (C3): <an observable result checkable by a test or by hand; C3 is a row of the spec's test plan>
- [ ] AC2 (C4): …
- [ ] All tests pass; the build and the linter are green with no new warnings.

## How to verify
Commands and/or manual steps for QA.

## Out of scope
What we deliberately do not do in this task.

## Developer notes
(filled in by the developer: decisions along the way, deviations, what is left)
```

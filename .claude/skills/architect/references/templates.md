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

## Ticket: an issue on GitHub

You draft a ticket as a file `T<n>-<slug>.md` in the directory the dispatcher
names; the dispatcher creates the issue from it. Inside the spec the tickets
of an epic are T1, T2, … in the order of work, and a draft names another
ticket of the same epic by that label; the dispatcher puts the issue numbers
in.

Write every paragraph and every list item on one line: GitHub shows a line
break inside an issue as a break.

```markdown
Title: <verb + result>
Labels: infrastructure | enhancement | bug | documentation

Part of #<epic>.

## Context
What changes for the system or the user, in one or two sentences. Then what the developer needs to know that is not in the spec and the ADRs. Links, not retelling.

## Tasks
- Optional: the steps, when their order matters.

## Architecture Notes
Depends on: T1 (or "none"). Complexity: normal | high.

May be changed: the modules and the directories.

Must not be touched: the contracts in source-api (unless the ticket is about them), …

## Acceptance Criteria
- [ ] AC1 (C3): <an observable result checkable by a test or by hand; C3 is a row of the spec's test plan>
- [ ] AC2 (C4): …
- [ ] All tests pass; the build and the linter are green with no new warnings.

## How to verify
Commands and/or manual steps for QA.

## Out of scope
What we deliberately do not do in this ticket.

## Spec
`docs/specs/E-NN-<slug>.md` § … (ticket Tn, approved YYYY-MM-DD). Basis: ADR-NNNN, CONTRACTS.md § …
```

The developer's notes are not part of a ticket: the developer returns them in
its report.

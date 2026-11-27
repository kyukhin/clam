# Specs

Clam is developed spec-first. Every epic has a spec in this folder. A spec
describes how the feature works now and is committed together with the code
that implements it.

Specs are written by Claude (the architect role) and approved by the owner. The
spec header does not repeat this.

## Rules

1. **Read first.** Before designing, coding, testing and verifying, read this
   index, `docs/architecture/OVERVIEW.md` and the specs of every area you touch.
2. **One spec per epic:** `E-NN-<slug>.md`, the epic number comes from
   `docs/plan/ROADMAP.md`. Fixes and small tasks update the spec of their area.
   Every spec has a row in the index below; the row is updated by whoever
   created the spec, renamed it or changed its status.
3. **Statuses:** `planned` (in the index, not written yet) → `draft` (written,
   waiting for the owner) → `approved` (the owner has read the whole spec; the
   date is in the header) → `implemented`. Before `approved` there are neither
   `ready` tasks nor code.
4. **The spec and the code travel together.** The commit that implements a task
   updates its spec: decisions, test plan, status. Any deviation found during
   development is recorded in the spec in the same commit, with the reason.
   - The deviation is visible to the user or changes the architecture (data
     model, storage, migrations, module boundaries, contracts, dependencies) →
     the spec goes back to `draft`, work stops and waits for the owner to
     approve it again.
   - A small implementation detail → only a line in "History"; the report after
     the task and the PR description carry the note "spec changed".
5. **Implemented.** When the last task of the epic lands in `master`, the status
   becomes `implemented`. From then on the spec is kept up to date: every edit
   is a line in "History". A follow-up to an implemented spec is approved
   separately, and the index shows it:
   `implemented; follow-up TASK-NNN approved 2026-12-10`.
6. **Spec and ADR.** An ADR is a decision that outlives the epic: the stack, the
   modules, the source contract, track identity. A spec links to an ADR and does
   not retell it. If a spec needs another such decision, first comes an ADR in
   `proposed` and the owner gate.
7. **The owner's decisions** are recorded with a date: `2026-12-01 (owner): …`.
   An approval is a line in "History" with the owner's words, translated into
   English as closely as possible. A question the owner did not answer is closed
   with the recommendation and marked "accepted by default".
8. **Style.** English, short and concrete: numbers, names and paths instead of
   adjectives. Present tense, as things are now. No "maybe" or "probably": what
   we do not know is an open question. The spec is read before every task.

## Template

```markdown
# E-NN: <Feature>

> Status: draft | approved by the owner YYYY-MM-DD | implemented · Milestone: MN · Tasks: TASK-NNN, TASK-MMM · Updated: YYYY-MM-DD

Read first: OVERVIEW.md, ADR-NNNN, neighboring specs that change the same place.

## Why
The problem and who has it. The scenarios and MVP items from the PRD that the epic covers.

## Behavior
What the user sees and does. Every state: empty, loading, error, no network.
A "was → now" table if something changes.

### Decisions
- YYYY-MM-DD (owner): …
- YYYY-MM-DD (ADR-NNNN): …

## Design
Data, modules, API, migrations, constraints. Links to code, ADRs and CONTRACTS.md.

## Test plan
| No. | Acceptance criterion | Task | Proved by |
|---|---|---|---|
| C1 | … | TASK-NNN | unit: `TestName` |
| C2 | … | TASK-NNN | by hand on the device: steps and the expected result |

## Open questions
A question for the owner: options, the recommendation, what happens by default. No questions: "None".

## History
- YYYY-MM-DD: what changed and why.
```

The architect fills the "Proved by" column with the kind of check (unit, UI,
contract test, by hand on the device), the developer adds the test names, QA
checks every row. The task numbers in the header and in the plan appear after
the epic is cut into tasks; that is not an edit of the spec and needs no new
approval.

## Index

| Spec | Status | Epic |
|---|---|---|

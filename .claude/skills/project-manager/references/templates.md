# PM templates

## docs/plan/ROADMAP.md

```markdown
# Roadmap

PRD: docs/product/PRD.md (version X.Y, approved YYYY-MM-DD)

| Milestone | What can be tried | MVP items | Status |
|---|---|---|---|
| M0 Skeleton | … | M1 | planned / active / done |

## M0: Skeleton
Goal: …
Done when: …

### Epics
- **E-01 <name>**: the goal; MVP: M1; done when: …; spec: `docs/specs/E-01-<slug>.md`
- **E-02 …**

## Approvals
- YYYY-MM-DD: the milestone plan is approved by the owner ("the owner's words, translated").

## Later
- E-xx <idea>: where it came from, the date
```

## docs/plan/BOARD.md

```markdown
# Board

Current milestone: M0
Next role: architect (E-01 has no tasks)

| Task | Epic | Status | Role now | Note |
|---|---|---|---|---|
| TASK-001 Module structure | E-01 | ready | developer | |
| TASK-002 MediaSource contract | E-01 | draft | architect | waits for ADR-0002 |

## Blocked
| Task | Reason | Since | Who unblocks |
|---|---|---|---|

## Log
| Date | Task | Transition | Who |
|---|---|---|---|
| YYYY-MM-DD | TASK-001 | draft → ready | project-manager |
```

# PM templates

Everything here is text for GitHub, `kyukhin/clam`. Write every paragraph and
every list item on one line: GitHub shows a line break inside an issue as a
break. The template of a ticket is in the architect's templates.

## Milestone

The title is `MN <name>`: `M0 Skeleton`. The description:

```markdown
Goal: …

What can be tried: …

Done when: …

MVP items: PRD M1, M2. Order of the epics: E-03, E-01.
```

```
gh api repos/kyukhin/clam/milestones -f title='M0 Skeleton' -f description='…'
```

## Epic

The title is `Epic E-NN: <name>`. The labels: `epic`, plus `infrastructure`,
`enhancement` or `documentation`. The milestone: the one the epic belongs to.

```markdown
## Goal
One or two sentences: what kyukhin gets.

## Scope
- …

## Tickets
Spec: `docs/specs/E-NN-<slug>.md` (planned | draft | approved YYYY-MM-DD). Order: #A, then #B and #C.

- [ ] #A <title of the ticket>
- [ ] #B …

Steps only kyukhin can do:
- [ ] #K

Follow-ups: #F.

## Acceptance Criteria
- [ ] The readiness criterion of the epic.

MVP items: PRD M1.
```

Before the spec is approved "Tickets" says: `None yet: the architect cuts them
after kyukhin approves the spec.`

```
gh issue create -R kyukhin/clam --title 'Epic E-05: …' --body-file <file> --label epic --label enhancement --milestone 'M1 Retro shell'
```

## Idea for later

The title is `Epic (idea): <name>`. The labels: `epic`, `idea`. The milestone:
`wishlist`.

```markdown
## Goal
An idea for after the MVP. Not scoped: no spec, no tickets.

## Source
Where it came from and the date: PRD section 6; kyukhin, YYYY-MM-DD.
```

## Step only kyukhin can do

A ticket assigned to kyukhin, in the milestone where it is needed.

```markdown
Part of #<epic>.

## Context
Only kyukhin can do this. Why, and what waits for it.

## Tasks
- …

## Acceptance Criteria
- [ ] …

## Spec
`docs/specs/E-NN-<slug>.md`, the step by its name in the spec.
```

A key, a password or a token never gets into an issue or a comment.

## Follow-ups of an epic

One issue per epic, titled `Follow-ups from <what>`, `Part of #<epic>.`, with
a list under "Tasks". An item is ticked when it is done, recorded where it
belongs or dropped with a reason.

## Reading the plan

```
gh api repos/kyukhin/clam/milestones -q '.[] | "\(.title): \(.open_issues) open"'
gh issue list -R kyukhin/clam --milestone 'M0 Skeleton' --state all
gh issue list -R kyukhin/clam --label epic --state all
gh issue list -R kyukhin/clam --assignee kyukhin
gh issue view <N> -R kyukhin/clam --comments
```

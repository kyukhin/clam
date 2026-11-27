# Clam: a mobile player for audiobooks and music kept in "non-standard" storage

The name: Latin *clam* means "secretly", English *clam* is the shellfish. The
music does not live in a home of its own but in other people's storage that was
never designed for it. The repository and identifiers are `clam`. The first
source is Telegram (one channel = one book or album). S3, WebDAV and others come
later. The user's main pain: Telegram loses the listening position, and part of
the books and music is not available on streaming services.

## Language

- The chat with kyukhin is in Russian.
- Everything that lands in the repository or on GitHub is in English only: code,
  identifiers, comments, the app's base UI strings, every document under
  `docs/`, `CHANGELOG.md`, this kit (`CLAUDE.md`, skills, agents), branch names,
  commit messages, PR titles and descriptions, review comments and issues.
- The one exception: the app's interface is translated into Russian and Greek.
  The translations live only in the localization resources and in the store
  listing texts for these languages; their paths are fixed by the stack ADR and
  listed in `docs/architecture/OVERVIEW.md`. Keys, the base language, code and
  comments stay English.
- kyukhin's words go into documents in English translation, as close to the
  original as possible. Outside the localization resources no Russian or Greek
  text is ever pasted into a file.
- The templates in this kit are in English. What you say to kyukhin in chat
  (reports, digests, questions) you say in Russian.

2026-11-27 (kyukhin, translated): "All texts on GitHub are in English only."
2026-11-27 (kyukhin, translated): the interface languages are "English, Russian, Greek".

The person who runs the project and makes the decisions is written as
`kyukhin` in every file, never as a role name (2026-11-27, kyukhin's request).

## You are the dispatcher

kyukhin talks only to you. You run the pipeline of roles yourself and stop
only where kyukhin is needed (see "When to stop and wait for kyukhin").

- **CPO** and **Project Manager** work right in this session: CPO is the
  dialogue with kyukhin, PM is your own logic for choosing the next step.
  Before working in a role, read its skill: `.claude/skills/cpo/SKILL.md`,
  `.claude/skills/project-manager/SKILL.md`.
- **Architect, Developer, QA, Committer** are subagents from `.claude/agents/`.
  You call them, they work in a clean context and return a report. You do not
  do their work yourself: you do not write code for the developer or verify for
  QA. Even when doing it yourself seems faster, call the subagent. That is the
  point of the separation: a QA that did not see the code being written checks
  it honestly.

## The main principle

**Not a line of product code without an approved epic spec and a `ready` task.**
Development is spec-first: the rules, the template and the index are in
`docs/specs/README.md`. The pipeline:

```
CPO ─► PM ─► Architect: epic spec ─► kyukhin gate ─► Architect: tasks ─►
    ─► Developer ─► QA ─► Committer ─► PR ─► (report to kyukhin) ─► PM …
           ▲         │
           └─ FAIL ──┘
```

## The dispatcher loop

1. Read `docs/plan/BOARD.md` (if it does not exist, the project is at the CPO stage).
2. Using the rules of the project-manager skill, determine the next step.
3. Do it: yourself (CPO/PM) or by calling a subagent with a clear brief: which
   task or epic, which files to read, what to return.
4. Read the subagent's report. If it contains `QUESTION FOR KYUKHIN`,
   `GATE REQUIRED` or `SPEC FOR APPROVAL`, stop and ask kyukhin.
5. Otherwise go on to the next step without a pause, up to the nearest stop.

A typical task cycle without kyukhin:
developer → qa → (FAIL → developer → qa) → committer → PR → **stop, report**.

## When to stop and wait for kyukhin

1. **After every committed task:** a short report (template below) and the
   question "merge and continue?". Do not start the next task before the answer.
2. **Gates:** approval of the PRD; approval of the milestone plan; approval of
   an epic spec, and again if the spec went back to `draft`; any ADR that
   chooses or changes the stack, the module structure or the source contract.
3. **Outward git:** creating the remote repository, the first push, merging a PR
   into `master`, publishing a release. Pushing a task branch and opening a PR
   too, until kyukhin gives a standing permission (see "Git and GitHub").
4. **A task came back from QA for the second time** (do not start a third
   developer → qa cycle): show kyukhin what the disagreement is about and
   offer options.
5. **A `blocked` task** that the architect cannot unblock without kyukhin.
6. **A subagent asked kyukhin a question.**
7. **QA returned `PASS-PENDING-DEVICE`.** Give kyukhin the manual steps from
   the QA report. When kyukhin answers, add the section "Check by kyukhin on
   device" to `docs/qa/TASK-NNN.md` (the date, what was confirmed in
   kyukhin's words, what did not pass). Everything passed → committer; something
   did not pass → developer, with this section as the finding.

Silence is not consent. "OK, go on" is consent only to what was shown.

## Agreeing documents with kyukhin

Applies to the PRD, the milestone plan, ADRs that need a gate and epic specs.

1. **Show a digest and the path to the file.** 5–10 lines: what the user will
   see, which decisions were made and what the alternatives were, what will have
   to be checked by hand on the phone. The document is approved as a whole, not
   the digest.
2. **Open questions come with a recommendation.** For each: the options, what
   you recommend and what happens by default. No more than 3–5 at a time.
3. **Approval is explicit only.** After a "yes", write the status and the date
   into the document header and a line with kyukhin's words into its
   "History". A question kyukhin did not answer is closed with the
   recommendation and marked "accepted by default".
4. **Edits.** First record kyukhin's words in the document as a decision with
   a date (`2026-12-01 (kyukhin): …`), then call the role to rework it, then show
   what changed and ask again.
5. **An approved document does not change silently.** Every edit is a line in
   "History". An edit that the user will notice or that changes the
   architecture sends the document back to `draft`, which is a gate again.

## Report after a task

```
✅ TASK-NNN <title> — PR #N, branch kyukhin/NNN-slug
What changed: 1–3 lines in plain language.
How to try it: if it is already possible, what to run and what to see; otherwise "nothing yet".
QA: PASS on the first try / after N returns (the gist).
Spec: unchanged / changed: what and why.
Notes for later: new draft tasks, if any appeared.
Next: TASK-MMM <title> (role). Merge the PR and continue?
```

No logs, diffs or retelling of the QA report: kyukhin can ask for details.
While there is no remote repository, a short commit hash stands in for the PR.

## Git and GitHub

The committer makes the branch and the commit (the message style is in its
skill). Everything below you do yourself.

- **The history of `master` is linear:** there are no merge commits. Only what
  passed QA gets into `master`, and only through a task branch
  `kyukhin/NNN-<two-three-words>`. There is no direct push to `master`.
- **PR.** After the committer's report: `git push -u origin <branch>` and
  `gh pr create` into `master`. The title is the first line of the commit, the
  description comes from the committer's report.
- **Merging** happens after kyukhin's "yes": `gh pr merge --rebase --delete-branch`
  (several commits in the branch: `--squash`), then `git switch master` and
  `git pull --rebase`. Never `git merge` with a merge commit.
- **kyukhin's comments on a PR** go the usual way: developer → qa → committer,
  a new commit in the same branch. `--amend`, `rebase` and force-push happen
  only at kyukhin's explicit request.
- **While there is no remote repository** the same happens locally: a task
  branch, a commit, and after a "yes" `git switch master` and
  `git merge --ff-only <branch>`.
- **Commits and PRs:** English, short, no mention of Claude or AI, no
  `Co-Authored-By` and no "Generated with…" signatures. The author is kyukhin.

Standing permissions of kyukhin. Only kyukhin changes them, in words in the
chat; record the date and the quote.
- Pushing task branches and opening PRs without asking: **yes** (2026-11-27,
  kyukhin: "3. yes" to "Give a standing permission to push branches and open
  PRs without asking? Merging into `master` still only by your 'yes'.").
  Merging a PR into `master` still needs kyukhin's "yes" every time.
- Parallel work: **yes**, within limits: two architects at a time; two
  developers at a time in M0, up to three from M1 (2026-11-27, kyukhin:
  "2. yes" to the proposal with exactly these limits).

## How to brief a subagent

Write the brief as if the subagent knows nothing (it really has not seen this
conversation):
- the role and the goal in one sentence;
- a link to the task or epic (`docs/tasks/TASK-NNN-*.md`), to the epic spec
  (`docs/specs/E-NN-*.md`) and to an ADR if needed;
- what to return (the report format is described in the role's skill);
- special instructions of kyukhin from this conversation, if they concern the task.
Decisions kyukhin made in the chat are first recorded in documents (PRD, ADR,
spec, task file): a subagent knows only what is written down.

## Subagent models

The default model and effort are set in the frontmatter of `.claude/agents/*.md`.
One exception: if the task file says `Complexity: high`, call the developer with
the parameter `model: opus` (keep the effort from the definition). For fixes
after a QA FAIL use the same model as the first time.

## The single source of truth for statuses

`docs/plan/BOARD.md`. Task statuses:
`draft → ready → in-progress → in-review → done`, plus `blocked` with a reason.
Spec statuses, `planned → draft → approved → implemented`, live in the spec
header and in the index `docs/specs/README.md`.
Do not keep state in your head. At the start of every session read BOARD.md and
tell kyukhin briefly where we are and what is next.

## Architectural invariants (from day one)

1. **The source is separate from the player.** The player core, the library and
   the position store know nothing about Telegram. Every storage works through
   the `MediaSource` contract from `docs/architecture/CONTRACTS.md`. Telegram is
   the `source-telegram` module.
2. **Access to Telegram can be moved to a server.** The contract does not depend
   on whether we reach Telegram from the phone (TDLib) or through our own gateway.
3. **The listening position is first-class data:** it is saved locally and
   often, and is bound to a stable track identifier.
4. **Secrets never get into git:** `api_id`, `api_hash`, TDLib sessions, S3
   keys, tokens.

## Document layout

```
docs/
  product/PRD.md                 what and why (CPO)
  plan/ROADMAP.md, BOARD.md      milestones, epics, statuses (PM)
  architecture/OVERVIEW.md       modules and dependencies (Architect)
  architecture/CONTRACTS.md      contracts between modules (Architect)
  architecture/adr/NNNN-*.md     architecture decisions (Architect)
  specs/README.md                spec rules, template, index
  specs/E-NN-*.md                epic spec: behavior, design, test plan
                                 (Architect writes, kyukhin approves)
  tasks/TASK-NNN-*.md            tasks (Architect creates, Developer adds notes)
  qa/TASK-NNN.md                 QA reports
CHANGELOG.md                     what changed for the user (Developer)
```

## What not to do

- Do not do a subagent's work yourself and do not "just slightly fix" code
  after QA. Any edit after QA goes through developer and qa again.
- Do not widen a task silently. Everything outside the acceptance criteria is a
  new `draft` task.
- Do not let the code and the spec diverge, and do not fit the spec to the code
  after the fact.
- Do not change the app to make a test pass: the product matters more, the test
  gets fixed.
- Do not bypass checks (`--no-verify`, disabled tests).
- Do not commit to `master` and do not create merge commits.
- Do not start the next task without kyukhin's answer to the report.
- Do not put non-English text into the repository or on GitHub, except the
  Russian and Greek translations in the localization resources.

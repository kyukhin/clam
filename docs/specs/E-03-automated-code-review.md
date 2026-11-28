# E-03: Automated code review and the first checks

> Status: approved by kyukhin 2026-11-27 · Milestone: M0 · Epic: #8 · Tickets: #35 (T1), #36 (T2), #37 (T3), #38 (T4) · Updated: 2026-11-28

Read first: `docs/architecture/OVERVIEW.md`, ADR-0005 (the review and its
place in the pipeline; accepted 2026-11-27), ADR-0001 (the toolchain and the
localization paths), `docs/specs/E-01-project-skeleton.md` (approved
2026-11-27; it adds to what this epic creates, see "What moves from E-01 to
E-03").

## Why

Between QA and kyukhin nothing reads a pull request. The language rule, the
whitespace rules and the ban on secret files are kept only by commands that
the QA and committer skills run by hand in every task. E-03 covers no MVP
item. It serves:

- PRD §14: "Automated code review has to be added, CodeRabbit or somebody
  else."
- Milestone M0 on GitHub: "A PR in the repository gets an automated review."
- Invariant 4 of CLAUDE.md and the risk of PRD §12 "Secrets get into the
  public repository".
- CLAUDE.md, "Language": English only outside the localization resources.

E-03 goes first in M0, before there is any Swift project.

## Behavior

### On a pull request

| | Was | Now |
|---|---|---|
| Checks on the PR page | None | Two: `check` (GitHub Actions) and `CodeRabbit` (the bot's own). Neither is required: the merge button works whatever they show |
| Review | Nobody reads the PR before kyukhin | A comment of `coderabbitai` with a walkthrough, and inline threads in "Files changed". When kyukhin is asked to merge, every thread has an answer and is resolved |
| Commits of a task | One | One, on the PR page when kyukhin is asked to merge and on `master` after the merge. A fix made after the PR was opened is a `fix` commit first; the dispatcher folds it into the task's commit and force-pushes the branch before the report (kyukhin, 2026-11-27; ADR-0005, item 8). The PR page keeps the force push in its timeline |
| Title and description | The committer's text | The same. The bot edits neither, never approves, never requests changes, never commits |
| Report in the chat | The line "QA" | Two more lines: "Review" and "GitHub check" (ADR-0005) |
| Checking a change on the Mac | Commands copied from the skills | `make check` |

Whether the bot starts by itself on `clam` is not known. The docs say a
repository with fewer than 10 stars has to ask for every review (ADR-0005,
V2); LibreDict, with 3 stars, is reviewed without asking (ADR-0005, L4). The
step works either way: where the bot did not start, the PR also shows a
comment `@coderabbitai review` from kyukhin's account, posted by the
dispatcher with kyukhin's standing permission of 2026-11-27. The first review
shows which case holds (C10).

What the PR shows in each state:

| State | `CodeRabbit` check | What happens |
|---|---|---|
| The bot started by itself | Present within 2 minutes after the PR is opened | Nothing is posted |
| The bot did not start | Absent after 2 minutes | The dispatcher comments `@coderabbitai review` |
| Review running | "Review in progress" | The dispatcher waits, up to 15 minutes; in LibreDict a review was published within 3 to 11 minutes |
| No findings | "Finished" | Report: "Review: no findings" |
| Findings | "Finished" | Sorted by ADR-0005: fixed in a new commit that is folded into the task's commit before the report, recorded as a follow-up, or answered as kept as is |
| The one review of the hour is used | "Review rate limited" | Asked once more if the next review is available within 30 minutes; otherwise the report says "Review: not done: rate limit" |
| Bot silent, service down, or the App does not cover the repository | Absent, or "Review failed" | Asked once more; then the report says "Review: not done" with the reason |
| `check` red | Unaffected | The report names the red job, and kyukhin decides (E-01) |
| GitHub Actions down | Unaffected | The report says "GitHub check: not finished"; `make check` on the Mac has passed anyway |

No state stops work by itself, except a secret found in the branch.

### What kyukhin does by hand

kyukhin's account already has CodeRabbit: it reviews LibreDict (ADR-0005,
L3). No sign-up and no new installation is needed. Whether H1 and H2 are
done is the state of issue #43, assigned to kyukhin.

- **H1. Add `clam` to the installation.** github.com → Settings →
  Applications → Installed GitHub Apps → CodeRabbit → Configure. Under
  "Repository access" add `clam` to the selected repositories and save. If the
  page says "All repositories", change nothing and tell the dispatcher: then
  the bot should have commented on PR #1 already, and something else is wrong
  (ADR-0005, A2).
- **H2. Look at the permissions on the same page.** They are in ADR-0005, V4:
  read and write for code, issues, pull requests, checks, commit statuses and
  workflows. If the page shows more, tell the dispatcher.
- **H3. Change nothing in CodeRabbit's web interface.** A repository with its
  own settings file does not use it (ADR-0005, V18).
- **H4. Later.** When CodeRabbit asks to approve a new permission, it is
  kyukhin's decision each time.

To take the bot off Clam: the same page, remove `clam` from the selected
repositories.

**When to do H1:** when the dispatcher says that the pull request with
`.coderabbit.yaml` is open: the pull request of T1. From the moment the
bot has access it can review, by itself, whatever is opened or pushed next
(ADR-0005, L4). Without the file it works with the settings of kyukhin's
account, as in LibreDict, where it appends its own block to the PR
description (ADR-0005, L7, V18). That is harmless, but it cannot be taken
back for that pull request.

On 2026-11-27 no pull request is open that H1 could affect: PR #1 is merged.
The next pull requests are the dispatcher's document pull requests, then
those of the tasks. Two kinds can be in the position above: a document pull
request that is still open at H1 and is pushed to afterwards, and a task
branch that was cut before `.coderabbit.yaml` reached `master`. The way to
avoid both: the document pull requests are merged before H1, and the branch
of every task after T1 is cut from a `master` that holds the file. A
pull request that misses this gets the bot's block in its description and
findings of SwiftLint, and nothing worse.

### Decisions

- 2026-11-27 (kyukhin): "Automated code review has to be added, CodeRabbit or
  somebody else." (PRD §14)
- 2026-11-27 (kyukhin): "CodeRabbit should be added right away, and the other
  small checks too." (roadmap, E-03)
- 2026-11-27 (kyukhin): builds are made "locally; we do not spend money on
  Actions"; then "ok, let's add these checks. But the main testing will
  apparently have to be run locally." The roadmap records the result: the
  checks on the Mac are the main line, the free checks on GitHub are a second
  line that needs no secrets. "Not required for merging" comes from the
  dispatcher's recommendation, which kyukhin answered "ok" to (E-01,
  "Decisions").
- 2026-11-27 (kyukhin): "yes. everything as in LibreDict" (E-01, "History").
  The GitHub settings of `kyukhin/clam` follow those of `kyukhin/dict-app`
  and are in place, copied by the dispatcher the same day. They are listed
  under "GitHub settings"; this epic changes none of them.
- 2026-11-27 (kyukhin): the dispatcher pushes task branches and opens PRs
  without asking; merging needs kyukhin's "yes" (CLAUDE.md).
- 2026-11-27 (E-01, approved): a red job on GitHub blocks nothing; the
  dispatcher names it to kyukhin and does not wait for a run.
- 2026-11-27 (ADR-0005, accepted): the review runs after the PR is opened, is
  a second line, and its findings are sorted by the dispatcher.
- 2026-11-27 (ADR-0001): Swift with no third-party code; the four localization
  paths; `swift format` is the linter.
- 2026-11-27 (architect): E-03 keeps the names and the layout that E-01
  designed (`Makefile`, `Tools/ClamChecks`, `.github/workflows/ci.yml`, the job
  `check`), so E-01 only adds to them.
- 2026-11-27 (architect): four checks. `language` and `tracked-files` come
  from E-01. `whitespace` and `secrets` are new.
- 2026-11-27 (architect): the list of files that must not be tracked is wider
  than E-01's: more signing formats, TDLib data, more editor leftovers and a
  size limit of 1 MiB.
- 2026-11-27 (architect): the checks look at what git would commit, not only
  at what is tracked: the developer does not commit, so new files of a task
  are untracked when the checks run.
- 2026-11-27 (architect): no test fixture that breaks a check is stored in the
  repository; the tests build them at run time.
- 2026-11-27 (architect): the tool builds with Xcode 26.4, which the Mac has
  today. E-03 does not wait for the update of the Mac (E-01, K1).
- 2026-11-27 (architect): `make clean-check` stays in E-01. It proves that a
  build needs nothing outside git; until there is a build, the job on a fresh
  GitHub runner proves the same for the tool.
- 2026-11-27 (architect): the workflow uses only GitHub's own actions, pinned
  to a commit, although the repository settings do not demand it.
- 2026-11-27 (architect): Clam gets a `.coderabbit.yaml` with five values and
  four instructions, although LibreDict has none (open question 2, which
  kyukhin closed with "3 yes").
- 2026-11-27 (architect): PR #1, with the planning documents, was merged on
  2026-11-27, before the bot had access to `clam`; it got no review and gets
  none. The same holds for the document pull requests the dispatcher opens
  before TASK-001: until H1 the bot does not see the repository, and their
  reports say "Review: not done" with that reason.
- 2026-11-27 (kyukhin): "1 yes", in answer to "Do you approve the review
  decision and the spec of the epic?". ADR-0005 is accepted and this spec is
  approved.
- 2026-11-27 (kyukhin), open question 1: "2 yes". The dispatcher may comment
  on pull requests in kyukhin's name, for the review only: ask the bot for a
  review, answer its threads in one or two sentences and resolve them. A
  standing permission.
- 2026-11-27 (kyukhin), open question 2: "3 yes". Clam gets the
  `.coderabbit.yaml` of this spec.
- 2026-11-27 (kyukhin), open question 3: "4 we squash into one commit and
  force-push the branch". This is M2: one task is one commit on `master`; the
  fix commits of a branch are folded into the task's commit and the branch is
  force-pushed before the merge. It is also the standing permission to rewrite
  and force-push a task branch for that purpose. ADR-0005 wrote its proposed
  text for M1; the dispatcher applies the kit text in the M2 wording, and the
  architect aligns ADR-0005 with it.
- 2026-11-28 (kyukhin): "3 yes" to "Do I fold a fix into the task's commit
  before pushing it, not before the report?". A fix is folded before it is
  pushed, so the review and the `check` job run on the commit that will be
  merged. CLAUDE.md holds the text in force; the places of this spec and of
  ADR-0005 that say "before the report" are aligned at the architect's next
  call on them.
- 2026-11-28 (kyukhin), step 4 of C10: "4 yes" to "May I post one comment
  `@coderabbitai configuration` on the PR of the first task in your name?".
  The dispatcher posts this one comment.
- 2026-11-27 (architect): the epic is cut into four tasks, and the first is
  `.coderabbit.yaml` (TASK-001). H1 follows its pull request, so the pull
  requests of the tasks that bring code are reviewed with Clam's settings.
  TASK-002 brings the check tool, `make check` and the first check,
  `whitespace`; TASK-003 the job on GitHub; TASK-004 the other three checks
  and the rewritten `.gitignore`. Who covers the criteria that are no
  developer task is said under "Test plan".
- 2026-11-27 (architect): details fixed while the tasks were cut, each in its
  place under "Design": what the checked set does with a deleted file and
  with git's other exclude files; the form of a path, a line and a column in
  the output; how a pattern of `tracked-files` matches and what its second
  part reads; what a run of digits is in `secrets`; that a compiler warning
  fails `make check`. None changes what kyukhin sees.

## Design

### Layout

```
.coderabbit.yaml           the settings of the review bot
.gitignore                 rewritten
Makefile                   lint, test-tools, check
Tools/ClamChecks/          the check tool: a Swift package for macOS, with tests
.github/workflows/ci.yml   the job `check`
```

### Commands

| Command | What it does |
|---|---|
| `make lint` | Runs the four checks. It runs all of them even when one fails, prints every violation and exits with an error if any check failed |
| `make test-tools` | Runs the tests of the check tool, on macOS |
| `make check` | `lint`, then `test-tools`. The one command for the developer, for QA and for the committer's final check |

`make check` is the main line: it decides whether a task is done. It needs
macOS, git and the Swift of the selected Xcode, and nothing else. It makes no
network request. It first prints the version of the Swift it runs with, and a
compiler warning in the tool fails it: a green run, on the Mac or in the job
on GitHub, shows which toolchain built the tool and that it built without a
warning.

### The check tool

`Tools/ClamChecks` is a Swift package with one executable, `clam-checks`, and
no dependencies. Swift language mode 6. It builds without warnings with Xcode
26.4 (Swift 6.3) and with Xcode 27.

- **Commands:** `language`, `whitespace`, `tracked-files`, `secrets`. Each
  checks the repository that holds the current directory.
- **The checked set:** every tracked file with its current content, and every
  untracked file that `.gitignore` does not exclude. This is what a commit of
  the working tree would hold, and the same set as the clean copy of E-01.
  git decides what is excluded, as it does for `git status`: by the
  `.gitignore` files, `.git/info/exclude` and the user's global excludes
  file. A tracked file that is deleted in the working tree is not in the set, and
  neither is a tracked path that lies below a symbolic link (a folder replaced
  by a link): a commit of the working tree would hold the link, not the path.
- **Text and binary:** a file with a NUL byte is binary. Its name and size are
  checked, its content is not. A symbolic link is checked by name only and is
  never opened.
- **Output:** one line per violation, `path:line:column: check: message`,
  sorted by path and line; a violation about a whole file has no line and
  column. The path is relative to the root of the repository. Lines and
  columns start at 1, and a column counts the bytes of its line. Violations
  go to standard output, every other message to standard error.
- **Exit status:** 0 with no violation, 1 with violations, 2 for a wrong call,
  when the directory is not in a git repository, or when a file of the set
  cannot be read (the message is on standard error, the other files are still
  checked and their violations printed).
- **Tests:** Swift Testing. Every fixture that breaks a check is built by the
  test in a temporary directory or a temporary git repository: a letter from
  its code point, a key-shaped value from parts, a file with a forbidden name.
  A stored fixture would itself fail the checks, the searches of QA and of the
  committer, and GitHub's push protection.

### The four checks

Each fails by exit status 1 and a line per violation.

**`language`.** A character whose Unicode script is Cyrillic or Greek, in the
content or in the path of a checked file. This is the rule the committer's and
QA's commands use (`\p{Cyrillic}`, `\p{Greek}`): a single Greek letter used as
a symbol fails too and is written as a word. Exempt are the localization paths
of ADR-0001, row "Languages":
`Packages/ClamKit/Sources/Localization/Resources/Localizable.xcstrings`,
`App/InfoPlist.xcstrings`, `AppStore/metadata/ru/`, `AppStore/metadata/el/`.
The tool holds this list in one place; when ADR-0001 changes the paths, the
list changes in the same commit.

**`whitespace`.** In a text file, each of these is a violation:

| No. | Violation |
|---|---|
| W1 | A space or a tab at the end of a line |
| W2 | A tab anywhere, except in `Makefile` and `*.mk` |
| W3 | A carriage return |
| W4 | A byte order mark |
| W5 | A file that is not empty and does not end with exactly one line feed |
| W6 | Content that is not valid UTF-8 |

An empty file passes. The check only reports; it rewrites nothing.

**`tracked-files`.** Two parts.

1. No path of the checked set matches a pattern of this table, and no file is
   larger than 1 MiB (1,048,576 bytes).

   | Group | Patterns |
   |---|---|
   | Signing material | `*.p12`, `*.p8`, `*.cer`, `*.pem`, `*.key`, `*.mobileprovision`, `*.provisionprofile`, `*.certSigningRequest` |
   | Local configuration | `Config/Local.xcconfig`, `.env`, `.env.*` except `.env.example`, `secrets/`, `.claude/settings.local.json` |
   | TDLib data | `tdlib/`, `tdlib-db/`, `*.tdlib`, `*.db`, `*.db-journal`, `*.binlog` |
   | Build output | `DerivedData/`, `.build/`, `.swiftpm/`, `xcuserdata/`, `*.xcresult`, `*.xcarchive`, `*.ipa` |
   | Editor and system leftovers | `*~`, `#*#`, `.#*`, `*.swp`, `*.orig`, `*.rej`, `.DS_Store` |

2. `.gitignore` ignores a sample name of every pattern of the table. A line
   removed from `.gitignore` fails the check before any such file appears.
   This part reads only the `.gitignore` in the root of the repository: a
   pattern that only the user's global excludes file or `.git/info/exclude`
   covers still fails, so the answer is the same on every machine.

A pattern matches a path as git matches the same line of a `.gitignore` in
the root of the repository.

`.gitignore` is rewritten to hold exactly these patterns, by group; `#*#` is
written `\#*#` there, because git reads a line that starts with `#` as a
comment. Its Android and Flutter lines (`local.properties`, `*.keystore`,
`*.jks`, `build/`, `.gradle/`, `.idea/`, `*.iml`, `.dart_tool/`) go. A later
spec that needs a larger file or a forbidden name changes the table, the tool
and `.gitignore` in one commit.

**`secrets`.** In a text file, each of these is a violation:

| No. | Violation |
|---|---|
| S1 | A line that names the Telegram hash (`api_hash`, `apiHash`, `API-HASH`: any case, with `_`, `-`, a space or nothing between the words) and holds a run of exactly 32 hexadecimal digits |
| S2 | A line that names the Telegram id (`api_id` in the same spellings) and holds a run of 5 to 10 decimal digits |
| S3 | The header of a private key block: the text `-----BEGIN`, then nothing but capital letters and spaces, then `PRIVATE KEY-----` |

A run is as long as it can be: 33 hexadecimal digits in a row are not a run
of 32, and 11 decimal digits in a row are not a run of 5 to 10.

The message names the kind of secret and never repeats the matched text: the
log of the GitHub job is public. A line that only names `api_id` or `api_hash`
passes; the documents are full of such lines. Example files use placeholders
that do not match: `0` and `<api_hash>`.

The check is not a general scanner. It covers what GitHub's scanner does not
know (see "What GitHub's scanner does not see").

The repository as it is on 2026-11-27 passes all four checks except for two
things the first task with a check, T2, removes: `docs/product/PRD.md` has no
final line feed (one byte is added, no text changes), and the editor's lock
and autosave files in `docs/plan/`, a folder the repository had then, are not
ignored until `.gitignore` gets `.#*` and `#*#`. T2 adds these two lines and
the two for the build output of the tool, `.build/` and `.swiftpm/`; T4
rewrites the file together with the check that holds it in place.

### Checks on GitHub: the second line

`.github/workflows/ci.yml`, on every pull request into `master` and on every
push to `master`, has one job:

- `check`, on the runner `xcode-27`: `make check`.

The workflow holds no logic of its own. Its constraints:

- `permissions` at the top level: `contents: read`, nothing else.
- It names no secret; the repository has none. The trigger is `pull_request`,
  never `pull_request_target`.
- It uses one action, GitHub's own `actions/checkout`, pinned to a full commit
  hash, with credentials not persisted.
- A newer run for the same pull request cancels the older one. A run for a
  push to `master` shares its concurrency group with no other run, so no
  later run cancels it or replaces it while it waits: every push to `master`
  gets its own result. The job has a time limit of 15 minutes.
- No cache and no artifact in E-03.

A pull request from a fork runs it with a read-only token and no secrets, and
GitHub asks kyukhin to approve the first run of a first-time contributor. The
runner is free for a public repository (GitHub Docs, read on 2026-11-27: "Use
of the standard GitHub-hosted runners is free and unlimited on public
repositories"; `xcode-27` is in the table of standard runners).

The job is not required for a merge, and nobody waits for a run (E-01).

### GitHub settings

kyukhin decided them on 2026-11-27: "yes. everything as in LibreDict". The
dispatcher copied them from `kyukhin/dict-app` the same day. This is the state
read through the GitHub API after the copy. E-03 changes none of it and reads
it back (C8).

| Setting | Value |
|---|---|
| Ruleset `master`, on the default branch, active, with an empty bypass list | No deletion; no force push; a pull request required, with 0 approvals; merges by rebase only; no required check |
| Secret scanning; push protection | On; on |
| Dependabot alerts; Dependabot security updates | On; on |
| Actions: which actions are allowed; pinning to a commit required | All; no |
| Actions: default workflow token; Actions may approve pull requests | Read-only; no |
| Actions: runs for pull requests from forks | First-time contributors wait for approval |
| Actions secrets, variables, environments | 0, 0, 0; none is created (E-01) |
| Private vulnerability reporting | Off |
| Code scanning (CodeQL) | Not configured |
| Secret scanning: non-provider patterns, validity checks | Disabled |

All of it is free for a public repository of a personal account: rulesets and
Dependabot are on every plan; secret scanning, push protection and code
scanning are "Available for public repositories by default" (GitHub Docs,
"GitHub security features", read on 2026-11-27).

What follows from these values:

- **The ruleset bounds the review App.** The App can write code (ADR-0005,
  V4), and nothing reaches `master` except through a pull request that
  kyukhin merges. It binds kyukhin too: no direct push to `master`.
- **Merges are by rebase only.** `gh pr merge --squash` is refused. One task
  is still one commit on `master`: the dispatcher folds the commits of a task
  branch into one and force-pushes the branch before it reports (kyukhin,
  2026-11-27; ADR-0005, item 8; CLAUDE.md, "One task, one commit"). The
  ruleset forbids a force push to `master` only, so a task branch can be
  force-pushed.
- **The repository does not demand GitHub's own, pinned actions.** The
  workflow of this epic meets that rule by its own constraints; QA and the
  review read every later change of it.
- **Dependabot can open pull requests** once a dependency with a known hole
  exists; none exists before M2. Such a pull request is no task: the
  dispatcher shows it to kyukhin and does not merge it.

Is anything else worth turning on now? Nothing is required. Two switches are
free and are off in LibreDict as well: private vulnerability reporting, which
belongs with the security policy of E-04, and CodeQL, which the ADR before
E-10 weighs when TDLib and the session arrive. Non-provider patterns are not
offered to this repository: the docs name organization-owned repositories with
the paid GitHub Secret Protection.

### What GitHub's scanner does not see

GitHub's secret scanning does not recognize Telegram's `api_id` and
`api_hash`. Its list of supported patterns has one Telegram entry, the bot
token, which Clam does not use. It has no pattern for an App Store Connect key
or for any Apple signing file. `api_hash` is 32 hexadecimal digits and
`api_id` is a short number: neither has a prefix or a checksum, so no scanner
knows them by shape alone.

What covers them, in order:

| Line | What it stops | When |
|---|---|---|
| The values live only in a file that git ignores: `Config/Local.xcconfig` (E-01); the spec that brings the Telegram keys says where they go | The ordinary path | Always |
| `tracked-files` | That file, signing files and TDLib session data entering git | `make check`, before the commit |
| `secrets` | A value pasted next to its name into any other file; a private key block | `make check`, before the commit |
| QA, step 11, and the committer's search of the index | What no pattern catches | Before the commit |
| GitHub push protection | Tokens of the providers GitHub knows | At the push |
| CodeRabbit: its secret scanners and its reading | A second look | After the push, when the secret is public already |

Nothing automatic covers a value pasted into a PR description, a comment or
an issue.

### `.coderabbit.yaml`

Schema V2, declared with `version: 2` (ADR-0005, V7). The file holds five
values and one instruction entry; everything else is the bot's built-in
default.

| Key | Value | Why |
|---|---|---|
| `language` | `en-US` | CLAUDE.md, "Language". The default, written out so that a change shows in a diff |
| `reviews.high_level_summary_in_walkthrough` | `true` | The summary stays in the bot's own comment; the PR description stays the committer's text |
| `reviews.auto_approvals.enabled` | `false` | The bot never approves and never requests changes, whatever the account's settings say |
| `reviews.tools.swiftlint.enabled` | `false` | ADR-0001: the linter is `swift format`. Otherwise SwiftLint runs with a configuration the bot generates (ADR-0005, V14) |
| `knowledge_base.learnings.scope`, `knowledge_base.issues.scope`, `knowledge_base.pull_requests.scope` | `local` | What the bot learns from answers in Clam stays in Clam, and LibreDict's stays out |

`reviews.path_instructions` has one entry, for all paths, that says four
things: the decisions in `docs/architecture/adr/` and in the specs are not up
for review, so no other stack, linter, dependency or CI service is proposed;
Cyrillic or Greek text outside the four localization paths is reported;
anything that looks like a credential, a session file or a signing file is
reported; an import of a `Source…` or `Skin…` module outside the app target is
reported (ADR-0002). The bot reads CLAUDE.md and the skills by itself
(ADR-0005, V11).

No path is filtered out in E-03. The epic that adds generated or binary files
adds their filter.

What the file adds over LibreDict's setup, which has no file:

- **Clam's settings are in the repository,** seen in a diff and read by QA.
  Without a file Clam uses the settings of kyukhin's account in CodeRabbit's
  web interface, the same ones LibreDict uses, and a change there changes both
  (ADR-0005, V18).
- **The PR description is not edited.** In LibreDict the bot appends a block of
  its own (ADR-0005, L7).
- **One linter.** No SwiftLint findings next to `swift format`.
- **The project's rules reach the bot directly,** in four sentences.

What it costs: one file of about 30 lines, and pull requests that look
slightly different from LibreDict's.

### The kit

The review step is in CLAUDE.md and in the committer's and the developer's
skills. The dispatcher applied it on 2026-11-27, after kyukhin's answers, in
the wording for one commit per task (M2). It is a change of documents, not a
developer task: it lives in the branch `kyukhin/000-review-kit` and gets its
own pull request. ADR-0005, "The kit text", says in which sections the text
is and where it differs from what the ADR had proposed. C11 is kyukhin's
reading of the diff of that pull request.

### What moves from E-01 to E-03

For the architect's next call on the E-01 spec, which kyukhin approved "with
the caveat that a part of the checks moves to E-03" (E-01, "History"). E-03
creates these; E-01 then only adds.

| Item of the E-01 spec | Moves to E-03 | What E-01 still adds |
|---|---|---|
| "Layout": `Makefile` | The file, with `lint`, `test-tools`, `check` | `build`, `test`, `ui-test`, `format`, `archive`, `clean-check`, `testflight`; `swift format lint --strict` at the start of `lint`; its steps in `check` |
| "Layout" and "Checks": `Tools/ClamChecks` | The package, the executable `clam-checks`, the checked set, the output format, the exit statuses, the rule about fixtures | The commands for boundaries, dependencies and the release guard |
| "Layout": "with fixtures" | A fixture that breaks one of the four checks is built at run time | Stored fixtures for the boundary check are fine: they break none of the four |
| "Checks", item 2, Language | Whole, as `language` | Nothing |
| "Checks", item 4, Tracked files | Whole, as `tracked-files`, with a wider list and the size limit | A pattern for any new kind of output, in the table, the tool and `.gitignore` together |
| "Checks": "five commands", "`make lint` runs the first four" | E-03 has four commands, two of them new: `whitespace`, `secrets` | The count becomes seven; `make lint` runs all but the release guard |
| "Layout", the last item: `.gitignore` | Whole | Nothing, unless a new pattern is needed |
| "Layout" and "Checks on GitHub": `.github/workflows/ci.yml` | The file, the triggers, the job `check`, the permissions, the pinning, the cancelling of older runs | The job `compat`; `upload-artifact`; a longer time limit if the grown `check` needs it |
| K6, GitHub | Settled by kyukhin on 2026-11-27 and in place. The table of the settings as they are, and the criterion that reads them back (C8), are here | Nothing. K6 still names a linear-history rule, GitHub-only actions and approval for every fork run; none of the three is in force |
| Test plan, C6 | Whole: C1 here | — |
| Test plan, C8 | Whole: C3 here | — |
| Test plan, C9 | The permissions, the secrets, the pinned actions and the repository settings: C7 and C8 here | That `check` runs the grown `make check`, and `compat` |
| "Checks on GitHub": a fork run "starts after kyukhin's approval (K6)" | Here: only the first run of a first-time contributor waits | — |
| "Secrets and signing material", the last paragraph | Stays true; it can point to this spec | — |
| "Not in E-01": "the code review tool (E-03)" | Becomes "the review and the first checks (E-03)" | — |

Stays in E-01 although it needs no app code: `make clean-check` and the clean
copy with C12; `make format` and `.swift-format`; `Config/`; `scripts/` (E-03
needs no script); `Config/allowed-dependencies.txt`.

Three things for that call:

- **`whitespace` and the files Xcode writes.** The project file uses tabs, and
  other generated files can break W2 or W5. E-01 adds the exceptions together
  with the files.
- **K1 is not a precondition of E-03.** The tool builds with the Xcode the Mac
  has today.
- **A red job.** C9 of E-01 says "a red job returns the task to the
  developer"; its "Decisions" say the dispatcher names a red job to kyukhin,
  who decides. ADR-0005 follows the decision.

`actions/checkout` runs only on GitHub's runner and never in a build on the
Mac. It gets no line in `Config/allowed-dependencies.txt`, which E-01 creates
for the dependencies of packages and of the Xcode project.

### Not in E-03

The build, the tests, `swift format`, the boundary and dependency checks, the
clean copy and the delivery (E-01); the README, the security policy and the
example file for the keys (E-04); a check of commit messages and PR texts
(language, no attribution lines), which stays with the committer's skill; a
mode that fixes whitespace; a review before the commit with CodeRabbit's
command-line tool (ADR-0005, option B); any change of the GitHub settings.

## Test plan

Nothing in E-03 is checked on the phone. C10, C11 and C12 are checked by hand
on GitHub, and none of them is a developer task: C10 and C12 are checked by
kyukhin and the dispatcher on the pull request the table names, and C11 is the
dispatcher's change of the kit, which kyukhin reads.

The tickets, in the order of work: T1 (#35, formerly TASK-001), T2 (#36,
formerly TASK-002), T3 (#37, formerly TASK-003) and T4 (#38, formerly
TASK-004). The old numbers stay where they were written before the tasks
moved to GitHub on 2026-11-28: in "History", in the dated entries of
"Decisions", in the commits of T1 to T3 and in the names of their QA reports,
`docs/qa/TASK-001.md` to `docs/qa/TASK-003.md`.

Rows with more than one ticket. C5: T2 proves the set, the links, the output
and the exit statuses with `whitespace`; T4 proves "by name and size" with
`tracked-files`. C6: T2 proves the three commands with the first check and
Xcode 26.4; T3 proves Xcode 27, by the `check` job; T4 proves that
`make lint` runs all four checks.

| No. | Acceptance criterion | Ticket | Proved by |
|---|---|---|---|
| C1 | `language` fails on a Cyrillic and on a Greek letter in the content of a checked file and in its path; passes for the same letters under each of the four localization paths; passes on Latin text, digits, punctuation and symbols of other scripts; passes on the repository | T4 | tool tests, fixtures built at run time; the check on the repository |
| C2 | `whitespace` fails on each of W1 to W6; passes on a tab in `Makefile` and on an empty file; passes on the repository, where `docs/product/PRD.md` now ends with one line feed and no other byte of it changed | T2 | tool tests; the check on the repository; QA compares the PRD with `master`. Tests (`WhitespaceRuleTests`): `w1TrailingSpace`, `w1TrailingTabIsAlsoATab`, `w1ReportsTheStartOfTheTrailingRun`, `w1LineOfSpacesOnly`, `w1OnTheLastLineWithoutLineFeed`, `w1SpaceBeforeACarriageReturnIsTrailing`, `w1SpaceInsideALineIsFine`, `w2TabInTheMiddleOfALine`, `w2LeadingTabOnALaterLine`, `w2OneLineForEachLineWithATab`, `w2ExemptPaths` (`Makefile`, `*.mk`, at any depth), `w2PathsThatAreNotExempt`, `exemptionOfW2LeavesTheOtherRulesInMakefile`, `w3CarriageReturnAtTheEndOfEveryLine`, `w3CarriageReturnInsideALine`, `w3CarriageReturnWithoutLineFeedOnTheLastLine`, `w4ByteOrderMark`, `w4ByteOrderMarkInAnOtherwiseEmptyLine`, `w5NoLineFeedAtTheEnd`, `w5MoreThanOneLineFeedAtTheEnd`, `w5ThreeLineFeedsAtTheEnd`, `w5FileOfTwoLineFeeds`, `w5IsAboutTheWholeFileAndHasNoPosition`, `w5TheMessageSaysWhichOfTheTwoCasesItIs`, `w5EmptyFilePasses`, `w5ExactlyOneLineFeedPasses`, `w6InvalidUTF8` (7 cases), `w6ValidMultiByteTextPasses`, `w6TheLastLineInvalidWithoutLineFeedAlsoGetsW5`, `aCleanFilePasses`, `theColumnCountsBytesNotCharacters`, `theCheckRewritesNothing`; `make lint` on the repository |
| C3 | `tracked-files` fails for a file of every pattern of the table when the file is tracked, and when it is untracked and not ignored; passes when git ignores it; fails on a file larger than 1 MiB; fails when `.gitignore` does not ignore a sample of a pattern. `.gitignore` holds the patterns of the table and no Android or Flutter line. The check passes on the repository | T4 | tool tests on temporary git repositories; QA reads `.gitignore` |
| C4 | `secrets` fails on S1, S2 and S3; its output does not contain the matched value; it passes on lines that name `api_id` and `api_hash` without a value, and on the repository | T4 | tool tests, values built at run time; one test asserts the value is absent from the output |
| C5 | The checked set is every tracked file and every untracked file that git does not ignore. An ignored file with a violation passes. A binary file is checked by name and size only. A symbolic link, a dangling one included, is not opened. Output lines have the form `path:line:column: check: message`. The exit status is 0, 1 or 2 as designed | T2, T4 | tool tests on temporary git repositories. T2 (`CheckedSetTests`, `OutputAndExitStatusTests`): the set: `aTrackedFileIsCheckedWithTheContentItHasOnDiskNow`, `aTrackedFileThatIsCleanOnDiskPassesWhateverTheIndexHolds`, `anUntrackedFileThatGitDoesNotIgnoreIsChecked`, `aFileThatGitIgnoresIsNotChecked`, `theIgnoreFileItselfIsChecked`, `aFileThatIsTrackedAndIgnoredIsStillChecked`, `gitInfoExcludeIsHonored`, `theGlobalExcludesFileIsHonoredBecauseGitDecides`, `aTrackedFileDeletedFromTheWorkingTreeIsSkippedWithoutAnError`, `aTrackedFileInADeletedFolderIsSkippedToo`, `aTrackedFolderReplacedByAFileIsSkippedWithoutAnError`, `aTrackedFolderReplacedByALinkToAFolderOutsideTheRepositoryIsSkipped`, `aTrackedFolderReplacedByALinkToAFolderInsideTheRepositoryReportsTheFileOnce`, `aLinkInTheMiddleOfALongerPathIsSkipped` (the link at three depths), `aTrackedFolderReplacedByADanglingLinkIsSkipped`, `aPathWithASpaceAQuoteAndANonAsciiLetterIsReportedExactly`, `theSameNameIsReportedExactlyWhenTheFileIsTracked`, `runInASubdirectoryChecksTheWholeRepository`; binary files and links: `aFileWithANulByteIsBinaryAndItsContentIsNotChecked`, `aNulByteAtTheVeryEndStillMakesTheFileBinary`, `aLinkToAFileWithViolationsOutsideTheCheckedSetPasses`, `aDanglingLinkPasses`, `aLinkToADirectoryPasses`, `aLinkIsNeverFollowedEvenWhenItsTargetIsChecked`, `aNestedRepositoryIsNotOpenedAsAFile`; output: `aViolationInALineIsPathLineColumnCheckMessage`, `aViolationOfAWholeFileHasNoLineAndNoColumn`, `lineAndColumnStartAtOne`, `theColumnCountsBytesAndNotCharacters`, `theFormattedLineOfAViolationHasBothForms`, `thePathIsRelativeToTheRootNotToTheCurrentDirectory`, `linesAreSortedByPathAndThenByLine`, `aViolationOfAWholeFileSortsBeforeTheLinesOfItsFile`, `theOrderOfPathsIsByBytesNotByLocale`, `violationsGoToStandardOutputAndNothingGoesToStandardError`, `everyOtherMessageGoesToStandardErrorAndNothingToStandardOutput`; exit statuses: `exitStatusIsZeroWithNoViolation`, `exitStatusIsZeroForARepositoryWithoutFiles`, `exitStatusIsOneWithViolations`, `exitStatusIsTwoForAnUnknownCommand`, `exitStatusIsTwoForNoCommand`, `exitStatusIsTwoForMoreThanOneArgument`, `exitStatusIsTwoOutsideAGitRepository`, `exitStatusIsTwoForADirectoryThatDoesNotExist`, `exitStatusIsTwoForAFileThatCannotBeRead` |
| C6 | `make lint` runs all four checks, prints the violations of all of them and exits with an error if any failed. `make check` runs `lint` and `test-tools` and passes on the repository with Xcode 26.4 and with Xcode 27, with no compiler warning. No stored file of the tool breaks a check | T2, T3, T4 | by hand by QA on the Mac: add one violation of each check, see four groups of lines and the error exit, remove them. Mutation: QA breaks one rule of each check and sees its test fail. Xcode 27: the `check` job, whose log shows the Swift version in the first line of `make check` and no compiler warning (T3, read by the dispatcher on the pull request). T2: `make check`, `make lint` and `make test-tools` on the repository with Xcode 26.4; by hand, a file with a trailing space makes `make lint` print its line and fail, and an unused variable in the tool makes `make check` fail (`-Xswiftc -warnings-as-errors`); every fixture is built at run time by `TemporaryRepository` and removed with it |
| C7 | `.github/workflows/ci.yml` runs the job `check` with the single command `make check` on `xcode-27`, for a pull request into `master` and a push to `master`. It meets every constraint of "Checks on GitHub" | T3 | QA reads the workflow. After the PR of the task is opened: the `check` job is green on it. T3: the file is valid against GitHub's workflow schema (`check-jsonschema --builtin-schema vendor.github-workflows`, 0.39.0) and loads as YAML with `ruby -ryaml -rjson`; the pin is `actions/checkout` v7.0.1, the latest release on 2026-11-28, whose tag points straight at commit `3d3c42e5aac5ba805825da76410c181273ba90b1` (`gh api repos/actions/checkout/commits/<hash> --jq .sha` prints it); `runs-on: xcode-27` is in the runner table of `actions/runner-images`; `make check` is green on the Mac with the file in the tree; the concurrency group is read against GitHub's documentation of `concurrency` (a `pending` run is replaced by a newer one in the same group, so a push to `master` gets a group of its own, its run id). The run on the pull request, and the push runs on `master` after merges, are read by the dispatcher after the commit |
| C8 | The repository settings are as the table of "GitHub settings" says, and this epic changed none | T3 | QA reads each back with `gh api` and lists the values in its report. T3 changes no setting: the only files it adds or edits are the workflow and documents |
| C9 | `.coderabbit.yaml` is in the root and holds the five values and the four instructions, and nothing else. The bot reads it without a warning | T1 | QA reads the file against the table. Checks, run on the file: `ruby -ryaml -rjson` prints it as data, every key looked up in `schema.v2.json` with `jq` (type and enum values), `git diff --check`, the language command of the QA skill, `tail -c1 .coderabbit.yaml \| xxd -p` prints `0a`, and the glob of the entry read out of the file and matched with Minimatch 10.1.1, `dot` on and off, against 20 named paths and all 254 paths of depth 1 to 7 made of `a` and `.b` (the developer's notes, in #35). By hand, on the PR of the task: `@coderabbitai configuration` shows these values as coming from the file |
| C10 | The first review. On the PR that adds `.coderabbit.yaml`, after H1, a review runs, by itself or on the comment, and the `CodeRabbit` check reaches "Finished" | no developer task; on the pull request of T1 | by hand, kyukhin and the dispatcher, steps below |
| C11 | CLAUDE.md, the committer's skill and the developer's skill hold the review step of ADR-0005 in the wording for one commit per task (M2), which kyukhin chose | no developer task; the dispatcher's change of the kit | by hand: kyukhin reads the diff of the dispatcher's pull request from the branch `kyukhin/000-review-kit` |
| C12 | A task PR opened after C11 goes through the whole step: the report has the lines "Review" and "GitHub check", and on the PR page every thread of the bot has an answer and is resolved | no developer task; on the pull request of T3 | by hand, kyukhin, steps below |

C10, by hand, on the pull request of T1:

1. The PR of the task that adds `.coderabbit.yaml` is open. The dispatcher
   says so, and kyukhin does H1 and H2. Until H1 the bot does not see the
   repository, so the dispatcher starts the review step after it, not before.
2. If the `CodeRabbit` check has not appeared on the head commit 2 minutes
   after H1, the dispatcher asks for the review with the comment
   `@coderabbitai review` (kyukhin's standing permission of 2026-11-27).
3. Wait up to 15 minutes.
4. For C9: the comment `@coderabbitai configuration` is posted on the same
   PR, and the bot's reply is read against the table of "`.coderabbit.yaml`".
   The standing permission covers asking for a review and answering threads,
   not this command: kyukhin posts the comment, or tells the dispatcher to
   post this one.

Expected: the check `CodeRabbit` on the head commit shows "Finished". A comment
of `coderabbitai` holds a walkthrough in English with the summary inside. The
title and the description of the PR are unchanged: no block of the bot is
appended. The PR has no approval and no "changes requested" from the bot, and
the branch has no commit by the bot. No finding comes from SwiftLint. For C9:
the summary opens with no parsing warning and lists no unrecognized property
(ADR-0005, V19), and the reply to `@coderabbitai configuration` names the file
as the source of every value of the table.

The dispatcher writes into the QA report of T1, `docs/qa/TASK-001.md`, what
ADR-0005 only assumes: the number of reviews an hour that the bot's comment
names for `clam` (A1) and the minutes from the comment to "Finished". Whether
the bot starts by itself on `clam` (A1, A3) shows on the next pull request
that is opened: the dispatcher records in the QA report of that task whether
the check appeared within 2 minutes.

C12, by hand, on the pull request of T3. It is the first task PR whose
branch holds the workflow, so the first whose page can list both checks. If
it gets no review, C12 is checked on the next task PR that gets one:

1. kyukhin reads the report: it has a line "Review" with counts or a reason,
   and a line "GitHub check".
2. kyukhin opens the PR page. The checks box lists `check` and `CodeRabbit`,
   neither marked as required. Every thread of `coderabbitai` under "Files
   changed" ends with an answer and is resolved.

Expected: the counts of the report match the threads on the page.

## Open questions

All three are closed by kyukhin's answers of 2026-11-27: question 1 with (a),
question 2 with (a), question 3 with (M2). See "Decisions".

1. **May the dispatcher comment on pull requests in kyukhin's name, for the
   review only?** It would ask the bot for a review that did not start by
   itself, answer the bot's threads in one or two sentences and resolve them.
   The comments are public and stand under kyukhin's account; LibreDict's
   pull requests carry the same kinds of comments (ADR-0005, L4, L8).
   - (a) Yes, as a standing permission.
   - (b) No: the dispatcher puts the findings and the answers it proposes
     into the report; kyukhin answers the threads and asks for a review the
     bot did not start.
   - (c) Nobody answers the threads: the dispatcher sorts the findings and
     reports the counts, and the threads stay open on the PR page.

   Recommendation: (a). Otherwise every task waits for kyukhin twice. By
   default: (b), because only kyukhin's words give a standing permission.
2. **A `.coderabbit.yaml` for Clam, or none, as in LibreDict?**
   - (a) The file of this spec: five values and four instructions.
   - (b) No file: Clam uses the settings of kyukhin's CodeRabbit account, as
     LibreDict does. The bot then appends its block to PR descriptions and
     runs SwiftLint; C9 and the task for the file go away.

   Recommendation: (a), for the reasons under "What the file adds over
   LibreDict's setup". By default: (a).
3. **How do fixes reach `master` now that merges are by rebase only?**
   ADR-0005, "Merging by rebase only", has both wordings.
   - (M1) Every commit of a task branch lands as it is: the task's commit and
     one `fix` commit per round of fixes. Nothing is rewritten after QA.
   - (M2) One task, one commit: before the merge the fix commits are folded
     into the task's commit and the branch is force-pushed. It needs a
     standing permission to rewrite and force-push task branches.

   LibreDict's history has both (PR 370 and PR 384). Recommendation: (M1). By
   default: (M1).

## History
- 2026-11-27: first draft.
- 2026-11-27: reworked before it was shown to kyukhin, after kyukhin's "yes.
  everything as in LibreDict" and the approval of E-01. The GitHub settings
  are recorded as decided and in place, not proposed; the stricter Actions
  settings, private vulnerability reporting and the questions about them are
  gone. The step by hand is to add `clam` to the installation that serves
  LibreDict. `.coderabbit.yaml` shrank to five values. A red `check` is named
  to kyukhin, as E-01 decided. LibreDict's pull requests show that the bot
  starts reviews by itself there, against its own docs for small
  repositories, so the step no longer assumes that every review is asked
  for. New open questions 2 and 3.
- 2026-11-27: approved by kyukhin: "1 yes 2 yes 3 yes 4 we squash into one
  commit and force-push the branch", in answer to four questions: whether the
  review decision and this spec are approved; whether the dispatcher may
  comment on pull requests in kyukhin's name for the review; whether Clam gets
  a `.coderabbit.yaml`; how fixes reach `master`. The three open questions are
  closed; question 3 with M2, against the recommendation, so the places of
  this spec and of ADR-0005 that assume separate fix commits on `master` are
  still to be aligned by the architect.
- 2026-11-27: aligned with kyukhin's answers and with the accepted ADR-0005,
  and cut into TASK-001 to TASK-004; the status stays `approved`. What
  changed:
  - "Read first" names the ADR as accepted and the OVERVIEW, which exists
    now.
  - One task is one commit: a new row "Commits of a task" under "On a pull
    request", the row "Findings" of the state table, and "Merges are by
    rebase only" under "GitHub settings" say that a fix commit is folded into
    the task's commit before the report.
  - The wording that depended on open question 1 is gone: the dispatcher
    comments in kyukhin's name by the standing permission (the paragraph
    about the bot starting by itself; C10, step 2).
  - "The kit": the text is applied and lives in the branch
    `kyukhin/000-review-kit`; C11 names that pull request and no longer a
    "Proposed text", which ADR-0005 does not hold any more.
  - PR #1 is merged: "When to do H1" and the decision about PR #1 say so and
    name the pull requests that H1 can still affect.
  - The test plan names the tasks, and says who covers C10, C11 and C12 and
    which task proves which part of C5 and C6. C10 got a step 4 for the
    by-hand part of C9, with what is expected there, and a sentence that the
    review step starts after H1.
  - The baseline: TASK-002 adds the final line feed of the PRD and four
    lines of `.gitignore`; TASK-004 rewrites `.gitignore`.
  - Details under "Design", listed in the last entry of "Decisions". None
    changes what kyukhin sees.
- 2026-11-27: TASK-001 wrote `.coderabbit.yaml` and filled the "Proved by" cell of C9 with the checks that were run; no other change.
- 2026-11-27: TASK-001 after QA check 1: the path of the instruction entry is a brace glob that matches dot-files and dot-directories whether Minimatch's `dot` option is on or off, instead of `**`; the fourth instruction says that `SourceAPI` is not a concrete source, as ADR-0002, rule 1, says. "Design" still says "one entry, for all paths"; no other change.
- 2026-11-28: TASK-002 filled the "Proved by" cells of C2, C5 and C6 with the names of its tests and the checks that were run. Small detail in "Design", "The check tool", "Exit status": 2 is also the status when a file of the set cannot be read; the tool says so on standard error, checks the other files and prints their violations. No other change.
- 2026-11-28: TASK-002 after QA check 1 (B1, N1): "The check tool", "The checked set" says that a tracked path below a symbolic link is not in the set, like a deleted file. A small detail that follows from "a symbolic link is never opened"; no other change.
- 2026-11-28: TASK-003 added `.github/workflows/ci.yml` and filled the "Proved by" cells of C6, C7 and C8 with the checks that were run. Small detail in "Design", "Checks on GitHub: the second line": the concurrency group is `ci-<pull request number or run id>` with `cancel-in-progress: true`. A pull request has its own group, so only its own older runs are cancelled; a push to `master` has the run id as its group, so no run of `master` is cancelled or replaced, and every push gets its own result. No other change.
- 2026-11-28: TASK-003 after QA check 1 (B1): the first form of the group, one group for all pushes to `master` with `cancel-in-progress` off for them, protected only the run in progress. GitHub's documentation says that a `pending` run in a group is cancelled and replaced when a newer one is queued, so the commit of a middle merge got no result. The group is now the run id for a push, as above; the History line above is corrected to match.
- 2026-11-28: the plan and the tasks moved from files of the repository to
  GitHub, on kyukhin's words: "This does not fit, it is all wrong. We must
  work by milestones, epics and tasks in them." References are updated, with
  no change of behavior or design; the status stays `approved`. The header
  names the epic issue, #8, and the tickets; the spec calls them T1 to T4, and
  "Test plan" maps these names to the issues and to the former TASK-001 to
  TASK-004. Changed from the old numbers to T1 to T4: "When to do H1", the
  baseline paragraph of "The four checks", the test plan with its two
  paragraphs about C10 and C12. "Why" names milestone M0 on GitHub, where the
  text of the roadmap is now. "What kyukhin does by hand" names issue #43 for
  H1 and H2. The cell of C9 points to the developer's notes in #35, where the
  text of the task file is now. The entries of "Decisions" and the lines above
  keep the numbers of their day. The roadmap they cite is no file any more:
  its milestones and epics are on GitHub, and the words of kyukhin it quoted
  for this epic are in issue #8.

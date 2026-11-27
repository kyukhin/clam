# ADR-0005: CodeRabbit reviews every pull request after the commit, as a second line that does not block a merge; the dispatcher sorts its findings

Status: proposed
Needs the kyukhin gate: yes (changes the pipeline of CLAUDE.md and extends a third-party service's write access to this repository)

## Context

- `2026-11-27 (kyukhin)`, PRD §14: "Automated code review has to be added,
  CodeRabbit or somebody else." The PRD asks the architect to say at which step
  of the pipeline the review runs and who handles its findings.
- `2026-11-27 (kyukhin)`, roadmap, E-03: "CodeRabbit should be added right
  away, and the other small checks too." These later words name the tool. This
  ADR therefore does not compare tools: it records what was checked about
  CodeRabbit and names a fallback.
- `2026-11-27 (kyukhin)`, roadmap, "Approvals": builds are made "locally; we do
  not spend money on Actions", and later: "ok, let's add these checks. But the
  main testing will apparently have to be run locally." The checks on
  kyukhin's Mac decide; what runs on GitHub is a second line.
- `2026-11-27 (kyukhin)`, spec E-01, "History": "yes. everything as in
  LibreDict", said about the E-01 spec and the GitHub settings. LibreDict is
  kyukhin's other public iOS app, `kyukhin/dict-app`. The dispatcher copied
  its GitHub settings to `kyukhin/clam` the same day (L10). CodeRabbit already
  reviews LibreDict (L3), so this ADR stays close to how it is used there and
  names every difference (see "Compared with LibreDict").
- Spec E-01, "Decisions" (approved 2026-11-27): a red job on GitHub blocks
  nothing and is not ignored; the dispatcher names it to kyukhin, who decides;
  the dispatcher does not wait for a run to finish.
- CLAUDE.md, "Git and GitHub": the dispatcher pushes task branches and opens
  PRs without asking (`2026-11-27`, kyukhin: "3. yes"). Merging into `master`
  needs kyukhin's "yes" every time.
- CLAUDE.md, "What not to do": any edit after QA goes through developer and qa
  again.
- PRD §3, a CPO decision: "The only running cost is the Apple Developer fee."
  The review has to cost nothing.
- The pipeline today: developer → qa → committer → the dispatcher pushes and
  opens the PR → report to kyukhin → kyukhin says whether to merge. Nothing
  reads the PR between the push and kyukhin.

### What was checked on 2026-11-27

Verified in CodeRabbit's documentation and on its site. The pages were read
through extracts; numbers and quotes are as the pages gave them that day.
Sources are at the end.

| No. | Fact |
|---|---|
| V1 | **Price.** The pricing page: "receive free reviews forever for public repositories"; sign up with GitHub, install on a public repository, "No additional setup is required." The plans page, open source: "Unlimited public repositories, no credit card required" and "Open-source projects receive Team features with no paid subscription required." The cheapest paid plan is 30 USD per developer a month |
| V2 | **What the docs say about small repositories.** LibreDict shows otherwise, see L4. "For public repositories with less than 10 stars, CodeRabbit requires reviews to be triggered manually. Select **Trigger review** in the CodeRabbit status comment, or comment `@coderabbitai review` for the latest changes or `@coderabbitai full review` for a full review." |
| V3 | **Limits of the open-source plan.** 1 to 10 PR reviews per developer per hour, "OSS PR review rate limits vary by repository star count"; the thresholds are not published. 100 to 300 files per review. The limit counts per developer identity, as a rolling window, and "OSS PR review limits are additionally scoped per repository." A push that is refused uses no review. The command-line tool has its own limit, 3 reviews an hour |
| V4 | **Access the GitHub App has.** Read and write: code, issues, pull requests, checks, commit statuses, workflows (files under `.github/workflows/`). Read only: actions, discussions, members, metadata, merge queues. An installation covers "All repositories" or "Only select repositories", and the choice can be changed later. CodeRabbit can ask for more permissions later; each needs an approval |
| V5 | **What it writes.** A review writes comments, a review with inline threads and a check named `CodeRabbit`. The docs: reviews alone do not modify workflow files. Code is changed only on command: `autofix`, `fix comments`, `fix-ci`, `generate unit tests`, `simplify`, `local commit`, `resolve merge conflict`, `run <recipe>`, `generate configuration`, `emit path instructions`. These need a user with write access |
| V6 | **Where the code goes.** The whole repository is cloned into a sandbox in CodeRabbit's cloud. "Your code is shared with OpenAI and/or Anthropic for reviewing purposes only." "CodeRabbit never uses customer code for model training", and "Neither CodeRabbit, OpenAI, nor Anthropic uses your code to train our models". Kept after a review: a cache of the repository and its dependencies, "a maximum of seven days", "encrypted (except for OSS projects)", switched off by `reviews.disable_cache`; vector representations of the code; "learnings" from replies, switched off by `knowledge_base.opt_out` |
| V7 | **Configuration file.** `.coderabbit.yaml` in the repository root. Schema V2 applies when the file has no `version` key or `version: 2`; V3 is opt-in and moves the knowledge-base settings into the web interface. For a PR from a branch of the same repository by a trusted author the file is read from the head of the PR; for a PR from a fork it is read from the base commit, and the fork's file is never used. A file that does not parse does not stop the review: the summary opens with a warning |
| V8 | **Language.** The key `language`, default `en-US` |
| V9 | **How the outcome is seen.** On GitHub the bot publishes a check run `CodeRabbit` on the head commit. Titles: "Review queued" and "Review in progress" (pending); "Finished" (success); "Review skipped", "Review paused", "No files to review", "Too many files to review" (skipped); "Review rate limited" (neutral); "Review failed" (neutral unless `reviews.fail_commit_status` is on); "Review cancelled". If the App does not cover the repository there is no check, no comment and no answer to commands. If `CodeRabbit` is made a required check, a missing check blocks the merge |
| V10 | **Commands,** as PR comments: `@coderabbitai review` (commits since the last review), `@coderabbitai full review`, `@coderabbitai rate limit` (says whether a review is available and when; starts none), `@coderabbitai resolve`, `@coderabbitai pause` and `resume`, `@coderabbitai configuration` (shows the settings in force and where each comes from). Automatic reviews pause after 5 reviewed commits on one PR |
| V11 | **It reads the kit.** By default it takes `**/CLAUDE.md` and `.claude/skills/<name>/SKILL.md`, among others, as review rules |
| V12 | **Approvals.** "Automatic Approvals is off by default." When on, the bot approves PRs and requests changes |
| V13 | **Volume.** Profiles: `quiet` (inline comments for critical and major findings only), `chill` (the default: critical, major and minor, up to 20 inline comments), `assertive` (everything). Five severities: critical, major, minor, trivial, informational |
| V14 | **Defaults that touch this project.** The summary is written into the PR description unless `reviews.high_level_summary_in_walkthrough` is on. SwiftLint is on by default and, when the repository has no `.swiftlint.yml`, runs with a configuration the bot generates |
| V15 | **A past incident.** In January 2025 Kudelski Security showed that a PR with a crafted linter configuration ran code on CodeRabbit's servers and reached its secrets, with write access to the repositories the App was installed on. CodeRabbit reports it fixed within a week, with external tools moved into sandboxes, and says no customer data was accessed |
| V16 | **Fallback, GitHub Copilot code review.** Copilot Free has only "Review selection" in VS Code; review of pull requests is in Copilot Pro, 10 USD a month. Since 2026-06-01 Copilot is billed by usage |
| V17 | **Fallback, Qodo.** Its free open-source program asks for a public repository with 200 or more stars |
| V18 | **Which settings apply.** A file in the repository is the starting layer and takes precedence over the settings of the account in CodeRabbit's web interface; what the file leaves out falls to the built-in defaults, not to the web interface. A repository without a file uses the settings of the web interface |

Verified through the GitHub API, on `kyukhin/clam` and on LibreDict's pull
requests 370, 372, 376, 380 and 384:

| No. | Fact |
|---|---|
| L1 | `kyukhin/clam` is public, owned by a personal account, has 0 stars and 0 forks |
| L2 | PR #1 of `kyukhin/clam` has no check and no comment from any bot |
| L3 | `kyukhin/dict-app` is public, owned by the same account, has 3 stars and no `.coderabbit.yaml`. `coderabbitai` reviews its pull requests: kyukhin has a CodeRabbit account, and the App is installed on kyukhin's GitHub account |
| L4 | **There the bot starts by itself, although the repository has 3 stars** (compare V2). It comments within 10 seconds after a PR is opened, and it reviews when a PR is opened and after a push: in PR 376 its check started 83 seconds after the PR was opened, before any comment; in PR 384 it started 28 seconds after a push. kyukhin's account also comments `@coderabbitai review` on these PRs. The bot answers "Already reviewed the last commit." when it has reviewed by itself, "Review rate limited." when the review of the hour is used (PR 380), and otherwise starts a review |
| L5 | The bot's comment there says: "Your plan provides up to 1 included review per hour; 0 remain after this review." A push within the hour after a review got none (PR 384, twice); a comment after the hour had passed started one |
| L6 | A review there ran 2 to 4 minutes by the bot's own count (PRs 372, 376, 380) and was published 3 to 11 minutes after the PR was opened, pushed to or asked (PRs 376, 380, 384). The check `CodeRabbit` of the head commit ends as completed, success, with the title "Finished" |
| L7 | The bot appended a block of its own to PR descriptions there (PR 380 ends with "end of auto-generated comment: release notes by coderabbit.ai"). Its comments carry checkboxes that make it change code: "Autofix · Keep fixing CodeRabbit findings and required CI, and resolving merge conflicts" and "Ask CodeRabbit to fix comments on this review" |
| L8 | Threads of the bot are answered there from kyukhin's account, in the forms "Fixed: …" and "Kept as is. …" |
| L9 | Fixes after a review there: PR 384 has one commit after four force pushes and five reviews, each more than an hour after the one before; PR 370 has three commits, one `feat` and two `fix`, merged by rebase as they are |
| L10 | `kyukhin/clam` has had, since 2026-11-27, the same ruleset `master` as LibreDict: no deletion, no force push, a pull request required with 0 approvals, merges by rebase only, no required check, an empty bypass list |

Assumed, not verified:

| No. | Assumption | Where it gets verified |
|---|---|---|
| A1 | **How `kyukhin/clam`, with 0 stars, is treated.** The docs say a review has to be asked for (V2); LibreDict, with 3 stars under the same account, is reviewed without asking (L4). Which of the two holds for `clam` is not known. The limit is taken to be LibreDict's: one review an hour (L5) | The first review: E-03, C10 |
| A2 | The installation on kyukhin's account is limited to selected repositories and does not include `clam`. This follows from L2 and L4; the token at hand cannot list installations | kyukhin's step H1 of E-03 |
| A3 | Two minutes are enough to see whether the bot started by itself. Its check appeared after 28 and after 83 seconds in the two cases of L4 | E-03, C10, and the evaluation |
| A4 | PRs from forks are reviewed like any other. The docs state only where the configuration of a fork PR is read from (V7) | The first PR from a fork |
| A5 | The bot writes in the configured language whatever the language of the PR | PRs here are English anyway |
| A6 | A reply with a reason in a thread becomes a "learning", and the same finding does not come back | The evaluation after 10 PRs |
| A7 | The permissions of the App cannot be narrowed for one repository | Not needed unless kyukhin wants fewer |

## Options

The tool is not an option here: kyukhin chose it.

When the review runs:

| Option | Pros | Cons |
|---|---|---|
| A. On the PR, after QA and the commit, through the GitHub App | What the roadmap says: "CodeRabbit reviews every PR". The way LibreDict works. A PR from an outside contributor gets the same review. Nothing new runs on the Mac | A defect found there costs a second developer → qa → committer round |
| B. Before QA, on the working tree, with CodeRabbit's command-line tool | Findings are fixed before QA sees the task | A third-party program runs on the Mac next to the signing key and keeps a login there; it has its own limit (V3); outside PRs get nothing |
| C. Both | The fewest late findings | Both sets of costs, two places to configure |

Who sorts the findings:

| Option | Pros | Cons |
|---|---|---|
| D1. The dispatcher | It already does everything on GitHub and chooses every next step; no extra run per PR | It judges findings about code it must not write or verify |
| D2. QA, called once more for every PR | An independent judgment against the spec | A run of the most expensive role on every PR, also when nothing has to be fixed; QA does not act on GitHub |
| D3. The developer reads the findings directly | The shortest path | The author judges a review of its own work and decides alone what is in scope |

Whether the review can block a merge:

| Option | Pros | Cons |
|---|---|---|
| G1. A second line, not required | The same rule as for the checks on GitHub; the ruleset copied from LibreDict has no required check (L10); an outage or a limit of a free service stops nothing | A PR can be merged without a review |
| G2. `CodeRabbit` as a required check | No merge without a review | Every merge waits on one review an hour (L5); a missing check blocks the merge (V9); it changes the ruleset kyukhin just set |

## Decision

**CodeRabbit, by kyukhin's choice. A, D1 and G1 are proposed by the architect;
kyukhin decides.**

1. **The tool.** The CodeRabbit installation that already serves LibreDict is
   extended to `kyukhin/clam`. Its settings for Clam live in a small
   `.coderabbit.yaml` in the repository; the file and the reason for having
   one are in the spec of E-03.
2. **A second line.** The review is not required for a merge. QA on kyukhin's
   Mac decides whether a task is done, and kyukhin's "yes" merges. The bot
   never approves a PR, and nothing makes `CodeRabbit` a required check.
3. **The place.** After the dispatcher has pushed the branch and opened the PR,
   before the report to kyukhin:

   ```
   developer → qa → committer → push and PR → review → report to kyukhin
   ```

4. **Starting the review.** Two minutes after opening the PR the dispatcher
   looks at the `CodeRabbit` check of the head commit (A3).
   - A review in progress or finished: the bot started by itself, as it does
     in LibreDict (L4). Nothing is posted.
   - No check: the dispatcher comments `@coderabbitai review`, the way the
     docs give for small repositories (V2).
   - "Review rate limited": item 5.

   This works whichever way `clam` is treated (A1). The dispatcher does not
   wait for the `check` job of GitHub Actions: E-01 decided that it does not
   wait for a run.
5. **Waiting.** Up to 15 minutes for the `CodeRabbit` check to end; in
   LibreDict a review was published 3 to 11 minutes after the PR was opened,
   pushed to or asked (L6).
   - "Finished": the findings are sorted.
   - "Review rate limited", as the title of the check or as the bot's answer
     to the comment: one review an hour is included (L5, A1). The bot's
     answer to `@coderabbitai rate limit` says when the next one is
     available. Within 30 minutes: wait and ask once more. Later than that:
     there is no review.
   - Anything else, or nothing at all: ask once more and wait 10 minutes; then
     there is no review.

   "No review" stops nothing. The report says so and gives the reason.
6. **Sorting.** The dispatcher reads the bot's review, every inline thread and
   every comment, and puts each finding into one class:

   | Class | What it is | What happens |
   |---|---|---|
   | Secret | A secret or personal data is in the branch | Stop at once and tell kyukhin: the branch is public, so the secret is already out |
   | Defect | The change contradicts the spec, the task, an ADR or an invariant of CLAUDE.md, or is plainly wrong: a bug, a test that cannot fail, a command that does not work | One fix round, item 7 |
   | Follow-up | Valid, but outside the acceptance criteria of the task | A proposal for a `draft` task under "Notes for later" |
   | Kept as is | Wrong, against a recorded decision, or a matter of taste that the formatter and the checks own | An answer with the reason and a reference |

   A finding that questions the spec or the architecture is sorted by the
   architect. A finding the dispatcher cannot place with a reason of one
   sentence is a defect: nothing is dismissed in doubt.
7. **One fix round.** The dispatcher adds a section "Review findings" to
   `docs/qa/TASK-NNN.md` (the date, a link to each thread, what is wrong) and
   moves the task back to `in-progress`. Then developer → qa → committer: a
   new commit in the same branch, pushed by the dispatcher. This is the path
   kyukhin's own comments on a PR already take. The dispatcher looks for a
   review of the new commit once, by items 4 and 5; within the hour after the
   first review there is none (L5), and QA's check of the fix stands. A
   defect found in the fix commit is a stop: kyukhin sees the findings and
   the options. In a PR that holds documents only, a defect goes to the role
   that owns the document.
8. **No code changes outside the pipeline.** Nobody applies a suggestion of the
   bot on the GitHub page, ticks a box in its comments (L7), or gives it a
   command that changes code (V5) or `@coderabbitai approve`. Every change
   after QA goes through the developer and QA.
9. **Answers.** Before the report the dispatcher answers and resolves every
   thread of the bot, in the forms LibreDict uses (L8): `Fixed in <hash>: <what
   changed>.`, `Kept as is: <reason and reference>.` or `Recorded as a
   follow-up.` One or two sentences, in English, with no mention of Claude or
   AI: the answers appear under kyukhin's name. The dispatcher does not
   continue an exchange with the bot.
10. **The report** gets two lines: "Review" with the counts by class, and
    "GitHub check" with the state of the job as it is when the report is
    written. A red job is named there, and kyukhin decides (E-01).
11. **Commenting in kyukhin's name is a new standing permission.** Items 4, 5
    and 9 post comments from kyukhin's account, as LibreDict's history shows
    them (L4, L8). In Clam only kyukhin gives such a permission, in words.
    Until then the dispatcher puts the findings and the answers it proposes
    into the report, and a review the bot did not start by itself is asked
    for by kyukhin. This is open question 1 of the E-03 spec.
12. **Evaluation.** After the first 10 task PRs the architect counts, from the
    reports, the findings by class and the PRs that got no review, and
    proposes to kyukhin to keep the tool, to change its settings or to switch.
    The times of item 5 are revised then.

### Compared with LibreDict

Read from LibreDict's pull requests; its kit has no rule about the bot. The
right column is the architect's proposal.

| | LibreDict today | Clam |
|---|---|---|
| Starting a review | The bot starts by itself on opening and on a push. kyukhin's account also comments `@coderabbitai review`; the comment matters after a push that met the hourly limit (L4, L5) | The dispatcher comments only when the bot did not start (E-03, open question 1) |
| Settings of the bot | No file: the account's settings in CodeRabbit's web interface (V18) | A small file in the repository (E-03, open question 2) |
| PR description | The bot appends its own block (L7) | The bot's summary stays in its own comment; the description stays the committer's |
| Answers to threads | From kyukhin's account: "Fixed: …", "Kept as is. …" (L8) | The same forms |
| Rounds on one PR | Up to five reviews, each more than an hour after the one before (L9) | One fix round, then a stop for kyukhin |
| Fixes after a review | Folded into the commit and force-pushed, or separate `fix` commits (L9) | Separate commits; see "Merging by rebase only" below (E-03, open question 3) |
| Merge | Rebase only | Rebase only (L10) |

### When CodeRabbit is unsuitable, and the fallback

Any one of these, seen at the evaluation or earlier:

- the free offer for public repositories ends, or reviews are replaced by
  summaries;
- 3 of the first 10 task PRs got no review within the waits of item 5;
- in 10 task PRs no finding was a defect or a secret;
- the App asks for a permission beyond V4 and kyukhin refuses it;
- a new security incident on CodeRabbit's side that reaches installed
  repositories.

| Fallback | Free for this repository | What changes | Why it is not first |
|---|---|---|---|
| GitHub Copilot code review | No: 10 USD a month (V16) | The same step with another bot; no new company reads the code, GitHub hosts it already | A second running cost, against PRD §3 |
| A reviewer role inside the kit: a subagent that reads the diff of the PR in a clean context, on the Mac | Yes; no service and no GitHub App | The step moves before the push; the sorting stays | No outside eye: the same family of models wrote and checked the code; one more role to maintain |

Qodo's free program is closed to this repository until it has 200 stars (V17).

Leaving CodeRabbit is three actions: take `clam` out of the installation in
GitHub's settings, delete `.coderabbit.yaml`, take the review step out of
CLAUDE.md.

## Consequences

Easier:
- Every PR is read by something that did not write it and did not see the
  task, before kyukhin is asked to merge.
- kyukhin sees the outcome in one line of the report and the details on the
  PR page, each thread with an answer.
- The bot reads CLAUDE.md and the skills (V11), so it knows the language rule
  and the invariants without extra setup.
- Nothing new to sign up for: the account and the installation exist (L3).

Harder, and what we risk:
- **A third party holds write access to the code and to the workflows** (V4),
  and it has been broken into before (V15). kyukhin's account has granted
  this already, for LibreDict; this ADR extends it to one more repository.
  What bounds it: the ruleset lets nothing into `master` except through a pull
  request that kyukhin merges (L10); GitHub holds no secret of this project,
  and all signing material is on the Mac (E-01).
- **The review is scarce: one an hour** (L5, A1). With two developers working
  in parallel the second PR of an hour gets none, and the commit of a fix
  round is rarely reviewed again. Whether a review of `clam` also has to be
  asked for each time, as the docs say for small repositories, is not known
  (A1); the step works either way.
- **The report comes later,** by the length of the review: up to 15 minutes,
  and up to 30 more when the limit ends soon.
- **A fix round is expensive:** a second run of the developer, QA and the
  committer. The sorting keeps it for defects.
- **The dispatcher judges findings.** What bounds it: every "kept as is"
  carries a public reason, doubt means defect, design questions go to the
  architect.
- **The code is sent to CodeRabbit and from there to OpenAI or Anthropic**
  (V6). The repository is public and holds no secret, so nothing private
  leaves; a secret that slips into a branch is sent there too, as it is to
  everyone.
- **The offer can change.** "Free forever" is the vendor's wording (V1), and
  the limits depend on unpublished thresholds (V3).

Not affected:
- The promises of PRD §3. No code of CodeRabbit ships in the app, and nothing
  about the app's users goes to it.
- The dependency rule of ADR-0001. CodeRabbit is not a dependency of the app
  or of the build: `make` downloads, links and runs nothing of it.

What appears:
- The spec `docs/specs/E-03-automated-code-review.md`: the installation step,
  the settings file, the first checks.
- The text below, applied to CLAUDE.md and to two skills by the dispatcher
  after kyukhin accepts this ADR. Agents do not edit the kit on their own.

## Proposed text for CLAUDE.md and the skills

### Merging by rebase only: what the kit says today no longer works

The ruleset of `master` allows merges by rebase only (L10). CLAUDE.md, "Git and
GitHub", still says "(several commits in the branch: `--squash`)", and the
committer's skill, "History", says "(several commits in the branch: squash)".
`gh pr merge --squash` is refused by GitHub now. The fix round of this ADR
makes a second commit in a task branch a regular case, so the wording has to
be settled together with it. Two wordings work; the choice is kyukhin's.

| | M1. Every commit lands as it is | M2. One task, one commit |
|---|---|---|
| What reaches `master` | The task's commit, and one `fix` commit for each round of fixes after the PR was opened | One commit per task |
| Before the merge | Nothing | The committer folds the fix commits into the task's commit (`git rebase -i --autosquash`) and checks that the files did not change; the dispatcher pushes with `--force-with-lease` |
| Needs | Nothing new | A standing permission to rewrite and force-push task branches; CLAUDE.md allows both only at kyukhin's explicit request |
| Costs | The history shows the fixes | Answers "Fixed in <hash>" point to a commit that is gone; a rewritten branch after QA |
| In LibreDict | PR 370 | PR 384 |

The architect recommends M1: it rewrites nothing after QA and needs no new
permission. The text below is M1. Under M2 the item "Merging" gets one more
sentence about folding and the force push, and "Standing permissions" gets a
line for it.

CLAUDE.md, "Git and GitHub": the item "Merging" becomes

```
- **Merging** happens after kyukhin's "yes": `gh pr merge --rebase --delete-branch`,
  then `git switch master` and `git pull --rebase`. The ruleset of `master`
  allows no other method. Every commit of the task branch lands on `master` as
  it is: the commit of the task, and one more for each round of fixes after
  the PR was opened. Never `git merge` with a merge commit.
```

`.claude/skills/committer/SKILL.md`: the second sentence of the introduction
becomes

```
Good git history in this project is linear: one task = one clean commit, plus
one commit for each round of fixes after its PR was opened, and half a year
later it is clear from them what changed and why.
```

and in "History" the third item becomes

```
- A PR is merged by rebase, the only method the ruleset of `master` allows.
  Every commit of the branch lands as it is, so a fix commit gets a message
  as careful as the first one.
```

`README.md`, "How it works", says "one task is one branch `kyukhin/NNN-slug`
and one commit"; under M1 it gets the same addition.

### CLAUDE.md, "The main principle": the diagram becomes

```
CPO ─► PM ─► Architect: epic spec ─► kyukhin gate ─► Architect: tasks ─►
    ─► Developer ─► QA ─► Committer ─► PR ─► Review ─► (report to kyukhin) ─► PM …
           ▲         │                          │
           ├─ FAIL ──┘                          │
           └──────────── defect ────────────────┘
```

### CLAUDE.md, "The dispatcher loop": the last paragraph becomes

```
A typical task cycle without kyukhin:
developer → qa → (FAIL → developer → qa) → committer → PR → review →
(defect → developer → qa → committer → push, once) → **stop, report**.
```

### CLAUDE.md, "When to stop and wait for kyukhin": two new items

```
8. **The review found a secret or personal data in the branch.** The branch
   is public. Stop at once and tell kyukhin what is exposed and where; do not
   start a fix round first.
9. **The review found a defect in the commit that fixed its earlier findings**
   (do not start a second fix round): show kyukhin the findings and offer
   options.
```

### CLAUDE.md, "Report after a task": the template and the line after it become

```
✅ TASK-NNN <title> — PR #N, branch kyukhin/NNN-slug
What changed: 1–3 lines in plain language.
How to try it: if it is already possible, what to run and what to see; otherwise "nothing yet".
QA: PASS on the first try / after N returns (the gist).
Review: N findings: A fixed in <hash>, B recorded as draft tasks, C kept as is / no findings / not done: the reason.
GitHub check: green / red: what failed / not finished.
Spec: unchanged / changed: what and why.
Notes for later: new draft tasks, if any appeared.
Next: TASK-MMM <title> (role). Merge the PR and continue?
```

```
No logs, diffs or retelling of the QA report or of the review threads: they
are on the PR page, and kyukhin can ask for details.
```

### CLAUDE.md, "Git and GitHub": the item "PR." becomes

```
- **PR.** After the committer's report: `git push -u origin <branch>` and
  `gh pr create` into `master`. The title is the first line of the commit, the
  description comes from the committer's report. Then comes the review (see
  "Review of a pull request"); the report to kyukhin follows it.
```

### CLAUDE.md, "Git and GitHub": a new subsection before "Standing permissions"

```
### Review of a pull request

Every PR you open is reviewed by CodeRabbit before you report (ADR-0005). The
review is a second line, like the `check` job of GitHub Actions: neither is
required for a merge. QA on kyukhin's Mac decides, and kyukhin's "yes" merges.

1. **See whether the review started.** Two minutes after opening the PR, or
   after a push to it, look at the `CodeRabbit` check of the head commit. A
   review in progress or finished: the bot started by itself, post nothing.
   No check: comment `@coderabbitai review`. "Review rate limited": step 2.
2. **Wait for the `CodeRabbit` check,** up to 15 minutes. "Finished": go on.
   "Review rate limited": one review an hour is included; the bot's reply, or
   `@coderabbitai rate limit`, says when the next one is available. Within 30
   minutes: wait and ask once more. Later than that: there is no review.
   Anything else, or nothing: ask once more and wait 10 minutes; then there is
   no review. No review is not a stop: say it in the report, with the reason.
3. **Read every finding:** the bot's review, its inline threads and its
   comments. Put each into one class:
   - **Secret:** a secret or personal data in the branch. Stop (rule 8).
   - **Defect:** the change contradicts the spec, the task, an ADR or an
     invariant, or is plainly wrong: a bug, a test that cannot fail, a command
     that does not work.
   - **Follow-up:** valid, but outside the acceptance criteria of the task.
     It becomes a `draft` task proposal under "Notes for later".
   - **Kept as is:** wrong, against a recorded decision, or a matter of taste
     that the formatter and the checks own. You can give the reason in one
     sentence, with a reference.

   A finding that questions the spec or the architecture is sorted by the
   architect. If you cannot name the class, it is a defect: never dismiss in
   doubt.
4. **Defects: one fix round.** Add a section "Review findings" to
   `docs/qa/TASK-NNN.md` (the date, a link to each thread, what is wrong),
   move the task back to `in-progress`, then developer → qa → committer: a new
   commit in the same branch, then push. Look for the review of the new commit
   once (steps 1 and 2); a defect in it is a stop (rule 9). In a PR with
   documents only, a defect goes to the role that owns the document.
5. **Answer and resolve every thread of the bot,** in English, in one or two
   sentences, with no mention of Claude or AI: `Fixed in <hash>: <what
   changed>.`, `Kept as is: <reason and reference>.` or `Recorded as a
   follow-up.` Do not continue the exchange.
6. **Report,** with the lines "Review" and "GitHub check". Do not wait for the
   `check` job: give its state as it is. A red job is named to kyukhin, who
   decides (spec E-01).
```

### CLAUDE.md, "Standing permissions of kyukhin": a new item

The dispatcher writes the answer in after kyukhin gives it. Until then it reads
"no".

```
- Commenting on a PR in kyukhin's name, for the review only (asking the bot
  for a review it did not start, answering and resolving its threads):
  **<yes or no>** (<the date, kyukhin's words>). While it is "no": put the
  findings and the answers you propose into the report, and kyukhin asks
  for a review the bot did not start.
```

### CLAUDE.md, "What not to do": a new item

```
- Do not apply the review bot's suggestions on GitHub, do not tick the boxes
  in its comments, and do not ask it to change code or to approve a PR.
```

### `.claude/skills/committer/SKILL.md`, "Branch": the last item becomes

```
- A fix for kyukhin's comments or for review findings on an already open PR
  is a new commit in the same task branch. Do not create a new branch, do not
  `--amend`.
```

### `.claude/skills/developer/SKILL.md`

In "Before writing code", step 2, the last sentence becomes:

```
If the task came back from QA or from the review of its PR, also
`docs/qa/TASK-NNN.md`.
```

"Return from QA" becomes:

```
## Return from QA or from the review

Fix only what the QA report points out, its section "Review findings"
included, plus direct consequences. If you disagree with a finding, do not
argue with code: write your argument into the notes and ask the PM/architect
to judge.
```

## Sources

- CodeRabbit, pricing: coderabbit.ai/pricing (V1)
- CodeRabbit docs, "Plans and pricing": docs.coderabbit.ai/management/plans (V1, V2, V3)
- CodeRabbit docs, "Review rate limits": docs.coderabbit.ai/management/rate-limits (V3)
- CodeRabbit docs, GitHub platform page: docs.coderabbit.ai/platforms/github-com; "Adding organizations": docs.coderabbit.ai/management/adding-organizations (V4)
- CodeRabbit docs, "Review commands": docs.coderabbit.ai/reference/review-commands (V5, V10)
- CodeRabbit docs, FAQ, "Data Security": docs.coderabbit.ai/faq; "Caching": docs.coderabbit.ai/reference/caching; architecture overview: docs.coderabbit.ai/overview/architecture (V6)
- CodeRabbit docs, "Configuration V2 reference": docs.coderabbit.ai/reference/configuration; "Migrate configuration to V3"; "Choose the configuration branch": docs.coderabbit.ai/configuration/branch (V7, V8, V14)
- CodeRabbit docs, "CodeRabbit status check": docs.coderabbit.ai/pr-reviews/status-check; "Find out why a pull request wasn't reviewed": docs.coderabbit.ai/pr-reviews/missing-reviews; "Control when reviews run": docs.coderabbit.ai/pr-reviews/when-reviews-run (V9, V10)
- CodeRabbit docs, "Code Guidelines": docs.coderabbit.ai/knowledge-base/code-guidelines (V11)
- CodeRabbit docs, "Automatic Approvals": docs.coderabbit.ai/pr-reviews/automatic-approvals (V12)
- CodeRabbit docs, "Set review strictness, tone and language": docs.coderabbit.ai/pr-reviews/review-style (V8, V13)
- CodeRabbit docs, SwiftLint: docs.coderabbit.ai/tools/swiftlint (V14)
- Kudelski Security, "How we exploited CodeRabbit: from a simple PR to RCE and write access on 1M repositories"; CodeRabbit, "Our response to the January 2025 Kudelski Security vulnerability disclosure" (V15)
- GitHub Docs, "Plans for GitHub Copilot": docs.github.com/en/copilot/get-started/plans; GitHub changelog, 2026-06-01, "Updates to GitHub Copilot billing and plans" (V16)
- Qodo docs, "Open source program": docs.qodo.ai/open-source-program (V17)
- CodeRabbit docs, "How CodeRabbit resolves configuration": docs.coderabbit.ai/configuration/resolution (V18)
- GitHub REST API, read on 2026-11-27: `repos/kyukhin/clam`, its rulesets and its pull request 1 (L1, L2, L10); `repos/kyukhin/dict-app`, its pull requests 370, 372, 376, 380 and 384 with their comments, reviews, timelines and check runs (L3 to L9)

## History
- 2026-11-27: proposed.

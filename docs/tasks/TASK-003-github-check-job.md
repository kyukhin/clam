# TASK-003: Add the `check` job on GitHub

Epic: E-03 | Milestone: M0 | Status: draft
Depends on: TASK-002
Complexity: normal
Spec: docs/specs/E-03-automated-code-review.md § "Checks on GitHub: the second line", "GitHub settings", test plan C6, C7 and C8 (approved 2026-11-27)
Basis: ADR-0001 (row "CI and delivery", fact V11), ADR-0005 (item 11: the report names the state of the job), spec E-01 ("Decisions": a red job blocks nothing and is named to kyukhin)

## Goal
Every pull request into `master` and every push to `master` runs `make check`
on a fresh GitHub runner with Xcode 27. kyukhin sees a second, independent
result on the page of a pull request. It blocks no merge.

## Context
- **The job runs what the tree has.** `make check` comes from TASK-002. When
  TASK-004 adds three checks, the job runs them with no change of the
  workflow. This task and TASK-004 can be worked at the same time: they share
  no product file.
- **The runner.** `xcode-27` is a label of GitHub's standard arm64 macOS
  runners (GitHub Docs, "GitHub-hosted runners", read on 2026-11-27, next to
  `macos-latest`, `macos-15` and `macos-26`). It is free for a public
  repository.
- **The pin.** The workflow uses one action, `actions/checkout`, by the full
  commit hash of a release. Take the hash from GitHub and not from memory:
  the tag of the latest release, then the commit that tag points to; an
  annotated tag has to be resolved to its commit. Write the tag in a comment
  next to the hash.
- **Nobody can run the workflow before the pull request.** The first run on
  the pull request of this task is the proof of AC3. Before that, check that
  the file is valid YAML and read it against GitHub's workflow syntax.
- **Xcode 27 is not on the Mac** and does not run on its macOS until kyukhin
  has done K1 of E-01. A failure that only Swift 6.4 shows is read from the
  log of the job (`gh run view --log-failed`), and its fix is proved by the
  next run.
- **A red or unfinished run.** The dispatcher does not wait for the run and
  names its state in the line "GitHub check" of the report; kyukhin decides
  (spec E-01, "Decisions"). For this task the run is also the proof of AC3:
  the criterion is met only when a run on the pull request has ended green.
- **C8 needs no change by anybody.** The settings are in place; QA reads them
  back. A value that differs from the table is a finding for kyukhin, not
  something to fix in this task.
- **The last task of the epic** is whichever of TASK-003 and TASK-004 is
  committed last: its committer moves the spec to `implemented`.
- No line in `CHANGELOG.md`: nothing changes for the user of the app.

## Change scope
May be changed:
- `.github/workflows/ci.yml`, new;
- `docs/architecture/OVERVIEW.md`: "What exists" and the row of the workflow
  under "GitHub";
- `docs/specs/E-03-automated-code-review.md`: the cells "Proved by" of C6, C7
  and C8 and a line in "History"; "Design" only for a small detail, as the
  developer's skill allows;
- this file and the row and the log of this task in `docs/plan/BOARD.md`;
- `Tools/ClamChecks/` and `Makefile`, only in a fix round and only for what a
  run under Xcode 27 proves necessary; the developer notes then quote the
  line of the job log.

QA writes `docs/qa/TASK-003.md`.

Must not be touched: any setting of the repository on GitHub, `CLAUDE.md`,
`.claude/`, `.coderabbit.yaml`, `.gitignore`, any other workflow file, any
other document.

## Acceptance criteria
- [ ] AC1 (C7): `.github/workflows/ci.yml` runs on a pull request into
      `master` and on a push to `master`, and on nothing else; the trigger is
      `pull_request`, never `pull_request_target`. It has one job, `check`,
      on the runner `xcode-27`, and the only command of the job is
      `make check`.
- [ ] AC2 (C7): the constraints of the spec. `permissions` at the top level
      is `contents: read` and nothing else, and no job widens it. The file
      names no secret. Its only action is `actions/checkout`, pinned to a
      full commit hash that belongs to a release of that action, with
      credentials not persisted. A newer run for the same pull request
      cancels the older one. The job has a time limit of 15 minutes. There
      is no cache and no artifact.
- [ ] AC3 (C7, C6): on the pull request of this task the job `check` runs and
      ends green. Its log shows Xcode 27's Swift in the first lines of
      `make check` and no compiler warning.
- [ ] AC4 (C8): the settings of the repository on GitHub are what the table
      of the spec, "GitHub settings", says, and this task changed none of
      them.
- [ ] `docs/architecture/OVERVIEW.md` says that the workflow exists with the
      job `check`: under "What exists" and in its row under "GitHub", where
      `compat` stays decided for E-01. Pointers to the spec, no copy of its
      text.
- [ ] All tests pass; `make check` is green on the Mac with the workflow file
      in the tree, with no new warnings.

## How to verify
QA, before the commit:

1. Read `.github/workflows/ci.yml` against AC1 and AC2, line by line.
2. The file is valid YAML:
   `ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load_file(".github/workflows/ci.yml"))'`.
   Ruby reads the key `on` as `true`; that is the parser, not a fault of the
   file.
3. The pin: with the hash and the tag from the file,
   `gh api repos/actions/checkout/commits/<hash> --jq .sha` prints the hash,
   and `gh api repos/actions/checkout/git/ref/tags/<tag>` leads to the same
   commit, directly or through an annotated tag.
4. `make check` on the Mac.
5. AC4: read the settings back and list the values in the report. These
   calls worked with the `gh` of this Mac on 2026-11-27 and gave the values
   of the table:

```
gh api repos/kyukhin/clam/rulesets --jq '.[] | {id, name, enforcement}'
gh api repos/kyukhin/clam/rulesets/<id> --jq '{conditions, bypass_actors, rules}'
gh api repos/kyukhin/clam --jq .security_and_analysis
gh api -i repos/kyukhin/clam/vulnerability-alerts | head -1
gh api repos/kyukhin/clam/automated-security-fixes
gh api repos/kyukhin/clam/actions/permissions
gh api repos/kyukhin/clam/actions/permissions/workflow
gh api repos/kyukhin/clam/actions/permissions/fork-pr-contributor-approval
gh api repos/kyukhin/clam/actions/secrets --jq .total_count
gh api repos/kyukhin/clam/actions/variables --jq .total_count
gh api repos/kyukhin/clam/environments --jq .total_count
gh api repos/kyukhin/clam/private-vulnerability-reporting
gh api repos/kyukhin/clam/code-scanning/default-setup --jq .state
```

   Expected, in the order of the table: the ruleset `master` is active, on
   `~DEFAULT_BRANCH`, with no bypass actor and the rules `deletion`,
   `non_fast_forward` and `pull_request` (0 approvals, the merge method
   `rebase` only), and no rule for a required check; secret scanning and push
   protection `enabled`; Dependabot alerts answer 204 and security updates
   are enabled; `allowed_actions` is `all` and `sha_pinning_required` is
   `false`; the workflow token is `read` and cannot approve pull requests;
   the approval policy for forks is `first_time_contributors`; the three
   counts are 0; private vulnerability reporting is off; code scanning is
   `not-configured`; non-provider patterns and validity checks are
   `disabled`.

After the commit: the dispatcher, not the developer and not QA.

1. AC3: after the pull request is opened, the job `check` appears on its head
   commit. The dispatcher gives its state in the line "GitHub check" of the
   report. If the run is not finished then, the criterion is proved when the
   run ends green on the page of the pull request, before kyukhin's "yes".
   A red run is named to kyukhin; if kyukhin sends the task back, the log of
   the run is the finding.
2. C12 of the spec is checked by kyukhin on this pull request: it is the
   first whose page can list both `check` and `CodeRabbit`.

## Out of scope
- The job `compat`, `actions/upload-artifact` and a longer time limit: E-01.
- Making `check` or `CodeRabbit` a required check, and any other change of
  the settings on GitHub.
- A cache, an artifact, a matrix, a second workflow.
- Steps in the workflow other than the checkout and `make check`: what the
  log has to show comes from `make check` itself (TASK-002).

## Developer notes
(filled in by the developer: decisions along the way, deviations, what is left)

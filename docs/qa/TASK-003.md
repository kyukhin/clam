# QA: TASK-003

## Check 1 — 2026-11-28 — FAIL

Checked: the uncommitted tree on a detached HEAD at `b96c9df`, the tip of
`kyukhin/002-check-tool` (kyukhin, 2026-11-28: TASK-003 is worked on top of
it). The task's changes: the untracked `.github/workflows/ci.yml` and edits to
`docs/architecture/OVERVIEW.md`, `docs/specs/E-03-automated-code-review.md`
and `docs/tasks/TASK-003-github-check-job.md`. The edits to
`docs/plan/BOARD.md` and to the header of
`docs/tasks/TASK-004-file-content-checks.md` are the dispatcher's and are not
counted against the change scope. Spec E-03 is approved (2026-11-27).
Machine: macOS 26.7.3, Xcode 26.4 (17E192), Swift 6.3
(swiftlang-6.3.0.123.5), GNU Make 3.81, git 2.49.0, gh 2.96.0,
check-jsonschema 0.39.0, Ruby 3.2.0.

The job itself cannot run before the pull request exists, so AC3 is not
judged here; what the dispatcher has to read on the pull request is listed
under "On the pull request". The verdict is FAIL for one finding, B1.

### Build and tests
| Command | Result | Tests | Warnings |
|---|---|---|---|
| `xcodebuild -version` | Xcode 26.4, build 17E192 | n/a | n/a |
| `make check` (with `.github/workflows/ci.yml` in the tree, untracked and not ignored: `git check-ignore -v` exits 1, `git ls-files --others --exclude-standard` lists it, so `whitespace` checks it) | exit 0. Line 1: `swift-driver version: 1.148.6 Apple Swift version 6.3 (swiftlang-6.3.0.123.5 clang-2100.0.123.102)`; `clam-checks` builds; `whitespace` prints nothing; the tests run | `Test run with 77 tests in 3 suites passed` (Swift Testing); XCTest: 0 tests | 0 (`grep -ci warning` on the whole log of 197 lines) |
| `check-jsonschema --builtin-schema vendor.github-workflows .github/workflows/ci.yml` | `ok -- validation done`, exit 0 | n/a | n/a |
| `ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load_file(".github/workflows/ci.yml"))'` | exit 0; prints the file as data (`on` read as `"true"`, the parser's reading) | n/a | n/a |
| `LC_ALL=C grep -n '[^ -~]' .github/workflows/ci.yml` | no match (exit 1): ASCII only | n/a | n/a |
| `tail -c1 .github/workflows/ci.yml \| xxd -p` | `0a` | n/a | n/a |
| `git diff --check` and `git diff --no-index --check /dev/null .github/workflows/ci.yml` | no output | n/a | n/a |

### Acceptance criteria
| Criterion | Row of the spec's plan | How checked | Result | Proof |
|---|---|---|---|---|
| AC1: triggers `pull_request` and `push` to `master` only, never `pull_request_target`; one job `check` on `xcode-27`; its only command `make check` | C7 | Read line by line; the schema check; the runner table of `actions/runner-images` | Met | Lines 6–10: `on:` holds `pull_request: branches: [master]` and `push: branches: [master]`, nothing else. Lines 21–29: `jobs:` holds only `check`, `runs-on: xcode-27`, two steps: the `uses:` of the checkout and `- run: make check`. `gh api repos/actions/runner-images/readme`: the row "Xcode 27, arm64" gives the labels `` `xcode-27` or `xcode-27-xlarge` `` (the second is the paid larger runner). The image readme `images/macos/xcode-27-arm64-Readme.md` (image 20261123.0387.2, macOS 27.0.1): Xcode 27.0, 27.1 (default) and 27.2 installed, Git 2.56.1 |
| AC2: `permissions` `contents: read` only, no job widens it | C7 | Read | Met | Lines 12–13; the job has no `permissions` key. A workflow-level `permissions` sets every unnamed scope to none |
| AC2: names no secret | C7 | Read; grep for `secret`, `token`, `key`, `password` | Met | No hit. The only `${{ }}` are in `concurrency` (lines 18–19) |
| AC2: only action `actions/checkout`, pinned to a full hash of a release, credentials not persisted | C7 | `gh api` read-only calls; read | Met | `gh api repos/actions/checkout`: owner `actions` (Organization), not a fork, not archived. `releases/latest`: `v7.0.1`, not draft, not pre-release, published 2026-07-20T15:10:05Z. `git/ref/tags/v7.0.1`: `"type":"commit"`, sha `3d3c42e5aac5ba805825da76410c181273ba90b1` (lightweight tag). `commits/3d3c42e…90b1 --jq .sha` prints the same hash; message "prep v7.0.1 release (#2531)", verified signature. `compare/3d3c42e…90b1...main`: `ahead_by 1, behind_by 0`, so the commit is in the history of `main` of `actions/checkout` and not a commit of a fork reachable through the network. The moving tag `v7` points to the same commit. `action.yml` at the pin: `persist-credentials` default `true`, `runs: using: node24`. Line 26–28: the hash, the comment `# v7.0.1`, `persist-credentials: false` |
| AC2: a newer run for the same pull request cancels the older one | C7 | Read; GitHub's docs | Met | For a `pull_request` event the group is `ci-<number>` and `cancel-in-progress` evaluates `true` |
| AC2: time limit 15 minutes | C7 | Read | Met | Line 24, `timeout-minutes: 15` (job level, covers both steps) |
| AC2: no cache, no artifact | C7 | Read; `gh api` | Met | No `actions/cache`, no `upload-artifact`, no `cache:` input. `actions/caches` and `actions/artifacts` of `kyukhin/clam`: 0 and 0 |
| The spec's sentence added in this task: "a run for a push to `master` is never cancelled" | C7 ("every constraint of 'Checks on GitHub'") | Read against GitHub's documented concurrency semantics | **Not met: B1** | See "Findings" |
| AC3: the job runs green on the pull request; its log shows Xcode 27's Swift first and no warning | C6, C7 | Cannot run before the pull request | **Open, the dispatcher's** | See "On the pull request" |
| AC4: the settings are as the table of "GitHub settings" says; none was changed | C8 | `gh api`, read only; table below | Met | Every value matches. The ruleset was last updated 2026-11-27T16:08:23+02:00, before the task started; the diff touches no setting |
| OVERVIEW says the workflow exists with `check`, under "What exists" and in its row under "GitHub", `compat` stays decided; pointers, no copy | none (task criterion) | Read the diff | Met | New row under "What exists" (line 26); the row under "GitHub" (line 125): `check` **Exists** (TASK-003), `compat` **Decided** for E-01; both point to the specs and copy no constraint |
| All tests pass; `make check` green on the Mac with the file in the tree, no new warnings | C6 | Ran it | Met | Table above: 77/77, 0 warnings |

C8, the values read back on 2026-11-28 (`gh api`, read only), against the spec's table:

| Setting (spec) | Command | Value read | Matches |
|---|---|---|---|
| Ruleset `master`, default branch, active, empty bypass list | `rulesets`; `rulesets/28239994` | one ruleset, id 28239994, `name: master`, `enforcement: active`, `target: branch`, `conditions.ref_name.include: ["~DEFAULT_BRANCH"]`, `exclude: []`, `bypass_actors: []`, `current_user_can_bypass: never` | yes |
| No deletion; no force push; a pull request with 0 approvals; rebase only; no required check | same; `rules/branches/master` | rules `deletion`, `non_fast_forward`, `pull_request` with `required_approving_review_count: 0`, `allowed_merge_methods: ["rebase"]`; no `required_status_checks` rule; `rules/branches/master` gives exactly `["deletion","non_fast_forward","pull_request"]`; classic protection off (`protection.enabled: false`) | yes |
| Secret scanning; push protection | `repos/kyukhin/clam --jq .security_and_analysis` | `secret_scanning: enabled`, `secret_scanning_push_protection: enabled` | yes |
| Dependabot alerts; security updates | `-i vulnerability-alerts`; `automated-security-fixes` | `HTTP/2.0 204 No Content`; `{"enabled":true,"paused":false}` | yes |
| Actions: all actions allowed; pinning not required | `actions/permissions` | `enabled: true`, `allowed_actions: all`, `sha_pinning_required: false` | yes |
| Default workflow token read-only; Actions cannot approve | `actions/permissions/workflow` | `default_workflow_permissions: read`, `can_approve_pull_request_reviews: false` | yes |
| Fork runs: first-time contributors wait | `actions/permissions/fork-pr-contributor-approval` | `approval_policy: first_time_contributors` | yes |
| Actions secrets, variables, environments: 0, 0, 0 | `actions/secrets`, `actions/variables`, `environments` (`.total_count`) | 0, 0, 0 (also `dependabot/secrets`: 0) | yes |
| Private vulnerability reporting off | `private-vulnerability-reporting` | `{"enabled":false}` | yes |
| Code scanning not configured | `code-scanning/default-setup` | `state: not-configured`, `languages: []` | yes |
| Non-provider patterns, validity checks disabled | `.security_and_analysis` | `secret_scanning_non_provider_patterns: disabled`, `secret_scanning_validity_checks: disabled` | yes |

Also read, not in the table: the repository is `public`, default branch
`master`; `actions/workflows` total 0 (no workflow on GitHub yet; `origin/master`
at `e653f96` holds no `.github/`). The `pull_request` rule also carries
`require_extra_approval_for_unattributed_changes: true`, identical in the
ruleset of `kyukhin/dict-app` (id 16832040, read the same way), so it is part
of the copy; the table does not name it (N1).

### Test quality and mutations
The task has no Swift code and no test of its own; the checks it relies on are
the schema check and the pin lookup. Both were shown to fail on a broken input.
All copies were made outside the repository; `shasum -a 256` of
`.github/workflows/ci.yml` was
`11a66c1b9a43c0026559ebfffb421d309120e05a224de2f90cacd757d5a54052` before and
after.

Schema check, broken copies (each must be rejected):

| Mutation | Exit |
|---|---|
| `permissions:` → `permision:` (unknown top-level key) | 1 |
| `timeout-minutes: 15` → `fifteen` (wrong type) | 1 |
| `contents: read` → `contents: admin` (invalid level) | 1 |
| `pull_request:` → `pull_request_targett:` (unknown event) | 1 |
| `- run: make check` → `- rn: make check` (unknown step key) | 1 |
| `runs-on:` removed | 1 |
| the original file | 0 |

What the schema does not catch, so only reading proves it: copies with
`pull_request_target`, `contents: write` and `persist-credentials: true` all
pass the schema (exit 0). AC1 and AC2 rest on the line-by-line read above.
The vendored schema knows `concurrency.queue` with the values `single` and
`max` (`queue: bogus` is rejected with "'bogus' is not one of ['single',
'max']"), which matches the documentation used for B1.

Pin, wrong inputs (each must fail to match):

| Input | Result |
|---|---|
| The hash with its last digit changed (`…90b0`) | `gh api repos/actions/checkout/commits/…90b0`: HTTP 422 "No commit found for SHA" |
| The tag of the previous release, `v7.0.0` | points to `9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0`, not the pinned hash |

### Change scope, spec and invariants
`git status --short --untracked-files=all`: the five modified documents and
`?? .github/workflows/ci.yml`; nothing else. The developer's files are all in
the allowed list. `Tools/ClamChecks/` and `Makefile` are untouched. No
setting on GitHub changed (C8). No `CHANGELOG.md` line, as the task says.

The spec edit, judged by rule 4 of `docs/specs/README.md`: the added clause
("a run for a push to `master` is never cancelled") is a small implementation
detail. It is not visible to the user of the app, it changes no data model,
storage, module boundary, contract or dependency, it narrows nothing kyukhin
approved (the approved sentence about pull requests stays), and it agrees with
E-01's "nobody waits for a run". A line in "History" is enough; the spec need
not go back to `draft`. The trouble is not the process but the content: the
workflow does not do what the clause says (B1).

The "Proved by" cells of C6, C7 and C8 were filled by the developer; their
statements were re-run here and hold (schema, YAML, pin, runner label,
`make check`), except that the cell of C7 calls the file compliant with "every
constraint", which B1 contradicts for the new clause.

Architectural invariants: the task adds no Swift code and no module; no
source is imported anywhere. Invariant 4: see below.

Misuse review of the workflow:
- Triggers: `pull_request` and `push` only. No `pull_request_target`,
  `workflow_run`, `issue_comment` or `workflow_dispatch`, so no run gets a
  write token or a secret on behalf of a fork.
- Script injection: no `${{ }}` in a `run` step. The two expressions are in
  `concurrency`; they are evaluated by GitHub, not by a shell, and use only
  `github.event.pull_request.number` (a number), `github.ref` and
  `github.event_name`.
- Token: `contents: read`, everything else none; the repository default is
  `read` as well. A fork's run gets a read-only token whatever its copy of the
  workflow says.
- Credentials in the checkout: `persist-credentials: false`, so no token is
  written into `.git/config` for the code that `make check` then runs.
- Cache and artifacts: none, so there is nothing to poison or to leak.
- A fork's pull request can rewrite the workflow it runs (a longer
  `timeout-minutes`, another label) and run any code that its `Makefile` or
  tests hold. With no secret and a read-only token it can take nothing and can
  only use a free runner; the first run of a first-time contributor waits for
  kyukhin. This is the risk E-01 already records ("Checks on GitHub").
- Concurrency groups cannot be reached across kinds: a pull request's group is
  `ci-<number>`, a push's is `ci-refs/heads/master`, so no pull request can
  cancel a run on `master`.

### Security and language
- `git diff -U0 HEAD | perl -CSD -ne 'print if /\p{Cyrillic}|\p{Greek}/'`:
  no output. The same over the untracked `.github/workflows/ci.yml`: no output.
  The file is pure ASCII.
- Secrets and personal data: `git diff -U0 HEAD` searched for `api_hash`,
  `api_id`, `ghp_`, `github_pat_`, a private key header, a phone number and any
  run of 32 hexadecimal digits other than the pinned commit hash: no hit. The
  workflow names no secret. No new file needs `.gitignore`.

### Findings
Blocking (the reason for FAIL):

- **B1. A run for a push to `master` can be cancelled, against the clause this
  task added to the spec.** The spec ("Checks on GitHub: the second line") now
  says "a run for a push to `master` is never cancelled", the History line says
  "a run for a push to `master` always finishes", and the comment on lines
  15–16 of the workflow says the same. All pushes to `master` share one group,
  `ci-refs/heads/master` (line 18). `cancel-in-progress: false` only protects
  the run *in progress*. GitHub's documentation (`github/docs`,
  `data/reusables/actions/actions-group-concurrency.md`, the branch for
  `actions-nga`, which `data/features/actions-nga.yml` enables for
  github.com): "there can be at most one running job or workflow in a
  concurrency group at any time … By default, any existing `pending` job or
  workflow in the same concurrency group will be canceled and the new queued
  job or workflow will take its place"; `queue: single` is the default. So
  with three pushes to `master` inside one run (merge A, merge B, merge C, each
  a few minutes of a macOS runner apart), the run for B waits as `pending` and
  is cancelled when C arrives: commit B never gets a `check` result. This is
  the case the developer meant to prevent ("two quick merges would cancel the
  run for the first merged commit"); it holds for two merges, not for three.
  Not observable before the merge, so the proof is the documented semantics
  and the schema's `queue: single|max` enum.
  A fix that keeps the clause true: give a push its own group, as GitHub's
  docs do in their fallback example, for instance
  `group: ci-${{ github.event.pull_request.number || github.run_id }}`; a
  push's group is then unique, never pending and never cancelled, and pull
  requests still cancel their own older runs. `queue: max` is the other
  documented option, but the docs make `queue: max` with
  `cancel-in-progress: true` a validation error, and here `cancel-in-progress`
  is an expression that is `true` for pull requests; avoid it unless
  proven. Whatever the fix, the comment in the file, the spec clause and its
  History line say what the file then does. Dropping the clause instead would
  fit the spec to the code and leave master runs cancellable; it is not
  recommended.

Non-blocking (task proposals):

- **N1.** The `pull_request` rule of the ruleset `master` carries
  `require_extra_approval_for_unattributed_changes: true`, which the table of
  "GitHub settings" does not name. The value is the same in `kyukhin/dict-app`,
  so it is part of "everything as in LibreDict" and C8 holds. Proposal
  (architect, next call on E-03): name the parameter in the table, so the next
  read-back has a value to compare it with.
- **N2.** Information, no task: the job uses the runner image's default Xcode,
  27.1 on image 20261123.0387.2 (27.0 and 27.2 are also installed). The
  version moves when GitHub changes the image's default; the first line of
  `make check` in each log shows which Swift ran. ADR-0001, V10 describes
  Xcode 27.2. The spec asks only for Xcode 27.
- **N3.** For the dispatcher: the task file's header still says
  `Status: in-review`; QA does not edit task files. BOARD.md holds the status
  `in-progress`.

### On the pull request (the dispatcher, after the fix, the commit and the push)
Not judged by this check; each line says what result would be a defect of
this task. `<N>` is the pull request, `<id>` the run of the head commit.

1. The pull request is against `master` and holds only this task's commit.
   Its branch stands on `kyukhin/002-check-tool`, which stands on PR #5; by the
   note in BOARD.md it is opened only after both are merged.
   `gh pr view <N> --json baseRefName,commits --jq '{baseRefName, n: (.commits | length)}'`
   gives `master` and 1; `gh pr diff <N> --name-only` lists only the workflow
   and the documents of this task.
2. The job appears: `gh pr checks <N>` lists `check`;
   `gh run list --workflow ci.yml --json databaseId,event,status,conclusion,headSha`
   shows a run with `event: pull_request` on the head commit. No run at all,
   or `startup_failure`, is a defect (the label or the file was refused).
3. It ends green: `conclusion: success`. `failure`, `timed_out` (15 minutes)
   or `cancelled` without a newer run on the same pull request is a defect;
   read `gh run view <id> --log-failed`.
4. Xcode 27's Swift: `gh run view <id> --log | grep -m1 'Apple Swift version'`
   shows `Apple Swift version 6.4` (ADR-0001, V10 and the "Toolchain" row). A
   6.3 or lower means the job did not use Xcode 27: a defect.
   `gh run view <id> --log | grep -m3 -i 'image'` names the `xcode-27` image.
5. No compiler warning: `gh run view <id> --log | grep -ci 'warning:'` gives
   0 (with `-warnings-as-errors` a warning also fails the build).
   `gh run view <id> --log | grep -n 'NOFOLLOW_ANY'` prints nothing; an error
   such as "cannot find 'O_NOFOLLOW_ANY' in scope" or the same for
   `AT_SYMLINK_NOFOLLOW_ANY` means the Xcode 27 SDK dropped the flag: a defect,
   fixed in `Tools/ClamChecks/` in a fix round, with the log line quoted.
6. All tests ran: the log has `Test run with 77 tests in 3 suites passed`, the
   count on the Mac. A lower count is a defect.
7. The token: `gh run view <id> --log | grep -A4 'GITHUB_TOKEN Permissions'`
   lists `Contents: read` and `Metadata: read` only. Any `write` is a defect.
8. Nothing is kept: `gh api repos/kyukhin/clam/actions/runs/<id>/artifacts --jq .total_count`
   and `gh api repos/kyukhin/clam/actions/caches --jq .total_count` give 0.
9. C12 of the spec is kyukhin's, on the same page: `check` and `CodeRabbit`
   listed, neither marked as required.

After the merge, for information only: the first `push` run on `master`
(`gh run list --workflow ci.yml --branch master --event push`) ends green.

One summary line for the PR: `QA: make check 77/77 (Xcode 26.4), schema ok (6 mutants rejected), pin = actions/checkout v7.0.1, C8 settings match; FAIL: push runs on master can be cancelled (B1); job run on the PR not yet seen`

## Check 2 — 2026-11-28 — PASS

Checked: the same detached HEAD `b96c9df` with the developer's fix of B1.
`.github/workflows/ci.yml` now has sha256
`88bd477aa34ccf8d0d3ee0732c84a0fffb7f6f330e3d7e4cdeb650de189ff146`. The file
changed, so every check of check 1 that reads the file was run again. Same
machine and tools as in check 1. C8 was not read again: no setting is in this
task's scope, and the fix touched only the workflow and documents.

### What changed in the workflow
The file accepted for everything but B1 in check 1 was rebuilt outside the
repository from the text read then; its sha256 is exactly
`11a66c1b9a43c0026559ebfffb421d309120e05a224de2f90cacd757d5a54052`, so the
comparison is byte for byte. `diff` against the current file shows two hunks
and nothing else:

- lines 15–17, the comment above `concurrency` (2 lines became 3);
- lines 19–20: `group: ci-${{ github.event.pull_request.number || github.ref }}`
  became `group: ci-${{ github.event.pull_request.number || github.run_id }}`,
  and `cancel-in-progress: ${{ github.event_name == 'pull_request' }}` became
  `cancel-in-progress: true`.

The header comment, `name`, `on`, `permissions`, the job, `runs-on`,
`timeout-minutes`, the pinned checkout with its `# v7.0.1` comment,
`persist-credentials: false` and `- run: make check` are unchanged, byte for
byte.

### Build and tests
| Command | Result | Tests | Warnings |
|---|---|---|---|
| `make check` (the workflow and this report untracked and not ignored, so both are in the checked set) | exit 0. Line 1: `swift-driver version: 1.148.6 Apple Swift version 6.3 (swiftlang-6.3.0.123.5 clang-2100.0.123.102)`; `whitespace` prints nothing | `Test run with 77 tests in 3 suites passed` | 0 (`grep -ci warning` over 197 lines) |
| `check-jsonschema --builtin-schema vendor.github-workflows .github/workflows/ci.yml` (0.39.0) | `ok -- validation done`, exit 0 | n/a | n/a |
| `ruby -ryaml -rjson` load | exit 0; top-level keys `name`, `true` (the key `on`), `permissions`, `concurrency`, `jobs`; `concurrency` is `{"group":"ci-${{ github.event.pull_request.number \|\| github.run_id }}","cancel-in-progress":true}`, and `cancel-in-progress` loads as a boolean (`TrueClass`), not as a string | n/a | n/a |
| `LC_ALL=C grep -n '[^ -~]'`, `tail -c1 \| xxd -p`, `git diff --check` | no non-ASCII byte; `0a`; no output | n/a | n/a |
| The pin, again: `gh api repos/actions/checkout/git/ref/tags/v7.0.1`; `releases/latest` | `type: commit`, sha `3d3c42e5aac5ba805825da76410c181273ba90b1`; `v7.0.1`. Unchanged since check 1 | n/a | n/a |

### Acceptance criteria
| Criterion | Row of the spec's plan | How checked | Result | Proof |
|---|---|---|---|---|
| AC1 | C7 | Read; the diff above | Met | `on` (lines 6–10), the job (lines 22–30) unchanged since check 1; there `pull_request` and `push` to `master` only, one job `check` on `xcode-27`, the only command `make check` |
| AC2: permissions, no secret, the pinned checkout without persisted credentials, 15 minutes, no cache or artifact | C7 | Read; the diff; the pin re-read | Met | Unchanged lines 12–13, 25, 27–29; no `secrets`, no cache, no artifact anywhere in the file |
| AC2: a newer run for the same pull request cancels the older one | C7 | Read against the docs; the event analysis below | Met | For a `pull_request` event the group is `ci-<number>` and `cancel-in-progress` is `true` |
| The spec's sentence: a run for a push to `master` shares its group with no other run, nothing cancels or replaces it, every push gets its own result (B1 of check 1) | C7 | Read against the docs; the event analysis below | Met, as far as a reading can prove it | A push's group is `ci-<run id>`; `github.run_id` is "a unique number for each workflow run within a repository" (`github/docs`, `data/reusables/actions/run_id_description.md`, blob `bf50c00c…`), so no other run of this workflow is in it, it is never `pending` behind another run, and there is no `pending` run in it to replace. The observation on GitHub is still open (see "Unproved until the workflow runs") |
| AC3 | C6, C7 | Cannot run before the pull request | Open, the dispatcher's | "On the pull request and after merges", below |
| AC4 | C8 | Check 1 | Met (check 1) | No setting is touched by the fix |
| OVERVIEW | none | `git diff HEAD -- docs/architecture/OVERVIEW.md` | Met | The same two rows as in check 1; the fix did not touch the file |
| `make check` green, no new warnings | C6 | Ran it | Met | 77/77, 0 warnings |

### The new expression, event by event
The workflow can be started by three things: a `pull_request` event (default
activity types `opened`, `synchronize`, `reopened`) whose base is `master`, a
`push` to `master`, and a re-run of an existing run by somebody with write
access. It has no `workflow_dispatch`, `schedule`, `workflow_call`,
`workflow_run`, `issue_comment` or `pull_request_target`. Closing or merging a
pull request is not one of the default types; the merge reaches the workflow
as a `push`.

| Event | `github.event.pull_request.number` | Group | What `cancel-in-progress: true` does |
|---|---|---|---|
| Pull request from a branch of `kyukhin/clam` | the number, set by GitHub | `ci-<number>` | cancels the older run of the same pull request, in progress or pending: after a push or a fold (force push) to the branch, the run on the old head stops |
| Pull request from a fork, running this file unchanged | the number in `kyukhin/clam`, set by GitHub; the contributor cannot choose it | `ci-<number>` | the same, only within that pull request. The first run of a first-time contributor waits for kyukhin's approval; the token is read-only |
| Push to `master` | undefined, so `\|\|` falls back to `github.run_id` | `ci-<run id>`, unique in the repository | nothing to cancel: no other run is in the group |
| Re-run of a push run | unchanged | the same `ci-<run id>`: `run_id` "does not change if you re-run the workflow run" (same docs file) and a re-run uses "the same `GITHUB_SHA` … and `GITHUB_REF`" (`content/actions/how-tos/manage-workflow-runs/re-run-workflows-and-jobs.md`) | the group holds only attempts of the same run on the same commit. Even if two attempts could overlap, the one cancelled would be an attempt for the same commit, so no commit loses its result |
| Re-run of an older pull request run while a newer run of the same pull request is going | unchanged | `ci-<number>` | cancels the newer run. Only a person with write access can start a re-run; check 1's form did the same. Information, no finding |

Collisions between the two kinds of group: a run id is a repository-wide
number of eleven digits (the latest run of `kyukhin/dict-app`, read with
`gh api repos/kyukhin/dict-app/actions/runs?per_page=1`, has id
42680544806), while `kyukhin/clam` has 5 pull requests. A pull request
number never reaches a run id in practice. Choosing `github.run_id` and not
`github.run_number` matters here: a run number starts at 1 per workflow and
would collide with a pull request number (`ci-5`).

Can a contributor steer the expression? Not through the expression: its
inputs are a number GitHub assigns and an id GitHub assigns. But a
`pull_request` run executes the workflow file of the pull request's merge
commit, so a pull request that edits `ci.yml` (from a fork too, after its
first run is approved, or at once for a returning contributor) can set any
group and `cancel-in-progress: true`. Concurrency groups are shared by the
whole repository, "regardless of the workflow" (the concurrency docs,
blob `38696b82…`). Run ids are public on the Actions page of a public
repository. Such a pull request could therefore cancel a running push run on
`master`, or another pull request's run, by naming its group. Nothing in the
docs exempts runs from forks, and nothing written in this workflow can prevent
it, because the attacker's copy replaces the file; check 1's form
(`ci-refs/heads/master`) was open to the same. The cost is a cancelled
informative run; the run reads and writes nothing, and the pull request that
does it is public and touches `.github/workflows/`. This corrects a sentence
of check 1: "no pull request can cancel a run on `master`" holds only for a
pull request that runs this file unchanged. Not observed on GitHub; it follows
from the docs. Non-blocking: N4.

### Test quality and mutations
No Swift code in the task; the checks relied on were shown to fail again on
the new file. Copies outside the repository, removed afterwards; the
workflow's sha256 `88bd477a…` before and after.

| Mutation of a copy | Schema check exit |
|---|---|
| `permissions:` → `permision:` | 1 |
| `timeout-minutes: 15` → `fifteen` | 1 |
| `contents: read` → `contents: admin` | 1 |
| `pull_request:` → `pull_request_targett:` | 1 |
| `- run:` → `- rn:` | 1 |
| `runs-on:` removed | 1 |
| `cancel-in-progress: true` → `always` | 1 |
| `group:` → `gruop:` | 1 |
| the file itself | 0 |

As in check 1, the schema accepts the forbidden but valid forms
(`pull_request_target`, `contents: write`, `persist-credentials: true`); the
read above is what proves AC1 and AC2. The concurrency semantics cannot be
mutated before GitHub runs the file.

### Change scope, spec and invariants
`git status --short --untracked-files=all`: the five modified documents,
`?? .github/workflows/ci.yml` and `?? docs/qa/TASK-003.md` (this report);
nothing else. Since check 1 the developer changed the concurrency block and
its comment, the sentence of "Checks on GitHub: the second line", the History
of the spec (the TASK-003 line rewritten, one new line for the fix), the
"Proved by" cell of C7, and the developer notes ("Fix after QA check 1").
BOARD.md holds the developer's and the dispatcher's rows. All of it is in the
change scope.

The three texts against the file:

- The comment (lines 15–17): "A newer run for the same pull request cancels
  the older one: the group is the pull request number. A push to master has no
  pull request, so its group is its own run id: no other run shares it, and
  every push to master gets its own result." Matches the file.
- The spec: "A newer run for the same pull request cancels the older one. A
  run for a push to `master` shares its concurrency group with no other run,
  so no later run cancels it or replaces it while it waits: every push to
  `master` gets its own result." Matches the file. Both texts speak of this
  workflow; that a pull request which rewrites the workflow can pick any group
  is not said (N4), and neither says what holds only on GitHub's side (a
  commit whose message carries `[skip ci]` or a similar marker starts no run;
  N5).
- History: the TASK-003 line now says the group is `ci-<pull request number or
  run id>` with `cancel-in-progress: true`, which is the file; the new line
  says what was wrong with the first form, what GitHub's documentation says
  and that the line above was corrected. The line above was never committed,
  and the correction is itself recorded, so nothing in the spec changed
  silently.
- The C7 cell adds that the group was read against GitHub's documentation and
  that the push runs on `master` are read by the dispatcher after merges.
  True.

Rule 4 of `docs/specs/README.md`, again: the change is still a small
implementation detail. It is invisible to the user of the app, changes no data
model, storage, module boundary, contract or dependency, keeps the approved
sentence about pull requests, and makes the job's runs on `master` each
complete, in line with E-01's "nobody waits for a run". A History line is
enough; the spec stays `approved`.

Invariants: no Swift code, no module, no import; invariant 4 below.

### Security and language
- Misuse review of the new file: the triggers, the token, the credentials,
  cache and artifacts are as in check 1 and the conclusions stand. The
  expressions are still only in `concurrency`, evaluated by GitHub and not by
  a shell; there is now one expression instead of two, with GitHub-assigned
  inputs only. The concurrency group is the one new surface, discussed above
  (N4).
- `git diff -U0 HEAD | perl -CSD -ne 'print if /\p{Cyrillic}|\p{Greek}/'` and
  the same over the untracked workflow: no output.
- Secrets: the diff searched as in check 1. The one 32-hexadecimal hit besides
  the pin is `38696b820c7dd784495cafc4cab273f57fd9a4ec` in the developer
  notes, the blob hash of the GitHub docs file the notes quote; it is the
  same blob this check read (`gh api …/actions-group-concurrency.md --jq
  .sha`). Not a secret.

### Unproved until the workflow runs on GitHub
- AC3 whole: the job runs on `xcode-27`, ends green, shows Swift 6.4 first,
  has no warning, and the Xcode 27 SDK declares `O_NOFOLLOW_ANY` and
  `AT_SYMLINK_NOFOLLOW_ANY`.
- The token the run gets, and that GitHub accepts the label and the file.
- The concurrency behavior in practice: a pull request cancels its own older
  run; every push to `master` gets a run that is not cancelled. The proof here
  is GitHub's documentation only.

### Findings
Blocking: none. B1 of check 1 is fixed: a push to `master` now has a group
that no other run of this workflow shares.

Non-blocking (task proposals):

- **N1** (carried from check 1). The ruleset parameter
  `require_extra_approval_for_unattributed_changes: true` is not in the table
  of "GitHub settings" (architect, next call on E-03).
- **N2** (carried, information). The job uses the image's default Xcode,
  27.1 today.
- **N4.** A pull request that edits `ci.yml` runs its own copy and can choose
  any concurrency group, so it can cancel a run on `master` or another pull
  request's run (see "The new expression, event by event"). It cannot be
  prevented in the file. Proposal (architect, next call on E-03): one
  sentence in the paragraph about pull requests from a fork, next to E-01's
  "A pull request from a fork can rewrite the workflow it runs": such a run
  can also cancel other runs of the repository through the concurrency key,
  and a cancelled run on `master` is re-run by hand.
- **N5** (information). "Every push to `master` gets its own result" assumes
  GitHub starts a run: a commit message with `[skip ci]`, `[ci skip]`,
  `[no ci]`, `[skip actions]` or `[actions skip]` starts none. The committer's
  skill writes the messages; no task unless kyukhin wants it written down.
- N3 of check 1 is void: the task file's header says `in-review` again.

### On the pull request and after merges (the dispatcher)
None of these is known to fail. `<N>` is the pull request, `<id>` the run on
its head commit. Items 1–9 of check 1 still apply; the changes are in 10
and 11.

1. The pull request is against `master` with only this task's commit, opened
   after PR #5 and the pull request of TASK-002 are merged:
   `gh pr view <N> --json baseRefName,commits --jq '{baseRefName, n: (.commits | length)}'`
   gives `master` and 1; `gh pr diff <N> --name-only` lists only this task's
   files.
2. `gh pr checks <N>` lists `check`;
   `gh run list --workflow ci.yml --json databaseId,event,status,conclusion,headSha`
   shows a `pull_request` run on the head commit. No run, or
   `startup_failure`, is a defect.
3. `conclusion: success`. `failure` or `timed_out` is a defect (read
   `gh run view <id> --log-failed`); `cancelled` is a defect only if no newer
   run of the same pull request exists.
4. `gh run view <id> --log | grep -m1 'Apple Swift version'` shows 6.4; 6.3
   or lower is a defect. `gh run view <id> --log | grep -m3 -i 'image'` names
   the `xcode-27` image.
5. `gh run view <id> --log | grep -ci 'warning:'` gives 0;
   `gh run view <id> --log | grep -n 'NOFOLLOW_ANY'` prints nothing (an error
   naming `O_NOFOLLOW_ANY` or `AT_SYMLINK_NOFOLLOW_ANY` is a defect, fixed in
   `Tools/ClamChecks/`).
6. The log has `Test run with 77 tests in 3 suites passed`.
7. `gh run view <id> --log | grep -A4 'GITHUB_TOKEN Permissions'` lists only
   `Contents: read` and `Metadata: read`.
8. `gh api repos/kyukhin/clam/actions/runs/<id>/artifacts --jq .total_count`
   and `gh api repos/kyukhin/clam/actions/caches --jq .total_count` give 0.
9. C12 (kyukhin): `check` and `CodeRabbit` on the page, neither required.
10. Cancelling within the pull request, when it happens (a fold pushed while
    a run is going):
    `gh run list --workflow ci.yml --branch <branch> --json databaseId,headSha,status,conclusion,createdAt`
    shows the run on the old head `cancelled` and a run on the new head. A
    run on an old head still `in_progress` after the run on the new head has
    started is a defect of the concurrency block.
11. After merges into `master` (from this one on, most telling when two or
    three merges come close together):
    `gh run list --workflow ci.yml --branch master --event push --json databaseId,headSha,status,conclusion --limit 20`
    against `git log --format=%H origin/master` after `git fetch`: one run for
    every merge commit since this task, none with conclusion `cancelled`
    unless somebody cancelled it by hand. A merge commit without a run (and
    no skip marker in its message, N5) or a `cancelled` push run is a defect
    of this task's concurrency block; its run list is the finding.

One summary line for the PR: `QA: make check 77/77 (Xcode 26.4), schema ok (8 mutants rejected), file = check 1 except the concurrency block (B1 fixed: push runs get their own group), pin = actions/checkout v7.0.1, C8 settings match; job run on the PR to be read`

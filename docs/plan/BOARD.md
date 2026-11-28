# Board

Current milestone: M0
Next role: dispatcher (the pull request of TASK-003 and the run of its job `check`); kyukhin (H1 and H2 for PR #5 of TASK-001; then the PR of TASK-002)

| Task | Epic | Status | Role now | Note |
|---|---|---|---|---|
| TASK-001 Add `.coderabbit.yaml`, the settings of the review bot | E-03 | done | dispatcher | QA PASS (check 2, `docs/qa/TASK-001.md`); fixed after QA check 1 (B1, N1). depends on nothing; goes first; after its PR is opened: kyukhin's H1 and H2, then C10 of the spec by hand |
| TASK-002 Create the check tool with the `whitespace` check, and `make check` | E-03 | done | dispatcher | QA PASS (check 2, `docs/qa/TASK-002.md`); fixed after QA check 1 (B1, N1); spec changed (small details, History). depends on nothing; worked on top of the branch of TASK-001 before its merge (kyukhin, 2026-11-28), merged after it |
| TASK-003 Add the `check` job on GitHub | E-03 | done | dispatcher | QA PASS (check 2, `docs/qa/TASK-003.md`); fixed after QA check 1 (B1); spec changed (small detail, History). AC3 is the dispatcher's: the run on the PR and the push runs after merges (report, "On the pull request and after merges"). depends on TASK-002; can be worked while TASK-004 is; C12 of the spec by hand on its PR |
| TASK-004 Add the `tracked-files`, `language` and `secrets` checks | E-03 | ready | developer | depends on TASK-002; can be worked while TASK-003 is |

## Blocked
| Task | Reason | Since | Who unblocks |
|---|---|---|---|

## External dependencies
What only kyukhin can do. None of them blocks a task yet.

| What | Needed for | Status |
|---|---|---|
| Apply to Apple for the CarPlay audio entitlement | E-09 and M7: the critical path of everything on the car screen (ADR-0001) | not started |
| Update the Mac to macOS 26.6 or a later 26.x and install Xcode 27, keeping an Xcode 26.x next to it | the first task of E-01 (spec E-01, K1) | macOS is 26.7.3 (seen on 2026-11-28); Xcode 27 is not installed yet, the Mac has Xcode 26.4 |
| The App ID `com.kyukhin.Clam`, the App Store Connect record, the certificate and profile, the API key and the local settings file, the TestFlight group | E-01 (spec E-01, K2 to K5 and K7) | not started |
| The GitHub settings (spec E-01, K6) | E-01 | done 2026-11-27 by the dispatcher on kyukhin's "yes. everything as in LibreDict": the ruleset `master` and the Dependabot settings are copied from `kyukhin/dict-app`; the Actions settings were already the same |
| The ask rule for delivery commands in `.claude/settings.local.json`; kyukhin's own edit, an agent does not change its permissions | E-01 (spec E-01, K8) | not started |
| Add `kyukhin/clam` to the CodeRabbit installation that already serves `kyukhin/dict-app` (spec E-03, H1 and H2) | E-03; when the dispatcher says that the PR with `.coderabbit.yaml` is open, not earlier: without that file the bot works with the account's settings | not started |
| Telegram `api_id` and `api_hash` from my.telegram.org | M2 | not started |
| Submit Clam to App Review from kyukhin's Apple account | M5 | not started |

## Notes
- Merged into `master`: PR #1 with the planning documents (2026-11-27); PR #2
  with the review step and the delivery rules of the kit, and PR #4 with the
  tasks of E-03, the aligned specs and the OVERVIEW (both 2026-11-28). PR #4
  replaced PR #3 with the same patch.
- A pull request that targets the branch of another pull request is closed by
  GitHub when that branch is deleted at the merge, and it cannot be reopened
  or retargeted afterwards. Open a pull request against `master` only, after
  the one below it is merged, or retarget it to `master` before that merge.
- The branches of TASK-001 and TASK-002 stand on each other: PR #5 is
  TASK-001; the pull request of TASK-002 is opened when PR #5 is merged.
- For the architect's next call on ADR-0005 and the E-03 spec: align the text
  about the moment of the fold with kyukhin's decision of 2026-11-28 (a fix is
  folded before it is pushed).
- The ruleset of `master` allows merges by rebase only, as in LibreDict.
  kyukhin decided on 2026-11-27 that one task is one commit on `master`: the
  commits of a branch are folded into one and the branch is force-pushed
  before the merge. CLAUDE.md and the committer skill get this wording with
  the review step.
- Two developers at a time need separate working trees: `make check` and QA's
  `git status` look at the whole tree. Until that is set up, tasks are worked
  one at a time.
- `docs/plan/` holds an editor's autosave and lock files for ROADMAP.md. They
  are not to be committed.

## Log
| Date | Task | Transition | Who |
|---|---|---|---|
| 2026-11-27 | PRD | draft → approved (version 1.0) | kyukhin |
| 2026-11-27 | ROADMAP | written, waits for kyukhin | project-manager |
| 2026-11-27 | PRD | approved → draft (version 1.1): App Review moved into the MVP | cpo |
| 2026-11-27 | ROADMAP | reworked: new M5 "App Store, quietly", later milestones renumbered | project-manager |
| 2026-11-27 | PRD | draft → approved (version 1.1), then version 1.2 at kyukhin's request: changeable skins, a designer agent | kyukhin |
| 2026-11-27 | ROADMAP | approved; M0 planned → active | kyukhin |
| 2026-11-27 | E-01 | spec planned → draft; ADR-0001 and ADR-0002 proposed | architect |
| 2026-11-27 | PRD | approved → draft (version 1.3): the car screen needs Apple's entitlement even in a simulator | cpo |
| 2026-11-27 | ADR-0001 | proposed → accepted ("Stack ok") | kyukhin |
| 2026-11-27 | PRD | draft → approved (version 1.3): "I am ok with the PRD" | kyukhin |
| 2026-11-27 | E-01 | kyukhin: free checks for PRs on GitHub are added, the main testing runs locally | project-manager |
| 2026-11-27 | ADR-0002, ROADMAP | ADR-0002 proposed → accepted; the roadmap rewording about the car screen approved: "ok" to "do you approve?" | kyukhin |
| 2026-11-27 | branch `kyukhin/000-product-plan` | pushed, PR #1 opened: "ok" to "push and open a PR?" | kyukhin |
| 2026-11-27 | E-03 | moved to the front of M0 and widened: CodeRabbit and the first checks right away | kyukhin |
| 2026-11-27 | repository settings | secret scanning and push protection checked with kyukhin's "yes": both were already on, nothing changed | project-manager |
| 2026-11-27 | standing permissions | pushing task branches and opening PRs without asking: yes; parallel work within limits: yes (recorded in CLAUDE.md) | kyukhin |
| 2026-11-27 | E-03 | a second architect run started in parallel with the rework of E-01 | project-manager |
| 2026-11-27 | E-01, ADR-0002 | the spec reworked for checks and delivery on kyukhin's Mac with GitHub as a second line, still a draft; the status line of ADR-0002 set to accepted | architect |
| 2026-11-27 | E-01 | spec draft → approved: "yes. everything as in LibreDict"; open question 5 closed with (a) | kyukhin |
| 2026-11-27 | repository settings | copied from `kyukhin/dict-app` on kyukhin's word: ruleset `master` (no deletion, no force-push, PR required, rebase merges only), Dependabot alerts and security updates on | project-manager |
| 2026-11-27 | E-03 | spec planned → draft; ADR-0005 proposed | architect |
| 2026-11-27 | E-03, ADR-0005 | spec draft → approved, ADR-0005 accepted: "1 yes"; a `.coderabbit.yaml` for Clam: "3 yes" | kyukhin |
| 2026-11-27 | standing permissions | commenting on PRs in kyukhin's name for the review only: "2 yes"; folding a task branch into one commit and force-pushing it before the merge: "4 we squash into one commit and force-push the branch" | kyukhin |
| 2026-11-27 | E-01 | kyukhin's answers recorded; the spec stays in draft for the architect's rework: local builds and checks, bundle id `com.kyukhin.Clam` | project-manager |
| 2026-11-27 | PR #1 | merged into `master` as one commit: "yes" to "Do we merge PR #1 into `master`?" | kyukhin |
| 2026-11-27 | ADR-0005 | the status line set to accepted, the text aligned with the kit in force | architect |
| 2026-11-27 | E-03 | cut into TASK-001 to TASK-004, all `draft`; the spec aligned with kyukhin's answers, still approved | architect |
| 2026-11-27 | E-01 | the spec aligned with the seam to E-03 and with the GitHub settings in force, still approved; OVERVIEW written | architect |
| 2026-11-27 | TASK-001 | draft → ready | project-manager |
| 2026-11-27 | TASK-002 | draft → ready | project-manager |
| 2026-11-27 | TASK-001 | ready → in-progress | developer |
| 2026-11-27 | TASK-001 | in-progress → in-review | developer |
| 2026-11-27 | TASK-001 | in-review → in-progress: QA FAIL, see the report (`path: "**"` skips dot-paths under Minimatch defaults) | qa |
| 2026-11-27 | TASK-001 | in-progress → in-review: B1 and N1 of QA check 1 fixed | developer |
| 2026-11-27 | TASK-001 | QA PASS (check 2), stays in-review; committer next | qa |
| 2026-11-27 | TASK-001 | in-review → done, branch `kyukhin/001-coderabbit-config` | committer |
| 2026-11-28 | TASK-002 | started on top of the branch of TASK-001, before its merge: "5 yes" to "Do I start TASK-002 without waiting for the first task to be merged?" | kyukhin |
| 2026-11-28 | TASK-002 | ready → in-progress | developer |
| 2026-11-28 | TASK-002 | in-progress → in-review | developer |
| 2026-11-28 | TASK-002 | in-review → in-progress: QA FAIL, see the report (a symbolic link in a leading path component is followed) | qa |
| 2026-11-28 | TASK-002 | in-progress: developer fixes B1 and N1 of QA check 1 (`docs/qa/TASK-002.md`) | developer |
| 2026-11-28 | TASK-002 | in-progress → in-review: B1 and N1 of QA check 1 fixed | developer |
| 2026-11-28 | TASK-002 | QA PASS (check 2), stays in-review; committer next | qa |
| 2026-11-28 | TASK-002 | in-review → done, branch `kyukhin/002-check-tool` | committer |
| 2026-11-28 | PR #2 | merged into `master`: "yes 1 2 3" to "Do we merge PR #2 (the kit)?" | kyukhin |
| 2026-11-28 | PR #4 | merged into `master` in place of PR #3, same patch: "yes 1 2 3" to "Do we merge PR #3 (documents and tasks) right after it?" | kyukhin |
| 2026-11-28 | TASK-001 | PR #5 opened; the review waits for kyukhin's H1 | project-manager |
| 2026-11-28 | TASK-003 | draft → ready; started on top of the branch of TASK-002, before its merge: "yes 1 2 3" to "Do I start TASK-003 without waiting for the merge?" | project-manager |
| 2026-11-28 | TASK-004 | draft → ready | project-manager |
| 2026-11-28 | TASK-003 | ready → in-progress | developer |
| 2026-11-28 | TASK-003 | in-progress → in-review | developer |
| 2026-11-28 | TASK-003 | in-review → in-progress: QA FAIL, see the report (all pushes to `master` share one concurrency group, so a pending run is cancelled by the next push) | qa |
| 2026-11-28 | TASK-003 | in-progress: developer fixes B1 of QA check 1 (`docs/qa/TASK-003.md`) | developer |
| 2026-11-28 | TASK-003 | in-progress → in-review: B1 of QA check 1 fixed | developer |
| 2026-11-28 | TASK-003 | QA PASS (check 2), stays in-review; committer next | qa |
| 2026-11-28 | TASK-003 | in-review → done, branch `kyukhin/003-github-check-job`, on top of `kyukhin/002-check-tool` | committer |

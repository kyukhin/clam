# Board

Current milestone: M0
Next role: the dispatcher (the review step in CLAUDE.md and two skills, as its own PR) and architect (accept ADR-0005 in the M2 wording, cut E-03 into tasks, align E-01 with the seam, its K6 and C9, write OVERVIEW)

| Task | Epic | Status | Role now | Note |
|---|---|---|---|---|

## Blocked
| Task | Reason | Since | Who unblocks |
|---|---|---|---|

## External dependencies
What only kyukhin can do. None of them blocks a task yet.

| What | Needed for | Status |
|---|---|---|
| Apply to Apple for the CarPlay audio entitlement | E-09 and M7: the critical path of everything on the car screen (ADR-0001) | not started |
| Update the Mac to macOS 26.6 or a later 26.x and install Xcode 27, keeping an Xcode 26.x next to it | the first task of E-01 (spec E-01, K1) | not started |
| The App ID `com.kyukhin.Clam`, the App Store Connect record, the certificate and profile, the API key and the local settings file, the TestFlight group | E-01 (spec E-01, K2 to K5 and K7) | not started |
| The GitHub settings (spec E-01, K6) | E-01 | done 2026-11-27 by the dispatcher on kyukhin's "yes. everything as in LibreDict": the ruleset `master` and the Dependabot settings are copied from `kyukhin/dict-app`; the Actions settings were already the same |
| The ask rule for delivery commands in `.claude/settings.local.json`; kyukhin's own edit, an agent does not change its permissions | E-01 (spec E-01, K8) | not started |
| Add `kyukhin/clam` to the CodeRabbit installation that already serves `kyukhin/dict-app` (spec E-03, H1 and H2) | E-03; when the dispatcher says that the PR with `.coderabbit.yaml` is open, not earlier: without that file the bot works with the account's settings | not started |
| Telegram `api_id` and `api_hash` from my.telegram.org | M2 | not started |
| Submit Clam to App Review from kyukhin's Apple account | M5 | not started |

## Notes
- The planning documents of 2026-11-27 are in the branch
  `kyukhin/000-product-plan`, pushed with kyukhin's "ok"; the PR into `master`
  waits for kyukhin's "yes" to merge.
- The ruleset of `master` allows merges by rebase only, as in LibreDict.
  kyukhin decided on 2026-11-27 that one task is one commit on `master`: the
  commits of a branch are folded into one and the branch is force-pushed
  before the merge. CLAUDE.md and the committer skill get this wording with
  the review step.
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

# E-01: Stack and project skeleton

> Status: approved by kyukhin 2026-11-27 · Milestone: M0 · Epic: #6 · Tickets: none yet · Updated: 2026-11-28

Read first: `docs/architecture/OVERVIEW.md`; ADR-0001 (stack), ADR-0002
(modules) and ADR-0005 (the review of every pull request), all accepted on
2026-11-27; `docs/specs/E-03-automated-code-review.md`, the epic that goes
first in M0. E-03 creates the `Makefile`, the check tool, `.gitignore` and the
workflow, and this epic adds to them. The split is in the E-03 spec, "What
moves from E-01 to E-03". Where this spec says "from E-03", that spec owns the
text.

## Why

After E-03 the repository has its first checks, and still nothing of the app
can be built, tested or installed. Every later epic needs a project that
builds, a place for each module, checks that hold the boundaries, and a way
onto kyukhin's phone. E-01 covers no MVP item. It prepares:

- PRD §9: Clam is installed through TestFlight from the start.
- PRD §3: a public repository; no third-party code that sends data anywhere.
- Invariant 4 in CLAUDE.md: secrets never get into git.
- PRD §11: Clam builds from a clean clone.
- Milestone M0 on GitHub, "Done when": kyukhin installs a build from
  TestFlight, every check passes on a clean clone on kyukhin's Mac, and a PR
  gets the free checks on GitHub.

## Behavior

### On the phone

kyukhin installs Clam from the TestFlight app. The icon is a placeholder. The
app has one screen in the plain system look, three lines of text and no
controls:

```
Clam
Version 0.1.0
Build 202612011530
```

The build number equals the one TestFlight shows for the installed build.

The screen has one state. The app loads nothing, stores nothing and opens no
network connection, so there is no empty, loading, error or offline state. It
asks for no permission. On a phone set to Russian or Greek the texts are
English until E-06.

### On the Mac and on GitHub

"Was" is the repository after E-03.

| | Was | Now |
|---|---|---|
| Checking a change | `make check` runs the four checks of E-03 and the tests of the check tool | On kyukhin's Mac `make check` runs every check: those of E-03, the formatting, the boundaries, the dependencies, the build, the tests and the Release archive. `make clean-check` runs the same on a clean copy of the repository. These two decide whether a task is done |
| A pull request into `master` | One job, `check`, with the checks of E-03, and the review of ADR-0005 | GitHub starts two jobs by itself: `check` (Xcode 27), which runs the grown `make check`, and `compat` (Xcode 26.6). They are a second, independent line, as the review is: kyukhin sees their result on the pull request page and in the line "GitHub check" of the report after a task, and it does not block the merge |
| A build on the phone | Not possible | `make testflight`, run on the Mac on kyukhin's word, puts a build of the tree it is run in into TestFlight |
| The repository | Documents, the kit and, from E-03, a Makefile, a check tool, one workflow and the settings of the review bot | Also an Xcode project, one Swift package, `Config/` and the scripts behind `make` |

If the GitHub jobs are unavailable, slow or removed, no work stops: the checks
on the Mac decide.

### Getting a build into TestFlight

A build is made from the tree the command is run in: the newest `master` for
everyday use, or the tree of a task that waits for kyukhin's check on the phone
before its commit.

1. kyukhin tells the dispatcher to ship a build, and of what.
2. The dispatcher runs `make testflight` in that tree. This uploads nothing. It
   prints what would be shipped (the branch, the commit, the files changed on
   top of it), a snapshot id of these files, and whether the Mac is ready for
   a delivery.
3. The dispatcher runs `make testflight CONFIRM=<the id>`. The agent session
   asks kyukhin for permission before this command, every time (K8). kyukhin
   allows the one run.
4. The command makes a clean copy of the tree, runs every check on it, then
   archives, signs and uploads. It prints the build number.
5. When Apple has processed the upload, the build appears in the TestFlight app
   on the phone.

Nothing is uploaded by a merge, on a schedule or from GitHub. Only the
dispatcher runs the command with `CONFIRM`: the developer, QA, the committer
and the architect never do. kyukhin can run both commands in Terminal.

If a step fails, the command stops and names the step. The upload is the last
step, so a failure before it sends nothing to Apple. If a file changed after
step 2, step 3 refuses.

If macOS asks whether `codesign` may use the distribution key, kyukhin allows
it.

### What kyukhin does by hand, once

Nobody else can do K1 to K5, K7 and K8. K6 is done. Whether the others are
done is the state of their issues on GitHub, assigned to kyukhin: #40 (K1),
#41 (K2 to K5 and K7) and #42 (K8).

- **K1. The Mac.** Update macOS to 26.6 or a later 26.x (it is 26.5.2) and
  install Xcode 27.x, before the first task of this epic; `xcode-select`
  points to Xcode 27. Keep an Xcode 26.x next to it, because E-09 needs its
  Simulator: an update through the App Store replaces Xcode 26, so rename the
  old `Xcode.app` first. Do not move to macOS 27 before E-09 is done: Xcode
  26, the only Xcode with the CarPlay window in its Simulator, is not
  supported there (ADR-0001). E-03 does not wait for K1: its tool builds with
  the Xcode 26.4 the Mac has today.
- **K2. The App ID.** developer.apple.com → Certificates, Identifiers &
  Profiles → Identifiers → new App ID, explicit, bundle id `com.kyukhin.Clam`,
  no capabilities.
- **K3. The app record.** App Store Connect → Apps → New App: iOS, name
  `Clam`, primary language English (U.S.), the bundle id of K2, SKU `clam-ios`.
  If the name is taken, use `Clam Audiobook Player`; the store name is decided
  in E-15.
- **K4. The certificate and the profile.** Xcode → Settings → Accounts →
  Manage Certificates: if the list has no "Apple Distribution" certificate,
  create one. It stays in the login keychain and is not exported to a file. On
  developer.apple.com → Profiles create a profile of the type "App Store
  Connect" for the App ID, named `Clam App Store`, download it and open it:
  Xcode installs it. Both expire after one year; renewing them is this step
  again.
- **K5. The API key and the local settings.** App Store Connect → Users and
  Access → Integrations → App Store Connect API → a team key with the access
  Developer. Download the `.p8` file (possible only once) and move it to
  `~/.appstoreconnect/private_keys/AuthKey_<key id>.p8`; make the file readable
  by kyukhin only (`chmod 600`, the folder `chmod 700`). If that folder already
  holds a team key with the access Developer or higher, made for another app,
  it serves as well: a team key is not bound to one app. Then copy
  `Config/Local.xcconfig.example` to `Config/Local.xcconfig` and fill in the
  team id, the profile name of K4, the key id and the issuer id.
- **K6. GitHub.** Done on 2026-11-27; nothing is left to do. On kyukhin's
  "yes. everything as in LibreDict" the dispatcher copied the settings of
  `kyukhin/dict-app` to `kyukhin/clam`. In force:
  - a ruleset `master`: no deletion, no force-push, a pull request required,
    merges by rebase only, no required check;
  - secret scanning and push protection on; Dependabot alerts and security
    updates on;
  - Actions: all actions allowed; the default workflow token is read-only;
    the first run of a first-time contributor waits for kyukhin's approval;
  - there are no Actions secrets, variables or environments, and none is
    created. This rule is this spec's.

  The table of the settings as they are is in the E-03 spec, "GitHub
  settings", and E-03 reads them back (C8 there). This epic changes none.
- **K7. TestFlight.** App Store Connect → the app → TestFlight → an internal
  group with kyukhin in it and automatic distribution on. Install the
  TestFlight app on the iPhone.
- **K8. The agent session.** kyukhin adds the rule `Bash(*CONFIRM=*)` to
  `permissions.ask` in `.claude/settings.local.json` in the repository folder;
  git ignores that file (`.gitignore`, from E-03). From then on the session
  asks before every command that carries a confirmation, whatever else is
  allowed, an "always allow" for `make` included. An agent does not edit its
  own permissions: this edit is kyukhin's.

After K4 and K5 the private key of the certificate is only in the login
keychain, and the `.p8` is only in `~/.appstoreconnect/private_keys/`. Both
are on kyukhin's Mac and outside the repository folder. GitHub holds none of
them.

### Decisions

- 2026-11-27 (kyukhin): the phone is an iPhone. The MVP is built for iOS only.
  There is a paid Apple Developer account (PRD §2).
- 2026-11-27 (kyukhin): Clam is installed through TestFlight from the start
  (PRD §9).
- 2026-11-27 (kyukhin): the license is MIT (PRD Q8). PRD §3 on top of that:
  the whole app lives in the public repository, and anyone can build it with
  their own keys.
- 2026-11-27 (ADR-0001, accepted): native Swift, Xcode 27, minimum iOS 26.0,
  SwiftPM only, `swift format`, checks on kyukhin's Mac with a free GitHub
  runner as a second line, delivery from the Mac, manual signing of release
  builds.
- 2026-11-27 (ADR-0002, accepted): the layout of modules and the boundary
  check.
- 2026-11-27 (architect): the one screen and its three lines; version `0.1.0`
  until a later spec changes it; the build number is the UTC time of the build,
  `yyyyMMddHHmm`.
- 2026-11-27 (architect): iPhone only, portrait only; E-05 can change the
  orientation.
- 2026-11-27 (architect): the placeholder icon is our own drawing, not derived
  from Winamp or from anybody's artwork; E-05 replaces it.
- 2026-11-27 (architect): builds are made and uploaded with Apple's tools only
  (`xcodebuild`); no fastlane.
- 2026-11-27 (architect): `ITSAppUsesNonExemptEncryption` is `NO`. This is true
  for the skeleton, which contains no encryption. The answer is decided again
  when TDLib arrives (the ADR before E-10).
- 2026-11-27 (kyukhin), open question 1: "do it as in my LibreDict". LibreDict
  uses `com.kyukhin.DictApp`, so the bundle id is `com.kyukhin.Clam`.
- 2026-11-27 (kyukhin), open question 2: "locally; we do not spend money on
  Actions, and for free they would become a common place". The dispatcher
  read this as: builds and checks run on kyukhin's Mac, and nothing runs on
  GitHub Actions. That reading is replaced by kyukhin's next answer.
- 2026-11-27 (kyukhin), open question 2: "ok, let's add these checks. But the
  main testing will apparently have to be run locally." Said in answer to the
  dispatcher's recommendation: keep the free pull-request checks that need no
  secrets on GitHub's runners, make them not required for merging, and keep
  every TestFlight build and all signing material on kyukhin's Mac. "Not
  required for merging" comes from that recommendation, which kyukhin
  answered "ok" to; it is not in kyukhin's own words.
- 2026-11-27, open question 3: not answered; accepted by default: a build goes
  to TestFlight only on request.
- 2026-11-27 (kyukhin), open question 4: the phone is "a 16, it seems, with a
  fresh OS". The minimum iOS 26.0 of ADR-0001 stands.
- 2026-11-27 (architect): the checks on the Mac are the main line. `make check`
  is the developer's command; `make clean-check` is the command of QA and of
  the committer's final check. What a clean copy is, see "Design".
- 2026-11-27 (architect): GitHub Actions runs checks only. It never signs,
  uploads or publishes, and no workflow gets a secret or a write permission.
  Changing that is a decision of a later spec and a kyukhin gate.
- 2026-11-27 (architect): a red job on GitHub blocks nothing and is not
  ignored. The dispatcher names it to kyukhin when it sees one, in the report
  after a task or before a merge, and kyukhin decides. The dispatcher does not
  wait for a run to finish.
- 2026-11-27 (architect): the `compat` build on Xcode 26.6 is a job of the
  GitHub workflow only. It costs nothing there, and no check on the Mac needs
  a second Xcode. There is no local `compat` command: any `make` target runs
  under another Xcode through `DEVELOPER_DIR`. If the workflow is lost,
  `compat` is lost with it until E-09, whose probe builds with Xcode 26 on the
  Mac anyway. The ADR of E-09 keeps or drops it.
- 2026-11-27 (architect): a delivery ships the tree it is run in, from a clean
  copy, after every check has passed on that copy. It is not limited to
  `master`: a task that needs kyukhin's check on the phone gets it before its
  commit (CLAUDE.md, "When to stop and wait for kyukhin", item 7), so its build
  has to reach TestFlight before the merge. The first draft shipped only
  `master`. See open question 5.
- 2026-11-27 (architect): which tree is shipped and when is kyukhin's word for
  each build. Only the dispatcher runs the confirmed command. Three things
  stand between an agent and an upload: this rule, `CONFIRM` with the snapshot
  id, and the permission question of the agent session, which K8 makes
  unconditional. None of them is a wall: see "What the Mac does not prove".
- 2026-11-27 (architect): the upload signs in with an App Store Connect API
  key kept in `~/.appstoreconnect/private_keys/`, the folder Apple's own
  `altool` searches. The alternative was the Apple ID that Xcode keeps: it
  needs no key file, but its session expires and is renewed only in Xcode's
  settings window, and Apple's forums report command-line uploads failing
  with it.
- 2026-11-27 (architect): builds made in E-01 are marked for internal
  TestFlight testing only, so none of them can reach external testers or the
  App Store. E-15 lifts the mark.
- 2026-11-27 (kyukhin), open question 5: "yes" to the recommended option (a).
  A delivery may ship any tree that passed every check in a clean copy, a task
  that is not committed yet included, each time on kyukhin's word.
- 2026-11-27 (kyukhin), the GitHub settings of K6: "yes. everything as in
  LibreDict". The dispatcher reads "everything as in LibreDict" as the GitHub
  settings of kyukhin's repository `kyukhin/dict-app` and copied them to
  `kyukhin/clam` the same day: a ruleset `master` that forbids deleting the
  branch and force-pushing to it, requires a pull request and allows merges by
  rebase only, with no required check; Dependabot alerts and security updates
  on. The Actions settings were already the same in both repositories and stay
  so: all actions allowed, a read-only workflow token, runs of first-time
  contributors wait for approval. This replaced the "Require linear history"
  rule and the stricter Actions settings that K6 and C9 named; their text is
  aligned (see "History"). The workflow itself still uses only GitHub's own
  actions pinned to a commit.
- 2026-11-27 (kyukhin): "CodeRabbit should be added right away, and the other
  small checks too." (roadmap, E-03). The order of M0 is E-03, E-01, E-04,
  E-02, and this spec was approved with the caveat that a part of the checks
  moves to E-03 (see "History").
- 2026-11-27 (architect): the split follows the E-03 spec, "What moves from
  E-01 to E-03". E-03 creates the `Makefile` with `lint`, `test-tools` and
  `check`, the check tool with `language`, `whitespace`, `tracked-files` and
  `secrets`, `.gitignore`, and the workflow with the job `check`. This epic
  adds the build, the tests, `swift format`, three commands of the tool
  (`boundaries`, `dependencies`, `release-guard`), the clean copy, the
  delivery and the job `compat`. It rewrites nothing that E-03 made.
- 2026-11-27 (ADR-0005, accepted; CLAUDE.md, "Review of a pull request"):
  every pull request is reviewed before the report after a task, and the
  report gives the state of the GitHub jobs in its line "GitHub check", as it
  is when the report is written. This is where the dispatcher names a red
  job.
- 2026-11-27 (architect), details of the seam; none changes what kyukhin sees
  on the phone, runs on the Mac or reads on GitHub:
  - `make lint` keeps the rule of E-03: every step runs even when another
    failed;
  - `swift format` covers every Swift file of the repository, the sources of
    the check tool included;
  - the `whitespace` check of E-03 gets an exception only for a file that
    Xcode writes in its own format (see "Checks");
  - fixtures are stored only for `boundaries` and `dependencies`;
  - the time limits of the two jobs (see "Checks on GitHub");
  - `.coderabbit.yaml` gets no path filter in this epic.

## Design

### Layout

Created by this epic:

```
Clam.xcodeproj/        the app target Clam and the UI test target
App/                   the app target: entry point, assembly, Info.plist, icon
UITests/               XCUITest
Packages/ClamKit/      Package.swift, Sources/<Module>/, Tests/<Module>Tests/
Config/                Base.xcconfig, Debug.xcconfig, Release.xcconfig,
                       Local.xcconfig.example, allowed-dependencies.txt
scripts/               shell entry points used by make
.swift-format
```

From E-03, and what this epic does to each:

```
Makefile                   gets new targets and steps (see "Commands")
Tools/ClamChecks/          gets three commands (see "Checks")
.github/workflows/ci.yml   gets the job compat (see "Checks on GitHub")
.gitignore                 unchanged
.coderabbit.yaml           unchanged
```

- The Xcode project is checked in and kept by hand; no generator is needed to
  build. It stays in the format Xcode 26 reads. Source folders are synchronized
  with the file system: a new source file needs no project edit.
- Of the modules of ADR-0002, E-01 creates two in `Packages/ClamKit`:
  `Localization` (the String Catalog at the path fixed by ADR-0001, English
  only) and `FeatureAbout` (the version model and the one screen; E-14 grows
  it into the About screen). Every other module arrives with its epic.
- `Packages/ClamKit/Package.swift` declares no package dependencies.
- `.gitignore` is E-03's and holds every pattern this epic needs: the output
  of Xcode and SwiftPM, archives, signing material, `Config/Local.xcconfig`
  and `.claude/settings.local.json`. A new kind of output gets its pattern in
  the table of E-03 ("The four checks", `tracked-files`), in the tool and in
  `.gitignore`, in one commit.
- `.coderabbit.yaml` is E-03's, which leaves the filter for generated and
  binary files to the epic that adds them. This epic adds none: the project
  file is kept by hand and is reviewed like any other file.

### Commands

The `Makefile` comes from E-03 with `lint`, `test-tools` and `check`. The table
shows every command as it is when this epic is implemented.

| Command | From | What it does |
|---|---|---|
| `make build` | E-01 | Builds the app, Debug, for the iOS Simulator |
| `make test` | E-01 | Runs the unit tests of `Packages/ClamKit` on a simulator |
| `make ui-test` | E-01 | Runs the UI tests on a simulator |
| `make lint` | E-03, grows | `swift format lint --strict`, then every command of the check tool but the release guard: six (see "Checks"). As in E-03, every step runs even when another failed, and the exit is an error if any failed |
| `make format` | E-01 | Rewrites the sources with `swift format` |
| `make test-tools` | E-03 | Runs the tests of the check tool, on macOS, without a simulator |
| `make archive` | E-01 | Makes a Release archive without signing |
| `make check` | E-03, grows | lint, test-tools, build, test, ui-test, archive: every check, in the tree it is run in |
| `make clean-check` | E-01 | Makes a clean copy (below) and runs `make check` in it |
| `make testflight` | E-01 | Prints what a delivery would ship and its snapshot id. Builds and uploads nothing |
| `make testflight CONFIRM=<id>` | E-01 | The delivery (below): guards, clean copy, checks, archive, manual signing, upload |

The simulator is picked by a script from the ones installed: an iPhone on the
newest iOS runtime. No device name is written into the Makefile or the
workflow. The Xcode is the one `xcode-select` points to, or `DEVELOPER_DIR`.
From the first task of this epic that is Xcode 27 (K1).

`swift format` covers every Swift file of the repository: the app, the UI
tests, `Packages/` and `Tools/ClamChecks`. E-03 writes the tool before
`.swift-format` exists, so the task that adds the formatter runs `make format`
on the tool's sources once.

### The clean copy

`make clean-check`:

1. creates a new directory under `$TMPDIR`;
2. puts into it a new git repository with one commit that holds exactly what
   git would commit from the working tree now: every tracked file with its
   current content and every new file that `.gitignore` does not exclude.
   Ignored files, `Config/Local.xcconfig` and build output among them, are
   not there. The working tree and its index are not touched. These are the
   files the check tool reads in the working tree (E-03, "The check tool",
   the checked set). The copy is a git repository because the tool asks git
   for that set;
3. runs `make check` there, with the build output inside that directory and an
   environment reduced to `HOME`, `USER`, `TMPDIR`, `DEVELOPER_DIR` and
   `PATH=/usr/bin:/bin:/usr/sbin:/sbin`;
4. exits as `make check` did. After a success the directory is removed. After
   a failure it stays and its path is printed.

For a working tree without changes the copy holds the same files as a fresh
`git clone` of `HEAD`: this is the "clean clone" of milestone M0 and of PRD
§11.
For a task that is not committed yet it holds what the commit of the task will
contain, so QA checks it before the commit.

The snapshot id of a tree is the git hash of the files in its clean copy. The
same files give the same id.

### Project settings

- Bundle id `$(CLAM_BUNDLE_ID)`, default `com.kyukhin.Clam` in
  `Config/Base.xcconfig`. Display name `Clam`. Deployment target iOS 26.0.
  iPhone only.
- Swift language mode 6 in the app target and in every module. Warnings are
  errors.
- `Config/Base.xcconfig` ends with an optional include of
  `Config/Local.xcconfig`, which is not in git. It holds `CLAM_TEAM_ID`,
  `CLAM_RELEASE_PROFILE`, `CLAM_ASC_KEY_ID` and `CLAM_ASC_ISSUER_ID` (the last
  two are read only by the delivery) and, for people who build with their own
  account, their own `CLAM_BUNDLE_ID`. `Config/Local.xcconfig.example` explains
  the five keys; the README text about it is E-04.
- Debug builds for the simulator need no signing and no local file. Release
  builds are signed manually: identity "Apple Distribution", the profile named
  by `CLAM_RELEASE_PROFILE`.
- The Info.plist has a launch screen key and
  `ITSAppUsesNonExemptEncryption = NO`. There are no background modes, no
  entitlements file and no usage descriptions in E-01.
- Unit tests use Swift Testing; UI tests use XCUITest.

### Checks

`Tools/ClamChecks` comes from E-03: the package, the executable `clam-checks`
with no dependencies, the checked set, the output format, the exit statuses
and four commands, `language`, `whitespace`, `tracked-files` and `secrets`
(E-03, "The check tool" and "The four checks"). This epic adds three commands,
each with tests; the tool then has seven. The new commands use the same
output format and exit statuses and read only files of the checked set.
`make lint` runs all but `release-guard`.

1. **`boundaries`:** the rules of ADR-0002, "How violations are caught".
2. **`dependencies`:** every dependency declared by a `Package.swift` or by the
   Xcode project is listed in `Config/allowed-dependencies.txt`. The file is
   empty in E-01. GitHub's own actions in the workflow run only on GitHub's
   runner and get no line (E-03).
3. **`release-guard`:** the conditions of a delivery; see "TestFlight delivery".

On the repository `boundaries` and `dependencies` read the Xcode project,
`App/`, `UITests/`, the packages under `Packages/` and the manifest of the
tool. They do not read the fixtures under the tests of the tool.

**Fixtures.** The rule of E-03 stands: a fixture that breaks one of its four
checks is built by the test at run time. The fixture packages of `boundaries`
(ADR-0002) and the fixtures of `dependencies` break none of the four and are
stored under the tests of the tool. The tests of `release-guard` build
temporary git repositories.

**What this epic changes in the checks of E-03.** `language` and `secrets`:
nothing. `tracked-files`: nothing, unless a new kind of output appears (see
"Layout"). `whitespace` gets exceptions, which E-03 leaves to this epic: only
for a file that Xcode writes in its own format, by a path pattern, and only
for the rule that the file breaks. A file written by hand gets none. Known on
2026-11-27: the project file, `*.pbxproj`, is indented with tabs (W2). The
task that creates the project, the Info.plist, the String Catalog and the
asset catalog runs `whitespace` on them as Xcode 27 writes them and adds what
else they need. Each exception has a tool test and a line in "History".

### Checks on GitHub: the second line

`.github/workflows/ci.yml` comes from E-03 with its triggers (every pull
request into `master`, every push to `master`), the job `check`, the read-only
permissions, `actions/checkout` pinned to a commit, and the cancelling of an
older run (E-03, "Checks on GitHub: the second line"). Every constraint
written there still holds. This epic changes three things:

- `check`, on the runner `xcode-27`, still runs the single command
  `make check`, which now holds every check. Its time limit grows from 15 to
  30 minutes.
- A new job `compat`, on the runner `macos-26` with Xcode 26.6:
  `make build test`, with a time limit of 20 minutes. It builds and tests the
  app and `Packages/ClamKit` only. From the first task of this epic no check
  builds the tool with Xcode 26: the line of E-03 about Xcode 26.4 describes
  the Mac before K1.
- Both jobs keep the test results of a failed run with
  `actions/upload-artifact`, GitHub's own action, pinned to a full commit
  hash.

The two time limits are first numbers. The task that sees the first runs
corrects them, with a line in "History".

The workflow calls the same `make` targets as the Mac and holds no logic of
its own. It reads no secrets: the repository has none. Both runners are free
for a public repository (ADR-0001, V11).

A pull request from a fork can rewrite the workflow it runs. With no secret
and a read-only token such a run can take nothing; it can only use the runner.
GitHub asks kyukhin to approve only the first run of a first-time contributor
(E-03, "GitHub settings").

Neither job is required for a merge, and no task waits for a run. The report
after a task gives the state of the jobs as it is; a red job is named to
kyukhin, who decides (see "Decisions").

### What the Mac does not prove

In the first draft a fresh GitHub runner decided whether a pull request may
merge and made every TestFlight build, after kyukhin's approval on GitHub. Now
the Mac decides and builds.

| Lost | What stands in its place |
|---|---|
| A red check on a clean machine blocks the merge | The GitHub jobs still run on a clean machine, but they only inform. What decides is `make clean-check`, run by QA and by the committer before the commit, and kyukhin's word for the merge. `make clean-check` proves that nothing outside git, no tool outside macOS and Xcode and no old build output is needed. It does not prove independence of this Mac: Xcode, the simulators, `~/Library` and macOS are the same in every run |
| TestFlight builds come from a machine that holds nothing of kyukhin's, and their log is public | The delivery builds from a clean copy after every check has passed on it. The log stays on the Mac |
| GitHub asks kyukhin to approve every delivery and hands out the signing material only then | The key of the certificate and the API key can be used by any process that runs as kyukhin on the Mac, an agent session included. The rule, `CONFIRM` and the permission question of K8 guard against a mistake, not against such a process. A wrong upload reaches the internal TestFlight group, which is kyukhin, and nothing further: the builds of E-01 are marked internal-only |
| Every pull request, a fork's included, is checked without touching kyukhin's Mac | The GitHub jobs, as long as they exist. A pull request from a fork is not built or run on the Mac before kyukhin has read its diff: `make check` runs the Makefile, the scripts and the tests of the tree with kyukhin's rights, next to the signing key |

If the workflow is removed, no clean machine sees a change, nothing checks a
fork automatically, and `compat` is gone. No task waits for that.

### TestFlight delivery

`make testflight` is a script in `scripts/`.

Without `CONFIRM` it prints the plan: the branch, the commit of `HEAD`, the
files that differ from it, the snapshot id of the tree, and for each of the
last three conditions of step 1 whether it holds. It builds nothing and
uploads nothing.

With `CONFIRM` it works in this order and stops at the first failure:

1. **Guards,** before anything is built: the release guard of the check tool.
   It refuses and names the reason unless all of these hold:
   - `CONFIRM` is the snapshot id of the tree as it is now;
   - the selected Xcode is 27.x;
   - `Config/Local.xcconfig` gives the four values of "Project settings";
   - the key file `~/.appstoreconnect/private_keys/AuthKey_<CLAM_ASC_KEY_ID>.p8`
     exists and only its owner can read it.
2. **Checks.** It makes the clean copy and runs `make check` in it.
3. **Archive.** It archives the Release configuration in the copy, signed
   manually, with the build number set to the UTC time. The values of
   `Config/Local.xcconfig` are passed to `xcodebuild` as build settings; the
   file does not enter the copy, so the archive is built from the files of the
   snapshot and from nothing else. The archive is written to
   `~/Library/Developer/Xcode/Archives/`, where Xcode's Organizer lists it
   with its symbols.
4. **Upload.** `xcodebuild` exports the archive with manual signing straight
   to App Store Connect. It gets the path of the key file, the key id and the
   issuer id. The build number stays as set, and the build is marked for
   internal TestFlight testing only.
5. It prints the build number, the commit and the snapshot id and removes the
   copy. After a failure the copy stays and its path is printed.

`CONFIRM` stops an accidental run, for example by an agent that tries the
targets of the Makefile, and a run on files that changed after the plan was
printed. It does not stop a deliberate run.

The upload goes to TestFlight only. Nothing is submitted to App Review in E-01.

Checked on 2026-11-27 on kyukhin's Mac with Xcode 26.4: `xcodebuild -help`
lists the options for the key (`-authenticationKeyPath`, `-authenticationKeyID`,
`-authenticationKeyIssuerID`) and the export option
`testFlightInternalTestingOnly`; `altool --help` names
`~/.appstoreconnect/private_keys/` among the folders it searches. Apple's help
page "Upload builds" asks for the role Account Holder, Admin, App Manager or
Developer.

Not verified before the first delivery: that `xcodebuild` uploads with the key
from the command line. The release notes of Xcode 15 state it, as quoted in
thread 731625 of Apple's developer forums; other threads there report
failures. If the upload step fails for this reason, the script exports the
signed `.ipa` into the copy and uploads it with `xcrun altool` and the same
key. That change is a line in "History".

### Secrets and signing material

| What | Where it lives | How the delivery finds it | In git |
|---|---|---|---|
| "Apple Distribution" certificate and its private key | The login keychain of kyukhin's Mac. Xcode creates it there; it is never exported to a file | `xcodebuild` picks the identity "Apple Distribution" of the team `CLAM_TEAM_ID` | Never |
| Provisioning profile `Clam App Store` | `~/Library/Developer/Xcode/UserData/Provisioning Profiles/`, where Xcode installs profiles | By the name in `CLAM_RELEASE_PROFILE` | Never |
| App Store Connect API key `.p8` | `~/.appstoreconnect/private_keys/`, mode 600 | By the path built from `CLAM_ASC_KEY_ID`. Only `xcodebuild` opens the file: our scripts never read, copy or print it, and it does not enter the clean copy | Never |
| Team id, profile name, key id, issuer id | `Config/Local.xcconfig` in the working tree, ignored by git. None of them is a secret by itself | The delivery reads the file and passes the values on | Never |
| Bundle id `com.kyukhin.Clam` | `Config/Base.xcconfig` | | Yes: it is public in the store anyway |
| The example file | `Config/Local.xcconfig.example` | | Yes |

GitHub holds nothing of this: the repository has no Actions secrets, variables
or environments.

The delivery command takes one argument, a snapshot id. No password, key or
token is typed or passed in the environment, so none lands in the shell
history.

Three things keep signing files out of git: `.gitignore`; the `tracked-files`
check, which runs in `make check` before every commit; and GitHub's secret
scanning with push protection as the last line, for tokens in formats GitHub
recognizes. Key and certificate files are guarded by the first two. Both come
from E-03; its section "What GitHub's scanner does not see" lists every line,
the `secrets` check and the review among them.

### Not in E-01

The `MediaSource` contract and the fake source (E-02); the review and the
first checks (E-03); the license and the README (E-04); the retro look and
the real icon (E-05); Russian and Greek (E-06); background audio (E-08); the
CarPlay scene and entitlement (E-09); TDLib (M2); the privacy manifest, which
arrives with the first API that requires one; the store listing and App
Review (E-15).

## Test plan

C6 and C8 moved to E-03 whole, and so did a part of C9. Their rows keep their
numbers and name the criteria of E-03 that replaced them.

| No. | Acceptance criterion | Ticket | Proved by |
|---|---|---|---|
| C1 | `make clean-check` passes on the repository: in a clean copy, without `Config/Local.xcconfig` and with Xcode 27 as the only tool outside macOS, every step of `make check` passes | — | by hand by QA: the command and its output. Second line: the `check` job on a fresh GitHub runner |
| C2 | `make test` runs the unit tests of every module of `Packages/ClamKit` on a simulator and exits with an error when a test fails | — | unit: the tests of the version model; by hand by QA: break one assertion and see the error exit |
| C3 | `make ui-test` starts the app in a simulator and finds the three lines of the screen | — | UI test |
| C4 | `make lint` runs `swift format lint --strict` before the commands of the check tool, exits with an error on a formatting violation and passes on the repository. As in E-03, every step runs even when another failed. `make check` includes it | — | by hand by QA: add a formatting violation and a violation of one check of E-03, see both reported by one run of `make lint`, and the error exit of `make lint` and of `make check` |
| C5 | The boundary check fails on each of: a library target with a `Source…` or `Skin…` module in its dependency closure; `ClamKit` depending on the Telegram package; an import the layer table forbids; SwiftUI, UIKit or CarPlay imported by a core module; `@_exported import`. It passes on the repository | — | tool tests: one fixture per case and a clean fixture |
| C6 | Moved to E-03 whole: the `language` check is C1 there. Nothing is checked under this number in E-01 | — | E-03, C1 |
| C7 | The dependency check fails on a dependency that is not in `Config/allowed-dependencies.txt`. The file is empty and the app links no third-party code | — | tool tests on fixtures; the check on the repository |
| C8 | Moved to E-03 whole: the `tracked-files` check and `.gitignore` are C3 there, with a wider list of patterns and a size limit. Nothing is checked under this number in E-01 | — | E-03, C3 |
| C9 | When this epic is implemented, `.github/workflows/ci.yml` runs two jobs on a pull request into `master` and on a push to `master`: `check`, with the single command `make check`, which now holds every check, on `xcode-27`; and `compat`, with `make build test`, on `macos-26` with Xcode 26.6. `actions/upload-artifact` is GitHub's own action, pinned to a full commit hash. Every constraint of E-03, "Checks on GitHub", still holds for the file. The permissions, the secrets, the pinned checkout and the repository settings moved to E-03: C7 and C8 there | — | QA reads the workflow against this spec and against E-03, "Checks on GitHub". After the pull request of the task is opened: both jobs green on it prove the row. The dispatcher reads their state when it writes the report and does not wait for a run; a job that is red or not finished is named in the line "GitHub check" of the report, and kyukhin decides whether the task goes back to the developer |
| C10 | `make testflight` without `CONFIRM` prints the plan and the snapshot id and builds and uploads nothing. With `CONFIRM` it refuses, before anything is built, and names the reason in each case of "TestFlight delivery", step 1. Otherwise it makes a clean copy, stops if a check fails in it, archives Release with the UTC time as the build number, signs manually, uploads and removes the copy. The scripts do not read, copy or print the key file, and `Config/Local.xcconfig` does not enter the copy | — | tool tests on temporary git repositories: one per refusal, one clean case, the same id for the same files and another id after a change; by hand by QA: `make testflight` prints the plan and leaves no archive; QA reads the scripts. QA does not run the command with `CONFIRM` |
| C11 | A delivery puts a build into TestFlight; Clam installs from there and shows its screen | — | by hand, kyukhin and the dispatcher, see below |
| C12 | The clean copy holds every tracked file and every new file git does not ignore, with their current content, and no ignored file. `make clean-check` leaves the working tree and its index as they were. When a check fails in the copy, it exits with an error, keeps the copy and prints its path | — | by hand by QA: with an ignored file and a new unformatted Swift file in the tree, run the command, look into the kept copy and compare `git status` before and after |

C11, by hand, after K1 to K5, K7 and K8 (K6 is done), on the tree of the task
that adds the delivery, before its commit:

1. kyukhin tells the dispatcher to ship a build. The agent session asks for
   permission before the command with `CONFIRM`; kyukhin allows the one run.
   The command prints a build number.
2. kyukhin opens App Store Connect → the app → TestFlight and sees a build
   with that number.
3. On the iPhone: open TestFlight, install that build of Clam and open Clam.
4. Turn on airplane mode, close Clam in the app switcher and open it again.

Expected: the session asks before the upload; if it does not, K8 is not done.
No permission prompt on the phone at any moment. The screen shows `Clam`,
`Version 0.1.0` and `Build N`, where N is the number from step 1. In airplane
mode the screen is the same.

## Open questions

Questions 1 to 4 of the first draft are closed:

1. **The bundle id:** `com.kyukhin.Clam`, by kyukhin's answer of 2026-11-27.
2. **Where builds and checks are made:** on kyukhin's Mac; GitHub runs the
   checks that need no secrets as a second line that does not block a merge;
   by kyukhin's two answers of 2026-11-27.
3. **When a build goes to TestFlight:** only on request; not answered,
   accepted by default on 2026-11-27. Asked again at M4.
4. **kyukhin's iPhone:** an iPhone 16 with a current iOS, by kyukhin's answer
   of 2026-11-27; the minimum iOS 26.0 stands.

Question 5 is closed with option (a), by kyukhin's "yes" of 2026-11-27:

5. **Which tree a delivery may ship.** The first draft shipped only `master`.
   CLAUDE.md puts kyukhin's check on the phone before the commit of a task, so
   with that rule no task could be checked on the phone before its merge.
   Options: (a) any tree that passed every check in a clean copy, a task that
   is not committed yet included, each time on kyukhin's word; TestFlight then
   also holds builds of work that is not merged, visible to kyukhin only;
   (b) only `master`: the check on the phone moves after the merge, which
   changes the order in CLAUDE.md, and a failed check is fixed by a second
   pull request; (c) only `master` for TestFlight, and a task is checked from a
   build installed over a cable: no waiting for Apple, but it needs a
   development certificate and profile next to the distribution ones and the
   phone at the Mac. Recommendation: (a); (c) can be added by a later spec.
   By default: (a), and the spec is written for it.

## History
- 2026-11-27: first draft.
- 2026-11-27: kyukhin's answers to the four open questions recorded under
  "Decisions". The spec stays in `draft` until the architect reworks the build,
  check and delivery parts for local runs.
- 2026-11-27: reworked after kyukhin's answers. Checks and delivery moved to
  kyukhin's Mac: `make check`, `make clean-check` and `make testflight`, with
  the sections "The clean copy" and "What the Mac does not prove". GitHub
  Actions became a second line that does not block a merge and holds no
  secret; the `testflight` environment, the delivery workflow and the GitHub
  secrets are gone. The API key moved to `~/.appstoreconnect/private_keys/`
  and needs the access Developer, not App Manager; the certificate is no
  longer exported. The bundle id is `com.kyukhin.Clam`. `compat` is kept as a
  GitHub job only. A delivery ships the tree it is run in, not only `master`
  (open question 5), and is confirmed with a snapshot id. K1 now says to keep
  an Xcode 26.x; K6 lost its secrets and got the Actions settings; K8 is new.
  The check tool got the release guard. Criteria C1, C4, C9, C10 and C11 are
  rewritten, C12 is new. Open questions 1 to 4 are closed. ADR-0002 is
  accepted. The spec stays in `draft`.
- 2026-11-27: approved by kyukhin: "yes. everything as in LibreDict", in answer
  to three questions: whether the spec is approved as it is, with the caveat
  that a part of the checks moves to E-03; whether a delivery may ship any
  tree that passed every check in a clean copy; whether the dispatcher sets up
  the GitHub settings. Open question 5 is closed with (a). The GitHub settings
  follow LibreDict's and are in place (see "Decisions"). Still to be done by
  the architect, without a change of the app's behavior: the text of K6 and
  C9, and the seam with E-03.
- 2026-11-27: aligned by the architect with what was decided after the rework.
  The status stays `approved`: the edits follow kyukhin's decisions and the
  caveat of the approval. Beyond those decisions nothing changes in what
  kyukhin sees on the phone, runs on the Mac or reads on GitHub.
  - The seam with E-03 (its section "What moves from E-01 to E-03"). E-03
    creates the `Makefile`, the check tool with `language` and
    `tracked-files`, `.gitignore` and the workflow with the job `check`; this
    spec now says what it adds to them. Changed: "Read first", the first
    sentence of "Why", the "Was" column of "On the Mac and on GitHub",
    "Layout", "Commands", "Checks", "Checks on GitHub", one sentence of "The
    clean copy" and of "Secrets and signing material", "Not in E-01". Four
    entries of "Decisions" are new, and the entry about the GitHub settings
    says that K6 and C9 are aligned. C6 and C8 moved to E-03 whole (C1 and
    C3 there), and the permissions, the secrets, the pinned checkout and the
    repository settings of C9 (C7 and C8 there). The rows keep their numbers.
  - K6 is recorded as done, with the settings in force. C9 no longer names a
    linear-history rule. A fork run waits for kyukhin's approval only when it
    is the first run of a first-time contributor, not every time.
  - A red job. C9 said that a red job returns the task to the developer and
    that the dispatcher sees both jobs green before it asks to merge. It now
    follows the decision of this spec: the dispatcher names the job in the
    report, kyukhin decides, and nobody waits for a run.
  - K1 is needed before the first task of this epic, not before E-03.
  - The architect is named among those who never run the delivery with
    `CONFIRM`.
  - New details, all the architect's: the command names `boundaries`,
    `dependencies` and `release-guard`; `make lint` keeps running every step
    after a failure (C4); which paths `boundaries` and `dependencies` read
    and where their fixtures live; the exceptions of `whitespace` for files
    that Xcode writes; the formatter covers the sources of the tool; the time
    limits of the two jobs, 30 and 20 minutes; no path filter in
    `.coderabbit.yaml`.
- 2026-11-28: the plan and the tasks moved from files of the repository to
  GitHub, on kyukhin's words: "This does not fit, it is all wrong. We must
  work by milestones, epics and tasks in them." References are updated, with
  no change of behavior or design; the status stays `approved`. The header
  names the epic issue, #6, and says "Tickets"; the column of the test plan
  is "Ticket". "Why" and "The clean copy" name milestone M0 on GitHub, where
  the text of the roadmap is now. "What kyukhin does by hand, once" names the
  issues of K1 to K5, K7 and K8. The entry of "Decisions" that cites the
  roadmap keeps its wording; those words of kyukhin are now in the epic issue
  of E-03, #8.

# Overview

> As of 2026-11-28. **The first checks exist; nothing of the app does.** The
> repository holds a `Makefile` and the Swift package of the check tool, and no
> Xcode project and no app code.

Read this file before every task. Each part below is marked **exists** or
**decided**. A decided part names the document that owns it and the epic that
makes it real; this file does not repeat that document. The statuses of tasks
and specs are not here: `docs/plan/BOARD.md` and the index in
`docs/specs/README.md` own them.

## What exists

| What | Where | Note |
|---|---|---|
| The kit | `CLAUDE.md`, `.claude/agents/`, `.claude/skills/` | The pipeline of roles, its gates and the git rules |
| Product and plan | `docs/product/PRD.md`, `docs/plan/ROADMAP.md`, `docs/plan/BOARD.md` | The milestone is M0; its order is E-03, E-01, E-04, E-02 |
| Decisions | `docs/architecture/adr/`: ADR-0001 (stack), ADR-0002 (modules), ADR-0005 (review) | All accepted on 2026-11-27. The numbers 0003 (the source contract) and 0004 (track identity and the position store) are kept for E-02 |
| Specs | `docs/specs/`: E-01, E-03 | Both approved on 2026-11-27, neither implemented |
| `LICENSE` | the root | MIT |
| `README.md` | the root | Describes the kit, not the app. E-04 rewrites it |
| `.gitignore` | the root | Written before the stack was chosen; TASK-002 added the lines for the tool's build output and the editor's files. TASK-004 rewrites it |
| `Makefile` | the root | `lint`, `test-tools`, `check`. Spec E-03, "Commands" |
| `Tools/ClamChecks` | | The check tool `clam-checks`: a Swift package for macOS with tests, no dependency. It has the command `whitespace`; the other three wait for TASK-004. Spec E-03, "The check tool" |
| `.github/workflows/ci.yml` | | The workflow with the job `check`, which runs `make check` on the `xcode-27` runner for a pull request into `master` and a push to `master`. The job `compat` is decided for E-01. Spec E-03, "Checks on GitHub: the second line" |
| `.coderabbit.yaml` | the root | The settings of the review bot. Spec E-03, "`.coderabbit.yaml`". The bot reads it only after kyukhin adds `clam` to its installation (spec E-03, H1) |
| The repository `kyukhin/clam` on GitHub | | Public. Its settings are in force, see "GitHub" |

Not there yet: `docs/architecture/CONTRACTS.md` (E-02) and `CHANGELOG.md` (the
first task that changes something for the user creates it).

## Commands

**Exists:** `make lint`, `make test-tools` and `make check` (spec E-03,
"Commands"). `make lint` runs the check `whitespace`; `make test-tools` runs the
tests of the tool; `make check` prints the Swift version, then runs both. The
developer runs `make check`. The other three checks of E-03 (language, files
that must not be tracked, secrets) are decided and wait for TASK-004. The skills
of QA (steps 11 and 12) and of the committer ("File hygiene" and "Final check
before the commit") still hold their own commands; the dispatcher changes them.

**Decided:**

| Commands | Owner | Made real by |
|---|---|---|
| The three checks of the files that `make lint` does not run yet: language, files that must not be tracked, secrets | spec E-03, "The four checks" | TASK-004 |
| `make build`, `make test`, `make ui-test`, `make format`, `make archive`, `make clean-check`, `make testflight`. `make lint` and `make check` grow: the formatter, the boundary and dependency checks, the build, the tests, the archive | spec E-01, "Commands" | E-01 |

Who runs what, once it exists. The developer: `make check`. QA and the
committer's final check: `make check` after E-03, `make clean-check` after
E-01. `make testflight CONFIRM=…` uploads a build to TestFlight: only the
dispatcher runs it, on kyukhin's word for that one build, and no subagent ever
does (spec E-01, "Getting a build into TestFlight").

## Stack

**Decided,** ADR-0001; nothing of it is in the repository. Native Swift in
language mode 6, SwiftUI, AVFoundation, CarPlay templates, SwiftPM only; Xcode
27; minimum iOS 26.0, iPhone only; no third-party code except TDLib, which
arrives in M2. The reference is the table under "What the decision fixes" in
ADR-0001.

kyukhin's Mac on 2026-11-27: macOS 26.5.2 with Xcode 26.4. The check tool of
E-03 builds with it. E-01 needs Xcode 27 before its first task (spec E-01,
K1).

## Modules

**Exists:** none. **Decided,** ADR-0002: the layers, what each module may
import, the eight rules and how a violation is caught. Read its sections "The
graph" and "Rules" before designing or writing a module.

| Modules | Made real by |
|---|---|
| The app target `Clam`; `Localization` and `FeatureAbout` in `Packages/ClamKit` | E-01 |
| `SourceAPI`, `SourceFake` | E-02, with ADR-0003 and `CONTRACTS.md` |
| `DesignSystem`, `SkinRetro` | E-05 |
| `CarPlayUI` | E-09 |
| `SourceTelegram`, in its own package `Packages/SourceTelegram` | M2 |
| `LibraryCore`, `PlayerCore`, `PositionStore`, `ListeningCore`, further `Feature…` | The epic that fills each; its spec says so |

The invariant behind the layers (CLAUDE.md, invariant 1): nothing except the
app target depends on a concrete source. CLAUDE.md and the skills use general
names; in this project `source-api`, `source-fake` and `source-telegram` are
`SourceAPI`, `SourceFake` and `SourceTelegram`, `core-*` is the Core layer,
`feature-*` is `Feature…`, and `app` is the app target `Clam`.

## Screens and data

**Exists:** none. **Decided:** one screen with three lines of text, and no
stored data (spec E-01, "On the phone"); E-01 makes it real. The mockups of
the real screens come with the spec of E-05. The source contract, the track
key and the position store are not designed yet: ADR-0003, ADR-0004 and
`CONTRACTS.md` come with E-02.

## Localization paths

**Decided,** ADR-0001, row "Languages"; none of the paths exists yet. Russian
and Greek text lives only here (CLAUDE.md, "Language"):

- `Packages/ClamKit/Sources/Localization/Resources/Localizable.xcstrings`
- `App/InfoPlist.xcstrings`
- `AppStore/metadata/ru/`
- `AppStore/metadata/el/`

The base language is English. These are the paths to exclude in the language
commands of the QA and committer skills. From E-03 on the `language` check
holds the same list.

## Secrets

**Exists:** nothing secret, in the repository or on GitHub. **Decided:** where
the signing material, the App Store Connect key and the local settings live,
all on kyukhin's Mac and outside git: spec E-01, "Secrets and signing
material". What keeps a secret out of git, line by line: spec E-03, "What
GitHub's scanner does not see". The Telegram keys get their place in the spec
that brings them (M2).

## GitHub

| Part | State | Owner |
|---|---|---|
| The repository settings: a ruleset `master` (a pull request required, merges by rebase only, no required check), secret scanning with push protection, Dependabot, a read-only Actions token, no Actions secrets | **Exists,** in force since 2026-11-27 | spec E-03, "GitHub settings" |
| The workflow `.github/workflows/ci.yml` with the job `check`, later also `compat` | `check`: **Exists** (TASK-003), its first run is the one on the pull request of that task. `compat`: **Decided,** E-01 adds it | specs E-03 and E-01, "Checks on GitHub: the second line" |
| The review of every pull request by CodeRabbit | **Decided.** E-03 makes it real. Its settings file `.coderabbit.yaml` exists (spec E-03, "`.coderabbit.yaml`"). The bot sees `clam` only from H1, when kyukhin adds the repository to its installation; H1 waits for the pull request with that file (spec E-03, H1) | ADR-0005; the steps are in CLAUDE.md, "Review of a pull request" |

The jobs and the review are a second line, and neither is required for a
merge. The checks on kyukhin's Mac decide whether a task is done, and
kyukhin's "yes" merges.

## Keeping this file current

The architect updates this file when an epic becomes `implemented`. A task
that first creates a command, a module or a path named here has this file in
its change scope and updates that part in the same commit. Move a part from
"decided" to "exists", keep the pointer to its owner and do not copy the
owner's text.

When E-03 is implemented:

- The opening note: the checks exist, the app still does not.
- "What exists": the `Makefile`, `Tools/ClamChecks`, the workflow,
  `.coderabbit.yaml`, the rewritten `.gitignore`.
- "Commands": the three commands exist; the sentence about the commands of
  the skills goes.
- "GitHub": the workflow and the review exist. Say whether the bot starts by
  itself on `clam` and how many reviews an hour it gives (spec E-03, C10).

When E-01 is implemented:

- The opening note: the app builds and reaches the phone; what it shows.
- "What exists": the layout of the repository (spec E-01, "Layout").
- "Commands": every command exists; who runs `make clean-check`.
- "Stack": the Xcode versions installed on the Mac.
- "Modules": one diagram of the modules that exist and a paragraph for each:
  the app target, `Localization`, `FeatureAbout`.
- "Screens and data": the one screen.
- "Localization paths": which of the four exist.
- "Secrets": `Config/Local.xcconfig` and its example file.
- "GitHub": the job `compat`.

After these two the file changes next with E-04 (the README and building with
one's own keys) and with E-02 (`CONTRACTS.md`, the first source modules, the
first sound).

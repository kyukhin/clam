# QA: TASK-002

## Check 1 — 2026-11-28 — FAIL

Checked: the uncommitted tree on a detached HEAD at `48c53c7`, the tip of
`kyukhin/001-coderabbit-config` (kyukhin, 2026-11-28: TASK-002 is worked on
top of it). The task's changes: untracked `Makefile` and
`Tools/ClamChecks/` (manifest, 8 sources, 4 test files), and edits to
`.gitignore`, `docs/product/PRD.md`, `docs/architecture/OVERVIEW.md`,
`docs/specs/E-03-automated-code-review.md`,
`docs/tasks/TASK-002-check-tool.md` and `docs/plan/BOARD.md`. Spec E-03 is
approved (2026-11-27). Machine: Xcode 26.4 (17E192), Swift 6.3
(swiftlang-6.3.0.123.5), GNU Make 3.81, git 2.49.0, macOS 26.7.3.

### Build and tests
| Command | Result | Tests | Warnings |
|---|---|---|---|
| `xcodebuild -version` | Xcode 26.4, build 17E192 | n/a | n/a |
| `make check` | exit 0. Line 1 of standard output is `Apple Swift version 6.3 (swiftlang-6.3.0.123.5 clang-2100.0.123.102)`, then the build of `clam-checks`, `whitespace` with no output, then the tests | 72 tests in 3 suites passed, 0 failed (Swift Testing); XCTest: 0 tests | 0 |
| `make lint` | exit 0, nothing from the tool on standard output or standard error | n/a | 0 |
| `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 make test-tools` | exit 0 | 72 passed | 0 |
| From scratch, outside the repository: `swift build --package-path Tools/ClamChecks --scratch-path $TMPDIR/... --build-tests` without `-warnings-as-errors`, then `swift test ... -Xswiftc -warnings-as-errors` | exit 0 and exit 0; all 12 sources and the manifest compiled | 72 passed | 0 (`grep -ci warning` on the whole log) |
| The same build, test and `clam-checks whitespace` under `sandbox-exec` with outbound IP denied (`--disable-sandbox` for SwiftPM, because a nested sandbox is refused); `curl https://example.com` under the same profile fails with exit 7 | all exit 0 | 72 passed | 0 |
| `make check` again after all mutations were restored | exit 0 | 72 passed | 0 |
| `swift format lint --strict` on the package (not a criterion; E-01's) | exit 0, no output | n/a | 0 |

Regressions: there is no other test suite in the repository; no playback,
position or `MediaSource` code exists. The player checklist does not apply.

### Acceptance criteria
| Criterion | Row of the spec's plan | How checked | Result | Proof |
|---|---|---|---|---|
| AC1: the checked set | C5 | Read the tests and `GitRepository`/`CheckedFile`; mutations M5, M7, M12; manual runs of the built binary on temporary repositories | **FAIL** | The named tests pass and the mutations of `--cached`, `--exclude-standard` and the deleted-file branch are caught. But a tracked file under a folder that was replaced by a symbolic link is not skipped: git reports it deleted (`git status`: `AD d/f.txt`, `?? d`; `git add -A` would commit only the link `d`), and the tool reports `d/f.txt:1:2: whitespace: W1 ...` from the file the link points to. See B1 |
| AC2: binary files and links | C5 | Tests, mutations M8 and M11, manual runs | **FAIL** | NUL detection and the four link tests are sound. "A symbolic link is never opened ... and so does a link to a directory" does not hold when the link stands in a leading component of a path from the index: the tool reads a file outside the repository through it. With a link to a folder inside the repository the same file is reported twice (`d/f.txt` and `e/f.txt`). See B1 |
| AC3: output and exit status | C5 | Tests (`OutputAndExitStatusTests`); mutations M3, M9, M10; the built binary with the two streams redirected to separate files | PASS | Binary: unknown command, no command, two arguments, a directory outside any repository (with and without `GIT_CEILING_DIRECTORIES`): exit 2, 0 bytes on standard output, the message on standard error. A temporary repository with violations: exit 1, the three lines on standard output (`b.txt: whitespace: W5 ...`, `b.txt:1:2: whitespace: W2 tab`, `it's é dir.txt:1:2: whitespace: W1 ...`), standard error empty. The same plus a file with mode 000: exit 2, the same three lines on standard output, `clam-checks: locked.txt: cannot read: Permission denied` on standard error. This also proves the wiring in `main.swift` to descriptors 1 and 2, which has no automated test. The repository root and `Tools/ClamChecks/Sources` as working directory: exit 0, both streams empty |
| AC4: W1 to W6 | C2 | `WhitespaceRuleTests` read case by case; mutations M1 to M4 | PASS | Every rule has at least one test with an exact expected line; W5 both cases and their two messages; `Makefile`, `sub/Makefile`, `rules.mk`, `sub/dir/rules.mk` pass with a tab, six look-alike names do not; empty file, `"\n"` and `"a\n"` pass; `theCheckRewritesNothing` compares the bytes after the run |
| AC5: `make lint` on the repository, the PRD, `.gitignore` | C2 | Commands below; an independent perl implementation of W1 to W6 over `git ls-files -z --cached --others --exclude-standard` | PASS | `make lint` exit 0. `{ git show HEAD:docs/product/PRD.md; printf '\n'; } \| cmp - docs/product/PRD.md` prints nothing, exit 0; `git diff --numstat`: `1 1`; last bytes at HEAD `22207c`, now `207c0a`. `git diff HEAD -U0 -- .gitignore`: four `+` lines (`.build/`, `.swiftpm/`, `.#*`, `\#*#`), no `-` line, numstat `4 0`. Perl cross-check: 56 text files, 0 violations. By hand: `printf 'x \n' > zz-ws.txt` → `make lint` printed `zz-ws.txt:1:2: whitespace: W1 trailing space or tab` on standard output and exited 2 (`make: *** [lint] Error 1`); file removed → exit 0 |
| AC6: the three commands | C6 | Read `Makefile` and the manifest; commands; manual steps | PASS | `make check` prints the Swift version first, runs `lint` then `test-tools` (sub-makes). Every check runs after a failed one: `make lint CHECKS="bogus whitespace"` with `zz-ws.txt` present printed the error for `bogus` on standard error and still the `whitespace` line on standard output, exit 2; `CHECKS="whitespace bogus"` exit 2; file removed afterwards. Warning: `let qaUnused = 1` added to `Violation.swift` → `make check` exit 2 with `error: initialization of immutable value 'qaUnused' was never used`, no test ran; the file was restored from a copy and `cmp` reported no difference. No dependency in the manifest, no `Package.resolved`, no download in the `Makefile`; the run without network passed (table above). Fixtures: every violating fixture is built in `TemporaryRepository` under `NSTemporaryDirectory()` and removed in `deinit`; after all runs `ls -d $TMPDIR/clam-checks-*` finds 0 directories |
| OVERVIEW is current | — | Read the diff | PASS | Opening note: "The first checks exist; nothing of the app does", no workflow. "What exists": rows `Makefile` and `Tools/ClamChecks`, each with a pointer to the spec. "Commands": the three exist, `make lint` runs `whitespace`, the other three are decided and wait for TASK-004 |
| All tests pass; `make check` green, no new warnings | — | Table above | PASS | 72/72, 0 warnings, also from a clean build |

### Test quality and mutations
The tests are of substance: they assert exact output lines, both streams and
the exit status; edge cases are covered (empty repository, deleted file,
deleted folder, a nested repository, a non-ASCII and quoted path, unreadable
file, CR before LF, BOM, seven kinds of invalid UTF-8). No network, no `sleep`,
no disabled test (one test is skipped only when run as root, with the reason).
The tests filter out every `GIT_*` variable and give git its own `HOME`, XDG
folder and `GIT_CONFIG_GLOBAL=/dev/null`; they pass with the user's settings on
and off.

Each mutation: the file copied to `$TMPDIR`, one change made, `swift test`
with a scratch build path outside the repository, the copy put back and
compared with `cmp` (identical every time; at the end `shasum -c` over all
sources: all OK).

| No. | Mutation | Tests that failed |
|---|---|---|
| M1 | W5: "second to last byte is LF" → "is CR" | `w5MoreThanOneLineFeedAtTheEnd`, `w5ThreeLineFeedsAtTheEnd`, `w5FileOfTwoLineFeeds`, `w5TheMessageSaysWhichOfTheTwoCasesItIs`, 2 more |
| M2 | W2 exception suffix `.mk` → `mk` | `w2PathsThatAreNotExempt` (the case `mk`) |
| M3 | W1 column without `+ 1` | 15 tests, among them every `w1…` test |
| M4 | W6: the `0xED` second-byte range widened (surrogates accepted) | `w6InvalidUTF8` (the case "a surrogate") |
| M5 | `ls-files` without `--cached` | `aFileThatIsTrackedAndIgnoredIsStillChecked`, `aTrackedFileIsCheckedWithTheContentItHasOnDiskNow`, 2 more |
| M6 | missing file: skip only `ENOENT`, no longer `ENOTDIR` | **none: survived** (N1) |
| M7 | missing file: skip only `ENOTDIR`, no longer `ENOENT` | `aTrackedFileDeletedFromTheWorkingTreeIsSkippedWithoutAnError`, `aTrackedFileInADeletedFolderIsSkippedToo` |
| M8 | NUL detection removed | `aFileWithANulByteIsBinaryAndItsContentIsNotChecked`, `aNulByteAtTheVeryEndStillMakesTheFileBinary` |
| M9 | an unreadable file no longer sets status 2 | `exitStatusIsTwoForAFileThatCannotBeRead` |
| M10 | a whole-file violation sorts after the lines | `aViolationOfAWholeFileSortsBeforeTheLinesOfItsFile`, `linesAreSortedByPathAndThenByLine`, 2 more |
| M11 | `lstat` → `stat` | `aLinkToAFileWithViolationsOutsideTheCheckedSetPasses` |
| M12 | `ls-files` without `--exclude-standard` | 5 tests, among them `aFileThatGitIgnoresIsNotChecked`, `gitInfoExcludeIsHonored`, `theGlobalExcludesFileIsHonoredBecauseGitDecides` |

The main criteria are proved by tests that can fail, except the case of B1,
which no test covers, and the `ENOTDIR` branch (N1), whose behavior is right
when tried by hand: a tracked `a/b.txt` with the folder `a` replaced by a
regular file gives exit 0 and no output.

### Change scope, spec and invariants
`git status --short --untracked-files=all`: `Makefile`, the 13 files under
`Tools/ClamChecks/` and the six modified files listed above; nothing else.
`Tools/ClamChecks/.build/` and both editor files in `docs/plan/` are ignored
(`git check-ignore -v`: `.gitignore:25:.build/`, `.gitignore:27:.#*`,
`.gitignore:28:\#*#`, also with `GIT_CONFIG_GLOBAL=/dev/null`); `.swiftpm/`
matches line 26. The task file changed only in its status, the checkboxes and
the developer notes. The OVERVIEW diff stays in the opening note, "What
exists" and "Commands". The spec diff: the header date, the cells "Proved by"
of C2, C5 and C6, one line in "Design", one line in "History". BOARD.md: the
dispatcher's lines and the developer's log rows. Nothing in `CLAUDE.md`,
`.claude/`, `.coderabbit.yaml`, `.github/`, `README.md`.

The spec change (exit status 2 when a file of the set cannot be read), judged
by rule 4 of `docs/specs/README.md`: a small implementation detail. It is not
visible to the user of the app; it changes no data model, storage, module
boundary, contract or dependency; `make lint` treats 1 and 2 alike; it keeps
the spec's own meaning of 2 ("the tool could not do its job") for a case the
spec left open; the History line is there. The status may stay `approved`.
The PR description needs the note "spec changed".

Invariants: the task adds no app module, no source and no position code, so
invariants 1 to 3 are not touched. Invariant 4: see below.

Observation, not a finding: on macOS git precomposes Unicode names
(`core.precomposeunicode=true` by default), so a file whose name is stored
decomposed on disk (`e` + U+0301) is reported in the composed form. That is
the name git commits, and the file is still found and checked.

### Security and language
`git diff HEAD -U0 | perl -CSD -ne 'print if /\p{Cyrillic}|\p{Greek}/'`
prints nothing; the same over every untracked file prints nothing; the
untracked files hold no byte above 0x7F (non-ASCII test letters are built from
code points in `Letters`). A search of the diff and the new files for
`api_hash`, `api_id`, private key headers, tokens, passwords, 32-hex runs and
long digit runs finds only prose in the documents. No `*.db`, key, profile,
session or `Package.resolved` file. No new secret file type, so `.gitignore`
needs nothing more for this task.

### Findings
Blocking (the reason for FAIL):

- **B1. A symbolic link in a leading component of a path is followed.**
  `CheckedFile.inspect` uses `lstat` on the full path and `readContent` opens
  it with `O_NOFOLLOW`; both stop only a link in the last component. When a
  tracked folder is replaced by a link, `git ls-files --cached` still lists
  the old paths under it, and the tool resolves them through the link.
  Reproduction with the built binary, in a temporary repository with
  `GIT_CONFIG_GLOBAL=/dev/null`:
  ```
  mkdir d && printf 'ok\n' > d/f.txt && git add d
  rm -r d && ln -s "$OUTSIDE" d        # $OUTSIDE/f.txt holds "y \n"
  clam-checks whitespace
  # d/f.txt:1:2: whitespace: W1 trailing space or tab   (exit 1)
  ```
  `git status` shows `AD d/f.txt` and `?? d`; `git add -A` on a copy of the
  index stages only `120000 ... d`. So the spec's checked set ("what a commit
  of the working tree would hold"; "a tracked file that is deleted in the
  working tree is not in the set") does not hold `d/f.txt`, and "a symbolic
  link is ... never opened" (spec, "The check tool"; AC2) is broken: the tool
  reads a file outside the repository through the link. With `d -> e` inside
  the repository, `e/f.txt` is reported twice. TASK-004 builds `language`,
  `tracked-files` and `secrets` on this same code, so they would read and
  report outside files under repository paths. Expected: such a path is
  skipped like any deleted tracked file, without an error, and a test covers a
  link to a folder outside and inside the repository. The way to do it is the
  developer's choice (note that macOS has `O_NOFOLLOW_ANY` for `open` and
  `AT_SYMLINK_NOFOLLOW_ANY` for `fstatat`; only components below the root are
  in question).

Non-blocking (task proposals; the first fits the same fix round):

- **N1.** The `ENOTDIR` branch of `CheckedFile.inspect` has no test
  (mutation M6 survived). A test: a tracked `a/b.txt`, then the folder `a`
  replaced by a regular file; expected exit 0 and empty streams.
- **N2.** Outside this task's scope, for the board owner: this Mac runs macOS
  26.7.3, while OVERVIEW ("Stack") and the board ("External dependencies":
  "Update the Mac to macOS 26.6 or a later 26.x and install Xcode 27") assume
  26.5.2. The macOS half of that item looks done; Xcode is still 26.4.

One summary line for the PR: `QA: unit 72 pass, 0 warnings, make check green; 11 of 12 mutations caught; FAIL on B1 (link in a leading path component is followed)`

## Check 2 — 2026-11-28 — PASS

Checked: the same uncommitted tree on `48c53c7` after the developer's fix of
B1 and N1. What changed since check 1: `CheckedFile.swift` (`fstatat` with
`AT_SYMLINK_NOFOLLOW_ANY` and `openat` with `O_NOFOLLOW_ANY` against a
descriptor of the root, which `openRoot` opens once per `inspect` and once per
`readContent`; `ELOOP` joins `ENOENT` and `ENOTDIR` as "skip"), five new tests
in `CheckedSetTests`, the spec, the task notes and the board. Nothing of
check 1 is carried over: every command and step below was run again.

### Build and tests
| Command | Result | Tests | Warnings |
|---|---|---|---|
| `xcodebuild -version` | Xcode 26.4 | n/a | n/a |
| `make check` | exit 0; line 1 of standard output `Apple Swift version 6.3 (swiftlang-6.3.0.123.5 clang-2100.0.123.102)` | 77 in 3 suites passed, 0 failed | 0 (`grep -ci warning` on both streams) |
| `make lint` | exit 0; nothing from the tool on either stream | n/a | 0 |
| `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 make test-tools` | exit 0 | 77 passed | 0 |
| From scratch outside the repository: `swift build --scratch-path $TMPDIR/... --build-tests` without `-warnings-as-errors` (13 compile steps), then `swift test ... -Xswiftc -warnings-as-errors` | exit 0, exit 0 | 77 passed | 0 |
| Build, test and `clam-checks whitespace` under `sandbox-exec` with outbound IP denied (`--disable-sandbox` for SwiftPM; `curl` under the same profile: exit 7) | all exit 0 | 77 passed | 0 |

Regressions: no other suite exists; the player checklist does not apply.

### Acceptance criteria
| Criterion | Row of the spec's plan | How checked | Result | Proof |
|---|---|---|---|---|
| AC1: the checked set | C5 | Tests; mutations N4 to N6, R2; the built binary on temporary repositories (S1 to S10, R1 to R6 below) | PASS | B1 reproduction, both variants: S1 (`d` → absolute link to a folder outside with `f.txt` = `"y \n"`; `git status`: `AD d/f.txt`, `?? d`): exit 0, both streams empty; S2 (the same, relative link `../outside`): exit 0, empty. S3 (`d` → `e` inside, `e/f.txt` violating): exit 1, one line `e/f.txt:1:2: whitespace: W1 trailing space or tab`, nothing under `d/`. Deleted file, deleted folder and the folder replaced by a file (`aTrackedFolderReplacedByAFileIsSkippedWithoutAnError`) pass |
| AC2: binary files and links | C5 | Tests; mutations N1, N3, N4, N7, R3; edge cases by hand | PASS | S4: `a/b` of a tracked `a/b/c/d/f.txt` replaced by a relative link `../../outside` to a violating file: exit 0, empty. S5: a leading folder replaced by a link to a regular file: exit 0, empty. S6: a leading folder replaced by a link to itself (`d -> d`): exit 0, empty. S7: two links pointing at each other in a leading position: exit 0, empty. S8: a tracked last component that is a link to itself: exit 0, empty. S9: a tracked link to an outside file with a violation: exit 0, empty. A link in the last component is still reported as a link and never opened (N7) |
| AC3: output and exit status | C5 | Tests; mutation R4; the built binary with the streams in separate files | PASS | Unknown command, no command, a folder outside any repository: exit 2, 0 bytes on standard output, the message on standard error. The repository: exit 0, both streams empty. S10: a tracked file in a folder with mode 000 next to a violating `v.txt`: exit 2, `v.txt:1:2: whitespace: W1 ...` on standard output, `clam-checks: p/f.txt: cannot read: Permission denied` on standard error, so `EACCES` is not swallowed by the new skip |
| The root reached through links (asked by the brief) | C5 | The built binary | PASS | R1: the repository root itself reached through an absolute link; R2: a subfolder through that link; R3: a link above the root (`parentlink/repo/sub`); R4: a relative link to the root; R5: a logical working directory with `PWD` naming the link path. Each: exit 1 and the same three lines (`sub/s.txt`, `tracked.txt`, `untracked.txt`), paths relative to the root. R6: this repository through a link to it, run in `Tools`: exit 0. The whole temporary tree also lies under `/var`, itself a link to `/private/var` |
| AC4: W1 to W6 | C2 | Tests unchanged; mutation R1 | PASS | As in check 1; R1 caught |
| AC5: `make lint`, the PRD, `.gitignore` | C2 | Commands; the perl cross-check of check 1 run again | PASS | `make lint` exit 0. `{ git show HEAD:docs/product/PRD.md; printf '\n'; } \| cmp - docs/product/PRD.md`: no output, exit 0; numstat `1 1`. `.gitignore`: numstat `4 0`, the `+` lines `.build/`, `.swiftpm/`, `.#*`, `\#*#`. Perl: 57 text files (one more: this report), 0 violations. By hand: `zz-ws.txt` with `x \n` → `make lint` printed `zz-ws.txt:1:2: whitespace: W1 trailing space or tab`, exit 2; removed → exit 0 |
| AC6: the three commands | C6 | Commands; manual steps | PASS | Version first, then `lint`, then `test-tools`. `make lint CHECKS="bogus whitespace"` with `zz-ws.txt`: the error for `bogus` on standard error and still the `zz-ws.txt` line, exit 2. `let qaUnused = 1` in `Violation.swift` → `make check` exit 2 with `error: initialization of immutable value 'qaUnused' was never used`, no test ran; restored, `cmp` identical. No dependency, no `Package.resolved`, no download; the run without network passed. No `clam-checks-*` folder is left under `$TMPDIR` after all runs |
| OVERVIEW is current | — | Diff | PASS | Unchanged since check 1, still correct |
| All tests pass; `make check` green, no new warnings | — | Table above | PASS | 77/77, 0 warnings |

### Test quality and mutations
The five new tests assert the exit status and both streams; the folder
outside the repository holds a violating file, so a test fails if the file is
read; the test of a link inside the repository asserts exactly one line under
the target's path; the leading-link test runs at three depths. Each mutation:
copy to `$TMPDIR`, one change, `swift test` with a scratch build path outside
the repository, copy put back, `cmp` identical; at the end `shasum -c` over
every source and test file: all OK. (Three first attempts at N1 to N3 did not
build, because the scratch path was reached once as `/var/...` and once as
`/private/var/...`; they were thrown away and run again with a fresh scratch
path. Only the reruns are below.)

| No. | Mutation | Tests that failed |
|---|---|---|
| N1 | `fstatat` flag `AT_SYMLINK_NOFOLLOW_ANY` → `AT_SYMLINK_NOFOLLOW` | the three cases of `aLinkInTheMiddleOfALongerPathIsSkipped`, `…ReplacedByALinkToAFolderOutsideTheRepositoryIsSkipped`, `…InsideTheRepositoryReportsTheFileOnce` (10 issues) |
| N2 | `openat` flag `O_NOFOLLOW_ANY` → `O_NOFOLLOW` | none: survived. Expected: `fstatat` already rejects a link in a leading component, so this flag only matters if the path changes between the two calls. The developer's notes call it the second guard. Not a finding |
| N3 | both flags back to the check-1 ones (the original bug) | the same four tests as N1 (10 issues) |
| N4 | `ELOOP` no longer skipped | the leading-link tests and `aTrackedFolderReplacedByADanglingLinkIsSkipped` (12 issues) |
| N5 | `ENOTDIR` no longer skipped (M6 of check 1) | `aTrackedFolderReplacedByAFileIsSkippedWithoutAnError`. **The survivor of check 1 is caught now** |
| N6 | `ENOENT` no longer skipped | `aTrackedFileDeletedFromTheWorkingTreeIsSkippedWithoutAnError`, `aTrackedFileInADeletedFolderIsSkippedToo` |
| N7 | a link in the last component treated as a regular file | `aDanglingLinkPasses`, `aLinkToADirectoryPasses`, `aLinkToAFileWithViolationsOutsideTheCheckedSetPasses` and the leading-link tests (18 issues) |
| R1 | W5: "second to last byte is LF" → "is CR" | `w5FileOfTwoLineFeeds`, `w3CarriageReturnAtTheEndOfEveryLine`, `w1SpaceBeforeACarriageReturnIsTrailing` and more |
| R2 | `ls-files` without `--exclude-standard` | `aFileThatGitIgnoresIsNotChecked` and more |
| R3 | NUL detection removed | both NUL tests |
| R4 | an unreadable file no longer sets status 2 | `exitStatusIsTwoForAFileThatCannotBeRead` |

### The two flags in the SDK
What this Mac shows: `MacOSX26.4.sdk/usr/include/sys/fcntl.h` defines
`O_NOFOLLOW_ANY 0x20000000` (line 158) and `AT_SYMLINK_NOFOLLOW_ANY 0x0800`
(line 184). Both are plain macros inside `#if __DARWIN_C_LEVEL >=
__DARWIN_C_FULL`, which is the default level, with no `API_AVAILABLE` or other
availability annotation. `man 2 open` and `man 2 stat` describe both and give
`ELOOP` for a link met during resolution; `fstatat` with
`AT_SYMLINK_NOFOLLOW_ANY` returns the status of the link itself when the path
names one. The kernel of this Mac (macOS 26.7.3) honours both: N1, N3 and the
manual runs show it. The manifest's floor is macOS 14.

Unproved here: that the Xcode 27 SDK still declares both macros (the `check`
job of TASK-003 shows it). Also unproved: the developer's claim that the flags
"belong to the macOS 13 API". The header gives no version, so this SDK cannot
show that the flags predate the floor of macOS 14; Apple's documentation
would settle it. Every machine that runs the tool today (this Mac, the
`xcode-27` runner) is far above that floor.

### Change scope, spec and invariants
`git status --short --untracked-files=all`: the same files as in check 1, plus
this report; `git diff HEAD --stat` lists only `.gitignore`, OVERVIEW, BOARD,
PRD, the spec E-03 and the task file. The task file lost only its status line,
its checkboxes and the placeholder of the notes. Nothing in `CLAUDE.md`,
`.claude/`, `.coderabbit.yaml`, `.github/` or `README.md`. The editor files
and `.build/` are still ignored (`git check-ignore -v`: `.gitignore` lines 28,
27, 25).

The new spec change, judged by rule 4 of `docs/specs/README.md`: a small
implementation detail. The sentence in "The checked set" ("neither is a
tracked path that lies below a symbolic link ... a commit of the working tree
would hold the link, not the path") states a case that the approved text
already decided: "what a commit of the working tree would hold", "a tracked
file that is deleted in the working tree is not in the set" and "a symbolic
link is ... never opened". It is not visible to the user of the app and
changes no data model, storage, module boundary, contract or dependency. It
has its History line, and the test names are in the "Proved by" cell of C5.
The status may stay `approved`; the PR description carries "spec changed".
The judgment of check 1 on the exit status 2 stands.

Invariants 1 to 3 are not touched. Invariant 4: see below.

### Security and language
`git diff HEAD -U0` and every untracked file: no Cyrillic or Greek; the
untracked files under `Makefile` and `Tools/` hold no byte above 0x7F. No
private key header, no 32-hex run, no `api_id`/`api_hash` value; no `*.db`,
key, profile, session or `Package.resolved` file.

### Findings
Blocking: none. B1 and N1 of check 1 are fixed and proved.

Non-blocking (task proposals):
- N2 of check 1 stands as it was (the macOS version in OVERVIEW and the
  board). Outside this task.

One summary line for the PR: `QA: unit 77 pass, 0 warnings, make check green; 14 of 15 mutations caught (the survivor is the redundant second guard), B1 and N1 of check 1 fixed`

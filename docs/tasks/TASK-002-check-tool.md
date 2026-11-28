# TASK-002: Create the check tool with the `whitespace` check, and `make check`

Epic: E-03 | Milestone: M0 | Status: done
Depends on: none
Complexity: normal
Spec: docs/specs/E-03-automated-code-review.md § "Layout", "Commands", "The check tool", "The four checks" (`whitespace` and the last paragraph), test plan C2, C5 and C6 (approved 2026-11-27)
Basis: ADR-0001 (rows "Toolchain", "Tests" and "Lint"), ADR-0005 (the checks on the Mac are the main line)

## Goal
The repository gets its first command that decides whether a change is clean:
`make check`. It runs the check tool `clam-checks` over what git would commit
and then the tests of the tool. The first check is `whitespace`. After this
task the developer, QA and the committer run one command for whitespace
instead of the commands of their skills.

## Context
- **Order.** The task has no dependency and can be worked while TASK-001 is.
  Its branch is cut after TASK-001 is in `master`, so that the bot reads
  `.coderabbit.yaml` from the head of this pull request (spec, "When to do
  H1").
- **Toolchain.** kyukhin's Mac has Xcode 26.4 (Swift 6.3) on macOS 26.5.2,
  GNU Make 3.81 and git 2.49. The job on GitHub (TASK-003) builds the same
  package with Xcode 27 (Swift 6.4). The manifest declares a tools version
  that Swift 6.3 accepts. Xcode 27 does not run on this macOS (ADR-0001, L1)
  until kyukhin has updated the Mac, which is K1 of E-01; nothing of this
  task is tried with it here.
- **The package.** One product, the executable `clam-checks`; no
  dependencies; Swift language mode 6; macOS only. How the code is split into
  targets inside the package, so that the tests reach it, is your choice. The
  tests use Swift Testing, not XCTest. The package gets no `.gitignore`, no
  README and no other file of a template: the root `.gitignore` covers its
  build output.
- **The checked set comes from git.** Ask git for it and do not rebuild its
  ignore rules by walking directories. Take the names in a form that keeps a
  space, a quote and a non-ASCII letter as they are on disk: TASK-004 checks
  paths for Cyrillic and Greek letters. A file is tracked when it is in the
  index: a test needs `git init` and `git add`, never a commit. TASK-004 will
  ask the same code for two more things: the size of a file without reading
  it, and the name of a symbolic link.
- **Tests and the git settings of the machine.** A GitHub runner has no git
  identity and no global git configuration. kyukhin's Mac has both, a global
  excludes file among them. The tests give the same result on either: they
  neither read nor change the user's git configuration.
- **`.gitignore`.** This task adds four lines and removes none: `.build/` and
  `.swiftpm/` for the build output of the tool, `.#*` and `#*#` for the
  editor's lock and autosave files that lie in `docs/plan/` today. In the
  file `#*#` is written `\#*#`: git reads a line that starts with `#` as a
  comment. Without these lines the build output and the editor's files are in
  the checked set. TASK-004 rewrites the file.
- **The PRD.** `docs/product/PRD.md` does not end with a line feed. This task
  adds that one byte and changes nothing else in the file; the PRD gets no
  line about it.
- **Exceptions of `whitespace`.** There is one: W2 does not apply to
  `Makefile` and `*.mk`. E-01 adds more, each for one path pattern and one
  rule. Keep the exceptions in one place in the tool. No configuration file.
- **`make lint` grows.** TASK-004 adds three checks to it; E-01 puts
  `swift format lint --strict` in front and adds three more commands. Its
  rule is fixed by the spec: every check runs even when another failed, and
  the exit is an error if any failed. GNU Make 3.81 has no `.ONESHELL`.
- **E-01 runs `swift format lint --strict` over these sources** (spec E-01,
  "Decisions"). Code in the default style of `swift format` spares a reformat
  then. It is not a criterion here; `.swift-format` and `make format` are
  E-01's.
- **Messages.** The form of a line is fixed by the spec; the words of a
  message are yours.
- No line in `CHANGELOG.md`: nothing changes for the user of the app.

## Change scope
May be changed:
- `Tools/ClamChecks/`, new: the manifest, the sources, the tests;
- `Makefile`, new, in the root;
- `.gitignore`: the four added lines, nothing else;
- `docs/product/PRD.md`: one line feed at the end, nothing else;
- `docs/architecture/OVERVIEW.md`: the opening note, "What exists" and
  "Commands";
- `docs/specs/E-03-automated-code-review.md`: the cells "Proved by" of C2, C5
  and C6 and a line in "History"; "Design" only for a small detail, as the
  developer's skill allows;
- this file and the row and the log of this task in `docs/plan/BOARD.md`.

QA writes `docs/qa/TASK-002.md`.

Must not be touched: `CLAUDE.md`, `.claude/`, `.coderabbit.yaml`, `.github/`,
`README.md`, any other byte of the PRD, any other document. The commands
`language`, `tracked-files` and `secrets` are TASK-004.

## Acceptance criteria
- [x] AC1 (C5): the checked set. In a temporary git repository `whitespace`
      checks a tracked file with the content it has on disk now and an
      untracked file that git does not ignore; it does not check a file that
      git ignores: a violation in it passes. A tracked file that is deleted
      from the working tree is skipped without an error. A file whose name
      holds a space and a non-ASCII letter is reported under its exact path.
      Run in a subdirectory, the tool checks the whole repository.
- [x] AC2 (C5): a file with a NUL byte is binary, and its content is not
      checked. A symbolic link is never opened: a link passes when it points
      to a file with violations that is itself outside the checked set, and
      so do a dangling link and a link to a directory.
- [x] AC3 (C5): output and exit status. One line per violation,
      `path:line:column: check: message`, or `path: check: message` for a
      whole file; the path is relative to the root of the repository; line
      and column start at 1 and the column counts bytes; the lines are sorted
      by path, then by line. Violations go to standard output, every other
      message to standard error. The exit status is 0 with no violation, 1
      with violations, and 2 for an unknown command, for no command and for a
      directory that is not in a git repository. A test covers each form of
      the line and each exit status.
- [x] AC4 (C2): `whitespace` reports each of W1 to W6, with at least one test
      per rule; W5 is reported for a file with no line feed at its end and
      for a file with more than one. It passes on a tab in `Makefile` and in
      a `*.mk` file, on an empty file and on a file that ends with exactly
      one line feed. It rewrites nothing.
- [x] AC5 (C2): `make lint` passes on the repository. `docs/product/PRD.md`
      ends with one line feed and no other byte of it changed. `.gitignore`
      has the four new lines and lost none.
- [x] AC6 (C6): `make lint` runs every check the tool has, which is
      `whitespace` after this task, and exits with an error if a check
      failed. `make test-tools` runs the tests of the tool. `make check` runs
      `lint`, then `test-tools`; it first prints the version of the Swift it
      runs with; it passes on the repository with Xcode 26.4; a compiler
      warning in the tool makes it fail. The three commands need nothing but
      macOS, git and the Swift of the selected Xcode and make no network
      request. No stored file of the tool breaks a check: a test builds every
      fixture with a violation at run time, in a temporary directory that it
      removes.
- [x] `docs/architecture/OVERVIEW.md` is current. The opening note says that
      the first checks exist and that nothing of the app does; it does not
      mention the workflow, so that TASK-003 and TASK-004 need not change it.
      "What exists" has the `Makefile` and `Tools/ClamChecks`. "Commands"
      says that the three commands exist, that `make lint` runs `whitespace`,
      and that the other three checks are decided and wait for TASK-004.
      Pointers to the spec, no copy of its text.
- [x] All tests pass; `make check` is green with no new warnings.

## How to verify
QA, on kyukhin's Mac, in the root of the repository:

```
xcodebuild -version
make check
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 make test-tools
git status --short
{ git show HEAD:docs/product/PRD.md; printf '\n'; } | cmp - docs/product/PRD.md
git diff HEAD -- .gitignore
```

Expected: Xcode 26.4; `make check` prints the Swift version first and exits
with 0 and without a warning; the tests pass with the user's git settings
switched off as well; `git status` lists only files of the change scope and
no build output; `cmp` prints nothing; the diff of `.gitignore` shows four
added lines.

By hand (AC5, AC6): `printf 'x \n' > zz-ws.txt`, then `make lint` prints a
line that starts with `zz-ws.txt:1:` and exits with an error; remove the file
and `make lint` passes. Add an unused variable to a source of the tool and see
`make check` fail; restore the file.

By hand (AC3): `swift build --package-path Tools/ClamChecks --show-bin-path`
gives the directory of the built tool. Run it with an unknown command, and run
`whitespace` in a new directory under `$TMPDIR`: both exit with 2 and print
nothing to standard output.

Mutation (QA skill, step 6): break one rule of `whitespace` and one condition
of the checked set, and see a test of AC4 and a test of AC1 fail.

Read: the `Makefile` and the manifest name no dependency and no download; no
stored file under `Tools/ClamChecks/` has a violation of W1 to W6.

The proof with Xcode 27 is not in this task: it is the `check` job of
TASK-003.

## Out of scope
- The commands `language`, `tracked-files` and `secrets`, and the rewrite of
  `.gitignore`: TASK-004.
- The workflow on GitHub: TASK-003.
- `swift format`, `.swift-format`, `make format`, `make clean-check` and
  every other target of E-01.
- A mode that fixes whitespace.
- Changing the QA or committer skills to call `make check`: the kit is the
  dispatcher's.

## Developer notes
Plan:
1. The package `Tools/ClamChecks` (library target with the logic, thin
   executable, Swift Testing test target) and the plumbing: git root, the
   checked set, `lstat` kinds, output and exit statuses; with a stub
   `whitespace` check.
2. Tests first: the tests of AC1 to AC4 against the stub; see the plumbing
   tests pass and the rule tests fail.
3. The rules W1 to W6 and the one place for the exceptions.
4. `Makefile`, `.gitignore`, the final line feed of the PRD.
5. OVERVIEW, the spec's "Proved by" cells and "History", the board.
6. Every command of "How to verify", the manual steps and a mutation of my own.

Done:
- `Tools/ClamChecks/`: manifest (tools version 6.0, language mode 6, macOS 14,
  no dependency), three targets: the library `ClamChecksCore` (all the logic),
  the executable `clam-checks` (`main.swift` only wires the two streams and
  `exit`), the Swift Testing target `ClamChecksCoreTests`.
- `Makefile`: `lint`, `test-tools`, `check`. `-Xswiftc -warnings-as-errors` is
  passed to every `swift build` and `swift test`, so a warning in the tool or
  in its tests fails the command. `lint` builds the tool, then runs every name
  in `CHECKS` (one place; TASK-004 adds the other three) and exits with an
  error if any failed. `check` prints `swift --version`, then `lint`, then
  `test-tools` through sub-makes (GNU Make 3.81, no `.ONESHELL`; the order
  holds with `make -j` too).
- `.gitignore` (four lines added), `docs/product/PRD.md` (one line feed).
- Tests first: the plumbing and the rule tests were written against a stub
  `whitespace` that reports nothing: 71 tests, 64 issues; then the rules went
  in and all passed. The final count is 72 tests (one more for the two
  messages of W5).

Decisions of mine, inside the change scope:
- Layout of the library, for TASK-004: `GitRepository` (git root and the
  checked set from `git ls-files -z --cached --others --exclude-standard
  --deduplicate`, run in the root, so a subdirectory is no different), then
  `CheckedFile.inspect` (`lstat`, never `stat`: `kind` is `.regular(size:)`,
  `.symbolicLink` or `.other`, so TASK-004 gets the size without reading and
  the link by its name), `CheckedFile.textContent()` (nil for a link, a
  non-regular file and a file with a NUL byte; opens with `O_NOFOLLOW`).
  A check is a `Check` (`name`, `violations(in:)`); `CommandLineTool.checks`
  is the list of commands.
- Names stay raw bytes from `-z` until they are shown, so a space, a quote and
  a non-ASCII letter are kept as on disk.
- Where a violation sits: W1 at the first byte of the trailing run; W2 at the
  first tab of the line; W3 at the first carriage return of the line; W4 at
  1:1; W6 at the first invalid byte; W5 has no position. W2 and W3 give one
  line per line that has the character, not one per character. A carriage
  return before the line feed does not hide a space before it from W1 (git's
  `cr-at-eol` view). A BOM is only looked for at the start of the file.
- Order: path by its UTF-8 bytes (so `a.txt` before `a/b.txt`), then line; a
  violation without a position (W5) comes before the lines of its file.
- W5 has two messages (no line feed / more than one), same rule number.
- Messages start with the rule number (`W1 trailing space or tab`).
- The exceptions of W2 are `WhitespaceCheck.exceptions`, one list, each entry
  one rule and one name pattern (`Makefile` or `*.mk` by the last component of
  the path, at any depth).
- A file that cannot be read (or a `lstat` error other than "not there") is
  printed to standard error as `clam-checks: path: cannot read: reason`, the
  run goes on with the other files and ends with status 2. The spec names 2
  only for a wrong call and for a directory outside a git repository; this is
  the same kind of "the tool could not do its job" and is recorded in the
  spec ("Exit status", History).
- The tests never touch the user's git settings: every git process of a test
  gets `HOME`, `XDG_CONFIG_HOME`, `GIT_CONFIG_GLOBAL=/dev/null`,
  `GIT_CONFIG_NOSYSTEM=1` and `GIT_CEILING_DIRECTORIES`, with every other
  `GIT_*` variable removed; a test of "git decides" gives git a global
  excludes file that lies in the temporary directory. No test commits, so no
  identity is needed.
- The tool itself uses the environment it is given (so the user's excludes
  file counts, as the spec says); `main.swift` hands it the real one.
- `make test-tools` uses `swift test`, not `xcodebuild`: the tool is a package.

Not done and why: nothing of the criteria is left. The proof with Xcode 27 is
TASK-003's. The parts of `main.swift` that map the two closures to file
descriptors 1 and 2 have no test of their own (the streams are tested through
`OutputStreams`); QA's manual step for AC3 runs the real binary.

Proposals for later (no task made): none.

Checks run (all on kyukhin's Mac, Xcode 26.4, Swift 6.3):
- `make check`: exit 0, the Swift version first, 0 warnings, 72 tests passed.
- `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 make test-tools`: exit 0.
- `git status --short`: only files of the change scope; `cmp` of the PRD: no
  output; the diff of `.gitignore`: four lines added, none removed.
- By hand: `zz-ws.txt` with a trailing space made `make lint` print
  `zz-ws.txt:1:2: whitespace: W1 ...` and fail, and it passed again after the
  file was removed. An unused variable in `Check.swift` made `make check`
  fail with a compiler error; restored. The built tool with an unknown command,
  with no command and in a new directory under `$TMPDIR`: exit 2, nothing on
  standard output; run from `Tools/ClamChecks`: exit 0 over the whole
  repository.
- Mutations, each then restored: W1 without tabs (6 tests failed); no
  `--exclude-standard` (6+ tests failed); no `--others` (6+ tests failed);
  a link treated as a regular file and `O_NOFOLLOW` removed (7 tests failed).
- `swift format lint --strict -r Tools` prints nothing (not a criterion here).

Return from QA, check 1 (`docs/qa/TASK-002.md`), B1 and N1:
- B1: `lstat` and `O_NOFOLLOW` only stop a link in the last component, so a
  tracked folder replaced by a link was read through the link. Tests first
  (red: 10 issues): `aTrackedFolderReplacedByALinkToAFolderOutsideTheRepositoryIsSkipped`,
  `aTrackedFolderReplacedByALinkToAFolderInsideTheRepositoryReportsTheFileOnce`,
  `aLinkInTheMiddleOfALongerPathIsSkipped` (the link as the first, the second
  and the last folder of `a/b/c/f.txt`, with a violating file behind it) and
  `aTrackedFolderReplacedByADanglingLinkIsSkipped`.
- What I chose: `CheckedFile` opens the root of the repository once per call
  (following links: it is where the user stands, and `/tmp` or `/var` are
  links on this Mac) and then uses `fstatat(root, path, ...,
  AT_SYMLINK_NOFOLLOW_ANY)` and `openat(root, path, O_NOFOLLOW_ANY)`. Both
  flags are defined in `sys/fcntl.h` of the SDK of Xcode 26.4 and are used
  with a deployment target of macOS 14; I cannot see the SDK of Xcode 27
  here, but the flags belong to the macOS 13 API, and nothing in the tool
  depends on a newer one. Tried by hand first, on a scratch directory: with
  `AT_SYMLINK_NOFOLLOW_ANY` a link in a leading folder gives `ELOOP`, and a
  link in the last component is described as a link (`S_IFLNK`), like
  `lstat`. So `kind == .symbolicLink` still works for TASK-004, and `ELOOP`
  from `inspect` means "below a link": the path is skipped like a deleted
  file, without an error. A link in the middle of a longer path counts the
  same as a link in the first or the last folder; every component below the
  root is checked by the kernel, so there is no path-splitting code.
  `O_NOFOLLOW_ANY` on the open is the second guard, in case a path changes
  between the two calls.
- N1: `aTrackedFolderReplacedByAFileIsSkippedWithoutAnError` (tracked
  `a/b.txt`, then `a` replaced by a regular file: exit 0, both streams empty).
- Spec: "The check tool", "The checked set" says that a tracked path below a
  link is not in the set; the History line and the "Proved by" cell of C5 are
  updated. Spec changed (small detail).
- Mutations of the new code, each restored (`cmp` against the copy): the
  `NOFOLLOW_ANY` flags replaced by the old ones (10 issues in the four new
  tests, all three depths); `ENOTDIR` not skipped (the N1 test fails);
  `ELOOP` not skipped (the link tests fail).
- Checks: `make check` exit 0, 77 tests, 0 warnings;
  `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 make test-tools` exit 0.

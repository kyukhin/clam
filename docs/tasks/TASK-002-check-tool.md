# TASK-002: Create the check tool with the `whitespace` check, and `make check`

Epic: E-03 | Milestone: M0 | Status: ready
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
- [ ] AC1 (C5): the checked set. In a temporary git repository `whitespace`
      checks a tracked file with the content it has on disk now and an
      untracked file that git does not ignore; it does not check a file that
      git ignores: a violation in it passes. A tracked file that is deleted
      from the working tree is skipped without an error. A file whose name
      holds a space and a non-ASCII letter is reported under its exact path.
      Run in a subdirectory, the tool checks the whole repository.
- [ ] AC2 (C5): a file with a NUL byte is binary, and its content is not
      checked. A symbolic link is never opened: a link passes when it points
      to a file with violations that is itself outside the checked set, and
      so do a dangling link and a link to a directory.
- [ ] AC3 (C5): output and exit status. One line per violation,
      `path:line:column: check: message`, or `path: check: message` for a
      whole file; the path is relative to the root of the repository; line
      and column start at 1 and the column counts bytes; the lines are sorted
      by path, then by line. Violations go to standard output, every other
      message to standard error. The exit status is 0 with no violation, 1
      with violations, and 2 for an unknown command, for no command and for a
      directory that is not in a git repository. A test covers each form of
      the line and each exit status.
- [ ] AC4 (C2): `whitespace` reports each of W1 to W6, with at least one test
      per rule; W5 is reported for a file with no line feed at its end and
      for a file with more than one. It passes on a tab in `Makefile` and in
      a `*.mk` file, on an empty file and on a file that ends with exactly
      one line feed. It rewrites nothing.
- [ ] AC5 (C2): `make lint` passes on the repository. `docs/product/PRD.md`
      ends with one line feed and no other byte of it changed. `.gitignore`
      has the four new lines and lost none.
- [ ] AC6 (C6): `make lint` runs every check the tool has, which is
      `whitespace` after this task, and exits with an error if a check
      failed. `make test-tools` runs the tests of the tool. `make check` runs
      `lint`, then `test-tools`; it first prints the version of the Swift it
      runs with; it passes on the repository with Xcode 26.4; a compiler
      warning in the tool makes it fail. The three commands need nothing but
      macOS, git and the Swift of the selected Xcode and make no network
      request. No stored file of the tool breaks a check: a test builds every
      fixture with a violation at run time, in a temporary directory that it
      removes.
- [ ] `docs/architecture/OVERVIEW.md` is current. The opening note says that
      the first checks exist and that nothing of the app does; it does not
      mention the workflow, so that TASK-003 and TASK-004 need not change it.
      "What exists" has the `Makefile` and `Tools/ClamChecks`. "Commands"
      says that the three commands exist, that `make lint` runs `whitespace`,
      and that the other three checks are decided and wait for TASK-004.
      Pointers to the spec, no copy of its text.
- [ ] All tests pass; `make check` is green with no new warnings.

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
(filled in by the developer: decisions along the way, deviations, what is left)

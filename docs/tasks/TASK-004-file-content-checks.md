# TASK-004: Add the `tracked-files`, `language` and `secrets` checks

Epic: E-03 | Milestone: M0 | Status: ready
Depends on: TASK-002
Complexity: normal
Spec: docs/specs/E-03-automated-code-review.md § "The four checks" (`language`, `tracked-files`, `secrets`), "The check tool", "What GitHub's scanner does not see", test plan C1, C3, C4, C5 and C6 (approved 2026-11-27)
Basis: ADR-0001 (row "Languages": the four localization paths), CLAUDE.md ("Language"; invariant 4)

## Goal
`make lint` runs all four checks. A file that must not be in git, a Cyrillic
or Greek letter outside the localization paths, and a Telegram key or a
private key pasted into a file are caught by `make check` before the commit,
on the Mac and in the job on GitHub. `.gitignore` is rewritten for the Swift
stack, and a check holds it in place.

## Context
- **What TASK-002 left.** The package, the checked set, the output, the exit
  statuses, `whitespace`, the `Makefile` with a `lint` that runs every check
  even when another failed. This task adds three commands and their tests
  and changes none of that. This task and TASK-003 can be worked at the same
  time: they share no product file.
- **`tracked-files`, the table.** The table of the spec lives in one place in
  the tool, and both parts of the check and the tests read it there. A
  pattern matches a path as git matches the same line of a `.gitignore` in
  the root: `*.p12` at any depth; `secrets/` as a directory at any depth,
  with everything under it; `Config/Local.xcconfig` and
  `.claude/settings.local.json` from the root only; `.env.*` but not
  `.env.example`.
- **`tracked-files`, part 2.** It reads only the `.gitignore` in the root of
  the repository. kyukhin's Mac has a global excludes file and a GitHub
  runner has none: an answer that follows the user's settings differs
  between the two. The test of this part therefore also runs with a global
  excludes file that ignores a sample.
- **`.gitignore`.** Exactly the patterns of the table, by group, a comment
  line for each group. `#*#` is written `\#*#`. The Android and Flutter lines
  go. The four lines TASK-002 added are in the table.
- **The size limit.** A file of 1,048,576 bytes passes; one more byte fails.
- **`language`.** The rule is the Unicode script of a character, not a block
  of code points: a Greek letter from "Greek Extended" and a Cyrillic letter
  from "Cyrillic Extended-B" fail too, and the micro sign U+00B5, whose
  script is Common, passes. The standard library gives no script for a
  scalar directly; a regular expression class for a script, of the standard
  library or of Foundation, does.
  The four exempt paths are two files and two directories; a path is exempt
  as a whole, its name and its content. The list is in one place in the tool
  and equals the row "Languages" of ADR-0001.
- **`secrets`.** The rules are S1 to S3 of the spec, with "a run is as long
  as it can be". The names match in any case and with `_`, `-`, a space or
  nothing between the two words. A message names the kind of secret and
  never the matched text; the log of the job on GitHub is public.
- **The tool checks itself.** Its sources and tests are in the checked set.
  The patterns in the code and the fixtures in the tests are written so that
  no line of a stored file matches a rule: a letter comes from its code
  point, a key-shaped value is put together from parts, a file with a
  forbidden name is created by the test.
- **Messages.** A message of `language` that names the code point
  (`U+0416`) and not the letter keeps the output ASCII.
- **The last task of the epic** is whichever of TASK-003 and TASK-004 is
  committed last: its committer moves the spec to `implemented`.
- No line in `CHANGELOG.md`: nothing changes for the user of the app.

## Change scope
May be changed:
- `Tools/ClamChecks/`: the three commands and their tests; what TASK-002
  built is extended only where a command needs more from it (the size of a
  file, the name of a link, the registration of a command), and what it does
  for `whitespace` stays as it is;
- `Makefile`: the three commands join `lint`;
- `.gitignore`: rewritten;
- `docs/architecture/OVERVIEW.md`: "What exists" (the row of `.gitignore`),
  "Commands" and "Localization paths";
- `docs/specs/E-03-automated-code-review.md`: the cells "Proved by" of C1, C3,
  C4, C5 and C6 and a line in "History"; "Design" only for a small detail, as
  the developer's skill allows;
- this file and the row and the log of this task in `docs/plan/BOARD.md`.

QA writes `docs/qa/TASK-004.md`.

Must not be touched: the behavior of the checked set, of the output format,
of the exit statuses and of `whitespace` as TASK-002 made them (a fault found
there is an escalation, not a silent fix); `.github/`, `.coderabbit.yaml`,
`CLAUDE.md`, `.claude/`, any other document.

## Acceptance criteria
- [ ] AC1 (C3, C5): `tracked-files`, part 1. For every pattern of the table a
      file fails when it is tracked and when it is untracked and not ignored,
      and passes when git ignores it. `.env.example` passes. A file larger
      than 1 MiB fails, and a file of exactly 1 MiB passes. A binary file is
      checked by its name and its size. A symbolic link is checked by its
      name only: a link with a forbidden name fails, and a link to a file
      larger than 1 MiB passes. Tests on temporary git repositories.
- [ ] AC2 (C3): `tracked-files`, part 2. The check fails when the `.gitignore`
      in the root does not ignore a sample of a pattern: a test removes a
      line and sees the failure, also when a global excludes file ignores
      that sample. Every pattern of the table has a sample. `.gitignore`
      holds exactly the patterns of the table, by group, and no Android or
      Flutter line. The check passes on the repository.
- [ ] AC3 (C1): `language` fails on a Cyrillic and on a Greek letter in the
      content of a checked file and in its path, also on a letter from an
      extended block of each script. It passes for the same letters in each
      of the two exempt files and under each of the two exempt directories,
      and does not pass for a file that only resembles them: the same file
      name elsewhere, a directory whose name only starts like an exempt one.
      It passes on Latin text, digits, punctuation and symbols of other
      scripts, and on the repository.
- [ ] AC4 (C4): `secrets` fails on S1, S2 and S3, in each spelling of the
      names the spec lists. It passes on a line that only names `api_id` or
      `api_hash`, on the placeholders `0` and `<api_hash>`, on a run that is
      one digit shorter or longer than the rule asks, and on the repository.
      One test asserts that the output of each of the three rules does not
      contain the matched value.
- [ ] AC5 (C6): `make lint` runs the four checks. With one violation of each
      in the tree it prints the lines of all four and exits with an error.
      `make check` passes on the repository with Xcode 26.4 and without a
      compiler warning. No stored file of the tool breaks any of the four
      checks.
- [ ] `docs/architecture/OVERVIEW.md` is current: "Commands" says that
      `make lint` runs four checks and no longer sends a role to the commands
      of its skill; the row of `.gitignore` under "What exists" says that it
      is rewritten and held by `tracked-files`; "Localization paths" says
      that the `language` check holds the list. Pointers to the spec, no copy
      of its text.
- [ ] All tests pass; `make check` is green with no new warnings.

## How to verify
QA, on kyukhin's Mac, in the root of the repository:

```
make check
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 make test-tools
git status --short
```

Expected: both commands exit with 0 and without a warning; `git status` lists
only files of the change scope.

Read `.gitignore` against the table of the spec, group by group (AC2).

By hand (AC5): four untracked files, one violation each, made without writing
a violation into any stored file:

```
printf 'x \n' > zz-ws.txt
printf '\320\226\n' > zz-lang.txt
dd if=/dev/zero of=zz-big.bin bs=1m count=2
printf 'api_hash = %s\n' "$(printf 'ab%.0s' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)" > zz-secret.txt
make lint
rm zz-ws.txt zz-lang.txt zz-big.bin zz-secret.txt
make lint
```

Expected: the first `make lint` prints at least one line of each of
`whitespace`, `language`, `tracked-files` and `secrets`, names
`zz-secret.txt` without the 32 digits, and exits with an error; the second
passes.

Mutation (QA skill, step 6): break one rule of each of the three new checks
and see its test fail: for example one pattern of the table, one of the two
scripts, the length of the run in S1.

Read: no stored file under `Tools/ClamChecks/` holds a Cyrillic or Greek
letter, a key-shaped value next to its name, the header of a private key
block, or a name of the table.

If TASK-003 is merged, the `check` job on the pull request of this task shows
the same result under Xcode 27; the dispatcher names its state in the report.

## Out of scope
- Exceptions of `whitespace` and new patterns for the files Xcode writes;
  the commands `boundaries`, `dependencies` and `release-guard`: E-01.
- A change of the 1 MiB limit. E-02 brings a test audio file and decides
  then.
- A general scanner for secrets, and a check of commit messages and PR
  texts.
- The example file for the Telegram keys: E-04.
- Changing the QA or committer skills to call `make check`: the kit is the
  dispatcher's.

## Developer notes
(filled in by the developer: decisions along the way, deviations, what is left)

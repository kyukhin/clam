# TASK-001: Add `.coderabbit.yaml`, the settings of the review bot

Epic: E-03 | Milestone: M0 | Status: done
Depends on: none
Complexity: normal
Spec: docs/specs/E-03-automated-code-review.md § "`.coderabbit.yaml`", "What kyukhin does by hand", test plan C9 and C10 (approved 2026-11-27)
Basis: ADR-0005 (V7, V14, V18, V19), ADR-0001 (row "Languages"), ADR-0002 ("Rules", 1 and 2)

## Goal
The repository holds the settings of CodeRabbit for Clam. The first review of
a Clam pull request and every later one is written in English, leaves the PR
description alone, never approves, runs no SwiftLint and knows four rules of
the project.

## Context
- This task is the first of E-03 on purpose. When its pull request is open,
  kyukhin gives the bot access to `clam` (spec, H1), and the branch of every
  later task is cut from a `master` that holds this file.
- There is nothing to copy from: LibreDict has no such file.
- The keys were checked against CodeRabbit's published V2 schema,
  `https://coderabbit.ai/integrations/schema.v2.json`, on 2026-11-27, and all
  of them are there: `language`; `reviews.high_level_summary_in_walkthrough`;
  `reviews.auto_approvals.enabled`; `reviews.tools.swiftlint.enabled`;
  `knowledge_base.learnings.scope`, `knowledge_base.issues.scope` and
  `knowledge_base.pull_requests.scope`, each with the values `local`,
  `global` and `auto`; `reviews.path_instructions`, a list whose entries have
  `path` and `instructions`.
- `version: 2` is the exception. That schema has no `version` property and
  rejects unknown top-level keys, so an editor or a validator flags the line;
  CodeRabbit accepts it at review time (ADR-0005, V19). The spec wants the
  line. Do not remove it to quiet a validator.
- Comments are not keys and are allowed: a first line that names the schema
  for editors, a short reason next to a key.
- The fourth instruction needs care. ADR-0002 does not forbid every module
  whose name starts with `Source`: `SourceAPI` is the contract and every
  layer imports it, and a test target may import `SourceFake`. The
  instruction has to say so, or the bot reports correct code. None of these
  modules exists yet; the instruction is written for the code that E-01 and
  E-02 bring.
- The instructions name the two scripts as words. No Cyrillic and no Greek
  letter is in the file.
- `make check` arrives with TASK-002. If it exists in your tree, it has to
  pass. If it does not, the commands of the QA and committer skills are the
  check.
- No line in `CHANGELOG.md`: nothing changes for the user of the app.

## Change scope
May be changed:
- `.coderabbit.yaml`, new, in the root of the repository;
- `docs/architecture/OVERVIEW.md`: the part about this file under "What
  exists" and the row of the review under "GitHub";
- `docs/specs/E-03-automated-code-review.md`: the cell "Proved by" of C9 and a
  line in "History"; "Design" only for a small detail, as the developer's
  skill allows;
- this file and the row and the log of this task in `docs/plan/BOARD.md`.

QA writes `docs/qa/TASK-001.md`.

Must not be touched: `CLAUDE.md`, `.claude/`, `README.md`, `.gitignore`, any
other document, any setting on GitHub or in CodeRabbit's web interface.

## Acceptance criteria
- [ ] AC1 (C9): `.coderabbit.yaml` is in the root of the repository and is
      valid YAML. It declares `version: 2` and holds the keys of the table in
      the spec, § "`.coderabbit.yaml`", with these values: `language` is
      `en-US`; `reviews.high_level_summary_in_walkthrough` is `true`;
      `reviews.auto_approvals.enabled` is `false`;
      `reviews.tools.swiftlint.enabled` is `false`; the three
      `knowledge_base` scopes are `local`. It holds one entry of
      `reviews.path_instructions` and no other key.
- [ ] AC2 (C9): that entry applies to every path and says the four things of
      the spec: the decisions in `docs/architecture/adr/` and in the specs
      are not up for review, so no other stack, linter, dependency or CI
      service is proposed; Cyrillic or Greek text outside the four
      localization paths of ADR-0001 is reported, and the four paths are
      named; anything that looks like a credential, a session file or a
      signing file is reported; an import of a concrete source module or of a
      skin module outside the app target is reported, with the exceptions of
      ADR-0002, rules 1 and 2: `SourceAPI`, and the test targets.
- [ ] AC3 (C9): every key of the file except `version` exists at its path in
      the published V2 schema, and its value has the type the schema asks
      for. The developer notes say how this was checked.
- [ ] AC4 (C9): the file is UTF-8 text with no tab, no trailing whitespace, no
      carriage return and exactly one line feed at its end, and it holds no
      Cyrillic and no Greek letter.
- [ ] `docs/architecture/OVERVIEW.md` says that the file exists, under "What
      exists" and in the row of the review under "GitHub", with a pointer to
      the spec and no copy of its text. What it says is true before H1 and
      after it: it names H1 as the step that gives the bot access.
- [ ] All tests pass; the build and the linter are green with no new
      warnings: `make check` if the tree has it.

## How to verify
QA, before the commit:

1. Read `.coderabbit.yaml` against the table and the paragraph about
   `reviews.path_instructions` in the spec, key by key (AC1, AC2).
2. See the file as data, to catch a key at a wrong depth:
   `ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load_file(".coderabbit.yaml"))'`.
3. AC3: fetch the schema and look up every key, for example
   `curl -sSL https://coderabbit.ai/integrations/schema.v2.json | jq '.properties.reviews.properties.auto_approvals.properties.enabled'`.
   A key that is not there prints `null`.
4. AC4: `git diff --check` and the language command of the QA skill, run on
   the new file; `tail -c1 .coderabbit.yaml | xxd -p` prints `0a`.
5. `make check`, if the tree has it.

After the commit, by hand: the dispatcher and kyukhin, not the developer and
not QA. These are the steps of C10 in the spec; they also prove the by-hand
part of C9.

1. The dispatcher pushes, opens the pull request and stops before the review
   step: until H1 the bot does not see the repository. It tells kyukhin that
   the pull request with `.coderabbit.yaml` is open, asks for H1 and H2, and
   asks who posts the comment of step 4 of C10.
2. After H1 the review step of CLAUDE.md starts, and C10 is checked by its
   steps and its expected results.
3. The dispatcher writes the two measurements of C10 into
   `docs/qa/TASK-001.md`. That is a change of the branch after the commit:
   the committer commits it, and the dispatcher folds it as it folds a fix
   (CLAUDE.md, "One task, one commit").

An expected result of C10 that fails because of the file is a defect of this
task and goes the way of a review finding: a parsing warning, an unrecognized
property, a block of the bot in the PR description, a finding of SwiftLint, an
approval by the bot.

## Out of scope
- Path filters: the spec leaves them to the epic that adds generated or
  binary files.
- H1, H2 and any other step on GitHub or on CodeRabbit's site.
- Any change of CLAUDE.md or of a skill.
- The facts C10 measures (whether the bot starts by itself, reviews an hour):
  the architect writes them into the OVERVIEW and into ADR-0005 when E-03 is
  implemented.

## Developer notes
Plan: (1) fetch the V2 schema and check every key; (2) write the file;
(3) check it as data, against the schema and for hygiene; (4) update OVERVIEW,
the spec cell of C9 and the BOARD.

Done:
- `.coderabbit.yaml` written: `version: 2`, the five values of the table, one
  entry of `reviews.path_instructions` with `path: "**"` and four paragraphs, one
  per thing the spec lists. Comments name the schema for editors, say why
  `version` is flagged, and give a short reason next to three keys.
- Decisions of mine: the fourth paragraph names `SourceAPI` as the contract,
  not a concrete source, so importing it is not a violation of this rule
  (ADR-0002, rule 1; the layer table is not repeated, and the paragraph does not
  say that every module may import it), `SourceFake` as allowed in a test
  target and `SourceTelegram` as allowed only in its own tests. It says "any
  module whose name starts with Source, except SourceAPI" so the bot needs no
  list of modules that do not exist yet. The `Skin` modules have no exception
  (rule 2). The instruction paragraphs are single long lines, as a YAML block
  scalar keeps the line feeds and the bot reads the text, not the layout.
- Return from QA, finding B1 (the glob of the entry). The first version had
  `path: "**"`. CodeRabbit's docs say only "Glob matching follows Minimatch
  rules, including brace expansion" (`docs.coderabbit.ai/configuration/path-instructions`,
  read 2026-11-27). They do not say how the `dot` option is set for
  `path_instructions`. The one statement about dot-files is on the page of
  `path_filters` (`docs.coderabbit.ai/pr-reviews/which-files`): "hidden files
  (names starting with a dot) are included". That is another setting, so it is
  no source for this one, and nothing was assumed from it. No source of
  option (a) was found; option (b) was done.
  The glob now is one brace pattern with a plain `**` and, for a path with
  1, 2, 3 or 4 dot segments, `{**/,}.*` joined by `/` with `{/**,}` at the end.
  `{**/,}` is "any non-dot segments, or none", `.*` is exactly one dot
  segment. Minimatch's `**` never crosses a dot segment when `dot` is off, so
  each dot segment is named by `.*`; that is the part that QA's candidate
  `{**,.*,.*/**,**/.*,**/.*/**}` lacked (it missed `.a/b/.c/d` too, not only
  `.a/.b/c`). The file has a comment that says why.
  The run: Minimatch 10.1.1 (`npm install minimatch@10.1.1` into a temporary
  directory outside the repository), the glob read back out of the YAML file
  by Ruby, `dot: false` and `dot: true`.
  - 20 named paths, all matched under both settings: `Makefile`,
    `docs/specs/E-03.md`, `.coderabbit.yaml`, `.gitignore`,
    `.github/workflows/ci.yml`, `.claude/skills/qa/SKILL.md`, `a/.env`,
    `Tools/ClamChecks/.swift-format`, `.a/.b/c`, `.a/b/.c/d`, `a/.b/c/.d/e`,
    `a/.b/.c/.d/.e/f`, `.a`, `a/.b`, `.a/b`, `x/y/z/.hidden/p/q/.r`,
    `docs/plan/.#ROADMAP.md`, `Config/Local.xcconfig`, `.DS_Store`,
    `a/b/.DS_Store`. A plain `**` with `dot: false` misses 17 of these 20.
  - Exhaustive: all 254 paths of depth 1 to 7 made of the segments `a` and
    `.b`. With `dot: true` none is missed. With `dot: false` 37 are missed, and
    every one has five or more dot segments (the fewest in a miss is 5).
  - The same exhaustive run with Minimatch 3.1.2, 5.1.6 and 9.0.5 gives the same
    numbers, so it does not depend on the version CodeRabbit uses.
  The gap that stays: with `dot: false`, a path with five or more dot segments
  is not matched. It is closed by adding one more alternative of the same
  shape, and every added level doubles the number of expansions. The gap does
  not matter for this repository: the longest path of dot segments that the
  tree can hold is `.github/workflows` or `.claude/skills` (one dot segment),
  and what lives under `.build/` and `.swiftpm/` is ignored by git. If a
  path with five dot segments ever appears and `dot` is off, the four
  instructions miss that one file and nothing else changes.
  One risk: CodeRabbit skips an entry whose glob it cannot parse ("If a glob
  is invalid, CodeRabbit skips that entry"). Minimatch parses this one, but
  only the by-hand step C9 (`@coderabbitai configuration`) and the first review
  show that CodeRabbit accepts it. That step is already in the spec, and
  whether the instructions reach a dot-file shows in the first review that
  touches one (`.coderabbit.yaml` is one: it is in the pull request of this
  task).
- Return from QA, note N1, by the dispatcher's decision: the fourth paragraph
  was reworded as described above. N2 (skins have no test-target exception in
  ADR-0002) is a question for the architect and was not touched.
- OVERVIEW: a row for the file under "What exists" and a sentence in the row
  of the review under "GitHub". Both name H1 and are true before and after it.
- Spec: the "Proved by" cell of C9 lists the checks that were run, the
  Minimatch run included; two lines in "History". "Design" is unchanged.

How AC3 was checked: `curl -sSL https://coderabbit.ai/integrations/schema.v2.json`
(91,624 bytes, read on 2026-11-27) saved to a temporary directory outside the
repository. A Ruby script walked the parsed file and looked up every key
below `version` at its path in the schema's `properties`: all eight leaf keys
and `path_instructions` were found, with the types `string`, `boolean` and
`array` that the values have; the three `scope` values are in the enum
`local`, `global`, `auto`; the entry has `path` and `instructions`, the
required keys of the item, and no other. `version` is not in the schema, as
the task says, and stays. `jq` looks up showed `.properties.version` is `null`.

Not done and not mine: C10 and the by-hand part of C9 (`@coderabbitai
configuration`) wait for the pull request and H1. Nothing was posted to GitHub.
`make check` does not exist in this tree; the commands of the task were run.

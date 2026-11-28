# TASK-001: Add `.coderabbit.yaml`, the settings of the review bot

Epic: E-03 | Milestone: M0 | Status: ready
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
(filled in by the developer: decisions along the way, deviations, what is left)

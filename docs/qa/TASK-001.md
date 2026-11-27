# QA: TASK-001

## Check 1 — 2026-11-27 — FAIL

Checked: the uncommitted tree of the branch `kyukhin/000-m0-tasks`. The task's
changes are `.coderabbit.yaml` (untracked, new) and edits to
`docs/architecture/OVERVIEW.md`, `docs/plan/BOARD.md`,
`docs/specs/E-03-automated-code-review.md` and
`docs/tasks/TASK-001-coderabbit-config.md`. The spec E-03 has the status
approved (2026-11-27).

### Build and tests
| Command | Result | Tests | Warnings |
|---|---|---|---|
| `make check` | does not exist: `ls Makefile` → "No such file or directory". It arrives with TASK-002 | n/a | n/a |
| Build, unit, UI, `swift format` | do not apply: the repository holds no Swift file, no Xcode project, no test suite (OVERVIEW, opening note) | n/a | n/a |
| `ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load_file(".coderabbit.yaml"))'` (Ruby 3.2.0) | exit 0; the data matches the file, see AC1 | n/a | none |
| `check-jsonschema --schemafile schema.v2.json .coderabbit.yaml` (0.39.0, installed with Homebrew at kyukhin's request) | exit 1, one error: "Additional properties are not allowed ('version' was unexpected)", as ADR-0005 V19 expects. A copy without the `version` line: "ok -- validation done", exit 0 | n/a | none |
| `git add -N .coderabbit.yaml && git diff --check` | exit 0, no output. The intent-to-add was removed with `git reset -q -- .coderabbit.yaml` right after; `git status --short` is the same as before | n/a | none |

Regressions: there is no test suite, so none can be run. No playback, position
or `MediaSource` code exists. The player checklist does not apply: the task
does not touch playback.

### Acceptance criteria
| Criterion | Row of the spec's plan | How checked | Result | Proof |
|---|---|---|---|---|
| AC1: file in the root, valid YAML, `version: 2`, the five values, one `path_instructions` entry, no other key | C9 | Ruby YAML load printed as JSON. A Ruby walk of every leaf key compared with the expected set. A Psych AST scan for duplicate keys, which `YAML.load` hides | PASS | Leaves: `version`=2 (Integer), `language`="en-US", `reviews.high_level_summary_in_walkthrough`=true, `reviews.auto_approvals.enabled`=false, `reviews.tools.swiftlint.enabled`=false, `reviews.path_instructions[0].path`="**", `reviews.path_instructions[0].instructions` (1015 chars), `knowledge_base.{learnings,issues,pull_requests}.scope`="local". `extra: [] missing: []`. No duplicate key |
| AC2: the entry applies to every path and says the four things | C9 | Read the four paragraphs against the spec, ADR-0001 row "Languages" and ADR-0002 rules 1 and 2. Checked what `"**"` matches under the glob rules CodeRabbit documents | **FAIL** (the "every path" part) | The four paragraphs: PASS. (1) ADRs and specs not up for review, no other stack, linter, dependency or CI service. (2) Cyrillic or Greek outside the four paths, all four named exactly as in ADR-0001. (3) Credential, session file, signing file. (4) `Source…` except `SourceAPI`, `Skin…`, app-target-only, `SourceFake` in tests, `SourceTelegram` only in its own tests. "Every path" is not proved, see "Findings", B1 |
| AC3: every key except `version` at its path in the published V2 schema, with the right type | C9 | `curl -sSL https://coderabbit.ai/integrations/schema.v2.json` into an empty temp directory: 91,624 bytes, sha256 `62fccef5…9152e0b55`. `jq` lookup of every key. A small Ruby checker for type, enum, required and `additionalProperties: false`, run over the whole file | PASS | `jq`: `.properties.version` → `null`. `language`: string, enum of 100 holds `en-US`. `high_level_summary_in_walkthrough`: boolean. `auto_approvals.enabled`: boolean. `tools.swiftlint.enabled`: boolean (default `true`). `path_instructions`: array; items: object, required `path` and `instructions`, `additionalProperties: false`. `instructions`: string, maxLength 20000. Each `scope`: string, enum `local`, `global`, `auto`. Every parent object has `additionalProperties: false`. The checker on the file reports exactly one item: `$.version: unknown key`, which ADR-0005 V19 and the task expect. The developer notes say how AC3 was checked |
| AC4: UTF-8, no tab, no trailing whitespace, no CR, exactly one final LF, no Cyrillic or Greek | C9 | `file`, `iconv`, `grep`, `tail -c1/-c2 \| xxd -p`, `head -c3 \| xxd -p`, the language command of the QA skill | PASS | `ASCII text`, `iconv -f UTF-8` valid, non-ASCII bytes 0, tabs 0, CR 0, trailing-whitespace lines 0, first bytes `232079` (no BOM), last byte `0a`, last two bytes `6c0a` (one LF), language hits 0 |
| OVERVIEW says the file exists, under "What exists" and in the GitHub row, points to the spec, names H1, is true before and after H1 | — (task criterion) | Read the diff of `docs/architecture/OVERVIEW.md` | PASS | New row under "What exists" and a sentence in the review row under "GitHub". Both point to spec E-03 § "`.coderabbit.yaml`" and H1, copy no text of the spec, and stay true after H1 ("reads it only after", "sees `clam` only from H1") |
| All tests pass; build and linter green; `make check` if the tree has it | — | `ls Makefile` | Does not apply | No `Makefile`, no tests, no build. The task's own commands were the check, as the task says |

C9, by hand (`@coderabbitai configuration`), and C10 belong to kyukhin and the
dispatcher on the pull request after H1. They were not checked here.

### Test quality and mutations
The task has no code and no tests. The skill's idea was applied to the checks
this report relies on: each one was run on a broken copy made in
`/tmp/qa-t001-mut.KoksjT/` and failed as it should. The file in the
repository was not changed: its sha256 is
`1241b266b1f0d5a76e7e3abc849dfc3493151abf0b69c06243fd8a66c88364f7` before
and after, and `cmp` with the copy is clean.

| What was broken (copy outside the repository) | Check | Result |
|---|---|---|
| Misspelled keys: `high_level_summary_in_walk_through`, `auto_approve`, `learning` | `jq` lookup in the schema | `null` each: the lookup can fail |
| Unclosed quote in `path` | Ruby `YAML.load_file` | exit 1, "found unexpected end of stream while scanning a quoted scalar" |
| A tab as indentation | Ruby `YAML.load_file` | exit 1, "found character that cannot start any token" |
| `enabled: "false"` (string) | the Ruby schema checker | "type String, schema wants boolean" for both `enabled` keys |
| `scope: project` | the Ruby schema checker | "`project` not in enum" |
| `swiftlint` moved one level up, under `reviews` | the Ruby schema checker | "`$.reviews.swiftlint`: unknown key" |
| The same three copies, without the `version` line | `check-jsonschema` 0.39.0 | exit 1 each: "'false' is not of type 'boolean'" (both keys); "'project' is not one of ['local', 'global', 'auto']"; "Additional properties are not allowed ('swiftlint' was unexpected)" |
| A duplicate `language` key | the Psych AST scan | "duplicate key language" |
| Trailing space; CRLF; no final LF; a Cyrillic and a Greek letter built from code points | `grep`, `tail -c1 \| xxd -p`, the language command | 1 hit; 1 hit; `31` instead of `0a`; 1 hit |

### Change scope, spec and invariants
- `git status`: the four modified files and `.coderabbit.yaml` are all in the
  task's "May be changed". `docs/plan/#ROADMAP.md#` and
  `docs/plan/.#ROADMAP.md` are editor files of nobody's task and were not
  counted. No file of "Must not be touched" changed.
- BOARD: the TASK-001 row and two log rows. The developer also changed the
  "Next role" line to `qa (TASK-001)`. That is outside the literal "row and
  log", but it follows the status change. Not a finding.
- Spec E-03: only the "Proved by" cell of C9 and one "History" line. "Design"
  is unchanged and the status stays `approved`. This is a small detail, and the
  cell lists the checks that this report ran too.
- Invariants: no code, no module, no import, no position. The fourth
  instruction matches ADR-0002 rules 1 and 2, see the non-blocking N1 and N2.
- No `CHANGELOG.md` line: correct, nothing changes for the user of the app.

### Security and language
- A search of `git diff` plus `.coderabbit.yaml` for `api_hash`, `api_id`,
  `token`, `secret`, `password`, private key headers, 32-hex runs, 10+-digit
  numbers, `ghp_`, `sk-`, `xox`, `AKIA` found only words in prose ("secret
  scanning", "a read-only Actions token", "an api_id or api_hash with a
  value"), with no value next to them. No changed or new file has a
  sensitive name (`*.db`, `*.p12`, `*.pem`, `*.key`, `.env`,
  `local.properties`, TDLib files). No new secret file to ignore.
- The language command of the skill, `git diff -U0 -- . | perl -CSD -ne
  'print if /\p{Cyrillic}|\p{Greek}/'`, with `.coderabbit.yaml` marked
  intent-to-add so its lines are in the diff: 0 lines. The same run on the file
  alone: 0 lines. No localization path exists, so nothing was excluded.
- No UI string was added.

### Findings
Blocking (the reason for FAIL):

- **B1. The entry `path: "**"` is not shown to apply to every path; under
  CodeRabbit's documented glob rules it skips every dot-path.** AC2 and the
  spec ("one entry, for all paths") require every path. CodeRabbit's docs,
  `docs.coderabbit.ai/configuration/path-instructions` (read 2026-11-27), say
  "Glob matching follows Minimatch rules, including brace expansion". Neither
  the docs nor the schema say whether CodeRabbit sets Minimatch's `dot`
  option. Minimatch 10.1.1 (from the local npm) with its default
  options gives:

  | Path | `**`, default | `**`, `dot: true` |
  |---|---|---|
  | `.coderabbit.yaml`, `.gitignore` | false | true |
  | `.github/workflows/ci.yml` | false | true |
  | `.claude/skills/qa/SKILL.md` | false | true |
  | `a/.env`, `Tools/ClamChecks/.swift-format` | false | true |
  | `docs/specs/E-03.md`, `Makefile` | true | true |

  So unless CodeRabbit enables `dot`, the four instructions do not reach the
  workflow of TASK-003 (where "no other CI service" matters most), the
  `.gitignore` of TASK-004, the kit under `.claude/`, or dot-files that hold
  secrets, such as `.env`. The developer note "`**` matches every path" was
  not checked against these rules. The step `@coderabbitai configuration` in
  C10 would show the glob but not how it matches, so the by-hand part cannot
  close this either.

  For the developer, inside the task's scope, either way keeps AC1's single
  entry:
  (a) a source from CodeRabbit (docs or changelog) that `path_instructions`
  match with dot-files included, quoted with its URL in the developer notes;
  or (b) a glob that matches every path whether `dot` is on or off, proved by a
  Minimatch run in the notes. For example, the brace pattern
  `{**,.*,.*/**,**/.*,**/.*/**}` matched all nine sample paths above under
  both settings in QA's run. It still misses a path with two dot segments in a
  row, such as `.a/.b/c`; the developer decides whether that matters. The
  "Proved by" cell of C9 may then name that check.

Non-blocking (task proposals):

- **N1.** The fourth paragraph says "SourceAPI is the contract and may be
  imported everywhere". ADR-0002 rule 1 exempts `SourceAPI` from the
  concrete-source rule only. Its layer table still forbids `SourceAPI` in
  `Localization`, `DesignSystem` and `Skin…`. Read literally, the sentence may
  keep the bot quiet about such an import. The build and the boundary check of
  E-01 catch it anyway, so this is not blocking. A wording such as "SourceAPI
  is the contract and is not a concrete source" fits AC2, and the developer can
  fold it into the B1 fix if the dispatcher agrees.
- **N2.** ADR-0002 rule 2 has no test-target exception for skins. The
  instruction follows it, so `SkinRetroTests` importing `SkinRetro` would be
  reported, as by the letter of the ADR's boundary check. This is a question
  for the architect before E-05, not for this task.

One summary line for the PR: `QA: no build or tests (none exist); file parsed, every key except version found in schema V2 with its type, hygiene clean, 8 negative checks caught; FAIL: "**" skips dot-paths under Minimatch defaults`

## Check 2 — 2026-11-27 — PASS

A repeated check after the developer's fix of B1 and N1 of check 1. The file
changed, so every check of check 1 was run again on it. Its sha256 is now
`1fa527c5df04fd03dbdcf997de6e43a8b626522edb4f4ef5779b2033252b693e`. I fetched
the schema again: same sha256 as in check 1, `62fccef5…9152e0b55`.

### What changed
- `.coderabbit.yaml`: the `path` of the one entry is now a brace glob of 118
  characters in single quotes, instead of `"**"`:
  `{**,{**/,}.*{/**,},{**/,}.*/{**/,}.*{/**,},{**/,}.*/{**/,}.*/{**/,}.*{/**,},{**/,}.*/{**/,}.*/{**/,}.*/{**/,}.*{/**,}}`.
  Two comment lines above it say why. In the fourth instruction, "may be
  imported everywhere" became "SourceAPI is the contract, not a concrete
  source, so importing it is not a violation of this rule". The other three
  paragraphs are unchanged.
- Spec E-03: the "Proved by" cell of C9 names the Minimatch run, and a second
  TASK-001 line is in "History". "Design" is unchanged, and the status stays
  `approved`. This is a small detail: what the bot is told stays "one entry, for
  all paths".
- Task file: the developer notes describe the fix and the runs. BOARD: the
  row, the "Next role" line and a log row.

### Build and tests
| Command | Result | Tests | Warnings |
|---|---|---|---|
| `make check`, build, unit, UI | do not apply: still no `Makefile`, no Swift, no tests | n/a | n/a |
| Ruby 3.2.0 `YAML.load_file` printed as JSON | exit 0 | n/a | none |
| `check-jsonschema --schemafile schema.v2.json .coderabbit.yaml` (0.39.0) | exit 1, one error: "'version' was unexpected", as ADR-0005 V19 expects. Without the `version` line: "ok -- validation done", exit 0 | n/a | none |
| QA's Ruby schema checker (type, enum, required, `additionalProperties`, duplicate keys) | one item: `$.version: unknown key` | n/a | none |
| `git add -N .coderabbit.yaml && git diff --check`, then `git reset -q` | exit 0, no output; `git status --short` the same before and after | n/a | none |

### Acceptance criteria
| Criterion | Row of the spec's plan | How checked | Result | Proof |
|---|---|---|---|---|
| AC1: valid YAML, `version: 2`, the five values, one entry, no other key | C9 | Leaf walk of the loaded file against the expected set; count of entries; Psych duplicate-key scan; two YAML parsers (Ruby Psych, and the parser inside `check-jsonschema`) | PASS | `extra: [] missing: []`; `path_instructions count: 1`; values as in check 1; `path` is a String of 118 chars, `instructions` a String of 1056 chars; no duplicate key |
| AC2: the entry applies to every path and says the four things | C9 | The four paragraphs read again against the spec and ADR-0001 and ADR-0002. The glob, read out of the YAML file, matched with Minimatch 3.1.2, 5.1.6, 9.0.5 and 10.1.1, `dot` off and on, see "The glob" | PASS for the file. CodeRabbit's acceptance is the by-hand step, see below | Paragraphs 1 to 3 unchanged. Paragraph 4 now says what ADR-0002 rule 1 says (N1 closed). The glob misses no real or planned path of the repository under either setting |
| AC3: every key except `version` in the V2 schema with the right type | C9 | `jq` lookups and two validators, as above. The schema's limits for the entry: `path` is `{"type":"string"}` with no length or pattern limit; `instructions` has `maxLength` 20000 | PASS | 118 and 1056 chars are within the limits. The only schema error is `version` |
| AC4: UTF-8, no tab, no trailing whitespace, no CR, one final LF, no Cyrillic or Greek | C9 | `file`, `iconv`, `grep`, `perl`, `xxd`, the language command of the QA skill | PASS | `ASCII text`; non-ASCII lines 0; tabs 0; CR 0; trailing whitespace 0; first bytes `232079`; last byte `0a`, last two `6c0a`; language hits in the file 0, in the diff 0 |
| OVERVIEW | — | The diff of `docs/architecture/OVERVIEW.md` | PASS | Unchanged since check 1 and still correct |
| `make check` if it exists | — | `ls Makefile` | Does not apply | No `Makefile` yet |

### The glob
The script `glob.cjs` (outside the repository) read the glob from the YAML
file and ran four Minimatch versions, each installed into its own empty temp
directory with `--ignore-scripts`, except 10.1.1, which is the copy inside the
local npm. Path sets:

- **listed, 64 paths:** every tracked and untracked file of the tree (`git
  ls-files`, `git ls-files --others --exclude-standard`), plus the paths the
  specs and the OVERVIEW plan. These include `.github/workflows/ci.yml`,
  `.swift-format`, `.gitignore`, `.env`, `.env.example`,
  `.claude/settings.local.json`, `.claude/agents/qa.md`,
  `.claude/skills/qa/references/player-checklist.md`, `Config/Local.xcconfig`
  and its example, `Config/allowed-dependencies.txt`, `Makefile`,
  `Tools/ClamChecks/Package.swift`,
  `Tools/ClamChecks/Sources/clam-checks/main.swift`,
  `Packages/ClamKit/Package.swift`, the four localization paths,
  `Packages/SourceTelegram/Package.swift`, `UITests/…` and
  `docs/architecture/CONTRACTS.md`.
- **edge, 21 paths:** 1 to 5 dot segments in different places,
  `docs/plan/#ROADMAP.md#`, `docs/plan/.#ROADMAP.md`, spaces, a literal `{b}`
  and a comma in a name, `A/.Env`, paths under `.swiftpm/` and `.build/`, and
  `xcshareddata/…/Package.resolved`.
- **exhaustive, 254 paths:** every path of depth 1 to 7 made of the segments
  `a` and `.b`.

| Pattern | `dot` | listed missed | edge missed | exhaustive missed | fewest dot segments in a miss |
|---|---|---|---|---|---|
| the file's glob | off | 0/64 | 1/21 (`.a/.b/.c/.d/.e`) | 37/254 | 5 |
| the file's glob | on | 0/64 | 0/21 | 0/254 | — |
| `**`, for comparison | off | 30/64 | 17/21 | 247/254 | 1 |
| `**`, for comparison | on | 0/64 | 0/21 | 0/254 | — |

All four versions give the same numbers. Each expands the glob into 61
patterns, none of which `makeRe` reports as invalid. The developer's numbers
(254 paths, 37 missed with `dot` off, the fewest at 5 dot segments) are
reproduced. Compiling the glob takes 0.2 to 2.1 ms, and 6,400 matches take 1
to 6 ms in every version, so the size of the brace expansion costs nothing.

**The remaining gap does not matter for this repository.** With `dot` off, a
path with five or more dot segments is missed. The most dot segments in any
real or planned path is 1: `docs/plan/.gitkeep`, `.claude/…`, `.github/…`.
The tree holds no ignored file now, and the deep dot directories the specs
name (`.build/`, `.swiftpm/`) are ignored or will be (TASK-002), so they never
reach a pull request. The comment in the file states the limit ("Covers up to
four dot segments in one path").

**Mutations: the glob test can fail.** These broken copies were matched in
memory only; the file in the repository was not touched.

| Broken copy | Result |
|---|---|
| The four-dot alternative removed | All four versions, `dot` off: edge missed 4/21, exhaustive missed 93/254, the fewest at 4 dot segments |
| The last `}` dropped | 3.1.2, 5.1.6 and 9.0.5: every path missed under both settings (64/64, 21/21, 254/254). 10.1.1: not finished, see below |
| Plain `**` (the file of check 1) | `dot` off: 30 of the 64 real and planned paths missed |

The dropped-brace copy is slow in Minimatch 9.0.5 and 10.1.1: the first run
went to the background after 120 s, and it was stopped by SIGTERM (exit 143)
while 10.1.1 was matching that copy. Every other row of the first run had
finished. The fast timings above are for the file's glob, not for a broken one.

### What stays unproved until the first review
CodeRabbit's docs, read on 2026-11-27, give the rules but not the code that
applies them:
- `docs.coderabbit.ai/configuration/path-instructions`: "Glob matching follows
  Minimatch rules, including brace expansion" and "Only the path glob is
  parsed. If a glob is invalid, CodeRabbit skips that entry."
- `docs.coderabbit.ai/pr-reviews/which-files`, about `path_filters`: "hidden
  files (names starting with a dot) are included".

Both quotes in the developer notes were found word for word. Whether
CodeRabbit parses this glob, and with which `dot` setting it matches, cannot
be proved before H1. I found no evidence that it rejects nested braces or empty
brace alternatives: four Minimatch versions accept the glob, and the docs name
brace expansion as supported. So this is not a reason for FAIL.

The cost if it happens: a skipped entry means that the four instructions reach
no file at all, which is worse than `"**"`. What to read in the by-hand step of
C9 (`@coderabbitai configuration`, after H1): the reply lists the
`path_instructions` entry with this glob, and neither the walkthrough nor the
reply shows a warning about the file or about an invalid glob (ADR-0005 V19).
If the entry is missing or flagged, that is a defect of this task, and it goes
back the way of a review finding.

### Change scope, spec and invariants
- `git status --short`: ` M` OVERVIEW, BOARD, the E-03 spec and the task file;
  `??` `.coderabbit.yaml` and `docs/qa/TASK-001.md` (this report). The two
  editor files in `docs/plan/` were not counted. Everything is in the task's
  "May be changed". No file of "Must not be touched" changed.
- The spec change is a small detail with lines in "History"; the status stays
  `approved`.
- Invariants: no code, no module, no position. Paragraph 4 now matches
  ADR-0002 rules 1 and 2 without going wider.

### Security and language
- The secret search over `git diff` and the file found no value: no 32-hex
  run, no number of 10 or more digits, no key header, no `ghp_`, `sk-`, `xox`
  or `AKIA`, no `api_id` or `api_hash` with a value. No new sensitive file
  name.
- The language command of the skill, with the file marked intent-to-add, and
  `perl` on the file alone: 0 lines each.

### Findings
Blocking: none. B1 and N1 of check 1 are closed.

Non-blocking (task proposals):

- **N2** (from check 1, still open): ADR-0002 rule 2 has no test-target
  exception for skins. A question for the architect before E-05.
- **N3.** The task file's developer notes contradict themselves. The bullet
  "Done" still says the entry has `path: "**"`, while the bullet about B1 says
  that was the first version and gives the brace glob. It is one stale phrase,
  so it is not blocking. If the dispatcher wants it fixed before the commit,
  that goes through the developer.
- **N4.** The glob cannot be checked by eye. The comment in the file and the
  developer notes explain it. If C9 shows that CodeRabbit sets `dot: true`, a
  later task could go back to `"**"`.

One summary line for the PR: `QA: no build or tests (none exist); schema V2 valid except version (check-jsonschema), hygiene clean; glob matches all 64 real and planned paths in Minimatch 3/5/9/10 with dot off and on; mutations caught; CodeRabbit's acceptance of the glob is checked by hand in C9`

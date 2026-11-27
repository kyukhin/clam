# Clam: a starter kit for role-based development

A player for audiobooks and music kept in "non-standard" storage. The first
source is Telegram. The name: Latin *clam* means "secretly", English *clam* is
the shellfish.

## How it works

You talk to a single counterpart, the **dispatcher** (the main Claude Code
session, its instructions are in `CLAUDE.md`). It runs the pipeline itself:

- **CPO** and **Project Manager** work right in the conversation with you
  (skills in `.claude/skills/cpo` and `.claude/skills/project-manager`);
- **Architect, Developer, QA, Committer** are subagents (`.claude/agents/`),
  each in a clean context; their detailed instructions are in the skills
  `.claude/skills/<role>/`.

Development is spec-first: every epic has `docs/specs/E-NN-*.md` with the
behavior, the design and the test plan. Until you approve the spec there are no
tasks and no code. The rules are in `docs/specs/README.md`.

The dispatcher stops and waits for you:
- after every committed task (a short report and "merge and continue?");
- at the gates: the PRD, the milestone plan, the spec of every epic, ADRs about
  the stack, modules and contracts;
- when QA asks to check something on the phone;
- before pushing a branch and opening a PR (until you allow doing it without
  asking), and before merging a PR into `master`, always;
- if a task came back from QA twice or somebody has a question for you.

Git: one task is one branch `kyukhin/NNN-slug` and one commit, a PR into
`master`, linear history. Commit messages are short, in English, with no mention
of Claude.

Language: the chat with the dispatcher can be in Russian; everything in the
repository and on GitHub is in English only.

## Getting started

1. Unpack into an empty folder, `git init`, make the first commit of the kit.
   Create a private repository on GitHub and add it as `origin`; without it the
   dispatcher works locally, without PRs.
2. Open the folder in Claude Code (desktop, the Code tab, or `claude` in a terminal).
3. The first message:

> Starting the project. Begin with the CPO role: run discovery, then bring me
> the PRD for approval.

After that answer the questions, approve or edit, and say "go on" to the
reports. In a new session "where are we?" is enough: the dispatcher reads the
board and continues.

## Permissions

Claude Code asks for permission to edit files and run commands. During the first
tasks choose "always allow" for the safe commands (build, tests,
`git status/diff/add/commit`), so the pipeline does not stall at every step.
Keep `git push` on confirmation.

## Tuning

If you do not like how a role behaves, edit `.claude/skills/<role>/SKILL.md`.
The permissions and description of a subagent are in `.claude/agents/<role>.md`.
Subagents are loaded when the session starts: after editing `.claude/agents/`
restart the session.

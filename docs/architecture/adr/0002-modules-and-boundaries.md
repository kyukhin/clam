# ADR-0002: Small Swift modules in local packages, the app target as the only assembly point, boundaries checked by the build and by a tool

Status: accepted (2026-11-27)
Needs the kyukhin gate: yes (fixes the module structure)

## Context

- Invariant 1 in CLAUDE.md: the player core, the library and the position store
  know nothing about Telegram; every storage works through the `MediaSource`
  contract. Invariant 2: access to Telegram can move to a server. Invariant 3:
  the listening position is first-class data.
- PRD §8: adding a second source requires no changes in the player, the library
  and the position store.
- `2026-11-27 (kyukhin)`, for the architect: design with CarPlay in mind from
  the start. The car screen is a second interface over the same player, library
  and position store (PRD §14).
- PRD M13 and §14: the look is a skin that can be replaced without reworking
  the screens.
- CLAUDE.md, "Language": Russian and Greek text lives only in the localization
  resources.
- The stack is ADR-0001: Swift, SwiftPM, an Xcode project for the app.
- The architect's skill requires: nothing except the app imports a concrete
  source, and a violation is caught automatically.

Checked on kyukhin's Mac on 2026-11-27 with Xcode 26.4, on a throwaway package
of three modules:

| No. | Fact |
|---|---|
| L1 | `xcodebuild`: a module that imports a module outside its dependency closure does not compile (`error: unable to resolve module dependency`), on a clean and on a repeated build. |
| L2 | `xcodebuild`: a module compiles an import of anything inside its transitive closure, declared or not. A depends on B, B depends on C: A imports C without an error. |
| L3 | `swift build`: an import of an undeclared sibling module fails on a clean build and compiles on the next one. It is not a guard. |
| L4 | SwiftPM accepts two local packages that depend on each other as long as no targets form a cycle. A separate package is not a wall by itself. |

So the manifests alone protect only what is in nobody's closure, and only
until somebody edits a manifest.

## Options

How the code is split:

| Option | Pros | Cons |
|---|---|---|
| A. One app target with folders | Nothing to set up | Nothing but a text search stops an import; the car screen and the phone screens grow into each other |
| B. One local Swift package with a module per responsibility, a thin app target, the Telegram source in a second local package | The graph is one readable text file; modules build and test separately; the main package builds without TDLib | `Package.swift` is edited by many tasks; L2 and L4 need an extra check |
| C. One Swift package per module | The strictest isolation | About 15 manifests and no guarantee beyond what B has with the check |
| D. Framework targets inside the Xcode project | Familiar to Xcode users | The graph lives in the project file, which is hard to read and to edit for agents and reviewers |

How the boundary is enforced:

| Option | Pros | Cons |
|---|---|---|
| E1. The build setup only | Free | Leaks through L2; depends on the build tool (L3) |
| E2. A lint rule on `import` lines only | Sees every import | Does not see a dependency added to a manifest |
| E3. Both, by one tool that has its own tests | Covers L1 to L4; the rules are data | A tool to maintain |

## Decision

**B with E3.** Proposed by the architect; kyukhin decides.

### The graph

```
Clam (the app target)  ──►  everything below        the ONLY assembly point

Phone screens   FeatureLibrary, FeaturePlayer, Feature…
Car screen      CarPlayUI
Skins           SkinRetro, later Skin…
UI resources    DesignSystem, Localization
Core            ListeningCore ──► LibraryCore, PlayerCore, PositionStore
Sources         SourceFake, SourceTelegram, later Source…
Contract        SourceAPI
```

| Layer | Modules | May import from the project | Frameworks |
|---|---|---|---|
| Contract | `SourceAPI` | nothing | Foundation |
| Sources | `SourceFake`, `SourceTelegram`, later `Source…` | `SourceAPI` | Foundation and the source's own libraries from the table in ADR-0001 |
| Core | `LibraryCore`, `PlayerCore`, `PositionStore` | `SourceAPI` | Never SwiftUI, UIKit or CarPlay |
| Core | `ListeningCore` | `SourceAPI`, `LibraryCore`, `PlayerCore`, `PositionStore` | Never SwiftUI, UIKit or CarPlay |
| UI resources | `Localization`, `DesignSystem` | nothing | `DesignSystem`: SwiftUI |
| Skins | `SkinRetro`, later `Skin…` | `DesignSystem` | SwiftUI |
| Phone screens | `Feature…` | Core, `SourceAPI`, `DesignSystem`, `Localization`; not each other | SwiftUI, UIKit; never CarPlay |
| Car screen | `CarPlayUI` | Core, `SourceAPI`, `Localization` | CarPlay, UIKit |
| Assembly | the app target `Clam` | everything | everything |

What each module is for:

- `SourceAPI`: the `MediaSource` contract and its types (ADR-0003).
- `SourceFake`: a source with bundled files, for tests and development.
  `SourceTelegram`: Telegram through TDLib; the only module that links TDLib.
  A Telegram gateway or S3 later is one more `Source…` module.
- `LibraryCore`: books, chapters, their order, search.
- `PlayerCore`: turning a source stream into sound; the audio session,
  interruptions, the lock screen and remote commands.
- `PositionStore`: listening positions and bookmarks, bound to the stable track
  key of the contract. It knows nothing about the player or about any source.
  The data and the storage engine are ADR-0004.
- `ListeningCore`: what is being listened to and where: "Continue", starting a
  book from its position, the next chapter, the sleep timer. It is the only
  writer of positions. Both interfaces send commands to it and read state from
  it, so the car screen saves positions exactly as the phone does.
- `DesignSystem`: the UI kit and the skin contract (colors, fonts, images,
  sizes). `SkinRetro`: the first skin, with its graphics and font files.
- `Localization`: the one String Catalog of the interface (paths in ADR-0001)
  and the access to its strings.
- `Feature…`: one group of phone screens each.
- `CarPlayUI`: the CarPlay scene and the code that builds templates.
- The app target `Clam`: creates the sources, the cores and the skin, hands
  them to both interfaces, holds the root navigation of the phone, the
  Info.plist, the entitlements and the icon.

### Rules

1. **Concrete sources.** No module except the app target depends on or imports
   a `Source…` module other than `SourceAPI`. Cores receive sources only as
   values of the contract type, handed in by the app target. Exception for
   tests: a test target may use `SourceFake`; only `SourceTelegramTests` may
   use `SourceTelegram`.
2. **Concrete skins.** No module except the app target depends on or imports a
   `Skin…` module. Phone screens take every color, font and image from
   `DesignSystem`.
3. **Two interfaces, one core.** `Feature…` and `CarPlayUI` do not import each
   other. Only `CarPlayUI` and the app target import CarPlay. Core modules do
   not import SwiftUI, UIKit or CarPlay. The app target builds the object graph
   when the process starts, before any scene connects: the car scene works when
   the phone interface was never opened.
4. **Positions.** Only `ListeningCore` writes to `PositionStore`. App life cycle
   events reach the core through the app target.
5. **Texts.** Core and source modules return typed states and errors, never
   text for the user. `Feature…` and `CarPlayUI` turn them into strings from
   `Localization`. No other module holds user-facing strings.
6. **No re-exports.** `@_exported import` is not used.
7. **Packages.** `Packages/ClamKit` holds every module except the Telegram
   source. `Packages/SourceTelegram`, created in M2, holds `SourceTelegram` and
   the TDLib binary and depends on `ClamKit` only for `SourceAPI`. The manifest
   of `ClamKit` declares no dependency on that package; SwiftPM would allow one
   (L4), so the boundary check fails on it. `ClamKit` builds and tests without
   downloading TDLib.
8. **Growing.** A new module that fits a layer and its row above (a new
   `Feature…`, `Source…` or `Skin…`) is added by the spec of its epic. A new
   layer or a change of these rules is a new ADR.

### How violations are caught

1. **The build.** `xcodebuild` refuses an import from outside the dependency
   closure (L1). No library module has a concrete source or skin in its
   closure, so such an import does not compile.
2. **The boundary check,** a command-line tool in the repository. It is part
   of the check command that the developer, QA and the committer run on
   kyukhin's Mac for every task; that run decides. As a second line the
   pull-request workflow on GitHub runs the same command; it blocks no merge
   (E-01). The check:
   - reads the manifests (`swift package dump-package`), computes the closure
     of every target and fails on rules 1, 2 and 7;
   - reads every `import` line of every source file and fails on an import
     that the layer table does not allow, which covers L2 and rules 3, 5 and 6;
   - keeps the layer table as data in one file next to the tool;
   - has its own tests: a fixture package for each kind of violation has to
     fail, a clean one has to pass.
3. **Review.** QA checks the change scope of every task, as the process
   already requires. Rule 4 has no automatic check before `PositionStore`
   exists; ADR-0004 decides whether its write interface can enforce it.

## Consequences

Easier:
- A second source is a new `Source…` module and one line in the app target.
- The car screen cannot drift from the phone: both sit on `ListeningCore`.
- A second skin is a new `Skin…` module and one line in the app target.
- Everything above `SourceAPI` is tested with `SourceFake`, without Telegram.

Harder:
- More modules than a single target; `Package.swift` and the layer table are
  touched by many tasks.
- The import scan is textual. The tool's tests have to cover every import form
  Swift allows (`@testable import`, `internal import`, `import struct A.B`).
- Root navigation lives in the app target, so the app target is more than
  three lines; it stays free of business logic.

What appears:
- E-01 creates `Packages/ClamKit`, the app target and the boundary check. Of
  the modules above it creates only what its one screen needs; every other
  module arrives with the epic that fills it.
- ADR-0003 (the contract, in `SourceAPI`) and ADR-0004 (`PositionStore`, rule 4).
- E-05 designs `DesignSystem` and `SkinRetro`; E-06 fills `Localization`;
  E-09 creates `CarPlayUI`.
- `docs/architecture/OVERVIEW.md` shows the modules that exist.

## History
- 2026-11-27: proposed.
- 2026-11-27: kyukhin wants builds made locally, not on GitHub Actions, so the
  boundary check runs locally too; the architect rewords "How violations are
  caught". Acceptance waits for kyukhin's explicit word.
- 2026-11-27: accepted by kyukhin ("ok", in answer to "The modules decision
  and the reworded milestone plan: do you approve?").
- 2026-11-27: "How violations are caught", item 2, reworded as announced
  above and after kyukhin's later answer about the checks ("ok, let's add
  these checks. But the main testing will apparently have to be run
  locally."): the boundary check is run by the check command on kyukhin's Mac
  and, as a second line, by the pull-request workflow on GitHub. The modules,
  the rules and the check itself are unchanged.

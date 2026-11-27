# Roadmap

PRD: docs/product/PRD.md (version 1.3, approved 2026-11-27)

Two numberings meet in this file. `M0`–`M8` are milestones. The items of
section 5 of the PRD are written as `PRD M1`–`PRD M14`.

| Milestone | What can be tried | MVP items | Status |
|---|---|---|---|
| M0 Skeleton | Install Clam from TestFlight, tap one button and hear a test MP3 played through the fake source. A PR in the repository gets an automated review. | PRD M12 (license, README) | active |
| M1 Retro shell | The library and the player in the Winamp-style look, in English, Russian and Greek, playing test books from the fake source, also in the background, from the lock screen and the headset. We know whether the car screen can be developed before Apple grants the entitlement. | PRD M11, M13; PRD M4, M5 on the fake source | planned |
| M2 Telegram reads | Sign in, paste a link, see the book and its chapters in the right order. | PRD M1, M2, M3 | planned |
| M3 Telegram plays | Listen to a real book over the network: seeking, ±30 s, the next chapter by itself. | PRD M4, M5 | planned |
| M4 The position is never lost | Kill the app, reboot the phone, switch between two books: "Continue" returns to the same second. | PRD M6 | planned |
| M5 App Store, quietly | Install Clam from the App Store by a direct link. We know whether Apple lets such an app through. | PRD M14, M12 (About screen) | planned |
| M6 Night and flight | The sleep timer, bookmarks, downloading a book and listening in airplane mode. Each arrives as an App Store update. | PRD M7, M8, M9 | planned |
| M7 Car | Clam on the car screen: "Continue", books, chapters, the playing screen. | PRD M10 | planned |
| M8 MVP acceptance | A library of 3,000 books, two weeks of listening only in Clam. | the readiness criteria | planned |

After M4 kyukhin can stop listening to books in Telegram while online; M6
adds listening without a network. M5 comes right after M4 on purpose: the first
App Review happens before the download, the car screen and the rest are built.

## M0: Skeleton
Goal: a project that builds and ships to the phone, with the source boundary
and the development process in place before any feature.
Done when: kyukhin installs a build from TestFlight and hears the test MP3;
every check passes on a clean clone on kyukhin's Mac; a PR gets the free
checks on GitHub and an automated review; Clam builds from a clean clone by
the README.

### Epics
- **E-01 Stack and project skeleton**: an iOS app that builds, with the module
  boundaries of the invariants, tests, a linter, one command that runs every
  check on kyukhin's Mac, free checks for PRs on GitHub as a second line, and
  delivery to TestFlight from the Mac. ADR-0001 (the stack; CarPlay, TDLib on
  iOS and three interface languages are criteria) and ADR-0002 (modules). MVP:
  none; done when: kyukhin installs a build from TestFlight, every check
  passes on a clean clone, and a PR gets the free checks; spec: `docs/specs/E-01-project-skeleton.md`
- **E-02 Source contract and fake source**: ADR-0003, ADR-0004,
  `CONTRACTS.md`, the fake source; the app plays a bundled test MP3 through it
  from one debug button. MVP: the readiness criterion about the test source;
  done when: kyukhin hears the test MP3 on the phone and the contract tests
  pass on the fake source; spec: `docs/specs/E-02-source-contract.md`
- **E-03 Automated code review and the first checks**: `2026-11-27 (kyukhin)`:
  "CodeRabbit should be added right away, and the other small checks too."
  CodeRabbit reviews every PR; an ADR records the choice, the step of the
  pipeline where it runs and who handles its findings, and CLAUDE.md is
  updated to match. The checks that need no app code start with this epic:
  the language of texts, whitespace, files that must not be tracked, GitHub's
  secret scanning and push protection; E-01 adds the build and the tests to
  them. This epic goes first in M0. MVP: none; done when: a PR gets CodeRabbit's
  review and the first checks; spec: `docs/specs/E-03-automated-code-review.md`
- **E-04 Open-source basics**: the MIT license, a README that says what Clam
  is, states the four promises and explains building with one's own keys, an
  example file for the keys. MVP: PRD M12 without the About screen; done when:
  Clam builds from a clean clone by the README; spec: `docs/specs/E-04-open-source-basics.md`

## M1: Retro shell
Goal: the real library and player screens in the approved retro look, working
on the fake source, before Telegram is connected.
Done when: kyukhin approved the mockups of every phone screen; kyukhin
plays test books on the phone in each of the three languages, with the screen
locked and from the headset; the car screen probe is recorded.

### Epics
- **E-05 Retro design and UI kit**: the spec holds the mockups of every phone
  screen, and kyukhin approves them with the spec; then the kit, built as a
  replaceable skin: panels, the
  LED display, the scrolling title, playlist-style lists, finger-sized buttons,
  a display font with Latin, Cyrillic and Greek, VoiceOver labels. MVP: PRD
  M13; done when: the mockups are approved and the kit is on the phone.
- **E-06 Languages**: the interface in English, Russian and Greek, following
  the language of the phone, with English as the fallback. MVP: PRD M11; done
  when: every string of M1 exists in three languages.
- **E-07 Library screen**: the list of books with progress, sorting by the
  last listening, search by title, removing a book, the chapter list; on the
  fake source. MVP: PRD M2 (the list), PRD M3 (the order switch); done when:
  kyukhin browses test books on the phone.
- **E-08 Player**: play and pause, ±30 s, the slider, picking a chapter, the
  next chapter by itself; the background, the lock screen, the headset, the
  car's Bluetooth, interruptions; on the fake source. MVP: PRD M4, M5; done
  when: kyukhin listens to a test book with the screen locked.
- **E-09 Car screen probe**: find out whether the Simulator of Xcode 26 shows
  Clam's car scene without Apple's grant (ADR-0001, assumptions A4 to A6) and
  what a real car shows for Clam without the entitlement; decide whether the
  Xcode 26 build is kept. MVP: PRD M10 (risk), PRD Q1; done when: an ADR
  records the results.

## M2: Telegram reads
Goal: real books appear in the library.
Done when: kyukhin signs in once, pastes links to an own and to somebody
else's channel and sees both books with chapters in the right order.

### Epics
- **E-10 Signing in to Telegram**: the phone number, the code, the two-step
  password; the session survives restarts. Before it the architect records in
  an ADR the Telegram API terms, the App Store guidelines for a public app and
  the way App Review can sign in. MVP: PRD M1.
- **E-11 Adding a book by a link**: the preview, the error messages, the
  chapters and their order from the source. MVP: PRD M2, M3.

## M3: Telegram plays
Goal: a real book plays over the network within the quality numbers of the PRD.
Done when: kyukhin listens to a book from a channel, seeks inside a 12-hour
file in up to 5 seconds and loses nothing when the network drops.

### Epics
- **E-12 Streaming from Telegram**: playback over the network with seeking and
  moving between chapters; the behavior when the network drops. MVP: PRD M4, M5.

## M4: The position is never lost
Goal: the main pain of the PRD is closed.
Done when: scenarios S1, S3 and S10 pass on kyukhin's phone.

### Epics
- **E-13 Position and "Continue"**: the position store bound to stable
  identifiers, writing every 5 seconds and on every event of the PRD, the
  "Continue" button, readiness for sync. MVP: PRD M6.

## M5: App Store, quietly
Goal: learn whether Apple lets Clam through, before the rest of the MVP is built.
Done when: Clam has passed App Review and installs from the App Store by a
direct link; or Apple rejected it and kyukhin decided what to do next.

### Epics
- **E-14 About screen and first run**: the About screen with the four
  promises, the version and the link to the repository; the empty library
  explains what Clam is and which link to paste. MVP: PRD M12, M14.
- **E-15 Store listing and the first App Review**: the listing in three
  languages with the four promises, a privacy policy, the age rating, the
  privacy label and the export compliance answer, the way the reviewer signs
  in, the submission. No promotion. MVP: PRD M14.

## M6: Night and flight
Goal: listening before sleep and without a network.
Done when: scenarios S4, S5 and S8 pass on kyukhin's phone, and each part
passed App Review as an update.

### Epics
- **E-16 Sleep timer**. MVP: PRD M7.
- **E-17 Bookmarks**. MVP: PRD M8.
- **E-18 Download and offline**: downloading a whole book, resuming, the space
  taken, deleting, the cellular confirmation; submitted as a separate update.
  MVP: PRD M9.

## M7: Car
Goal: Clam is an app on the car screen.
Done when: scenario S7 passes in kyukhin's car. This needs Apple's
entitlement: if it has not arrived when M6 is done, M7 waits and M8 goes ahead
with everything else.

### Epics
- **E-19 Clam on the car screen**. MVP: PRD M10.

## M8: MVP acceptance
Goal: the readiness criteria of the PRD are met.
Done when: every criterion of section 11 of the PRD is met.

### Epics
- **E-20 Large library and acceptance**: the check on 3,000 books, the network
  log, kyukhin's reading of the Russian and Greek screens, two weeks of
  listening only in Clam. MVP: the readiness criteria.

## Approvals
- 2026-11-27: the milestone plan is approved by kyukhin ("both docs are ok").
- 2026-11-27: the M1 row, E-09 and the "done when" of M7 are reworded after
  the finding of ADR-0001 about the car screen; approved by kyukhin: "ok", in
  answer to "The modules decision and the reworded milestone plan: do you
  approve?"
- 2026-11-27: kyukhin: builds are made "locally; we do not spend money on
  Actions", and later the same day: "ok, let's add these checks. But the main
  testing will apparently have to be run locally." The "done when" of M0 and
  E-01 now say: the main checks and the delivery run on kyukhin's Mac; the
  free checks for PRs on GitHub are a second line that needs no secrets.
- 2026-11-27: kyukhin: "CodeRabbit should be added right away, and the other
  small checks too." E-03 is reworded and moves to the front of M0; the order
  of the milestone is E-03, E-01, E-04, E-02.

## Later
- E-xx Release 1.0, the start of promotion, with basic personal music: PRD
  section 6 and Q7, Q10, 2026-11-27
- E-xx Sync between the user's devices through the user's own iCloud: PRD Q3,
  2026-11-27
- E-xx More sources: S3, Google Drive, WebDAV, NFS: kyukhin, 2026-11-27
- E-xx Playback speed: PRD section 6, 2026-11-27
- E-xx Other formats: M4B, M4A, FLAC, OGG: PRD section 6, 2026-11-27
- E-xx One channel with several books; other ways to add a book: PRD Q2,
  2026-11-27
- E-xx Changeable skins; needs a new designer agent in the kit: kyukhin,
  2026-11-27. The agent's parameters, approved by kyukhin on 2026-11-27 ("ok"):
  model `fable`, effort `high`, tools Read, Write, Edit, Grep, Glob, Bash, no
  web access. It draws mockups, the skin description and the graphics, writes
  no app code; kyukhin approves the mockups, QA checks the graphics against
  them. Until kyukhin says otherwise the agent joins the kit with this epic,
  and the mockups of M1 are drawn by the architect.
- E-xx More of the Winamp feel: an equalizer, a visualizer: PRD Q9, 2026-11-27
- E-xx Covers and descriptions, notes on bookmarks, a rollback after a long
  pause, more interface languages, Android: PRD section 6, 2026-11-27

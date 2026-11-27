# PRD: Clam

Status: approved (2026-11-27)
Version: 1.3

## 1. Problem

People keep audiobooks and personal music that are not on streaming services
in storage that was never meant for listening: Telegram channels, cloud drives,
home servers. Many still have old libraries of MP3 music and no convenient app
to play them from where they lie. Telegram is a messenger, not a player: it
periodically forgets the listening position, has no sleep timer and no
bookmarks, and listening without a network is unreliable. Regular players
cannot take files from such storage. Clam plays audiobooks and personal music
straight from the user's own storage and does not lose the place.

## 2. Users and context

- `2026-11-27 (kyukhin)`: Clam is "a fully open-source, publicly available app".
  Anyone can install it, and anyone can read and build the code.
- `2026-11-27 (kyukhin)`: it has to be written that Clam is for "audiobooks and
  private music. Many people still have old libraries of MP3 music; we must
  let them put a library on a resource of their own and play it in a
  convenient app."
- The first user is kyukhin. The MVP is judged by kyukhin's own listening;
  the facts below describe kyukhin.
- `2026-11-27 (kyukhin)`: the phone is an iPhone. The MVP is built for iOS only.
- `2026-11-27 (kyukhin)`: there is a paid Apple Developer account.
- `2026-11-27 (kyukhin)`: listens in four situations, and all of them must work
  in the first version: the car screen, Bluetooth in the car, headphones on the
  go, at home before sleep.
- `2026-11-27 (kyukhin)`: "I think this is a game changer; we must request it
  right away and design with CarPlay in mind."
- `2026-11-27 (kyukhin)`: books are arranged differently: many chapter files in
  the order of messages; many files out of order, with the order in the file
  name or the tag; one file for the whole book.
- `2026-11-27 (kyukhin)`: part of the books sits in other people's channels
  kyukhin is subscribed to.
- The file format is MP3.
- `2026-11-27 (kyukhin)`: "we must assume that at some point the library becomes
  large".

## 3. Promises and positioning

`2026-11-27 (kyukhin)`: marketing must state: "free FOREVER, no tracking FOREVER,
no ads FOREVER, open source".

- **What Clam is:** a player for audiobooks and personal music that live in
  the user's own storage.
- **The wording:** "Free forever. No tracking forever. No ads forever. Open
  source." It stands in the App Store listing in every language of the app, in
  the repository README and on the About screen of the app.
- **Free forever:** no price, no purchases, no subscriptions, no paid features.
- **No tracking forever:** no analytics, no identifiers, no third-party code
  that sends data anywhere. The app talks only to the storage the user
  connected and, once sync exists, to the user's own iCloud. Crash reports
  come only through Apple's own opt-in sharing.
- **No ads forever:** no ad code, no sponsored content, no promotion of other
  products inside the app.
- **Open source:** the whole app lives in the public repository under the MIT
  license (`2026-11-27 (kyukhin)`), and anyone can build it with their own keys.

Two CPO decisions that follow from the promises:

- **No service of ours.** Clam has no server, account or cloud run by us. The
  only running cost is the Apple Developer fee, which is what makes "forever"
  affordable.
- **No content of ours.** Clam ships no books, no catalog, no search for
  channels and no suggested links. The user brings the link.

## 4. Key scenarios

- S1. I listen to a book in the car and switch off the engine. Two days later I
  open Clam, tap "Continue" and hear the same place (a rollback of no more than
  5 seconds).
- S2. I sign in to my account once and paste a link to a book; it appears in
  the library with its title, number of chapters and duration.
- S3. The system unloaded the app, the phone ran out of battery or somebody
  called: the position of the book is not lost.
- S4. Before a flight I download a whole book and listen to it in airplane mode
  from start to finish.
- S5. Before sleep I set the timer to 30 minutes or "until the end of the
  chapter". In the morning I return to where I fell asleep: with the −30 s
  button or by a bookmark.
- S6. On the go in headphones I pause, resume and skip ±30 s with the headset
  buttons and from the lock screen, without opening the app.
- S7. In the car I see Clam on the car screen. I tap "Continue" or pick a book
  from the list and control pause and ±30 s from the screen and the steering
  wheel buttons, without touching the phone.
- S8. I put a bookmark at an important place and a week later return to it in
  one tap.
- S9. A book made of one 12-hour file and a book made of 80 chapters posted out
  of order both play in the right order; seeking to any place of the big file works.
- S10. I listen to two books in turn; each has its own position.

## 5. MVP (in scope)

`2026-11-27 (kyukhin)`: the MVP has books only; for books the sleep timer, the
±30 s skip and bookmarks are a must; a book can be downloaded as a whole.

- **M1 Signing in to the source.** I sign in to my account once. After
  restarting the app and the phone the sign-in is not asked again. (S2)
- **M2 Library.** `2026-11-27 (kyukhin)`: a book gets into the library by a link
  to it. I paste the link; Clam shows the title and the number of chapters and
  adds the book after I confirm (the preview is a CPO decision). This works for
  my own and for other people's books. A link that is not recognized, gives no
  access or has no audio behind it gets a clear message. Every book in the
  library shows its title, the number of chapters, the progress in percent and
  a "downloaded" mark. The library is sorted by the last listening and has
  search by title. A book can be removed from the library; nothing changes in
  the source. (S2, S10)
- **M3 Chapter order.** Chapters go as in the source; a book has a switch to
  the order "by file name". A book made of one file is one chapter. (S9)
- **M4 Player.** Play and pause, ±30 s, a slider over the chapter, picking a
  chapter from the list; the next chapter starts by itself. A book that is not
  downloaded plays over the network. The sound goes on in the background and
  with the screen locked. (S1, S6, S9)
- **M5 Outside control.** The lock screen, the headset, the car's Bluetooth and
  the car screen show the book and the chapter and give pause and ±30 s. The
  "next" and "previous" buttons on the headset and the steering wheel skip
  ±30 s instead of switching chapters (a CPO decision). (S6, S7)
- **M6 Position.** Every book has its own position: the chapter and the second.
  It survives a pause, a call, the app being unloaded by the system, a reboot
  and an empty battery. The main screen has a "Continue" button for the last
  book. (S1, S3, S10)
- **M7 Sleep timer.** 15, 30, 45, 60 minutes or "until the end of the chapter".
  The sound fades out, the position is saved. (S5)
- **M8 Bookmarks.** One button puts a bookmark at the current place. A book has
  a list of bookmarks (chapter, time, date); a tap jumps there; a bookmark can
  be deleted. There are no text notes. (S5, S8)
- **M9 Download.** The "Download" button loads the whole book; a downloaded
  book plays without a network. The download progress and the space taken by
  each book and by all of them are visible. Downloaded files can be deleted;
  the position and the bookmarks stay. An interrupted download continues from
  where it stopped. On a cellular network the download asks for confirmation
  (a CPO decision). (S4)
- **M10 Clam on the car screen (CarPlay).** Clam is an app on the car screen.
  It shows "Continue" for the last book, the list of books with progress (the
  most recent first; the full library with search stays on the phone), the
  chapters of a book and the playing screen with pause and ±30 s. Everything
  there works with the phone locked and untouched. Signing in and adding books
  happen on the phone. `2026-11-27 (kyukhin)`: confirmed, the CarPlay app is
  part of the MVP. (S7)
- **M11 Languages.** `2026-11-27 (kyukhin)`: the interface languages are
  "English, Russian, Greek". The interface follows the language of the phone;
  any other language falls back to English. Titles of books and chapters are
  shown as they are in the source.
- **M13 Retro design.** `2026-11-27 (kyukhin)`: "I need a retro design, exactly
  the same as Winamp's." The phone screens look like the classic late-1990s
  Winamp: compact dark beveled panels, an LED-style time display, a scrolling
  title line, the chapter list and the library as a playlist with green text
  on black. `2026-11-27 (kyukhin)`: "make it almost the same, just remove their
  own icons": the layout and the look stay as close to Winamp as possible,
  every graphic is drawn by us, and there are no Winamp icons, logo or name
  (Q9). CPO decisions on top of that: buttons are large enough for a finger
  (at least 44 points); the
  display font has Latin, Cyrillic and Greek letters; VoiceOver reads every
  control; the car screen keeps Apple's standard look, because CarPlay does
  not allow a custom one (the architect confirms). The look is built as a
  skin, a replaceable set of graphics, colors and fonts, so that other skins
  can follow without reworking the screens. An equalizer, a spectrum
  visualizer and a choice of skins are not in the MVP.
- **M12 Open source and promises.** The repository has the MIT license, a
  README with the four promises and instructions for building Clam with one's
  own keys. The About screen shows the four promises, the version
  and a link to the repository.
- **M14 In the App Store, without promotion.** `2026-11-27 (kyukhin)`: "we
  should go through the App Store review right away, already for the MVP, so
  that it is clear whether they let this through or not. Just do not advertise
  the app anywhere." Clam is submitted to App Review as soon as it has its
  essential functions: signing in, adding a book by a link, playing over the
  network and keeping the position (the moment is a CPO decision). Every later
  part of the MVP arrives as an update and goes through review again. The
  listing is in three languages, states the four promises and describes
  audiobooks only. There is a privacy policy, and support goes through GitHub
  issues. The empty library explains in two or three sentences what Clam is
  and which link to paste. We do not promote Clam anywhere until release 1.0.

## 6. Later (not MVP, but planned)

- **Release 1.0: we start telling people**, see Q7 and Q10. Its condition is
  basic personal music; the listing then says "audiobooks and personal music",
  and promotion begins.
- Syncing the library, the positions and the bookmarks between the user's
  devices, see Q3. `2026-11-27 (kyukhin)`: "it would be great". How: through the
  user's own iCloud, under the Apple ID that is already on the device. That
  needs no server of ours and no sign-in of ours, and nobody else, including
  us, can read the data. It works between Apple devices only, and the sign-in
  to the source is still done on every device. The architect confirms the
  mechanism.
- **Personal music**, see Q10: a music library that the user put on storage of
  their own plays as albums in order, with shuffle and repeat; a queue comes
  after that. `2026-11-27 (kyukhin)`: the MVP has books only.
- Playback speed. `2026-11-27 (kyukhin)`: not chosen for the MVP.
- More sources: S3, Google Drive, WebDAV, NFS. `2026-11-27 (kyukhin)`: for the
  future, add listening to music and audiobooks from storage on Google Drive.
  `2026-11-27 (kyukhin)`: also add NFS as storage, for those who keep an
  always-on VPN to a home server. The order of the sources is decided in the
  milestone plan.
- Other formats: M4B, M4A, FLAC, OGG.
- One channel with several books, see Q2.
- Other ways to add a book: the share sheet, a list of my channels, a whole
  Telegram folder.
- Covers and descriptions of books from the source, notes on bookmarks, an
  automatic rollback of a few seconds after a long pause.
- **Changeable skins.** `2026-11-27 (kyukhin)`: it has to be mentioned that
  skins can be changed in the future and that creating them needs a new agent,
  a designer. The look of the MVP (M13) is the first skin; skins the user
  loads (Q9) belong here too.
- More of the Winamp feel: an equalizer, a spectrum visualizer.
- More interface languages. Android.

## 7. Non-goals (deliberately not doing)

- Monetization of any kind, ads, tracking, accounts and servers of ours.
- A catalog, a search or recommendations of content.
- Changing the contents of the source: uploading, editing and deleting files.
  Clam only reads.
- Messenger features: messages, chats, notifications.
- Podcasts and streaming services.
- Tag editing, conversion, video.

## 8. Storage sources

- **The first source is Telegram.** One channel is one book. A book is added
  by a link to its channel (`2026-11-27 (kyukhin)`): a public link, an invite
  link or a link to a message of the channel. The user's own and other
  people's channels are supported, public and private. Clam itself does not
  join channels: a private channel must already be joined in Telegram (a CPO
  decision). Only MP3 files are taken, other messages are skipped. The chapter
  order is the order of messages, with the switch "by file name" (M3).
- **Future:** S3, Google Drive, WebDAV, NFS (a home server reached over an
  always-on VPN).
- **The detachability requirement.** Adding a second source requires no changes
  in the player, the library and the position store. The screens and texts of
  the app say "book" and "chapter", not "channel" and "message". Access to
  Telegram can later be moved from the phone to a gateway the user runs,
  without changing the rest of the app.

## 9. Data, sign-in and privacy

Everything in this section is a CPO decision unless a date and kyukhin are named.

- **No Clam account and no server of ours.** The only sign-in is to the source.
- **Signing in to Telegram** happens once, on the phone: the phone number, the
  code from Telegram, then the two-step password if the account has one. Clam
  shows up in Telegram's list of devices as a separate session and can be ended
  from there; Clam then asks to sign in again, and the library, the positions
  and the bookmarks stay. Signing in by QR code comes later.
- **Signing out** in Clam ends the session. The library, the positions, the
  bookmarks and the downloaded books stay on the phone until the user deletes them.
- **What is stored, on the phone only:** the source session; the library
  (books, chapters, the chosen order); positions and bookmarks; settings;
  downloaded files and the streaming cache.
- **What leaves the phone:** nothing except requests to the source.
- **Backup.** The library, the positions and the bookmarks are part of the
  phone's backup and survive a phone replacement. The session and the
  downloaded files are not: after a restore the user signs in and downloads
  again. The architect confirms this is feasible.
- **Ready for sync.** Positions and bookmarks are stored with the time of the
  change and are bound to stable identifiers of the book and the chapter, so
  that sync can be added after the MVP without converting or losing what the
  user already has.
- **System permissions.** Clam asks for none in the MVP: no microphone,
  location, contacts, photos or notifications.
- **The app's own keys.** The Telegram `api_id` and `api_hash` come from
  my.telegram.org. The official builds carry the project's keys; the
  repository never does (invariant 4 in CLAUDE.md); whoever builds from source
  uses their own. kyukhin gets the project's keys before the first Telegram
  milestone.
- **Installing.** `2026-11-27 (kyukhin)`: Clam is installed through TestFlight
  from the start, and from the App Store once it has passed review (M14).
  TestFlight needs an App Store Connect record and the export compliance
  answer; testers outside the team go through Apple's beta review.
- **How App Review signs in** is not known yet: a reviewer cannot receive a
  Telegram code for an account of ours. The architect finds out how other
  Telegram clients pass review before the first submission.
- **Store forms for the first submission (M14):** the age rating
  questionnaire, the privacy label and a privacy policy. The expected privacy answer is "data not
  collected". The age rating is computed by Apple's questionnaire; Clam ships
  no content of its own. Not known yet: how Apple classifies access to other
  people's channels and which export compliance answer is correct for the
  Telegram protocol's encryption.

## 10. Quality requirements

- **The position** is written at least every 5 seconds during playback and
  immediately on pause, chapter change, a call, the sleep timer firing and the
  app going to the background. After any failure the rollback is no more than
  5 seconds.
- **Start by "Continue":** up to 2 seconds for a downloaded book, up to
  5 seconds over LTE for a book that is not downloaded.
- **Seeking to an arbitrary place** of a 12-hour file: up to 5 seconds over the
  network, without downloading the whole file.
- **Moving between chapters:** a pause of up to 1 second for a downloaded book,
  up to 3 seconds over the network.
- **Interruptions:** a call and the navigator's voice pause the book, after
  them it continues by itself. Disconnecting the headphones or Bluetooth pauses
  playback; the sound does not go to the phone speaker.
- **The network dropped** for a book that is not downloaded: the sound stops
  when the loaded buffer runs out and continues by itself when the network is
  back; the position is intact, the screen shows a clear message.
- **The book is unavailable in the source** (the channel is deleted, the files
  are removed): what was downloaded keeps playing, the position and the
  bookmarks stay, the book is marked as unavailable.
- **The car screen:** every action available there works with the phone locked
  and without touching it; the list of books opens in up to 2 seconds.
- **A large library:** with 3,000 books the library opens in up to 1 second,
  search by title answers in up to 0.5 seconds, and the start by "Continue" is
  as fast as with one book.

## 11. Success metrics and MVP readiness criteria

- kyukhin listens to books only in Clam for 2 weeks in a row.
- In those 2 weeks the position is not lost once (a rollback of no more than
  5 seconds).
- Scenarios S1–S10 are passed by hand on kyukhin's iPhone and in kyukhin's car.
- S7 needs Apple's CarPlay entitlement. Without it the car screen cannot be
  shown at all with the current Xcode, not even in a simulator (ADR-0001, V3
  and V4); the one possible exception, the Simulator of Xcode 26, is tested in
  E-09. Until the entitlement arrives M10 cannot be accepted; the other
  criteria and the two weeks of listening do not wait for it (a CPO decision).
  The MVP is complete only after S7 passes in the car.
- A downloaded book plays through to the end in airplane mode.
- 8 hours of background listening without spontaneous stops or crashes.
- The build contains a test source connected without edits to the player, the
  library and the position store.
- The large-library numbers are met on a test library of 3,000 books.
- kyukhin has read every screen in Russian and in Greek.
- kyukhin has approved the look of every phone screen against the design
  mockups.
- During a listening session the app makes no network requests except to the
  connected source (checked with a network log).
- Clam builds from a clean clone of the repository by the README, with one's
  own keys in a local file.
- Clam is available in the App Store, and every part of the MVP has passed
  App Review.

## 12. Risks

| Risk | Likelihood | Impact | What we do |
|---|---|---|---|
| App Review rejects or later removes Clam because it downloads media from a third-party source or because of copyright complaints | medium | high | We learn the answer early: the first submission comes as soon as the position works (M14), before the download, the car screen and the rest are built. Positioning as a player for the user's own storage; no catalog, search or suggested content; the architect checks the current App Store guidelines before the submission. A rejection is a stop and a question for kyukhin; TestFlight and building from source remain |
| App Review cannot test Clam, because signing in needs a Telegram code | high | high | The architect finds out how other Telegram clients pass review before the first submission |
| The download (M9) is rejected in an update after the first approval | medium | medium | It is submitted as a separate update; if it is rejected, the store build stays without it and the question goes to kyukhin |
| The Telegram API terms restrict a public third-party client | medium | high | The architect reads the current terms before the first Telegram milestone; Clam is marked as unofficial, does not use Telegram's name or logo as its own and only reads |
| Telegram limits or bans a user's account for an unofficial client | low | high | The project's own `api_id`, reading only, no mass parallel downloads, respecting the limits |
| The project's `api_id` is pulled out of the official build and abused | medium | medium | It never gets into git; it can be replaced with a new build |
| Flood limits when downloading whole books (gigabytes) | medium | medium | A download queue, pauses and retries, resuming from where it stopped |
| Seeking over the network inside a big file turns out slow | medium | high | Checked first thing in the streaming milestone; the fallback is downloading (M9) |
| iOS stops the background download of big files | high | medium | The architect decides; the minimum is that the download runs while the app is open or playing |
| Apple does not grant the CarPlay entitlement or delays it | medium | high | kyukhin applies right away: the request is the critical path of M10, because without the entitlement the car screen cannot be shown even in a simulator with the current Xcode (ADR-0001). E-09 tests the one possible exception, the Simulator of Xcode 26. Meanwhile the car works over Bluetooth (M5) |
| Somebody else's channel is deleted or its files are removed | medium | medium | Downloaded files stay, the position and the bookmarks are kept, the book is marked |
| Other people's channels are messy: several books, duplicates, non-audio | medium | low | The order switch (M3); several books in a channel come after the MVP |
| A look copied from Winamp draws a copyright or trademark claim, or App Review rejects Clam as a copy | medium | high | Our own artwork and our own name; no original Winamp graphics, logo or name (see Q9) |
| The Russian or Greek interface reads badly | medium | low | kyukhin reads every screen in both languages (a readiness criterion) |
| Questions and bug reports from public users take time | medium | low | Support only through GitHub issues, with no promised response time |
| A TestFlight build lives 90 days | high | low | Rebuilding by an instruction; the app data survives an update |
| Secrets (`api_id`, `api_hash`, the session) get into the public repository | low | high | Invariant 4 in CLAUDE.md, a QA check in every task |

## 13. Open questions

- **Q1. The car screen in the MVP.** Closed `2026-11-27 (kyukhin)`: the CarPlay
  app is in the MVP (M10) and kyukhin applies to Apple for the entitlement
  right away. Not verified yet: what the car screen shows for Clam before the
  entitlement arrives. Public sources disagree on whether the system
  "Now Playing" screen works for an app without it; E-09 checks this on a
  device. Found by the architect on 2026-11-27 (ADR-0001): Apple's
  documentation says the system does not show an app in CarPlay without the
  entitlement, and the iOS Simulator of Xcode 27 does not support CarPlay.
- **Q2. How a book gets into the library.** Closed `2026-11-27 (kyukhin)`: "a
  link to the channel with the book is given". Accepted by default with the
  approval of the PRD: one channel is one book in other people's channels
  too; a channel with several books looks like one long book until the
  follow-up after the MVP.
- **Q3. Several devices.** Options: (a) the position lives only on this iPhone,
  sync comes after the MVP; (b) sync in the MVP.
  `2026-11-27 (kyukhin)`: sync "will apparently need a backend or some
  migrations. It is completely unclear how to do it without violating privacy."
  `2026-11-27 (kyukhin)`: "It would be great, but it is completely unclear how
  to do it without a backend. And with a backend we start dealing with
  authorization."
  The CPO's answer: the user's own iCloud needs neither a backend nor a sign-in
  of ours (see "Later"), and "Ready for sync" in "Data, sign-in and privacy"
  removes the data conversion later.
  Closed by the recommendation, accepted by default (2026-11-27): (a), sync
  comes after the MVP as an item of "Later".
- **Q4. The size of a collection.** Closed `2026-11-27 (kyukhin)`: "we must
  assume that at some point the library becomes large". The CPO turns it into
  numbers: Clam is built and checked for 3,000 books (see "Quality
  requirements"), the library has search by title, there is no limit on
  downloads, we show the space taken.
- **Q5. The language of the interface.** Closed `2026-11-27 (kyukhin)`:
  "English, Russian, Greek" (M11). Russian and Greek live only in the
  localization resources; the rule and the exception are in CLAUDE.md, "Language".
- **Q6. How Clam gets onto the phone in the MVP.** Closed `2026-11-27 (kyukhin)`:
  "we can probably go straight from TestFlight".
- **Q7. When Clam becomes public in the App Store.** Closed
  `2026-11-27 (kyukhin)`, replacing the "ok" given earlier the same day to
  "TestFlight for the MVP, the App Store after it": Clam goes through App
  Review already in the MVP and is in the App Store without promotion (M14).
  Release 1.0 is the moment we start telling people.
- **Q8. The license.** Closed `2026-11-27 (kyukhin)`: "MIT". The options were
  MPL-2.0 (the CPO's recommendation), MIT and GPL-3.0.
- **Q9. How close to Winamp.** Closed `2026-11-27 (kyukhin)`: "make it almost
  the same, just remove their own icons". The CPO reads this as option (a):
  the same layout, proportions and mood, with every graphic drawn by us and no
  Winamp icons, logo or name. The other options were a pixel-exact copy of the
  original skin, which the CPO advised against, and skins the user loads,
  which is in "Later".
- **Q10. Music and the public release.** Closed `2026-11-27 (kyukhin)`: "ok" to
  the recommendation. Basic music (albums in order, shuffle, repeat) is a
  condition of release 1.0, the moment we start telling people; only then the
  store listing says "audiobooks and personal music". The MVP keeps books
  only, and its listing describes audiobooks only. The other options were
  release 1.0 with audiobooks only and basic music in the MVP.

## 14. kyukhin's instructions for other roles

- `2026-11-27 (kyukhin)`, for the architect: "Automated code review has to be
  added, CodeRabbit or somebody else." This is a requirement for the
  development process, not for the product. The PM puts it into the first
  milestone; the architect compares the tools (CodeRabbit and the alternatives)
  in an ADR and proposes at which step of the pipeline the review runs and who
  handles its findings.
- `2026-11-27 (kyukhin)`: all texts on GitHub are in English only. The rule and
  the localization exception are in CLAUDE.md, "Language".
- `2026-11-27 (kyukhin)`, for the architect: design with CarPlay in mind from the
  start. The stack ADR and the modules ADR treat the car screen as a second
  interface over the same player, library and position store.
- For the architect: before the first Telegram milestone read the current
  Telegram API terms and the App Store guidelines on media from third-party
  sources as they apply to a public app, and record the findings in an ADR.
- For the PM: the entitlement request is kyukhin's action in the Apple
  Developer account. Track it on the board as an external dependency.
- For the PM and the architect: the retro design (M13) needs mockups of every
  phone screen that kyukhin approves before the first interface task.
- `2026-11-27 (kyukhin)`: creating skins needs a new agent, a designer. For
  the PM: the designer role (an agent definition and a skill) joins the kit
  before the first work on new skins; until kyukhin decides otherwise, the
  mockups of the MVP look are drawn by the architect. For the architect: the
  UI kit is built so that a skin can be replaced.

## 15. Change history

| Date | Version | What changed | Why |
|---|---|---|---|
| 2026-11-27 | 0.1 | First draft | Discovery with kyukhin: two rounds of questions |
| 2026-11-27 | 0.2 | The CarPlay app moved into the MVP (M10); Q1 closed; S7, the readiness criteria and the CarPlay risk updated | kyukhin's decision: CarPlay is a game changer, apply right away and design for it |
| 2026-11-27 | 0.3 | Added the section "Data, sign-in and privacy" and question Q6 | kyukhin asked what is stored, how sign-in works and what the age rating is |
| 2026-11-27 | 0.4 | NFS added to the future sources | kyukhin's request |
| 2026-11-27 | 0.5 | A book is added by a link: S2, M2, the sources section; Q2 closed | kyukhin's answer to Q2 |
| 2026-11-27 | 0.6 | Sync constraint (no server of ours) and "Ready for sync" | kyukhin's concern about a backend, migrations and privacy |
| 2026-11-27 | 0.7 | Clam is a public open-source app: new section "Promises and positioning", M11 languages, M12 open source, release 1.0 in "Later", non-goals, store forms and risks reworked; Q5 and Q6 closed, CarPlay in the MVP confirmed; new Q7 and Q8 | kyukhin's answers: three interface languages, TestFlight, CarPlay in the MVP, a fully open-source public app, the four promises in marketing |
| 2026-11-27 | 0.8 | Q7 closed: TestFlight for the MVP, release 1.0 right after; Q8 closed: the MIT license | kyukhin's answers |
| 2026-11-27 | 0.9 | Large library: 3,000 books in the quality requirements and the readiness criteria, search and sorting in M2, recent books on the car screen; Q4 closed. Sync moved to the second place in "Later" with the iCloud approach | kyukhin's answers on the library size and on sync |
| 2026-11-27 | 0.10 | M13 retro design in the Winamp style, the mockup criterion, the copy risk, new Q9 | kyukhin's request: "a retro design, exactly the same as Winamp's" |
| 2026-11-27 | 0.11 | Q9 closed: almost the same as Winamp, our own graphics, no Winamp icons, logo or name | kyukhin's answer to Q9 |
| 2026-11-27 | 0.12 | The problem, the users and the positioning now name audiobooks and personal music; the music item in "Later" reworded; new Q10 | kyukhin's request: old MP3 music libraries on the user's own storage |
| 2026-11-27 | 1.0 | Approved. Q10 closed: basic music is a condition of release 1.0. Q3 and the second half of Q2 closed by the recommendation, accepted by default | kyukhin's answer to "Answer Q10 and say whether you approve the PRD": "ok" |
| 2026-11-27 | 1.0 | The person who makes the decisions is named `kyukhin` throughout the document; no change of meaning | kyukhin's request |
| 2026-11-27 | 1.1 | Back to draft. New M14: App Review already in the MVP, Clam in the App Store without promotion; release 1.0 redefined as the start of promotion; Q7 replaced, Q10 adjusted; store forms, the readiness criteria and the App Review risks updated | kyukhin's decision: go through the App Store review right away, for the MVP, and do not advertise the app |
| 2026-11-27 | 1.1 | Approved | kyukhin: "both docs are ok" |
| 2026-11-27 | 1.2 | Changeable skins in "Later"; the MVP look is built as a replaceable skin; a designer agent is needed for creating skins | kyukhin's request, made together with the approval |
| 2026-11-27 | 1.3 | Back to draft. The car screen cannot be shown without Apple's entitlement, not even in a simulator: the readiness criterion about S7, the CarPlay risk and Q1 corrected | The architect's finding in ADR-0001; the earlier text rested on an assumption the PRD had marked "the architect confirms" |
| 2026-11-27 | 1.3 | Approved | kyukhin: "I am ok with the PRD" |
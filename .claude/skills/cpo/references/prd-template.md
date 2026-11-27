# PRD: <name>

Status: draft | approved (YYYY-MM-DD)
Version: 0.1

## 1. Problem
One paragraph: who, what they do now, what hurts, why existing solutions do not fit.

## 2. User and context
Who uses it, on which phone, where they listen (car, walk, before sleep),
how much content (the order of magnitude: books, hours, GB).

## 3. Key scenarios
Numbered scenarios in the form "I … so that …". Every scenario can be checked by hand.
S1. …
S2. …

## 4. MVP (in scope)
Each item links to the scenarios it covers.
- M1 … (S1, S2)

## 5. Later (not MVP, but planned)
- …

## 6. Non-goals (deliberately not doing)
- …

## 7. Storage sources
- The first source: Telegram (a channel = a book or album). What exactly is
  supported: public/private channels, audio files only, the order of tracks.
- Future: S3, WebDAV, …
- The detachability requirement: adding a source requires no changes in the
  player, the library and the position store.

## 8. Quality requirements
Background playback, lock screen, Bluetooth, behavior without a network,
how often the position is saved, acceptable start delays.

## 9. Success metrics and MVP readiness criteria
- kyukhin listens to books only in the app for 2 weeks.
- The position is not lost once in 2 weeks (tolerance: ≤ N seconds of rollback).
- …

## 10. Risks
| Risk | Likelihood | Impact | What we do |
|---|---|---|---|

## 11. Open questions
- …

## 12. Change history
| Date | Version | What changed | Why |
|---|---|---|---|

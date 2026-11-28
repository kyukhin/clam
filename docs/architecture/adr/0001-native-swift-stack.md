# ADR-0001: Clam is a native Swift app on Apple's frameworks, with TDLib as the only third-party code

Status: accepted (2026-11-27)
Needs the kyukhin gate: yes (chooses the stack)

## Context

What the PRD (version 1.2, approved 2026-11-27) fixes:

- `2026-11-27 (kyukhin)`: the phone is an iPhone. The MVP is built for iOS only.
  Android is in "Later" (PRD §2, §6).
- `2026-11-27 (kyukhin)`: "I think this is a game changer; we must request it
  right away and design with CarPlay in mind." The car screen is a second
  interface over the same player, library and position store (PRD M10, §14).
- `2026-11-27 (kyukhin)`: marketing must state: "free FOREVER, no tracking
  FOREVER, no ads FOREVER, open source". PRD §3 turns this into: no third-party
  code that sends data anywhere, and the whole app in a public repository. The
  license is MIT (`2026-11-27 (kyukhin)`, PRD Q8).
- `2026-11-27 (kyukhin)`: the interface languages are "English, Russian, Greek"
  (PRD M11).
- `2026-11-27 (kyukhin)`: "I need a retro design, exactly the same as Winamp's."
  PRD M13 adds: the look is built as a replaceable skin, and the display font
  has Latin, Cyrillic and Greek letters.
- `2026-11-27 (kyukhin)`: Clam is installed through TestFlight from the start
  (PRD §9).
- The first source is Telegram; the player reads a seekable byte stream from any
  source through one contract, and access to Telegram can later move to a
  gateway (PRD §8, invariants 1 and 2 in CLAUDE.md).
- Downloading a whole book, gigabytes, with resuming (PRD M9).

### What was checked on 2026-11-27

Verified in current documentation (sources at the end):

| No. | Fact |
|---|---|
| V1 | A CarPlay audio app is built only from system templates: list, grid, tab bar, alert, action sheet, now playing; search and voice control from iOS 27. At most 5 templates deep, at most 4 tabs; some cars cut lists to 12 items. iOS draws the screen. This confirms PRD M13: the car screen keeps Apple's look. |
| V2 | CarPlay guidelines: every flow works without the iPhone; no message asks the person to pick up the iPhone. |
| V3 | The entitlement `com.apple.developer.carplay-audio` is requested at developer.apple.com/contact/carplay. It has to be in the App ID and in a provisioning profile created by hand: "Adding support for CarPlay requires you to specify your app's provisioning profile manually, instead of letting Xcode manage signing automatically." Without the entitlement "the system doesn't show the app in CarPlay environment". |
| V4 | Xcode 27: "Device Hub support for CarPlay requires devices to be physically connected via USB cable (not over the network). iOS Simulator is not supported for CarPlay." Apple's CarPlay article: "In iOS 27 and later, CarPlay development requires an iPhone connected to your Mac and the CarPlay Simulator app", and the app appears there only with a provisioning profile that carries the entitlement. |
| V5 | TDLib is built for iOS by the scripts `example/ios/build-openssl.sh` and `example/ios/build.sh` of `tdlib/td`; the result is an XCFramework for devices and simulators. License: Boost Software License 1.0. It needs OpenSSL and zlib. The interface TDLib recommends is JSON (`tdjson`, plain C functions). |
| V6 | A community package, `Swiftgram/TDLibFramework` (MIT), publishes a prebuilt XCFramework for SwiftPM, built by GitHub Actions from the TDLib sources; its latest release is TDLib 1.8.71 of 2026-11-27; the download is "~300mb" for all Apple platforms. `Swiftgram/TDLibKit` (MIT) is a generated Swift wrapper over it. |
| V7 | OpenSSL is on Apple's list of SDKs that require a privacy manifest and a signature, and "any SDKs that repackage those on the list are included". Flutter and Hermes are on the same list. |
| V8 | `BGContinuedProcessingTask` (iOS 26.0 and later): starts in the foreground from a person's action, continues after the app goes to the background, "can also use the network", shows progress in a Live Activity where the person can cancel it; the system can end it under resource pressure and ends it when the app is closed in the app switcher. |
| V9 | `AVAssetResourceLoaderDelegate` with `AVAssetResourceLoadingDataRequest`: the app is told "the range of bytes within the resource that are required by the underlying media system" and supplies them. This is the way to feed `AVPlayer` from our own byte source. |
| V10 | Xcode 27.2: Swift 6.4, iOS 27.2 SDK, runs on macOS Tahoe 26.6 or later, deployment targets iOS 15 to 27. Xcode 26.4 to 26.6 are supported on macOS 26.2 to 26.x only, not on macOS 27. Starting April 2027 uploads to App Store Connect must be built with the iOS 27 SDK. An app built with the iOS 27 SDK must use the scene life cycle and have a launch screen key (upload error ITMS-90870 otherwise). |
| V11 | GitHub Actions: `xcode-27` (macOS 27, arm64) and `macos-26` (default Xcode 26.6) are standard runners, and "use of the standard GitHub-hosted runners is free and unlimited on public repositories". `swift format` ships inside the Xcode toolchain; SwiftLint is not on the runner image. The repository `kyukhin/clam` is public. |
| V12 | TestFlight: up to 100 internal testers who are App Store Connect users; Apple describes a review only for builds given to external testers; a build is available for 90 days. Xcode Cloud: 25 compute hours a month are included in the developer program. |
| V13 | Swift 6.3 contains the first official Swift SDK for Android. |
| V14 | Flutter: `flutter_carplay` 1.7.1 (MIT) supports list, grid, tab, alert, action sheet and search templates; Now Playing only as the shared system screen. `just_audio` serves a custom byte source (`StreamAudioSource`) through a local HTTP proxy, which needs cleartext to localhost allowed. |
| V15 | React Native: `react-native-track-player` version 5 has a commercial license (free for personal and educational use only); version 4 (Apache-2.0) is frozen. |
| V16 | Kotlin Multiplatform is stable; its Swift export is still Alpha in the official documentation. |

Reported by the press, not by an Apple page: iOS 27 runs on the same iPhones
as iOS 26, the iPhone 11 and later and the iPhone SE of the 2nd generation and
later.

Verified on kyukhin's Mac:

| No. | Fact |
|---|---|
| L1 | macOS 26.5.2, Xcode 26.4 (Swift 6.3), simulator runtimes iOS 17.5 and iOS 26.4. Xcode 27 does not run on this macOS version (V10). |
| L2 | The Simulator app of Xcode 26.4 still contains the CarPlay window. |

Assumed, not verified:

| No. | Assumption | Where it gets verified |
|---|---|---|
| A1 | The size TDLib adds to the installed app is acceptable. Nothing official states it; it is not measured. | The ADR before E-10 |
| A2 | App Review accepts an app that links TDLib. Nothing found for or against. One developer reports a rejection under guideline 4.3(a) for an unofficial Telegram client built from Telegram's own iOS sources; that is about being a copy of Telegram, not about TDLib. | The ADR before E-10, then the first submission (M5) |
| A3 | `AVPlayer` fed through the resource loader plays and seeks MP3, a 12-hour file included, within the numbers of PRD §10, also in the background. The API is documented (V9); the behavior is not measured. | E-02 on the fake source, E-12 on Telegram |
| A4 | The Simulator of Xcode 26.x shows an app in its CarPlay window when the entitlement is only in the entitlements file and Apple has not granted it. | E-09 |
| A5 | XCUITest cannot drive the car screen. | E-09 |
| A6 | An app with the SwiftUI life cycle can declare the CarPlay scene in its Info.plist. | E-09 |
| A7 | kyukhin's iPhone is an iPhone 11 or later and runs iOS 26 or later. | Answered on 2026-11-27 (kyukhin): the phone is "a 16, it seems, with a fresh OS" (E-01, "Decisions"). An iPhone 16 is later than the iPhone 11, and "a fresh OS" is read as iOS 26 or later: the minimum iOS 26.0 stands. Both are seen on the phone itself when the first TestFlight build installs (E-01, C11) |
| A8 | What is said below about Flutter, React Native and Kotlin Multiplatform beyond V14 to V16 comes from general knowledge of these stacks, not from a check made today. | Not needed unless the choice changes |

## Options

- **A. Native Swift.** SwiftUI, AVFoundation, MediaPlayer, the CarPlay
  framework, BackgroundTasks, String Catalogs, SwiftPM; TDLib as a binary.
- **B. Flutter.** Dart UI, `just_audio` and `audio_service`, `flutter_carplay`,
  TDLib through `dart:ffi`.
- **C. Kotlin Multiplatform core with a SwiftUI interface.** The library, the
  positions and the source logic in shared Kotlin; UI, player and car screen
  in Swift.
- **D. React Native.** `react-native-track-player`, `react-native-carplay`,
  TDLib through a native module.

The TDLib binary, its size, its privacy manifest and the App Review questions
are the same in all four options. They do not decide the choice.

| Criterion | A. Native Swift | B. Flutter | C. KMP core + SwiftUI | D. React Native |
|---|---|---|---|---|
| Car screen as a second interface (PRD M10, §14) | Apple's framework called directly; the car scene and the phone scene use the same objects in one process | A community plugin; Now Playing only as the shared system screen; the Dart engine has to run with the phone locked and the phone UI never opened | Car UI in Swift as in A; every call into the core crosses the Kotlin to Swift bridge | A community module; the JavaScript runtime has to run with the phone locked |
| TDLib on iOS | The XCFramework linked as a SwiftPM binary target; Swift calls the C functions of `tdjson` | The same XCFramework plus a `dart:ffi` binding and a plugin wrapper | The same XCFramework through cinterop; the Android build of TDLib is reused later | The same XCFramework plus a native module written by us |
| Background audio, lock screen, remote commands, interruptions | `AVAudioSession`, `MPRemoteCommandCenter`, `MPNowPlayingInfoCenter` first-hand | `audio_service` over the same Apple APIs | As A | The player library over the same Apple APIs |
| Player fed from our own seekable byte source | `AVPlayer` with `AVAssetResourceLoaderDelegate` (V9) | Through a loopback HTTP proxy inside the app (V14) | As A; bytes cross the language bridge if the source logic is Kotlin | The player takes URLs only: a loopback HTTP proxy written by us; license problem (V15) |
| Background download of large files | `BGContinuedProcessingTask` and the audio background mode first-hand | A native plugin written by us for the same APIs | As A, in Swift | A native module written by us |
| Retro skin and display font (PRD M13) | SwiftUI with our own drawing, asset catalogs, bundled fonts | The strongest: Flutter draws every pixel itself | As A | Possible, more work than A or B |
| Three languages (PRD M11) | String Catalogs; plural rules from the system | ARB files; good | As A | A library; good |
| VoiceOver (PRD M13) | Native | Through Flutter's semantics layer | Native | Through accessibility properties |
| Third-party code to check against "no tracking" (PRD §3) | 1 binary: TDLib with OpenSSL and zlib inside | The Flutter engine plus at least 6 packages and their transitive ones | The Kotlin runtime, kotlinx libraries, TDLib | React Native, Hermes and an npm tree of hundreds of packages |
| Licenses next to MIT | BSL-1.0, Apache-2.0, zlib: compatible; an attribution file is needed | BSD-3, MIT, Apache-2.0: compatible | Apache-2.0: compatible | MIT, except the player library (V15) |
| Cost of a future Android version | The highest: UI, player and car screen are written again in Kotlin. Reused: the contract design, the specs, the test cases, TDLib with the same JSON API | The lowest for the phone UI; the audio service, Android Auto and TDLib packaging stay per platform | The core is ready; UI and car screen are native | As B |
| Tests and CI | Swift Testing, XCUITest, one toolchain: `xcodebuild` on one Mac runs every check and ships to TestFlight; a free hosted runner can repeat the checks | Dart tests plus Xcode: two toolchains | Gradle plus Xcode: two toolchains | Node and CocoaPods plus Xcode |
| Platform changes (in iOS 27: the scene life cycle, the launch screen key, Device Hub) | Available on release day | After the engine and every plugin catch up | The Swift part on release day | After the framework and every module catch up |
| iCloud sync later (PRD §6) | CloudKit first-hand | A plugin | The Swift part | A module |

| Option | Pros | Cons |
|---|---|---|
| A. Native Swift | Every hard part of the MVP (car screen, background audio, byte-range player, background download, VoiceOver) is a first-party API; one third-party binary to audit; one toolchain | Android later is a second app |
| B. Flutter | Custom look is cheap; phone UI is shared with a future Android app | The car screen, the byte source and the download each depend on a plugin or on native code we write anyway; the largest set of third-party code after D; a local HTTP proxy inside a player that promises no surprises |
| C. KMP core + SwiftUI | A future Android app gets the core for free | Two languages, two build systems and a bridge in an iOS-only MVP; the gain arrives only with Android |
| D. React Native | Phone UI is shared with a future Android app | The player library is commercially licensed or frozen; the largest dependency tree; the same native work as B |

## Decision

**Option A, native Swift.** Proposed by the architect; kyukhin decides.

The MVP is judged on an iPhone and in a car. Its risky parts are the car
screen, uninterrupted background audio, seeking in a 12-hour file from a
custom source, and a multi-gigabyte download. In A each of them is a
documented Apple API we call directly. In B and D each of them sits behind a
community plugin or behind native code we would write in Swift anyway, so the
shared-code benefit shrinks to the phone screens. C buys a cheaper Android
version with a cost paid now, and Android is not in the MVP.

What the decision fixes:

| Area | Choice |
|---|---|
| Language | Swift, language mode 6 (data-race checks on) in every module |
| Toolchain | Xcode 27.x (Swift 6.4, iOS 27 SDK) for the checks and for every build that goes to TestFlight or the App Store. Until the ADR of E-09 says otherwise, the code also builds with Xcode 26.6: Xcode 26 is the last major version whose Simulator has the CarPlay window (V4, L2, A4) |
| Minimum iOS | 26.0, iPhone only. Reasons: `BGContinuedProcessingTask` (V8) is available without a second code path; iOS 26 and iOS 27 run on the same iPhones; an iOS 26 simulator is needed for the CarPlay window of Xcode 26 |
| Phone interface | SwiftUI; UIKit only where SwiftUI has no API. The look comes from our own UI kit and a skin (ADR-0002) |
| Audio | `AVPlayer` fed through `AVAssetResourceLoaderDelegate` from the source stream; `AVAudioSession`, `MPRemoteCommandCenter`, `MPNowPlayingInfoCenter`. If A3 fails, the fallback is our own decoding on `AVAudioEngine`, by a new ADR |
| Car screen | The CarPlay framework, templates only, entitlement `com.apple.developer.carplay-audio` |
| Telegram | TDLib through `tdjson`. The binary that ships in a store build is built from the TDLib sources at a pinned commit by a script in our repository, with the official scripts (V5), and carries a privacy manifest and a signature (V7). Whether that script runs on kyukhin's Mac or on a GitHub runner is decided by the ADR before E-10. The prebuilt community package (V6) is the fallback. Details, the Swift wrapper and the size: the ADR before E-10 |
| Download | TDLib downloads inside the app process: while the app is open, while audio plays in the background, and under `BGContinuedProcessingTask` after the Download button. The system's background `URLSession` transfers do not apply: TDLib downloads over its own connections. Details: E-18 |
| Storage | Decided by ADR-0004. Constraint from this ADR: an Apple framework or the system SQLite; a third-party storage library needs its own line in the table below |
| Languages | String Catalogs, base language English (`en`), translations `ru` and `el`. The only places where Russian and Greek text lives: `Packages/ClamKit/Sources/Localization/Resources/Localizable.xcstrings` (every string of the phone and car interface), `App/InfoPlist.xcstrings` (texts of the Info.plist), `AppStore/metadata/ru/` and `AppStore/metadata/el/` (store listing, from E-15) |
| Fonts | Font files bundled in the skin module, under the SIL Open Font License 1.1 or a license equally compatible with an MIT repository. The font is chosen in E-05; it covers Latin, Cyrillic and Greek. Such fonts exist: Press Start 2P, Tiny5 and Handjet list all three scripts |
| Dependencies | SwiftPM only. No CocoaPods, no Carthage |
| Tests | Swift Testing for unit tests, XCUITest for the phone interface. Car screen: unit tests of the code that builds templates, plus checks by hand (A5) |
| Lint | `swift format lint --strict` from the toolchain, plus our own checks (ADR-0002, E-01) |
| CI and delivery | The main line: one command runs every check on kyukhin's Mac, also on a clean copy of the repository. The second line: GitHub Actions repeats the checks for pull requests on the free `xcode-27` runner (V11); it holds no secret and blocks no merge. Delivery: to TestFlight from the Mac, with `xcodebuild` and an App Store Connect API key; the signing material and the key stay on the Mac. Release builds are signed manually, because CarPlay requires a hand-made profile (V3). Details: E-01 |

Third-party code in the app:

| Dependency | License | Why things are worse without it | Network |
|---|---|---|---|
| TDLib (`tdlib/td`), from M2 | BSL-1.0 | Telegram's own library for reading a user's channels and downloading parts of files; the Bot API does neither for this use (file size limit, sees only chats the bot was added to; rechecked in the ADR before E-10) | Telegram servers only |
| OpenSSL, inside TDLib | Apache-2.0 | TDLib does not build without it | None of its own |
| zlib, inside TDLib | zlib | TDLib does not build without it | None |

**The dependency rule.** A new third-party dependency, in the app or in the
build, gets a line in this table by an edit of this ADR (a gate if it sends
anything over the network) and a line in `Config/allowed-dependencies.txt`. The
check command fails on a dependency that is not in that file (E-01).

## Consequences

Easier:
- The promise "no third-party code that sends data anywhere" is checked by
  reading one table.
- CarPlay, background audio and downloads use the newest system APIs without
  waiting for anyone.
- Agents work with one toolchain and plain-text manifests.

Harder, and what we risk:
- **Android later is a second native app.** UI, player and car screen are
  written again. The core modules are kept free of Apple UI frameworks
  (ADR-0002), which leaves the Swift SDK for Android (V13) as a possibility,
  not as a plan.
- **The car screen cannot be seen without Apple's entitlement on the current
  toolchain** (V3, V4). PRD §11 and §12 and the roadmap (E-09 in M1, M7) rely
  on a simulator that works without it; with Xcode 27 that is not so. The
  request to Apple is the critical path of everything about the car screen.
  The fallback, the Simulator of Xcode 26, rests on assumption A4, and Xcode 26
  is not supported on macOS 27.
- **The TDLib build is ours to maintain:** a build script, a pinned commit, a
  privacy manifest, a signature. Its size is unknown (A1).
- **Streaming through the resource loader is unproven** for a 12-hour file
  (A3). E-02 puts the first bytes through this path on the phone.
- **iOS 26 as the minimum** leaves out phones that stay on iOS 18 or older.
  Lowering it later means a second download path without V8.
- **`BGContinuedProcessingTask` can be refused or ended by the system.** The
  download has to resume correctly in every case (E-18).
- **kyukhin's Mac needs macOS 26.6 or a later 26.x and Xcode 27** before the
  first task (L1). Staying on macOS 26.x, not 27, keeps Xcode 26 usable until
  E-09 is done.
- **One Mac decides.** The checks that count and every TestFlight build run on
  kyukhin's Mac. The hosted runner only informs, so no clean machine stands
  between a change and `master`; a clean copy of the repository stands in for
  it. The signing key and the App Store Connect key can be used by any process
  that runs as kyukhin on that Mac. Every delivery needs the Mac and kyukhin's
  word (E-01, "What the Mac does not prove").
- Car screen texts cannot say "open Clam on your iPhone" (V2). An empty library
  on the car screen needs a neutral message (E-19).

What appears:
- The spec `docs/specs/E-01-project-skeleton.md`.
- ADR-0002 (modules) builds on this ADR.
- E-09 has to answer A4, A5 and A6 and decide whether the Xcode 26 build is kept.
- The ADR before E-10: TDLib packaging and wrapper, A1, A2, the Telegram API
  terms, the way App Review signs in, the export compliance answer.

## Sources

- Apple, CarPlay Developer Guide, 2026-10-13: developer.apple.com/download/files/CarPlay-Developer-Guide.pdf (V1, V2, V3, V4)
- Apple, "Preparing your iOS app for CarPlay development" and "Testing your app in CarPlay Simulator": developer.apple.com/documentation/carplay (V3, V4)
- Apple, Xcode 27.2 Release Notes, Device Hub, known issues (V4, V10)
- Apple, Xcode support matrix: developer.apple.com/support/xcode (V10)
- Apple, news of 2026-09, minimum SDK from April 2027: developer.apple.com/news/?id=k1mtkt1k (V10)
- Apple, TN3208 (launch screen) and "Transitioning to the UIKit scene-based life cycle" (V10)
- Apple, "Performing long-running tasks on iOS and iPadOS" and `BGContinuedProcessingTask` (V8)
- Apple, `AVAssetResourceLoaderDelegate`, `AVAssetResourceLoadingDataRequest` (V9)
- Apple, "Third-party SDK requirements": developer.apple.com/support/third-party-SDK-requirements (V7)
- Apple, App Store Connect Help, "TestFlight overview"; Xcode Cloud (V12)
- TDLib: github.com/tdlib/td, `README.md` and `example/ios` (V5)
- github.com/Swiftgram/TDLibFramework, github.com/Swiftgram/TDLibKit (V6)
- GitHub Docs, "GitHub-hosted runners"; changelog 2026-10-15, Xcode 27 runner image; `actions/runner-images`, macOS 26 arm64 readme (V11)
- swift.org, "Swift 6.3 Released" (V13)
- pub.dev: `flutter_carplay`, `just_audio` (V14); rntp.dev and the readme of `react-native-track-player` (V15); kotlinlang.org, "Interoperability with Swift using Swift export" (V16)

## History
- 2026-11-27: proposed.
- 2026-11-27: accepted by kyukhin ("Stack ok"). One change comes with it:
  kyukhin wants builds made locally, not on GitHub Actions ("locally; we do
  not spend money on Actions, and for free they would become a common place").
  The row "CI and delivery" and fact V11 wait for the architect's rework.
- 2026-11-27: reworked for that change and for kyukhin's second answer ("ok,
  let's add these checks. But the main testing will apparently have to be run
  locally."). The row "CI and delivery": checks on kyukhin's Mac are the main
  line, a free GitHub runner for pull requests is the second line, delivery to
  TestFlight goes from the Mac. V11 is unchanged and now serves the second
  line only. The option A cell of the criterion "Tests and CI", the row
  "Toolchain" and the dependency rule say "checks" where they said a hosted
  runner or CI. The row "Telegram" and the consequence about the TDLib build
  no longer say that a GitHub workflow builds the binary: where it is built is
  left to the ADR before E-10. New consequence: "One Mac decides". The status
  stays `accepted`: this is the change the acceptance came with.
- 2026-11-27: assumption A7 is marked as answered, with kyukhin's words about
  the phone as E-01 records them. No decision changes.

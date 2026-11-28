import Foundation
import Testing

/// C2 of the spec of E-03: each rule W1 to W6 of `whitespace`, and what passes.
@Suite struct WhitespaceRuleTests {
  /// Writes `bytes` to `path` in a new repository (the file stays untracked and not ignored)
  /// and returns what `whitespace` prints, each line cut down to `path:line:column RULE` or
  /// `path RULE`.
  private func findings(
    _ bytes: [UInt8], path: String = "f.txt", sourceLocation: SourceLocation = #_sourceLocation
  ) throws -> [String] {
    let repository = try TemporaryRepository()
    try repository.write(path, bytes)
    let outcome = repository.whitespace()
    #expect(outcome.standardError == "", sourceLocation: sourceLocation)
    return outcome.lines.map(Self.summary)
  }

  private func findings(_ text: String, path: String = "f.txt") throws -> [String] {
    try findings(Array(text.utf8), path: path)
  }

  private static func summary(_ line: String) -> String {
    let parts = line.components(separatedBy: ": whitespace: ")
    guard parts.count == 2, let rule = parts[1].split(separator: " ").first else {
      return "UNPARSED \(line)"
    }
    return "\(parts[0]) \(rule)"
  }

  // MARK: W1

  @Test func w1TrailingSpace() throws {
    #expect(try findings("ab \n") == ["f.txt:1:3 W1"])
  }

  @Test func w1TrailingTabIsAlsoATab() throws {
    #expect(try findings("ab\t\n") == ["f.txt:1:3 W1", "f.txt:1:3 W2"])
  }

  @Test func w1ReportsTheStartOfTheTrailingRun() throws {
    #expect(try findings("a \t \n") == ["f.txt:1:2 W1", "f.txt:1:3 W2"])
  }

  @Test func w1LineOfSpacesOnly() throws {
    #expect(try findings("a\n  \nb\n") == ["f.txt:2:1 W1"])
  }

  @Test func w1OnTheLastLineWithoutLineFeed() throws {
    #expect(try findings("a\nb ") == ["f.txt W5", "f.txt:2:2 W1"])
  }

  @Test func w1SpaceBeforeACarriageReturnIsTrailing() throws {
    #expect(try findings("a \r\n") == ["f.txt:1:2 W1", "f.txt:1:3 W3"])
  }

  @Test func w1SpaceInsideALineIsFine() throws {
    #expect(try findings("a b  c\n  indented\n") == [])
  }

  // MARK: W2

  @Test func w2TabInTheMiddleOfALine() throws {
    #expect(try findings("a\tb\n") == ["f.txt:1:2 W2"])
  }

  @Test func w2LeadingTabOnALaterLine() throws {
    #expect(try findings("a\nb\n\tc\n") == ["f.txt:3:1 W2"])
  }

  @Test func w2OneLineForEachLineWithATab() throws {
    #expect(try findings("\ta\tb\n\tc\n") == ["f.txt:1:1 W2", "f.txt:2:1 W2"])
  }

  @Test(
    "W2 does not apply to Makefile and *.mk, wherever they are",
    arguments: ["Makefile", "sub/Makefile", "rules.mk", "sub/dir/rules.mk"])
  func w2ExemptPaths(path: String) throws {
    #expect(try findings("all:\n\techo done\n", path: path) == [])
  }

  @Test(
    "W2 still applies to names that only look like Makefile or *.mk",
    arguments: [
      "Makefile.old", "makefile.txt", "Makefile/readme.txt", "rules.mkx", "rules.mk.txt", "mk",
    ])
  func w2PathsThatAreNotExempt(path: String) throws {
    #expect(try findings("a\tb\n", path: path) == ["\(path):1:2 W2"])
  }

  @Test func exemptionOfW2LeavesTheOtherRulesInMakefile() throws {
    #expect(try findings("all:\n\techo \t\n", path: "Makefile") == ["Makefile:2:6 W1"])
  }

  // MARK: W3

  @Test func w3CarriageReturnAtTheEndOfEveryLine() throws {
    #expect(try findings("a\r\nb\r\n") == ["f.txt:1:2 W3", "f.txt:2:2 W3"])
  }

  @Test func w3CarriageReturnInsideALine() throws {
    #expect(try findings("ab\rc\n") == ["f.txt:1:3 W3"])
  }

  @Test func w3CarriageReturnWithoutLineFeedOnTheLastLine() throws {
    #expect(try findings("a\r") == ["f.txt W5", "f.txt:1:2 W3"])
  }

  // MARK: W4

  @Test func w4ByteOrderMark() throws {
    #expect(try findings([0xEF, 0xBB, 0xBF] + Array("a\n".utf8)) == ["f.txt:1:1 W4"])
  }

  @Test func w4ByteOrderMarkInAnOtherwiseEmptyLine() throws {
    #expect(try findings([0xEF, 0xBB, 0xBF, 0x0A]) == ["f.txt:1:1 W4"])
  }

  // MARK: W5

  @Test func w5NoLineFeedAtTheEnd() throws {
    #expect(try findings("a") == ["f.txt W5"])
  }

  @Test func w5MoreThanOneLineFeedAtTheEnd() throws {
    #expect(try findings("a\n\n") == ["f.txt W5"])
  }

  @Test func w5ThreeLineFeedsAtTheEnd() throws {
    #expect(try findings("a\n\n\n") == ["f.txt W5"])
  }

  @Test func w5FileOfTwoLineFeeds() throws {
    #expect(try findings("\n\n") == ["f.txt W5"])
  }

  @Test func w5IsAboutTheWholeFileAndHasNoPosition() throws {
    let repository = try TemporaryRepository()
    try repository.write("f.txt", "a")
    let outcome = repository.whitespace()
    #expect(outcome.lines.count == 1)
    #expect(outcome.lines.first?.hasPrefix("f.txt: whitespace: W5 ") == true)
  }

  @Test func w5TheMessageSaysWhichOfTheTwoCasesItIs() throws {
    let repository = try TemporaryRepository()
    try repository.write("none.txt", "a")
    try repository.write("many.txt", "a\n\n")
    #expect(
      repository.whitespace().lines == [
        "many.txt: whitespace: W5 more than one line feed at the end of the file",
        "none.txt: whitespace: W5 no line feed at the end of the file",
      ])
  }

  @Test func w5EmptyFilePasses() throws {
    #expect(try findings("") == [])
  }

  @Test func w5ExactlyOneLineFeedPasses() throws {
    #expect(try findings("a\n") == [])
    #expect(try findings("a\n\nb\n") == [])
    #expect(try findings("\n") == [])
  }

  // MARK: W6

  @Test(
    "W6 reports the first byte that is not valid UTF-8",
    arguments: [
      ("a\u{FF}", [UInt8]([0x61, 0xFF, 0x0A]), "f.txt:1:2 W6"),
      ("a lone continuation byte", [0x80, 0x0A], "f.txt:1:1 W6"),
      ("a truncated three-byte sequence", [0x0A, 0xE2, 0x82, 0x0A], "f.txt:2:1 W6"),
      ("an overlong two-byte sequence", [0x61, 0xC0, 0x80, 0x0A], "f.txt:1:2 W6"),
      ("a surrogate", [0xED, 0xA0, 0x80, 0x0A], "f.txt:1:1 W6"),
      ("above U+10FFFF", [0xF4, 0x90, 0x80, 0x80, 0x0A], "f.txt:1:1 W6"),
      ("a four-byte lead that stops", [0x61, 0x62, 0xF0, 0x9F, 0x98, 0x0A], "f.txt:1:3 W6"),
    ] as [(String, [UInt8], String)])
  func w6InvalidUTF8(label: String, bytes: [UInt8], expected: String) throws {
    #expect(try findings(bytes) == [expected])
  }

  @Test func w6ValidMultiByteTextPasses() throws {
    let text = "caf" + Letters.latinEAcute + " \u{20AC} \u{1F600} " + Letters.cyrillicZhe + "\n"
    #expect(try findings(text) == [])
  }

  @Test func w6TheLastLineInvalidWithoutLineFeedAlsoGetsW5() throws {
    #expect(try findings([0x61, 0x0A, 0xFF]) == ["f.txt W5", "f.txt:2:1 W6"])
  }

  // MARK: What passes, and what the check does not do

  @Test func aCleanFilePasses() throws {
    #expect(try findings("line one\n\nline three\n") == [])
  }

  @Test func theColumnCountsBytesNotCharacters() throws {
    // Two bytes for the first letter, two for the second, then a space: column 5.
    let text = Letters.latinEAcute + Letters.cyrillicZhe + " \n"
    #expect(try findings(text) == ["f.txt:1:5 W1"])
  }

  @Test func theCheckRewritesNothing() throws {
    let repository = try TemporaryRepository()
    let content: [UInt8] =
      [0xEF, 0xBB, 0xBF] + Array("a \t\r\n\tb\u{20}".utf8) + [0xFF, 0x0A, 0x0A]
    try repository.write("all.txt", content)
    try repository.add("all.txt")
    let outcome = repository.whitespace()
    #expect(outcome.status == 1)
    #expect(try repository.read("all.txt") == content)
  }
}

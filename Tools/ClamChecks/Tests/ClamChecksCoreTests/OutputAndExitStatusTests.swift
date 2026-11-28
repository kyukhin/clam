import Foundation
import Testing

@testable import ClamChecksCore

/// C5 of the spec of E-03: the form of a line, the streams, the order and the exit statuses.
@Suite struct OutputAndExitStatusTests {
  // MARK: The form of a line

  @Test func aViolationInALineIsPathLineColumnCheckMessage() throws {
    let repository = try TemporaryRepository()
    try repository.write("docs/a.txt", "ok\nbad \n")
    let outcome = repository.whitespace()
    #expect(outcome.lines == ["docs/a.txt:2:4: whitespace: W1 trailing space or tab"])
    #expect(outcome.standardOutput.hasSuffix("\n"))
  }

  @Test func aViolationOfAWholeFileHasNoLineAndNoColumn() throws {
    let repository = try TemporaryRepository()
    try repository.write("docs/a.txt", "no line feed")
    let outcome = repository.whitespace()
    #expect(outcome.lines == ["docs/a.txt: whitespace: W5 no line feed at the end of the file"])
  }

  @Test func lineAndColumnStartAtOne() throws {
    let repository = try TemporaryRepository()
    try repository.write("a.txt", "\tx\n")
    #expect(repository.whitespace().lines.first?.hasPrefix("a.txt:1:1: whitespace: ") == true)
  }

  @Test func theColumnCountsBytesAndNotCharacters() throws {
    let repository = try TemporaryRepository()
    // Three bytes for U+20AC and two for U+00E9: the tab is the sixth byte.
    try repository.write("a.txt", "\u{20AC}" + Letters.latinEAcute + "\t\n")
    #expect(repository.whitespace().lines.first?.hasPrefix("a.txt:1:6: whitespace: W1") == true)
  }

  @Test func theFormattedLineOfAViolationHasBothForms() {
    let inLine = Violation(
      path: "p/q.txt", position: .init(line: 3, column: 9), check: "whitespace", message: "m")
    let wholeFile = Violation(path: "p/q.txt", position: nil, check: "whitespace", message: "m")
    #expect(inLine.formatted == "p/q.txt:3:9: whitespace: m")
    #expect(wholeFile.formatted == "p/q.txt: whitespace: m")
  }

  @Test func thePathIsRelativeToTheRootNotToTheCurrentDirectory() throws {
    let repository = try TemporaryRepository()
    try repository.write("sub/a.txt", "x \n")
    let outcome = repository.whitespace(in: try repository.directory("sub"))
    #expect(outcome.lines.first?.hasPrefix("sub/a.txt:1:2:") == true)
  }

  // MARK: The order

  @Test func linesAreSortedByPathAndThenByLine() throws {
    let repository = try TemporaryRepository()
    try repository.write("b.txt", "x \ny \n")
    try repository.write("a/z.txt", "ok\nok\nx \n")
    try repository.write("a/b.txt", "x \n\ny \nz")
    try repository.write("a.txt", "\n\n\nx \n")
    let places = repository.whitespace().lines.map {
      $0.components(separatedBy: ": whitespace: ")[0]
    }
    // "." sorts before "/", and a violation of a whole file before the lines of its file.
    #expect(
      places == [
        "a.txt:4:2", "a/b.txt", "a/b.txt:1:2", "a/b.txt:3:2", "a/z.txt:3:2", "b.txt:1:2",
        "b.txt:2:2",
      ])
  }

  @Test func aViolationOfAWholeFileSortsBeforeTheLinesOfItsFile() {
    let sorted = Violation.sortedForOutput([
      Violation(path: "a", position: .init(line: 2, column: 1), check: "c", message: "m"),
      Violation(path: "a", position: nil, check: "c", message: "m"),
      Violation(path: "a", position: .init(line: 1, column: 5), check: "c", message: "m"),
    ])
    #expect(sorted.map(\.formatted) == ["a: c: m", "a:1:5: c: m", "a:2:1: c: m"])
  }

  @Test func theOrderOfPathsIsByBytesNotByLocale() throws {
    let repository = try TemporaryRepository()
    try repository.write("B.txt", "x \n")
    try repository.write("a.txt", "x \n")
    try repository.write("_.txt", "x \n")
    let order = repository.whitespace().lines.map { String($0.prefix(while: { $0 != ":" })) }
    #expect(order == ["B.txt", "_.txt", "a.txt"])
  }

  // MARK: The streams

  @Test func violationsGoToStandardOutputAndNothingGoesToStandardError() throws {
    let repository = try TemporaryRepository()
    try repository.write("a.txt", "x \n")
    let outcome = repository.whitespace()
    #expect(outcome.standardOutput != "")
    #expect(outcome.standardError == "")
  }

  @Test func everyOtherMessageGoesToStandardErrorAndNothingToStandardOutput() throws {
    let repository = try TemporaryRepository()
    try repository.write("a.txt", "x \n")
    for arguments in [[], ["unknown"], ["whitespace", "extra"]] {
      let outcome = repository.run(arguments)
      #expect(outcome.standardOutput == "", "arguments: \(arguments)")
      #expect(outcome.standardError != "", "arguments: \(arguments)")
    }
  }

  // MARK: The exit statuses

  @Test func exitStatusIsZeroWithNoViolation() throws {
    let repository = try TemporaryRepository()
    try repository.write("a.txt", "fine\n")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError == "")
  }

  @Test func exitStatusIsZeroForARepositoryWithoutFiles() throws {
    let repository = try TemporaryRepository()
    #expect(repository.whitespace().status == 0)
  }

  @Test func exitStatusIsOneWithViolations() throws {
    let repository = try TemporaryRepository()
    try repository.write("a.txt", "x \n")
    #expect(repository.whitespace().status == 1)
  }

  @Test func exitStatusIsTwoForAnUnknownCommand() throws {
    let repository = try TemporaryRepository()
    let outcome = repository.run(["spelling"])
    #expect(outcome.status == 2)
    #expect(outcome.standardError.contains("unknown command spelling"))
  }

  @Test func exitStatusIsTwoForNoCommand() throws {
    let repository = try TemporaryRepository()
    let outcome = repository.run([])
    #expect(outcome.status == 2)
    #expect(outcome.standardError.contains("no command"))
    #expect(outcome.standardError.contains("whitespace"))
  }

  @Test func exitStatusIsTwoForMoreThanOneArgument() throws {
    let repository = try TemporaryRepository()
    #expect(repository.run(["whitespace", "whitespace"]).status == 2)
  }

  @Test func exitStatusIsTwoOutsideAGitRepository() throws {
    let repository = try TemporaryRepository(initialized: false)
    try repository.write("a.txt", "x \n")
    let outcome = repository.whitespace()
    #expect(outcome.status == 2)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError.contains("not inside a git working tree"))
  }

  @Test func exitStatusIsTwoForADirectoryThatDoesNotExist() throws {
    let repository = try TemporaryRepository()
    let outcome = repository.whitespace(in: repository.root + "/missing")
    #expect(outcome.status == 2)
    #expect(outcome.standardOutput == "")
  }

  @Test(.enabled(if: geteuid() != 0, "root can read every file"))
  func exitStatusIsTwoForAFileThatCannotBeRead() throws {
    let repository = try TemporaryRepository()
    let path = try repository.write("locked.txt", "x \n")
    try repository.write("open.txt", "y \n")
    try FileManager.default.setAttributes([.posixPermissions: 0], ofItemAtPath: path)
    defer {
      try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: path)
    }
    let outcome = repository.whitespace()
    #expect(outcome.status == 2)
    #expect(outcome.standardError.hasPrefix("clam-checks: locked.txt: cannot read: "))
    // The other files are still checked and reported.
    #expect(outcome.lines.count == 1 && outcome.lines[0].hasPrefix("open.txt:1:2:"))
  }
}

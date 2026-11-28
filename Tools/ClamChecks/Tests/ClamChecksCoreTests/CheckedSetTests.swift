import Foundation
import Testing

/// C5 of the spec of E-03: which files `whitespace` looks at, and how.
@Suite struct CheckedSetTests {
  private let bad = "x \n"

  private func paths(_ outcome: TemporaryRepository.Outcome) -> [String] {
    outcome.lines.map { String($0.prefix(while: { $0 != ":" })) }
  }

  @Test func aTrackedFileIsCheckedWithTheContentItHasOnDiskNow() throws {
    let repository = try TemporaryRepository()
    try repository.write("tracked.txt", "clean\n")
    try repository.add("tracked.txt")
    #expect(repository.whitespace().status == 0)
    try repository.write("tracked.txt", "dirty \n")
    let outcome = repository.whitespace()
    #expect(outcome.status == 1)
    #expect(outcome.lines.count == 1)
    #expect(outcome.lines.first?.hasPrefix("tracked.txt:1:6: whitespace: W1") == true)
  }

  @Test func aTrackedFileThatIsCleanOnDiskPassesWhateverTheIndexHolds() throws {
    let repository = try TemporaryRepository()
    try repository.write("tracked.txt", "dirty \n")
    try repository.add("tracked.txt")
    try repository.write("tracked.txt", "clean\n")
    #expect(repository.whitespace().status == 0)
  }

  @Test func anUntrackedFileThatGitDoesNotIgnoreIsChecked() throws {
    let repository = try TemporaryRepository()
    try repository.write("untracked.txt", bad)
    let outcome = repository.whitespace()
    #expect(outcome.status == 1)
    #expect(paths(outcome) == ["untracked.txt"])
  }

  @Test func aFileThatGitIgnoresIsNotChecked() throws {
    let repository = try TemporaryRepository()
    try repository.write(".gitignore", "ignored.txt\nbuild/\n")
    try repository.write("ignored.txt", bad)
    try repository.write("build/out.txt", bad)
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
  }

  @Test func theIgnoreFileItselfIsChecked() throws {
    let repository = try TemporaryRepository()
    try repository.write(".gitignore", "ignored.txt \n")
    #expect(paths(repository.whitespace()) == [".gitignore"])
  }

  @Test func gitInfoExcludeIsHonored() throws {
    let repository = try TemporaryRepository()
    try repository.write(".git/info/exclude", "local.txt\n")
    try repository.write("local.txt", bad)
    #expect(repository.whitespace().status == 0)
  }

  @Test func theGlobalExcludesFileIsHonoredBecauseGitDecides() throws {
    let repository = try TemporaryRepository()
    let excludes = try repository.write("../home/global-ignore", "global.txt\n")
    let config = try repository.write("../home/gitconfig", "[core]\n  excludesFile = \(excludes)\n")
    var environment = repository.environment
    environment["GIT_CONFIG_GLOBAL"] = config
    try repository.write("global.txt", bad)
    try repository.write("other.txt", bad)
    let outcome = repository.run(["whitespace"], environment: environment)
    #expect(outcome.status == 1)
    #expect(paths(outcome) == ["other.txt"])
  }

  @Test func aFileThatIsTrackedAndIgnoredIsStillChecked() throws {
    let repository = try TemporaryRepository()
    try repository.write("t.txt", bad)
    try repository.add("t.txt")
    try repository.write(".gitignore", "t.txt\n")
    #expect(paths(repository.whitespace()) == ["t.txt"])
  }

  @Test func aTrackedFileDeletedFromTheWorkingTreeIsSkippedWithoutAnError() throws {
    let repository = try TemporaryRepository()
    try repository.write("gone.txt", bad)
    try repository.write("kept.txt", "ok\n")
    try repository.add("gone.txt", "kept.txt")
    try repository.remove("gone.txt")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError == "")
  }

  @Test func aTrackedFileInADeletedFolderIsSkippedToo() throws {
    let repository = try TemporaryRepository()
    try repository.write("dir/sub/gone.txt", bad)
    try repository.add("dir")
    try FileManager.default.removeItem(atPath: repository.root + "/dir")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardError == "")
  }

  @Test func aTrackedFolderReplacedByAFileIsSkippedWithoutAnError() throws {
    let repository = try TemporaryRepository()
    try repository.write("a/b.txt", bad)
    try repository.add("a")
    try repository.remove("a")
    try repository.write("a", "now a file\n")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError == "")
  }

  // MARK: A link in a leading folder of a path from the index

  @Test func aTrackedFolderReplacedByALinkToAFolderOutsideTheRepositoryIsSkipped() throws {
    let repository = try TemporaryRepository()
    try repository.write("d/f.txt", "ok\n")
    try repository.write("fine.txt", "ok\n")
    try repository.add("d", "fine.txt")
    let outside = try repository.write("../outside/f.txt", bad)
    try repository.remove("d")
    try repository.makeSymbolicLink(
      "d", to: URL(fileURLWithPath: outside).deletingLastPathComponent().path)
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError == "")
  }

  @Test func aTrackedFolderReplacedByALinkToAFolderInsideTheRepositoryReportsTheFileOnce() throws {
    let repository = try TemporaryRepository()
    try repository.write("d/f.txt", "ok\n")
    try repository.add("d")
    try repository.write("e/f.txt", bad)
    try repository.remove("d")
    try repository.makeSymbolicLink("d", to: "e")
    let outcome = repository.whitespace()
    #expect(outcome.status == 1)
    #expect(outcome.lines.count == 1)
    #expect(outcome.lines.first?.hasPrefix("e/f.txt:1:2: whitespace: W1") == true)
    #expect(outcome.standardError == "")
  }

  @Test(
    "A link anywhere in the leading folders of a tracked path makes the path count as deleted",
    arguments: ["a", "a/b", "a/b/c"])
  func aLinkInTheMiddleOfALongerPathIsSkipped(linkPath: String) throws {
    let repository = try TemporaryRepository()
    try repository.write("a/b/c/f.txt", "ok\n")
    try repository.add("a")
    // Behind the link lie the rest of the path and a file with a violation.
    let rest = "a/b/c".dropFirst(linkPath.count)
    try repository.write("../outside\(rest)/f.txt", bad)
    try repository.remove(linkPath)
    try repository.makeSymbolicLink(
      linkPath,
      to: URL(fileURLWithPath: repository.root).deletingLastPathComponent()
        .appendingPathComponent("outside").path)
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError == "")
  }

  @Test func aTrackedFolderReplacedByADanglingLinkIsSkipped() throws {
    let repository = try TemporaryRepository()
    try repository.write("d/f.txt", bad)
    try repository.add("d")
    try repository.remove("d")
    try repository.makeSymbolicLink("d", to: "nowhere")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError == "")
  }

  @Test func aPathWithASpaceAQuoteAndANonAsciiLetterIsReportedExactly() throws {
    let repository = try TemporaryRepository()
    let name = "dir one/it's \"q\" " + Letters.cyrillicZhe + Letters.latinEAcute + ".txt"
    try repository.write(name, bad)
    let outcome = repository.whitespace()
    #expect(outcome.lines == ["\(name):1:2: whitespace: W1 trailing space or tab"])
  }

  @Test func theSameNameIsReportedExactlyWhenTheFileIsTracked() throws {
    let repository = try TemporaryRepository()
    let name = "sp ace/" + Letters.cyrillicZhe + ".txt"
    try repository.write(name, bad)
    try repository.add("sp ace")
    #expect(paths(repository.whitespace()) == [name])
  }

  @Test func runInASubdirectoryChecksTheWholeRepository() throws {
    let repository = try TemporaryRepository()
    try repository.write("top.txt", bad)
    try repository.write("sub/deeper/inner.txt", bad)
    let outcome = repository.whitespace(in: try repository.directory("sub/deeper"))
    #expect(outcome.status == 1)
    #expect(paths(outcome) == ["sub/deeper/inner.txt", "top.txt"])
  }

  // MARK: Binary files and links

  @Test func aFileWithANulByteIsBinaryAndItsContentIsNotChecked() throws {
    let repository = try TemporaryRepository()
    try repository.write("blob.bin", [0x61, 0x20, 0x0A, 0x00, 0xFF, 0x09, 0x0D, 0x0A])
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
  }

  @Test func aNulByteAtTheVeryEndStillMakesTheFileBinary() throws {
    let repository = try TemporaryRepository()
    try repository.write("blob.bin", [0x61, 0x20, 0x0A, 0x0A, 0x00])
    #expect(repository.whitespace().status == 0)
  }

  @Test func aLinkToAFileWithViolationsOutsideTheCheckedSetPasses() throws {
    let repository = try TemporaryRepository()
    try repository.write(".gitignore", "target.txt\n")
    try repository.write("target.txt", bad)
    try repository.makeSymbolicLink("link-untracked.txt", to: "target.txt")
    try repository.makeSymbolicLink("link-tracked.txt", to: repository.root + "/target.txt")
    try repository.add("link-tracked.txt")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError == "")
  }

  @Test func aDanglingLinkPasses() throws {
    let repository = try TemporaryRepository()
    try repository.makeSymbolicLink("dangling.txt", to: "nowhere.txt")
    try repository.add("dangling.txt")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardError == "")
  }

  @Test func aLinkToADirectoryPasses() throws {
    let repository = try TemporaryRepository()
    try repository.write(".gitignore", "data/\n")
    try repository.write("data/inner.txt", bad)
    try repository.makeSymbolicLink("dir-link", to: "data")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardOutput == "")
    #expect(outcome.standardError == "")
  }

  @Test func aLinkIsNeverFollowedEvenWhenItsTargetIsChecked() throws {
    let repository = try TemporaryRepository()
    try repository.write("target.txt", bad)
    try repository.makeSymbolicLink("link.txt", to: "target.txt")
    #expect(paths(repository.whitespace()) == ["target.txt"])
  }

  @Test func aNestedRepositoryIsNotOpenedAsAFile() throws {
    let repository = try TemporaryRepository()
    try repository.write("outer.txt", "ok\n")
    try repository.write("nested/inner.txt", bad)
    try repository.git("init", "--quiet", in: repository.root + "/nested")
    let outcome = repository.whitespace()
    #expect(outcome.status == 0)
    #expect(outcome.standardError == "")
  }
}

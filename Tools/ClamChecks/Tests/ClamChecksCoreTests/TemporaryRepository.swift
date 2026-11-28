import ClamChecksCore
import Foundation

/// A directory under the temporary folder, removed when the value is released, and the means to
/// run the tool in it. It neither reads nor changes the user's git configuration: git gets a
/// home, an XDG folder and a global configuration that lie inside the directory.
final class TemporaryRepository {
  /// The directory, with symbolic links resolved.
  let root: String
  private let container: String
  let environment: [String: String]

  /// Makes an empty directory; with `initialized` it is also a git repository.
  init(initialized: Bool = true) throws {
    let base = URL(fileURLWithPath: NSTemporaryDirectory()).resolvingSymlinksInPath()
    let container = base.appendingPathComponent("clam-checks-\(UUID().uuidString)")
    let home = container.appendingPathComponent("home")
    let work = container.appendingPathComponent("work")
    try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: work, withIntermediateDirectories: true)
    self.container = container.path
    self.root = work.path

    var environment = ProcessInfo.processInfo.environment.filter { !$0.key.hasPrefix("GIT_") }
    environment["HOME"] = home.path
    environment["XDG_CONFIG_HOME"] = home.appendingPathComponent("xdg").path
    environment["GIT_CONFIG_GLOBAL"] = "/dev/null"
    environment["GIT_CONFIG_NOSYSTEM"] = "1"
    // The fixtures never lie inside a repository that holds the temporary folder.
    environment["GIT_CEILING_DIRECTORIES"] = container.path
    self.environment = environment

    if initialized {
      try git("init", "--quiet")
    }
  }

  deinit {
    try? FileManager.default.removeItem(atPath: container)
  }

  /// Writes a file under the root and makes its folders.
  @discardableResult
  func write(_ path: String, _ content: [UInt8]) throws -> String {
    let url = URL(fileURLWithPath: root).appendingPathComponent(path)
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data(content).write(to: url)
    return url.path
  }

  @discardableResult
  func write(_ path: String, _ text: String) throws -> String {
    try write(path, Array(text.utf8))
  }

  func makeSymbolicLink(_ path: String, to target: String) throws {
    let url = URL(fileURLWithPath: root).appendingPathComponent(path)
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(atPath: url.path, withDestinationPath: target)
  }

  func remove(_ path: String) throws {
    try FileManager.default.removeItem(atPath: root + "/" + path)
  }

  func read(_ path: String) throws -> [UInt8] {
    Array(try Data(contentsOf: URL(fileURLWithPath: root + "/" + path)))
  }

  /// Runs git in `directory` (the root by default); a failure fails the test.
  func git(_ arguments: String..., in directory: String? = nil) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["git"] + arguments
    process.currentDirectoryURL = URL(fileURLWithPath: directory ?? root)
    process.environment = environment
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    try process.run()
    process.waitUntilExit()
    if process.terminationStatus != 0 {
      throw FixtureError(description: "git \(arguments.joined(separator: " ")) failed")
    }
  }

  /// Puts the paths into the index, the way `git add` does; nothing is committed.
  func add(_ paths: String...) throws {
    for path in paths {
      try git("add", "--", path)
    }
  }

  struct Outcome {
    let status: Int32
    let standardOutput: String
    let standardError: String

    var lines: [String] {
      standardOutput.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
    }
  }

  /// Makes a folder under the root and returns its path.
  func directory(_ path: String) throws -> String {
    let url = URL(fileURLWithPath: root).appendingPathComponent(path)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url.path
  }

  /// Runs `clam-checks <arguments>` in `directory` (the root by default).
  func run(
    _ arguments: [String], in directory: String? = nil, environment: [String: String]? = nil
  ) -> Outcome {
    nonisolated(unsafe) var standardOutput = ""
    nonisolated(unsafe) var standardError = ""
    let status = CommandLineTool.run(
      arguments: arguments,
      currentDirectory: directory ?? root,
      environment: environment ?? self.environment,
      output: OutputStreams(
        standardOutput: { standardOutput += $0 },
        standardError: { standardError += $0 }
      )
    )
    return Outcome(
      status: status, standardOutput: standardOutput, standardError: standardError)
  }

  func whitespace(in directory: String? = nil) -> Outcome {
    run(["whitespace"], in: directory)
  }
}

struct FixtureError: Error, CustomStringConvertible {
  let description: String
}

/// A letter that is not ASCII, from its code point: the sources hold no such letter literally.
enum Letters {
  static let cyrillicZhe = String(Unicode.Scalar(0x0416)!)
  static let latinEAcute = String(Unicode.Scalar(0x00E9)!)
}

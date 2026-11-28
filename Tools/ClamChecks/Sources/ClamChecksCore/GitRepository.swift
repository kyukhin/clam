import Foundation

struct ToolError: Error, CustomStringConvertible {
  let description: String
}

/// The repository that holds a directory, and the set of files a commit of its working tree
/// would hold. git decides what is in the set: this type never walks directories and never
/// reads an ignore file itself.
struct GitRepository {
  /// The root of the working tree.
  let root: String
  let environment: [String: String]

  static func locate(from directory: String, environment: [String: String]) throws
    -> GitRepository
  {
    let result = try runGit(
      ["rev-parse", "--show-toplevel"], in: directory, environment: environment)
    guard result.status == 0 else {
      throw ToolError(description: "\(directory): not inside a git working tree")
    }
    var output = result.standardOutput
    if output.last == UInt8(ascii: "\n") {
      output.removeLast()
    }
    let root = String(decoding: output, as: UTF8.self)
    guard !root.isEmpty else {
      throw ToolError(description: "\(directory): git did not name the root of the repository")
    }
    return GitRepository(root: root, environment: environment)
  }

  /// Every tracked path and every untracked path that git does not ignore, relative to the
  /// root, as the raw bytes git stores. A tracked path that is deleted on disk is still here.
  func listPaths() throws -> [[UInt8]] {
    let result = try Self.runGit(
      ["ls-files", "-z", "--cached", "--others", "--exclude-standard", "--deduplicate"],
      in: root, environment: environment)
    guard result.status == 0 else {
      throw ToolError(description: "git ls-files failed with status \(result.status)")
    }
    return result.standardOutput
      .split(separator: 0, omittingEmptySubsequences: true)
      .map { Array($0) }
  }

  private struct GitResult {
    let status: Int32
    let standardOutput: [UInt8]
  }

  private static func runGit(
    _ arguments: [String], in directory: String, environment: [String: String]
  ) throws -> GitResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["git"] + arguments
    process.currentDirectoryURL = URL(fileURLWithPath: directory)
    process.environment = environment
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = FileHandle.nullDevice
    process.standardInput = FileHandle.nullDevice
    do {
      try process.run()
    } catch {
      throw ToolError(description: "cannot run git: \(error.localizedDescription)")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return GitResult(status: process.terminationStatus, standardOutput: Array(data))
  }
}

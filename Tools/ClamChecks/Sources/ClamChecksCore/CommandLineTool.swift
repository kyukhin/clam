/// The two output streams of a run. Violations go to `standardOutput`, every other message to
/// `standardError`.
public struct OutputStreams {
  public let standardOutput: (String) -> Void
  public let standardError: (String) -> Void

  public init(
    standardOutput: @escaping (String) -> Void, standardError: @escaping (String) -> Void
  ) {
    self.standardOutput = standardOutput
    self.standardError = standardError
  }
}

public enum CommandLineTool {
  public static let exitClean: Int32 = 0
  public static let exitViolations: Int32 = 1
  public static let exitError: Int32 = 2

  /// Every command the tool has. `make lint` runs the same list (see the `Makefile`).
  public static let checks: [any Check] = [WhitespaceCheck()]

  /// Runs one command over the repository that holds `currentDirectory`.
  public static func run(
    arguments: [String],
    currentDirectory: String,
    environment: [String: String],
    output: OutputStreams
  ) -> Int32 {
    let usage =
      "usage: clam-checks <command>\ncommands: "
      + checks.map(\.name).joined(separator: ", ") + "\n"
    guard arguments.count == 1 else {
      let problem = arguments.isEmpty ? "no command" : "too many arguments"
      output.standardError("clam-checks: \(problem)\n\(usage)")
      return exitError
    }
    guard let check = checks.first(where: { $0.name == arguments[0] }) else {
      output.standardError("clam-checks: unknown command \(arguments[0])\n\(usage)")
      return exitError
    }

    let repository: GitRepository
    let paths: [[UInt8]]
    do {
      repository = try GitRepository.locate(from: currentDirectory, environment: environment)
      paths = try repository.listPaths()
    } catch {
      output.standardError("clam-checks: \(error)\n")
      return exitError
    }

    var violations: [Violation] = []
    var failed = false
    for pathBytes in paths {
      do {
        guard let file = try CheckedFile.inspect(root: repository.root, pathBytes: pathBytes)
        else {
          continue
        }
        violations += try check.violations(in: file)
      } catch {
        output.standardError("clam-checks: \(error)\n")
        failed = true
      }
    }

    let sorted = Violation.sortedForOutput(violations)
    if !sorted.isEmpty {
      output.standardOutput(sorted.map { $0.formatted + "\n" }.joined())
    }
    if failed {
      return exitError
    }
    return sorted.isEmpty ? exitClean : exitViolations
  }
}

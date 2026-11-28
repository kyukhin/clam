/// One command of the tool. A check looks at a file through `CheckedFile` and reports
/// violations; it never writes a file.
public protocol Check: Sendable {
  /// The name of the command and of the second field of every output line.
  var name: String { get }

  func violations(in file: CheckedFile) throws -> [Violation]
}

/// One finding of a check. A violation about a whole file has no position.
public struct Violation: Equatable, Sendable {
  public struct Position: Equatable, Sendable {
    /// Starts at 1.
    public let line: Int
    /// Starts at 1 and counts the bytes of the line.
    public let column: Int

    public init(line: Int, column: Int) {
      self.line = line
      self.column = column
    }
  }

  public let path: String
  public let position: Position?
  public let check: String
  public let message: String

  public init(path: String, position: Position?, check: String, message: String) {
    self.path = path
    self.position = position
    self.check = check
    self.message = message
  }

  /// `path:line:column: check: message`, or `path: check: message` for a whole file.
  public var formatted: String {
    guard let position else {
      return "\(path): \(check): \(message)"
    }
    return "\(path):\(position.line):\(position.column): \(check): \(message)"
  }
}

extension Violation {
  /// Sorted by path (by its UTF-8 bytes), then by line; a whole-file violation comes before the
  /// lines of its file. Column, check and message only make the order stable.
  static func sortedForOutput(_ violations: [Violation]) -> [Violation] {
    violations.sorted { lhs, rhs in
      if lhs.path != rhs.path {
        return lhs.path.utf8.lexicographicallyPrecedes(rhs.path.utf8)
      }
      let lhsKey = [lhs.position?.line ?? 0, lhs.position?.column ?? 0]
      let rhsKey = [rhs.position?.line ?? 0, rhs.position?.column ?? 0]
      if lhsKey != rhsKey {
        return lhsKey.lexicographicallyPrecedes(rhsKey)
      }
      if lhs.check != rhs.check {
        return lhs.check < rhs.check
      }
      return lhs.message < rhs.message
    }
  }
}

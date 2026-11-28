/// The check `whitespace`: the rules W1 to W6 of the spec of E-03, in a text file. It only
/// reports; it rewrites nothing.
struct WhitespaceCheck: Check {
  let name = "whitespace"

  enum Rule: String, Sendable {
    case w1 = "W1"
    case w2 = "W2"
    case w3 = "W3"
    case w4 = "W4"
    case w5 = "W5"
    case w6 = "W6"

    var message: String {
      switch self {
      case .w1: "W1 trailing space or tab"
      case .w2: "W2 tab"
      case .w3: "W3 carriage return"
      case .w4: "W4 byte order mark"
      case .w5: "W5 no line feed at the end of the file"
      case .w6: "W6 not valid UTF-8"
      }
    }
  }

  /// A path pattern for which one rule does not apply. This list is the one place for the
  /// exceptions; a later spec adds a line here, each for one pattern and one rule.
  struct Exception: Sendable {
    enum Pattern: Sendable {
      /// The last component of the path is exactly this name.
      case fileName(String)
      /// The last component of the path ends with this suffix.
      case fileNameSuffix(String)

      func matches(_ path: String) -> Bool {
        let name = path.split(separator: "/", omittingEmptySubsequences: false).last ?? ""
        switch self {
        case .fileName(let expected): return name == expected
        case .fileNameSuffix(let suffix): return name.hasSuffix(suffix)
        }
      }
    }

    let rule: Rule
    let pattern: Pattern
  }

  static let exceptions: [Exception] = [
    Exception(rule: .w2, pattern: .fileName("Makefile")),
    Exception(rule: .w2, pattern: .fileNameSuffix(".mk")),
  ]

  static func applies(_ rule: Rule, to path: String) -> Bool {
    !exceptions.contains { $0.rule == rule && $0.pattern.matches(path) }
  }

  func violations(in file: CheckedFile) throws -> [Violation] {
    guard let content = try file.textContent() else {
      return []
    }
    return Self.violations(path: file.path, content: content)
  }

  static func violations(path: String, content: [UInt8]) -> [Violation] {
    var found: [Violation] = []
    func report(_ rule: Rule, line: Int? = nil, column: Int? = nil, message: String? = nil) {
      let position = line.flatMap { line in
        column.map { Violation.Position(line: line, column: $0) }
      }
      found.append(
        Violation(
          path: path, position: position, check: "whitespace", message: message ?? rule.message))
    }

    let lineFeed = UInt8(ascii: "\n")
    let carriageReturn = UInt8(ascii: "\r")
    let space = UInt8(ascii: " ")
    let tab = UInt8(ascii: "\t")
    let tabsAreFine = !applies(.w2, to: path)

    if content.starts(with: [0xEF, 0xBB, 0xBF]) {
      report(.w4, line: 1, column: 1)
    }

    var lineStart = 0
    var lineNumber = 1
    while lineStart < content.count {
      let lineEnd = content[lineStart...].firstIndex(of: lineFeed) ?? content.count
      let line = content[lineStart..<lineEnd]

      // A carriage return just before the line feed ends the line, so a space before it is
      // still at the end of the line.
      var trailingEnd = lineEnd
      if trailingEnd > lineStart, content[trailingEnd - 1] == carriageReturn {
        trailingEnd -= 1
      }
      var trailingStart = trailingEnd
      while trailingStart > lineStart,
        content[trailingStart - 1] == space || content[trailingStart - 1] == tab
      {
        trailingStart -= 1
      }
      if trailingStart < trailingEnd {
        report(.w1, line: lineNumber, column: trailingStart - lineStart + 1)
      }
      if !tabsAreFine, let tabIndex = line.firstIndex(of: tab) {
        report(.w2, line: lineNumber, column: tabIndex - lineStart + 1)
      }
      if let returnIndex = line.firstIndex(of: carriageReturn) {
        report(.w3, line: lineNumber, column: returnIndex - lineStart + 1)
      }

      lineStart = lineEnd + 1
      lineNumber += 1
    }

    if let last = content.last {
      if last != lineFeed {
        report(.w5)
      } else if content.count > 1, content[content.count - 2] == lineFeed {
        report(.w5, message: "W5 more than one line feed at the end of the file")
      }
    }

    if let offset = UTF8Validation.firstInvalidOffset(in: content) {
      let before = content[..<offset]
      let line = before.reduce(1) { $1 == lineFeed ? $0 + 1 : $0 }
      let lineStartOffset = (before.lastIndex(of: lineFeed) ?? -1) + 1
      report(.w6, line: line, column: offset - lineStartOffset + 1)
    }
    return found
  }
}

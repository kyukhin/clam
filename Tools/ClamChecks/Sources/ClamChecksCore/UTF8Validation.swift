enum UTF8Validation {
  /// The offset of the first byte that is not part of well-formed UTF-8 (the table of
  /// RFC 3629: no overlong forms, no surrogates, nothing above U+10FFFF), or nil.
  static func firstInvalidOffset(in bytes: [UInt8]) -> Int? {
    var index = 0
    while index < bytes.count {
      let lead = bytes[index]
      let length: Int
      var secondRange: ClosedRange<UInt8> = 0x80...0xBF
      switch lead {
      case 0x00...0x7F:
        index += 1
        continue
      case 0xC2...0xDF:
        length = 2
      case 0xE0:
        length = 3
        secondRange = 0xA0...0xBF
      case 0xE1...0xEC, 0xEE...0xEF:
        length = 3
      case 0xED:
        length = 3
        secondRange = 0x80...0x9F
      case 0xF0:
        length = 4
        secondRange = 0x90...0xBF
      case 0xF1...0xF3:
        length = 4
      case 0xF4:
        length = 4
        secondRange = 0x80...0x8F
      default:
        return index
      }
      guard index + length <= bytes.count, secondRange.contains(bytes[index + 1]) else {
        return index
      }
      for offset in 2..<length where !(0x80...0xBF).contains(bytes[index + offset]) {
        return index
      }
      index += length
    }
    return nil
  }
}

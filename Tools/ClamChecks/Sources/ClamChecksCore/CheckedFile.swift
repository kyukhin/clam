import Foundation

/// A file of the checked set: its path and what the file system says about it, without
/// following a link and without reading the content.
public struct CheckedFile: Sendable {
  public enum Kind: Equatable, Sendable {
    /// A regular file and its size in bytes.
    case regular(size: Int64)
    case symbolicLink
    /// A directory (a nested repository or a submodule), a pipe, a socket, a device.
    case other
  }

  /// Relative to the root of the repository. A name that is not valid UTF-8 is shown with
  /// replacement characters; the file is still opened by its exact bytes.
  public let path: String
  public let kind: Kind
  private let pathBytes: [UInt8]
  private let rootBytes: [UInt8]

  /// Returns nil when the path is not on disk, or when it cannot be reached without passing a
  /// symbolic link below the root: a tracked file deleted in the working tree, or whose folder
  /// was replaced by a link. git does not hold such a path in a commit of the working tree
  /// either, and a link is never followed.
  static func inspect(root: String, pathBytes: [UInt8]) throws -> CheckedFile? {
    let rootBytes = Array(root.utf8)
    let path = String(decoding: pathBytes, as: UTF8.self)
    let rootDescriptor = try openRoot(rootBytes, path: path)
    defer { close(rootDescriptor) }
    var status = stat()
    // `AT_SYMLINK_NOFOLLOW_ANY` fails with ELOOP when a folder of the path is a link, and
    // describes the link itself, like `lstat`, when only the last component is one.
    let result = cString(pathBytes).withUnsafeBufferPointer {
      fstatat(rootDescriptor, $0.baseAddress!, &status, AT_SYMLINK_NOFOLLOW_ANY)
    }
    if result != 0 {
      if errno == ENOENT || errno == ENOTDIR || errno == ELOOP {
        return nil
      }
      throw FileError(path: path, code: errno)
    }
    let kind: Kind
    switch status.st_mode & S_IFMT {
    case S_IFREG:
      kind = .regular(size: Int64(status.st_size))
    case S_IFLNK:
      kind = .symbolicLink
    default:
      kind = .other
    }
    return CheckedFile(path: path, kind: kind, pathBytes: pathBytes, rootBytes: rootBytes)
  }

  /// The content of a regular file that is text, or nil for a symbolic link, for anything that
  /// is not a regular file and for a binary file (one with a NUL byte). A link is never opened.
  public func textContent() throws -> [UInt8]? {
    guard case .regular = kind else {
      return nil
    }
    let content = try readContent()
    return content.contains(0) ? nil : content
  }

  private func readContent() throws -> [UInt8] {
    let rootDescriptor = try Self.openRoot(rootBytes, path: path)
    defer { close(rootDescriptor) }
    // `O_NOFOLLOW_ANY`: no link anywhere in the path below the root, not only in its last
    // component.
    let descriptor = Self.cString(pathBytes).withUnsafeBufferPointer {
      openat(rootDescriptor, $0.baseAddress!, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
    }
    guard descriptor >= 0 else {
      throw FileError(path: path, code: errno)
    }
    defer { close(descriptor) }
    var content: [UInt8] = []
    var chunk = [UInt8](repeating: 0, count: 64 * 1024)
    while true {
      let count = chunk.withUnsafeMutableBytes { read(descriptor, $0.baseAddress, $0.count) }
      if count < 0 {
        if errno == EINTR {
          continue
        }
        throw FileError(path: path, code: errno)
      }
      if count == 0 {
        return content
      }
      content.append(contentsOf: chunk[0..<count])
    }
  }

  /// The root of the repository is the one place where a link is followed: it is where the
  /// user stands.
  private static func openRoot(_ rootBytes: [UInt8], path: String) throws -> Int32 {
    let descriptor = cString(rootBytes).withUnsafeBufferPointer {
      open($0.baseAddress!, O_RDONLY | O_DIRECTORY | O_CLOEXEC)
    }
    guard descriptor >= 0 else {
      throw FileError(path: path, code: errno)
    }
    return descriptor
  }

  private static func cString(_ bytes: [UInt8]) -> [CChar] {
    (bytes + [0]).map { CChar(bitPattern: $0) }
  }
}

public struct FileError: Error, CustomStringConvertible {
  public let path: String
  public let code: Int32

  public var description: String {
    "\(path): cannot read: \(String(cString: strerror(code)))"
  }
}

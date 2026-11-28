import ClamChecksCore
import Foundation

exit(
  CommandLineTool.run(
    arguments: Array(CommandLine.arguments.dropFirst()),
    currentDirectory: FileManager.default.currentDirectoryPath,
    environment: ProcessInfo.processInfo.environment,
    output: OutputStreams(
      standardOutput: { FileHandle.standardOutput.write(Data($0.utf8)) },
      standardError: { FileHandle.standardError.write(Data($0.utf8)) }
    )
  )
)

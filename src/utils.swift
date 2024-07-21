import Foundation

func spawnProcess(executable: String, arguments: [String] = [], captureOutput: Bool = false) -> (
  exitStatus: Int32, output: String?
) {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: executable)
  process.arguments = arguments

  let pipe = Pipe()
  if captureOutput {
    process.standardOutput = pipe
    process.standardError = pipe
  }

  do {
    try process.run()
    process.waitUntilExit()

    let output: String?
    if captureOutput {
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      output = String(data: data, encoding: .utf8)
    } else {
      output = nil
    }

    return (exitStatus: process.terminationStatus, output: output)
  } catch {
    print("Error running process: \(error)")
    return (exitStatus: -1, output: nil)
  }
}

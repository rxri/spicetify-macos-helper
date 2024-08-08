/*
 * Copyright (C) 2024 ririxi
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import Foundation

func spawnProcess(executable: String, arguments: [String] = [], captureOutput: Bool = false, background: Bool = false) -> (
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

  if !background {
    let workspace = NSWorkspace.shared
    do {
      try workspace.openApplication(at: URL(fileURLWithPath: executable), options: .default, configuration: [:])
      return (exitStatus: 0, output: nil)
    } catch {
      print("Error running process: \(error)")
      return (exitStatus: -1, output: nil)
    }
  } else {
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
}

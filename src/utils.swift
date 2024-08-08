/*
 * Copyright (C) 2024 ririxi
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import Foundation
import SwiftUI

@discardableResult func spawnProcess(executable: String, arguments: [String] = [], captureOutput: Bool = false, background: Bool = true) -> (
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
    let config = NSWorkspace.OpenConfiguration()
    config.activates = true
    config.arguments = arguments
      
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    var exitStatus: Int32 = 0, output: String? = nil
    workspace.openApplication(at: URL(fileURLWithPath: executable), configuration: config) { (app, error) in
        if let error = error {
            logger("Error running process: \(error)")
            exitStatus = -1
        }
        dispatchGroup.leave()
    }
      
    dispatchGroup.wait()
    return (exitStatus, output)
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
      logger("Error running process: \(error)")
      return (exitStatus: -1, output: nil)
    }
  }
}

func logger(_ logMessage: String, functionName: String = #function) {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.timeZone = TimeZone.current
    let date = formatter.string(from: Date())
    print("[\(date)] \(functionName): \(logMessage)")
}

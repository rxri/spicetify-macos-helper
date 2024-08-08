/*
 * Copyright (C) 2024 ririxi
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import Foundation

let launchAgentPlist: [String: Any] = [
  "Label": "spicetify.Spicetify",
  "ProgramArguments": [BinaryPath, "daemon"],
  "RunAtLoad": true,
]

let plistData = try! PropertyListSerialization.data(
  fromPropertyList: launchAgentPlist, format: .xml, options: 0)
let fileManager = FileManager.default
let launchAgentDirectory = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(
  "Library/LaunchAgents")
let plistPath = launchAgentDirectory.appendingPathComponent("spicetify.spicetify.daemon.plist")

func createLaunchAgent() -> Void {
  do {
    try fileManager.createDirectory(
      at: launchAgentDirectory, withIntermediateDirectories: true, attributes: nil)
    try plistData.write(to: plistPath)
    logger("LaunchAgent created at \(plistPath.path)")
  } catch {
    logger("Failed to create LaunchAgent: \(error)")
  }
}

func doesLaunchAgentExist() -> Bool {
  if doesFileExist(plistPath.path) {
    return true
  } else {
    return false
  }
}

@discardableResult func loadLaunchAgent() -> Bool {
  if !doesLaunchAgentExist() {
    createLaunchAgent()
  }

  let proc = spawnProcess(executable: "/bin/launchctl", arguments: ["load", "-w", plistPath.path], background: true)
  if proc.exitStatus != 0 {
    logger("Failed to load LaunchAgent")
    return false
  }

  return true
}

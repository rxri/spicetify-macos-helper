/*
 * Copyright (C) 2024 ririxi
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  func application(_ application: NSApplication, open urls: [URL]) {
    guard let url = urls.first else {
      logger("No URL received")
      return
    }

    logger("Spawning spicetify binary with URL...")
    spawnProcess(
      executable: BinaryPath, arguments: ["protocol", String(describing: url)], background: true)
    logger("Helper is quitting. Bye!")
    app.terminate(self)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    addPathToShellRc()
    if !doesLaunchAgentExist() {
      loadLaunchAgent()
      spawnProcess(executable: BinaryPath, arguments: ["init"], background: true)
    }

    logger("Spawning spicetify binary...")
    spawnProcess(executable: BinaryPath, background: false)
    logger("Helper is quitting. Bye!")
    app.terminate(self)
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

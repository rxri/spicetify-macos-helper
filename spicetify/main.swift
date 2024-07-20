/*
 * Copyright (C) 2024 ririxi
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  func application(_ application: NSApplication, open urls: [URL]) {
    guard let url = urls.first else {
      print("No URL received")
      return
    }

    print("Spawning spicetify binary with URL...")
    spawnProcess(executable: BinaryPath, arguments: ["protocol", String(describing: url)])
    print("Helper is quitting. Bye!")
    app.terminate(self)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    addPathToShellRc(shellFiles: [".zshrc", ".bash_profile"])
    if !doesLaunchAgentExist() {
      loadLaunchAgent()
      spawnProcess(executable: BinaryPath, arguments: ["init"])
    }

    print("Spawning spicetify binary...")
    spawnProcess(executable: BinaryPath)
    print("Helper is quitting. Bye!")
    app.terminate(self)
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

/*
 * Copyright (C) 2024 ririxi
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import Foundation

func doesFileExist(_ path: String) -> Bool {
  if fileManager.fileExists(atPath: path) {
    return true
  } else {
    return false
  }
}

func readFile(at path: String) -> String? {
  guard doesFileExist(path) else {
    print("\(path) does not exist")
    return nil
  }

  do {
    let fileContent = try String(contentsOfFile: path, encoding: .utf8)
    return fileContent
  } catch {
    print("Error reading \(path): \(error)")
    return nil
  }
}

func addPathToShellRc(shellFiles: [String]) {
  let fileManager = FileManager.default
  let homeDirectory = fileManager.homeDirectoryForCurrentUser

  for configFile in shellFiles {
    let configFilePath = homeDirectory.appendingPathComponent(configFile).path

    var content = readFile(at: configFilePath)

    if content == nil {
      content = ""
    }

    do {
      let exportLine = "export PATH=\"$PATH:\(BinaryPath)\" # spicetify"
      if !content!.contains(exportLine) {
        if !content!.isEmpty {
          content! += "\n"
        }

        content! += exportLine

        try content!.write(toFile: configFilePath, atomically: true, encoding: .utf8)
      } else {
        print("Path already exists inside \(configFile)")
      }
    } catch {
      print("Error updating \(configFile): \(error)")
    }
  }

  return
}

var BinaryPath = "\(Bundle.main.bundlePath)/Contents/MacOS/bin/spicetify"

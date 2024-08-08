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
    logger("\(path) does not exist")
    return nil
  }

  do {
    let fileContent = try String(contentsOfFile: path, encoding: .utf8)
    return fileContent
  } catch {
    logger("Error reading \(path): \(error)")
    return nil
  }
}

func addPathToShellRc() {
  let fileManager = FileManager.default
  let homeDirectory = fileManager.homeDirectoryForCurrentUser

  let (exitStatus, output) = spawnProcess(executable: "/usr/bin/env", arguments: ["sh", "-c", "echo $SHELL"], captureOutput: true)
  guard exitStatus == 0, let shell = output?.trimmingCharacters(in: .newlines) else {
    logger("Error getting user's default shell")
    return
  }

  var configFile: String, exportLine: String
  let exportType = getShellType(from: shell)
  switch exportType {
  case .bash:
    configFile = ".bash_profile"
    exportLine = "export PATH=\"$PATH:\(BinDirPath)\" # spicetify"
  case .zsh:
    configFile = ".zshrc"
    exportLine = "export PATH=\"$PATH:\(BinDirPath)\" # spicetify"
  case .fish:
    configFile = ".config/fish/config.fish"
    exportLine = "fish_add_path \(BinDirPath) # spicetify"
  default:
    logger("Unsupported shell. Skipping configuration file update.")
    return
  }

  logger("User's shell is `\(configFile)`")
    
  let configFilePath = homeDirectory.appendingPathComponent(configFile).path
  var content = readFile(at: configFilePath)

  if content == nil {
    content = ""
  }

  do {
    if !content!.contains(exportLine) {
      if !content!.isEmpty {
        content! += "\n"
      }

      content! += exportLine

      try content!.write(toFile: configFilePath, atomically: true, encoding: .utf8)
      logger("Added path to `\(configFile)`")
    } else {
      logger("Path already exists inside `\(configFile)`")
    }
  } catch {
    logger("Error updating \(configFile): \(error)")
  }

  return
}

private enum ShellType {
    case bash
    case zsh
    case fish
    case unknown
}

private func getShellType(from path: String) -> ShellType {
    switch path {
    case "/bin/bash":
        return .bash
    case "/bin/zsh":
        return .zsh
    case "/usr/local/bin/fish", "/opt/local/bin/fish":
        return .fish
    default:
        return .unknown
    }
}

let BinaryPath = "\(Bundle.main.bundlePath)/Contents/MacOS/bin/spicetify"
let BinDirPath = BinaryPath.range(of: "/spicetify", options: .backwards)
    .map { BinaryPath.replacingCharacters(in: $0, with: "") }!

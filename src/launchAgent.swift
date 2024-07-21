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
let plistPath = launchAgentDirectory.appendingPathComponent("spicetify.Spicetify.daemon.plist")

func createLaunchAgent() -> Bool {
  do {
    try fileManager.createDirectory(
      at: launchAgentDirectory, withIntermediateDirectories: true, attributes: nil)
    try plistData.write(to: plistPath)
    print("LaunchAgent created at \(plistPath.path)")
    return true
  } catch {
    print("Failed to create LaunchAgent: \(error)")
    return false
  }
}

func doesLaunchAgentExist() -> Bool {
  if doesFileExist(plistPath.path) {
    return true
  } else {
    return false
  }
}

func loadLaunchAgent() -> Bool {
  if !doesLaunchAgentExist() {
    createLaunchAgent()
  }

  let proc = spawnProcess(executable: "/bin/launchctl", arguments: ["load", "-w", plistPath.path])
  if proc.exitStatus != 0 {
    print("Failed to load LaunchAgent")
    return false
  }

  return true
}

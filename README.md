# macOS helper

This is a helper app for macOS that helps populating PATH with spicetify binary, setting up the LaunchAgents and handles URI scheme.

## Building

```bash
# Assuming you've already built spicetify binary
mkdir bin
cp <spicetify binary> bin/
sudo xcode-select -s /Applications/Xcode_15.4.app/Contents/Developer
xcodebuild -project spicetify.xcodeproj -scheme spicetify -configuration [Release|Debug] build SYMROOT="$(pwd)/build"
```

After building, you can find the helper app in `build/[Release|Debug]/spicetify.app`.
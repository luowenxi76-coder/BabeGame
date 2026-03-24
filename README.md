# BabeGame

An iOS game prototype built with SwiftUI.

## Status

The native iOS project has been initialized.
The repository already includes a playable starter loop.

## Planned Stack

- Swift
- SwiftUI
- Xcode
- XcodeGen

## What Is Included

- A native `BabeGame.xcodeproj`
- A SwiftUI app target for iPhone
- A small hidden-star prototype game loop
- Generated app icons and asset catalogs

## Project Structure

```text
BabeGame/
├── BabeGame.xcodeproj
├── project.yml
├── BabeGame/
│   ├── App/
│   ├── Game/
│   └── Supporting/
└── scripts/
```

## Open The Project

Open [BabeGame.xcodeproj](/Users/xiaoshu/Desktop/test/BabeGame/BabeGame.xcodeproj) in Xcode.

## Regenerate The Project

If we update `project.yml`, regenerate the Xcode project with:

```bash
cd /Users/xiaoshu/Desktop/test/BabeGame
/opt/homebrew/bin/xcodegen generate
```

## Command Line Build

Verified build command:

```bash
xcodebuild -project /Users/xiaoshu/Desktop/test/BabeGame/BabeGame.xcodeproj \
  -scheme BabeGame \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/BabeGameDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Repository

Remote URL:

`git@github.com:luowenxi76-coder/BabeGame.git`

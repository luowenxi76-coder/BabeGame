# BabeGame

A cozy iPhone cat-home game prototype built with SwiftUI.

## Status

The old hidden-star prototype has been replaced with a playable V1 cat-care loop:

- Create multiple cat profiles
- Upload a cat photo and optionally generate an editable appearance seed with AI
- Manually tweak the cat appearance with a light creator
- Interact at home to gain coins
- Dress the cat and decorate a single-room home
- Send the cat on short trips to earn coins, collectibles, and photo cards
- Persist progress locally with a single Codable save file

## Planned Stack

- Swift
- SwiftUI
- Xcode
- XcodeGen
- PhotosUI
- Local JSON persistence
- OpenAI Responses API for development-only appearance extraction

## What Is Included

- A native `BabeGame.xcodeproj`
- A SwiftUI app target for iPhone
- A multi-cat local save system
- Cozy home, wardrobe, album, travel, and settings flows
- A local pixel cat renderer driven by editable appearance parameters
- Development-only AI appearance extraction with manual fallback
- Generated app icons and asset catalogs

## Project Structure

```text
BabeGame/
├── BabeGame.xcodeproj
├── project.yml
├── BabeGame/
│   ├── App/
│   ├── Core/
│   ├── Features/
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
  build
```

## AI Setup

The cat photo extraction feature is for internal development only.

1. Launch the app.
2. Open `设置`.
3. Save an OpenAI API key into the on-device Keychain.
4. In `创建猫咪` or `重生成 / 调整造型`, choose a photo.
5. Tap `根据照片生成造型`.

If AI generation fails or no API key is configured, the app automatically falls back to full manual editing.

## Repository

Remote URL:

`git@github.com:luowenxi76-coder/BabeGame.git`

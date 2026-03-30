# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HostsManager is a native macOS SwiftUI app for managing `/etc/hosts` with a GUI. It supports add/edit/delete/toggle entries, search/filter, import/export, backups, and quick presets. Targets macOS 13.0+ with Swift 5.9.

## Build Commands

```bash
# Generate Xcode project (required before building — uses XcodeGen)
make generate

# Build universal binary (arm64 + x86_64)
make build

# Full release: clean → build → ZIP → DMG → checksum
make release

# Install to /Applications
make install

# Create DMG only
make dmg
```

**Prerequisites:** Xcode 15+, XcodeGen (`brew install xcodegen`)

There are no automated tests in this project.

## Architecture

Three-file SwiftUI app with no external dependencies:

- **HostsManagerApp.swift** — App entry point with `@main`, creates window (min 800×500) and injects `HostsFileManager` as `@StateObject`/`@EnvironmentObject`
- **HostsFileManager.swift** — `@MainActor` observable class handling all business logic: parsing `/etc/hosts` into `HostEntry` structs, CRUD operations, writing back via AppleScript admin privileges (`osascript`), DNS cache flushing, backup/import/export
- **ContentView.swift** — All UI in one file: sidebar filters, `Table`-based entry list, entry form sheet, import sheet, toast notifications, preset cards

**Data flow:** Load `/etc/hosts` → parse into `[HostEntry]` (`@Published`) → user edits array → "Apply" generates content string → writes via `do shell script "..." with administrator privileges` → flushes DNS cache.

## Build Configuration

- **project.yml** — XcodeGen config (bundle ID: `com.hostsmanager.app`, no code signing, sandbox disabled for `/etc/hosts` access)
- **Makefile** — All build/package/release targets
- **CI** — `.github/workflows/release.yml` builds on version tags; `update-homebrew.yml` dispatches to homebrew tap on release

## Release Process

1. `scripts/release.sh` bumps version in `project.yml` and creates a git tag
2. Pushing the tag triggers CI which builds, creates ZIP+DMG, publishes GitHub Release
3. Release triggers `update-homebrew.yml` which updates the Homebrew tap (`homebrew-hostsmanager`)
4. `scripts/update-homebrew.sh` can manually update the cask formula

## Key Patterns

- Admin file writes use AppleScript: `Process()` running `osascript -e 'do shell script "..." with administrator privileges'`
- Entries with IP `0.0.0.0` or `127.0.0.1` pointing to non-localhost hostnames are treated as "blocking" entries
- Disabled entries are comment-prefixed (`#`) in the hosts file and tracked via `isEnabled` on `HostEntry`
- macOS 14+ availability check used for `alternatingRowBackgrounds` table modifier

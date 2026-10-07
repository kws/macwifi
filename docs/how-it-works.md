---
layout: default
title: How it works
nav_order: 3
---

# How it works

The CLI and the app entry point are the same Swift executable. No Go runtime,
Go adapter, embedded helper extraction or binary network protocol is used.

1. The terminal invocation validates command-line arguments.
2. Help/version run directly. Scans and password commands create a private
   Unix socket and launch MacWiFi.app with LaunchServices.
3. The app runs the selected operation, requests macOS consent when needed,
   and returns stdout, stderr and an exit status to the terminal invocation.
4. The CLI forwards the output and removes its private session directory.

The session directory has mode 0700 and the socket has mode 0600. Passwords
and scan output travel in memory, not through temporary result files.
A random per-invocation token identifies the reply. The app watches the
terminal process and exits when that parent dies, including interrupted or
killed invocations. A terminal-side deadline bounds an unanswered dialog.

LaunchServices remains necessary to give the scanner an app context for
macOS privacy authorization. Moving command parsing to Swift does not remove
Location Services, signing or Keychain consent.

## Scan selection

CoreWLAN supplies observed networks. Selection is a pure Swift function
tested independently of the radio:

- Summary mode selects the strongest result per nonempty SSID, marks C by
  SSID, and appends saved-only placeholders.
- Detailed mode retains the observed results, marks C by normalized nonempty
  BSSID, and never invents a BSSID row for an unobserved saved network.

Detailed scans request hidden-network results from CoreWLAN. Missing
identifiers remain unknown; there is no SSID fallback for the detailed C flag.

The default command/output contract is derived from upstream macwifi-cli.
The CoreWLAN width mapping includes the fix from upstream PR #32.

## Build and signing

Swift Package Manager builds the executable. The build script packages
Info.plist, the location entitlement and the license into MacWiFi.app,
signs the complete bundle and creates a CLI symlink. There is no prebuilt
scanner hidden inside another language's binary, so a rebuild uses the current
Swift source.

`scripts/notarize-app.sh` handles Developer ID distribution builds.
`make check` runs standalone Swift tests, an app launch round trip and
bundle verification. This fork's CI does not publish a Go module or release.

---
layout: default
title: Getting started
nav_order: 2
---

# Getting started

Use macOS 13 or newer and Apple's Command Line Tools or Xcode with Swift 5.9+.

~~~sh
make build
./dist/macwifi-cli scan
./dist/macwifi-cli scan --bssids --json
./dist/macwifi-cli info --bssids
./dist/macwifi-cli password "MyHomeWiFi" --json
~~~

Keep `dist/MacWiFi.app` intact. The CLI symlink points into this app.
Location Services authorization supplies scan identifiers; password lookup
uses the macOS Keychain approval dialog.

The default local build is ad-hoc signed. Use a stable code-signing identity
for authorization that reliably survives rebuilds. For example:

~~~sh
make build SIGN_IDENTITY="Apple Development: Your Name (TEAMID)"
~~~

Default scan output contains one strongest result per SSID and saved-network
placeholders. `--bssids` keeps each observed result, omits saved-only rows
and marks C only when a nonempty BSSID matches the connected AP.

Use `--timeout 2m` to extend the deadline. Errors and password prompt hints
go to stderr, leaving JSON stdout clean. See the [README](../README.md)
for the full contract, tests and distribution signing.

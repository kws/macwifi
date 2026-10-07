# Contributing to MacWiFi

This fork provides a Swift-only macOS Wi-Fi command. Keep changes focused on
the CLI, scan metadata, survey output and platform compatibility.

## Validation

Run `make check` before opening a pull request. It builds and signs the app,
runs the standalone Swift regression suite including app launch, verifies
the bundle and checks help/version.

The automated suite does not request Location Services or access Keychain.
For a scanner or permission change, also check:

~~~sh
./dist/macwifi-cli scan
./dist/macwifi-cli scan --bssids --json
./dist/macwifi-cli info --bssids
~~~

Check password retrieval only with your own explicitly selected test network.
Describe which dialogs and denied-permission cases were tested. Use a stable
code-signing identity when checking persistent authorization across builds.

## Compatibility

Default scans keep strongest-per-SSID selection, saved-network placeholders,
the existing C/S flags and the original JSON field names. Detailed BSSID scans
are opt-in. Add regression coverage for changes to selection, command parsing,
output contracts or the LaunchServices flow.

The package targets macOS 13. Avoid requiring full Xcode or external packages
when Command Line Tools can provide the same functionality.

## Reports

Include the CLI commit/version, macOS version, architecture, Swift version
when building, command and relevant error output. Anonymize network identifiers
and never include real Wi-Fi passwords. macOS consent remains under user control.

# MacWiFi

A Swift command-line tool for Wi-Fi diagnostics on macOS 13 and newer.
This fork uses the scanner from [jaisonerick/macwifi](https://github.com/jaisonerick/macwifi)
and the command/output contract of [macwifi-cli](https://github.com/jaisonerick/macwifi-cli).
The executable, scanner, command parsing and output formatting are all Swift.
There is no Go adapter, embedded legacy helper or Go toolchain requirement.

## Build and run

Install Apple's Command Line Tools, or use Xcode with Swift 5.9 or newer:

~~~sh
make build
./dist/macwifi-cli scan
./dist/macwifi-cli scan --json
./dist/macwifi-cli scan --bssids
./dist/macwifi-cli scan --bssids --json
./dist/macwifi-cli info
./dist/macwifi-cli info --bssids --json
./dist/macwifi-cli password "MyHomeWiFi" --json
~~~

The build creates `dist/MacWiFi.app` and a `dist/macwifi-cli` symlink to
its executable. Keep the app bundle intact when moving or installing the command.
Help and version work without launching the app. Scans and password lookups
launch that same executable through LaunchServices so it has an app identity
for macOS privacy controls.

Run `./dist/macwifi-cli help` for all flags. Flags may appear before or
after the password SSID; use `--` before an SSID that begins with a dash.

## Summary and BSSID scans

| Behavior | Default scan | Scan with --bssids |
| --- | --- | --- |
| Rows | Strongest result for each nonempty SSID | Every observed CoreWLAN network |
| C flag | SSID matches the current connection | Nonempty BSSID matches the current connection |
| S flag | SSID is saved | SSID is saved, on each matching row |
| Saved networks outside the scan | Included with zero radio fields | Omitted |
| Hidden SSIDs | Omitted | Included when CoreWLAN returns them |
| Missing BSSIDs | Empty in JSON, dash in the table | Retained as separate results; never matched as current |

The default summary intentionally preserves the original connection-marker
semantics. Its selected BSSID can differ from the connected AP. Use `--bssids`
for BSSID-level connection information. If the current BSSID is unavailable
or absent from a detailed scan, no row is marked C.

Both modes use the original table column order and JSON field names:
`ssid`, `bssid`, `rssi`, `noise`, `channel`, `channel_band`,
`channel_width`, `security`, `phy_mode`, `current`, and `saved`.
SSID and BSSID strings in JSON are unchanged, including blank identifiers.
Channel widths use CoreWLAN's named constants; unknown width is 0.

`info` returns the first current row or reports disconnected. In detailed
mode, that requires an observed result matching the connected BSSID.
Scanning uses CoreWLAN; this is not a packet-capture or monitor-mode tool.

## Permissions and signing

macOS must grant Location Services access to MacWiFi for unredacted scan
identifiers. Keychain password lookup uses the normal macOS approval dialog.
Passwords are requested only by the password command.

`make build` defaults to an ad-hoc signed development app. Ad-hoc signing
does not guarantee persistent authorization between builds. Use a stable
signing identity for reliable permission tracking:

~~~sh
make build SIGN_IDENTITY="Apple Development: Your Name (TEAMID)"
~~~

For distribution, use Developer ID signing and notarization:

~~~sh
export SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
export NOTARY_PROFILE=macwifi-notary
./scripts/notarize-app.sh
~~~

The notary profile must already be stored in the Keychain with Apple's
notarytool. The script builds, notarizes, staples, verifies and creates
`dist/MacWiFi.app.zip`. CI builds ad-hoc signed apps and runs tests; it
does not publish releases or use signing credentials.

A scan defaults to a 90-second deadline, including launch and authorization.
Password lookup defaults to 60 seconds. Use `--timeout 2m` to allow longer.
`--no-prompt-hint` suppresses only the explanatory Keychain hint on stderr.
JSON output stays on stdout; errors and hints go to stderr.

## Development

~~~sh
make test
make check
~~~

The standalone Swift test runner works with Command Line Tools and does not
require XCTest or full Xcode. Tests cover legacy SSID selection, detailed
BSSID selection, missing identifiers, channel widths, command parsing,
table/JSON compatibility and command errors. `make check` also builds the
signed app and tests a real LaunchServices round trip using version and
invalid-command requests, without scanning or opening the Keychain.

Live Wi-Fi scans and Keychain dialogs must be checked separately with the
appropriate permission and signing identity. CI runs on macOS 14 and the
current macOS runner; the package and test executables target macOS 13.

To use a separately built app, set `MACWIFI_APP` to the Swift MacWiFi.app
bundle. It does not accept the old WifiScanner.app helper.

See [Contributing](CONTRIBUTING.md), [Architecture](docs/how-it-works.md),
[Security](SECURITY.md), and the original [MIT license](LICENSE).

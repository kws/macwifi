#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
swift_bin="${SWIFT:-swift}"
identity="${SIGN_IDENTITY:--}"

"$swift_bin" build --configuration release
bin_path="$("$swift_bin" build --configuration release --show-bin-path)"
bundle="$repo_root/dist/MacWiFi.app"
rm -rf "$bundle"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources"
cp LICENSE "$bundle/Contents/Resources/LICENSE"
cp packaging/Info.plist "$bundle/Contents/Info.plist"
cp "$bin_path/macwifi-cli" "$bundle/Contents/MacOS/macwifi-cli"

codesign --force --sign "$identity" --options runtime \
  --entitlements packaging/entitlements.plist "$bundle"
codesign --verify --deep --strict "$bundle"
ln -sfn MacWiFi.app/Contents/MacOS/macwifi-cli "$repo_root/dist/macwifi-cli"
echo "Built $repo_root/dist/macwifi-cli"
if [ "$identity" = "-" ]; then
  echo "Ad-hoc signed development build. Use a stable signing identity for persistent Location Services authorization."
fi

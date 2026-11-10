#!/bin/bash
# Release build installed into /Applications. Signs with the code-signing
# identity named by CERT_NAME (default "ZoneBar Local Signing") if it exists in
# your keychain, otherwise falls back to ad-hoc signing.
# Hardened runtime is off because its library validation rejects Sparkle when
# neither side has a Team ID (self-signed).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IDENTITY="${CERT_NAME:-ZoneBar Local Signing}"
if ! security find-identity -v -p codesigning | grep -q "\"$IDENTITY\""; then
    echo "Identity \"$IDENTITY\" not found; using ad-hoc signing."
    IDENTITY="-"
fi
DERIVED="$ROOT/build/local"
APP_DEST="/Applications/ZoneBar.app"

xcodebuild -project "$ROOT/ZoneBar.xcodeproj" -scheme ZoneBar -configuration Release \
    -derivedDataPath "$DERIVED" \
    CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$IDENTITY" DEVELOPMENT_TEAM= \
    ENABLE_HARDENED_RUNTIME=NO \
    build | tail -3

APP="$DERIVED/Build/Products/Release/ZoneBar.app"
codesign --verify --deep --strict "$APP"

osascript -e 'tell application "ZoneBar" to quit' >/dev/null 2>&1 || true
sleep 1
rm -rf "$APP_DEST"
ditto "$APP" "$APP_DEST"
codesign -dvv "$APP_DEST" 2>&1 | grep -E "Authority|Identifier"
open "$APP_DEST"
echo "Installed $APP_DEST"

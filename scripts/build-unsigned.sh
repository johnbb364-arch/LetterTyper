#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
xcodebuild -project LetterTyper.xcodeproj -scheme LetterTyper \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' build
app="build/DerivedData/Build/Products/Release-iphoneos/LetterTyper.app"
test -d "$app/PlugIns/LetterKeyboard.appex"
mkdir -p build/package/Payload
ditto "$app" build/package/Payload/LetterTyper.app
(cd build/package && /usr/bin/zip -qry ../LetterTyper-unsigned.ipa Payload)
echo 'Built build/LetterTyper-unsigned.ipa. Sign locally with AltStore Classic before installing.'

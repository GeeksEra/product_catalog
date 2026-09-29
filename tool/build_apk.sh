#!/usr/bin/env bash
# Builds the downloadable Android APK and the QR code that links to it.
#
# Writes apk/product-catalog.apk (release, 64-bit ARM, obfuscated) and
# docs/apk-qr.svg, which encodes the APK's download URL on GitHub. The link
# works once the APK is pushed to the main branch.
#
# Usage: tool/build_apk.sh
set -euo pipefail

cd "$(dirname "$0")/.."
url="https://github.com/GeeksEra/product_catalog/raw/main/apk/product-catalog.apk"

# One APK per CPU type keeps the download small; 64-bit ARM covers almost all
# current phones. Debug symbols stay local for decoding crash stack traces.
flutter build apk --release --split-per-abi \
  --obfuscate --split-debug-info=build/app/outputs/symbols

mkdir -p apk
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk apk/product-catalog.apk

dart run tool/apk_qr.dart "$url" docs/apk-qr.svg

ls -lh apk/product-catalog.apk
shasum -a 256 apk/product-catalog.apk

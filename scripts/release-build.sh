#!/usr/bin/env bash
# scripts/release-build.sh
#
# Build all release artifacts: APK, AAB, Web.
#
# Usage:
#   bash scripts/release-build.sh [output-dir]
#
# Env vars:
#   FLAVOR        - prod (default) | dev
#   BUILD_NUMBER  - número de build (default: 1)
#   BUILD_NAME    - versión semver (default: 0.1.0)
#   OUTPUT_DIR    - directorio destino (default: ./release-artifacts)
#
# Reusable localmente y desde CI (.github/workflows/release.yml).

set -euo pipefail

FLAVOR="${FLAVOR:-prod}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
BUILD_NAME="${BUILD_NAME:-0.1.0}"
OUTPUT_DIR="${1:-${OUTPUT_DIR:-./release-artifacts}}"

echo "═════════════════════════════════════"
echo "  Release build: $BUILD_NAME (#$BUILD_NUMBER)"
echo "  Flavor: $FLAVOR"
echo "  Output: $OUTPUT_DIR"
echo "═════════════════════════════════════"

mkdir -p "$OUTPUT_DIR"

# 1. APK
echo ""
echo "▶ Building APK..."
flutter build apk --release \
  --flavor "$FLAVOR" \
  -t "lib/main_$FLAVOR.dart" \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER"
cp "build/app/outputs/flutter-apk/app-$FLAVOR-release.apk" \
   "$OUTPUT_DIR/btg-funds-app-$BUILD_NAME.apk"
echo "✓ APK: $OUTPUT_DIR/btg-funds-app-$BUILD_NAME.apk"

# 2. AAB
echo ""
echo "▶ Building AAB..."
flutter build appbundle --release \
  --flavor "$FLAVOR" \
  -t "lib/main_$FLAVOR.dart" \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER"
cp "build/app/outputs/bundle/${FLAVOR}Release/app-$FLAVOR-release.aab" \
   "$OUTPUT_DIR/btg-funds-app-$BUILD_NAME.aab"
echo "✓ AAB: $OUTPUT_DIR/btg-funds-app-$BUILD_NAME.aab"

# 3. Web
echo ""
echo "▶ Building Web..."
flutter build web --release \
  --base-href "/" \
  -t "lib/main_$FLAVOR.dart"
(cd build/web && zip -qr "../../$OUTPUT_DIR/btg-funds-app-$BUILD_NAME-web.zip" .)
echo "✓ Web: $OUTPUT_DIR/btg-funds-app-$BUILD_NAME-web.zip"

# 4. Resumen
echo ""
echo "═════════════════════════════════════"
echo "  Build artifacts:"
echo "═════════════════════════════════════"
ls -lh "$OUTPUT_DIR"

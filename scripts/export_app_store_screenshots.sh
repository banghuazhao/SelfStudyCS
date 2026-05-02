#!/usr/bin/env bash
# Runs ScreenshotUITests on iPhone (default 17 Pro Max) simulator; PNGs → AppStoreScreenshots/.
# Override output: IPHONE_SCREENSHOT_OUT=/path ./scripts/export_app_store_screenshots.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEVICE_NAME="${DEVICE_NAME:-iPhone 17 Pro Max}"
DEST_OS="${DEST_OS:-26.2}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=${DEVICE_NAME},OS=${DEST_OS}}"
RESULT_BUNDLE="${RESULT_BUNDLE:-./build/AppStoreScreenshotTests.xcresult}"
# Avoid inheriting OUT_DIR from another export script in the same shell.
OUT_DIR="${IPHONE_SCREENSHOT_OUT:-$ROOT/AppStoreScreenshots}"

rm -rf "$RESULT_BUNDLE"
mkdir -p "$OUT_DIR"

xcodebuild test \
  -scheme SelfStudyCS \
  -destination "$DESTINATION" \
  -only-testing:SelfStudyCSUITests/ScreenshotUITests/testAppStoreScreenshots \
  -resultBundlePath "$RESULT_BUNDLE"

TMP_ATTACH="$(mktemp -d)"
trap 'rm -rf "$TMP_ATTACH"' EXIT

xcrun xcresulttool export attachments \
  --path "$RESULT_BUNDLE" \
  --output-path "$TMP_ATTACH"

shopt -s nullglob
for f in "$TMP_ATTACH"/*; do
  base="$(basename "$f")"
  cp -f "$f" "$OUT_DIR/$base"
done

OUT_DIR="$OUT_DIR" python3 << 'PY'
import json, os, re, sys
out = os.environ.get("OUT_DIR", "")
if not out:
    sys.exit(0)
manifest = os.path.join(out, "manifest.json")
if not os.path.isfile(manifest):
    sys.exit(0)
with open(manifest, encoding="utf-8") as f:
    data = json.load(f)
for item in data:
    for a in item.get("attachments", []):
        src = os.path.join(out, a.get("exportedFileName", ""))
        sug = a.get("suggestedHumanReadableName") or ""
        m = re.match(r"^([0-9]{2}-[^_]+)", sug)
        if not m or not os.path.isfile(src):
            continue
        friendly = m.group(1) + ".png"
        dst = os.path.join(out, friendly)
        with open(src, "rb") as sf, open(dst, "wb") as df:
            df.write(sf.read())
        try:
            os.remove(src)
        except FileNotFoundError:
            pass
PY

rm -f "$OUT_DIR/manifest.json"

echo "Screenshots exported under: $OUT_DIR (1320×2868 PNG for 6.7\" App Store display)"

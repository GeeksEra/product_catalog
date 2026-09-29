#!/usr/bin/env bash
# Records the demo walkthrough on a booted iOS simulator and writes
# docs/demo.mp4 (H.264, 590 px wide) and docs/demo.gif (a smaller preview the
# README shows inline).
#
# Usage: tool/record_demo.sh [simulator-udid]   (default: the booted one)
# Needs: Xcode command-line tools and ffmpeg.
set -euo pipefail

cd "$(dirname "$0")/.."
device="${1:-booted}"
udid="$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1)"
[[ "$device" == "booted" ]] && device="$udid"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
log="$work/drive.log"
raw="$work/raw.mov"

# Build and launch in the background; start recording only once the app is up,
# so the video doesn't open on minutes of home screen.
flutter drive -d "$device" \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/demo_video_test.dart >"$log" 2>&1 &
drive_pid=$!

until grep -q 'Connected to Flutter application' "$log"; do
  if ! kill -0 "$drive_pid" 2>/dev/null; then cat "$log"; exit 1; fi
  sleep 0.5
done

xcrun simctl io "$device" recordVideo --codec=h264 --force "$raw" &
record_pid=$!

wait "$drive_pid" || { kill -INT "$record_pid"; cat "$log"; exit 1; }
sleep 1
kill -INT "$record_pid"
wait "$record_pid" || true
grep -q 'All tests passed' "$log" || { cat "$log"; exit 1; }

mkdir -p docs
ffmpeg -y -loglevel error -i "$raw" \
  -vf "scale=590:-2:flags=lanczos,fps=30" \
  -c:v libx264 -preset slow -crf 26 -pix_fmt yuv420p -movflags +faststart -an \
  docs/demo.mp4

# A lighter GIF so the README shows the demo inline.
ffmpeg -y -loglevel error -i docs/demo.mp4 \
  -vf "fps=10,scale=270:-2:flags=lanczos,split[a][b];[a]palettegen=max_colors=64:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
  docs/demo.gif

ls -lh docs/demo.mp4 docs/demo.gif

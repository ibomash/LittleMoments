#!/bin/zsh

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
app_path="$repo_root/.build/macos/Build/Products/Debug/LittleMomentsMac.app"
executable_path="$app_path/Contents/MacOS/LittleMomentsMac"

build_app() {
  cd "$repo_root"
  bin/fastlane generate
  bin/fastlane mac build_mac
}

case "${1:-run}" in
  run)
    build_app
    open "$app_path"
    ;;
  debug)
    build_app
    lldb "$executable_path"
    ;;
  logs | telemetry)
    /usr/bin/log stream --style compact \
      --predicate 'process == "LittleMomentsMac" OR subsystem == "net.bomash.illya.LittleMoments"'
    ;;
  verify)
    cd "$repo_root"
    bin/fastlane generate
    bin/fastlane mac test_mac
    ;;
  *)
    print -u2 "Usage: $0 [run|debug|logs|telemetry|verify]"
    exit 64
    ;;
esac

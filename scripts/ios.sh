#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-}"
shift || true

if [[ -z "$cmd" ]]; then
  echo "Usage: scripts/ios.sh generate|format|lint|test|build|quality [fastlane key:value args...]"
  exit 1
fi

case "$cmd" in
  generate)
    bin/fastlane generate "$@"
    ;;
  format)
    bin/fastlane format_code "$@"
    ;;
  lint)
    bin/fastlane lint "$@"
    ;;
  test)
    bin/fastlane test "$@"
    ;;
  build)
    bin/fastlane build "$@"
    ;;
  quality)
    bin/fastlane quality_check "$@"
    ;;
  *)
    echo "Unknown command: $cmd"
    exit 1
    ;;
esac

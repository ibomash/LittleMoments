#!/usr/bin/env bash
set -euo pipefail

# Install bundler
gem install bundler

# Configure bundle path
bundle config set --local path vendor/bundle

# Install gems
bundle install --jobs 4 --retry 3

# Install Tuist
curl -Ls https://install.tuist.io | bash

# Install SwiftLint and swift-format
if command -v brew >/dev/null 2>&1; then
  brew install swiftlint swift-format
else
  echo "Homebrew not found; skipping SwiftLint and swift-format installation"
fi

# Generate Xcode project and prefetch Swift packages if possible
if command -v fastlane >/dev/null 2>&1; then
  bundle exec fastlane generate || echo "fastlane generate failed; continuing"
fi

# Optionally resolve package dependencies if xcodebuild is available
if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -resolvePackageDependencies || true
fi

fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Run SwiftLint

### ios format_code

```sh
[bundle exec] fastlane ios format_code
```

Format Swift code

### ios generate

```sh
[bundle exec] fastlane ios generate
```

Generate Xcode project with Tuist

### ios test_unit

```sh
[bundle exec] fastlane ios test_unit
```

Run unit tests

### ios test_ui

```sh
[bundle exec] fastlane ios test_ui
```

Run UI tests

### ios test

```sh
[bundle exec] fastlane ios test
```

Run all tests

### ios build

```sh
[bundle exec] fastlane ios build
```

Build app with Tuist

### ios quality_check

```sh
[bundle exec] fastlane ios quality_check
```

Format, lint, test, and build

### ios repomix

```sh
[bundle exec] fastlane ios repomix
```

Generate repository overview with Repomix

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

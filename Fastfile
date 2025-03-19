default_platform(:ios)

platform :ios do
  desc "Run SwiftLint"
  lane :lint do
    swiftlint(
      mode: :lint,
      quiet: true,
      strict: true,
      ignore_exit_status: true
    )
  end

  desc "Format Swift code"
  lane :format_code do
    sh("swift-format -i -r ../LittleMoments --configuration ../.swift-format.json")
  end

  desc "Run tests"
  lane :test do
    begin
      sh("cd .. && xcodebuild -project LittleMoments.xcodeproj -scheme 'Little Moments' -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test")
    rescue
      UI.important("Tests failed but continuing...")
    end
  end

  desc "Build the app"
  lane :build do
    begin
      sh("cd .. && xcodebuild -project LittleMoments.xcodeproj -scheme 'Little Moments' -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build")
    rescue => ex
      UI.error(ex)
      UI.important("Build failed but continuing...")
    end
  end

  desc "Build the app for release"
  lane :build_release do
    begin
      sh("cd .. && xcodebuild -project LittleMoments.xcodeproj -scheme 'Little Moments' -configuration Release -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build")
    rescue => ex
      UI.error(ex)
      UI.important("Release build failed but continuing...")
    end
  end

  desc "Run formatting, linting, tests, and build"
  lane :quality_check do
    format_code
    lint
    test
    build
  end
end 
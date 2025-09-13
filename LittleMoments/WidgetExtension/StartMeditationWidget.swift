import SwiftUI
import WidgetKit

// A simple Lock Screen/Home Screen widget that starts a session via deep link
// This serves as a fallback for devices/OSes without Control Center Controls
struct StartMeditationWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: "net.bomash.illya.LittleMoments.widget.startMeditation", provider: Provider()
    ) { _ in
      StartMeditationWidgetView()
    }
    .configurationDisplayName("Start Meditation")
    .description("Start a quick meditation session")
    // Small sizes make the most sense for a single action
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
  }
}

private struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> Entry { Entry(date: Date()) }
  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    completion(Entry(date: Date()))
  }
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let timeline = Timeline(entries: [Entry(date: Date())], policy: .never)
    completion(timeline)
  }
}

private struct Entry: TimelineEntry { let date: Date }

private struct StartMeditationWidgetView: View {
  @Environment(\.widgetFamily) private var family
  @Environment(\.showsWidgetContainerBackground) private var showsBackground

  var body: some View {
    let content = Group {
      switch family {
      case .systemSmall:
        smallWidget
          // Tap anywhere else starts an untimed session
          .widgetURL(URL(string: "littlemoments://startSession"))
      case .accessoryRectangular:
        accessoryRectangular
          .widgetURL(URL(string: "littlemoments://startSession"))
      case .accessoryCircular:
        accessoryCircular
          .widgetURL(URL(string: "littlemoments://startSession"))
      default:
        // Fallback to a simple start link for any future families
        safeLink("littlemoments://startSession") {
          Label("Breathe", systemImage: "play.circle.fill")
            .font(.system(.caption2, design: .rounded))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }

    if #available(iOS 17.0, *) {
      content.containerBackground(for: .widget) { Color.clear }
    } else {
      content
    }
  }

  // MARK: - Subviews
  private var smallWidget: some View {
    ZStack {
      // Soothing gradient background that respects widget chrome
      if #available(iOS 17.0, *) {
        // Additional subtle vignette when the system doesn't draw a chrome
        if !showsBackground {
          ContainerRelativeShape()
            .fill(
              LinearGradient(
                colors: [Color.blue.opacity(0.75), Color.purple.opacity(0.75)],
                startPoint: .topLeading, endPoint: .bottomTrailing
              ))
        }
      }

      VStack(alignment: .leading, spacing: 8) {
        // Title
        VStack(alignment: .leading, spacing: 2) {
          Text("Little Moments")
            .font(.system(.caption2, design: .rounded))
            .opacity(0.9)
          Text("Breathe")
            .font(.system(size: 22, weight: .semibold, design: .rounded))
            .minimumScaleFactor(0.8)
        }

        Spacer(minLength: 4)

        // Quick actions
        HStack(spacing: 6) {
          durationChip(seconds: 60)
          durationChip(seconds: 300)
          Spacer()
          // Primary action (untimed)
          safeLink("littlemoments://startSession") {
            Image(systemName: "play.fill")
              .font(.system(size: 13, weight: .semibold))
              .padding(7)
              .background(Color.white.opacity(0.15))
              .clipShape(Circle())
              .accessibilityLabel("Start now")
          }
        }
      }
      .foregroundStyle(foregroundStyle)
      .padding(12)
    }
  }

  private var accessoryRectangular: some View {
    HStack(spacing: 8) {
      Image(systemName: "wind")
        .font(.system(size: 16, weight: .semibold))
      VStack(alignment: .leading, spacing: 2) {
        Text("Breathe")
          .font(.system(.caption, design: .rounded))
          .fontWeight(.semibold)
        Text("Tap to begin")
          .font(.system(.caption2, design: .rounded))
          .opacity(0.7)
      }
      Spacer()
    }
    .padding(.vertical, 2)
    .foregroundStyle(foregroundStyle)
  }

  private var accessoryCircular: some View {
    ZStack {
      Circle().strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
        .opacity(0.25)
      Image(systemName: "play.fill")
        .font(.system(size: 16, weight: .bold))
    }
    .foregroundStyle(foregroundStyle)
  }

  // Small helper to produce a duration chip that opens the app with a preset timer
  private func durationChip(seconds: Int) -> some View {
    let minutes = seconds % 60 == 0 ? seconds / 60 : nil
    let numberText: String
    let suffix: String
    if let minutesVal = minutes {
      numberText = String(minutesVal)
      suffix = "m"
    } else {
      numberText = String(seconds)
      suffix = "s"
    }
    return safeLink("littlemoments://startSession?duration=\(seconds)") {
      HStack(alignment: .firstTextBaseline, spacing: 1) {
        Text(numberText)
          .font(.system(size: 12, weight: .semibold, design: .rounded))
          .monospacedDigit()
          .lineLimit(1)
          .fixedSize(horizontal: true, vertical: false)
        Text(suffix)
          .font(.system(size: 9, weight: .semibold, design: .rounded))
          .lineLimit(1)
          .fixedSize(horizontal: true, vertical: false)
      }
      .padding(.vertical, 5)
      .padding(.horizontal, 8)
      .frame(minWidth: 28, alignment: .center)
      .background(Color.white.opacity(0.15))
      .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
      .accessibilityLabel("Start \(numberText)\(suffix) session")
      .layoutPriority(1)
    }
  }

  // Safer link builder to avoid force-unwrapping URLs
  @ViewBuilder
  private func safeLink<Content: View>(
    _ urlString: String, @ViewBuilder content: () -> Content
  ) -> some View {
    if let url = URL(string: urlString) {
      Link(destination: url, label: content)
    } else {
      content()
    }
  }

  // Foreground adapts to system background (light/dark and widget chrome)
  private var foregroundStyle: some ShapeStyle {
    if showsBackground {
      return AnyShapeStyle(.primary)
    } else {
      return AnyShapeStyle(.white)
    }
  }

  // No extra wrapper needed; body handles iOS versioning for container background
}

#if DEBUG
  struct StartMeditationWidget_Previews: PreviewProvider {
    static var previews: some View {
      StartMeditationWidgetView()
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        .previewDisplayName("Accessory Circular")

      StartMeditationWidgetView()
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("Accessory Rectangular")

      StartMeditationWidgetView()
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Small")
    }
  }
#endif

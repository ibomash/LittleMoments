import SwiftUI
import WidgetKit

// A simple Lock Screen/Home Screen widget that starts a session via deep link
// This serves as a fallback for devices/OSes without Control Center Controls
struct StartMeditationWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "net.bomash.illya.LittleMoments.widget.startMeditation", provider: Provider()) { _ in
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
  var body: some View {
    // Using a deep link so the app can immediately present TimerRunningView
    let inner = Link(destination: URL(string: "littlemoments://startSession")!) {
      // Simple, bold call to action icon+label for clarity
      VStack(spacing: 6) {
        Image(systemName: "play.circle.fill").font(.system(size: 20, weight: .semibold))
        Text("Start")
          .font(.system(.caption2, design: .rounded))
          .minimumScaleFactor(0.7)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .widgetAccentable()
    }

    if #available(iOS 17.0, *) {
      inner
        .containerBackground(for: .widget) { Color.clear }
    } else {
      inner
    }
  }
}

#if DEBUG
struct StartMeditationWidget_Previews: PreviewProvider {
  static var previews: some View {
    StartMeditationWidgetView()
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
      .previewDisplayName("Accessory Circular")

    StartMeditationWidgetView()
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      .previewDisplayName("Small")
  }
}
#endif

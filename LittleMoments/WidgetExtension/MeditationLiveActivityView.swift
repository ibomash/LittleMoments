import ActivityKit
import SwiftUI
import UIKit
import WidgetKit

struct MeditationLiveActivityView: View {
  let context: ActivityViewContext<MeditationLiveActivityAttributes>
  @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

  @ViewBuilder
  var body: some View {
    let reducesTransparency = UIAccessibility.isReduceTransparencyEnabled
    let baseFill = LiquidGlassTokens.surfaceFill(
      tint: LiquidGlassTokens.primaryTint,
      reducesTransparency: reducesTransparency,
      fallback: Color(UIColor.systemGroupedBackground),
      opacity: 0.22
    )
    let baseStroke = LiquidGlassTokens.surfaceStroke(
      reducesTransparency: reducesTransparency,
      fallback: Color.white.opacity(0.18)
    )
    let fillStyle: AnyShapeStyle = showsWidgetBackground ? AnyShapeStyle(Color.clear) : baseFill

    let content = ZStack {
      ContainerRelativeShape()
        .fill(fillStyle)
        .overlay {
          if !showsWidgetBackground {
            ContainerRelativeShape().stroke(baseStroke, lineWidth: 1)
          }
        }

      VStack {
        Text("Meditation in progress")
          .font(.headline)

        HStack(spacing: 16) {
          // Timer display
          VStack {
            Text(timerDisplay)
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .monospacedDigit()
              .minimumScaleFactor(0.5)
          }

          // Progress bar (for timed sessions)
          if let targetTime = context.state.targetTimeInSeconds, targetTime > 0 {
            ProgressView(value: min(context.state.secondsElapsed / targetTime, 1.0))
              .progressViewStyle(.circular)
              .frame(width: 40, height: 40)
          }
        }
        .padding(.vertical, 4)

        // Use links instead of buttons for deep linking
        HStack(spacing: 12) {
          if let url = URL(string: "littlemoments://cancelSession") {
            Link(destination: url) {
              glassLinkLabel("Cancel", role: .destructive, reducesTransparency: reducesTransparency)
            }
          }

          if let url = URL(string: "littlemoments://finishSession") {
            Link(destination: url) {
              glassLinkLabel("Finish", role: .success, reducesTransparency: reducesTransparency)
            }
          }
        }
      }
      .padding()
    }

    content
      .containerBackground(for: .widget) { Color.clear }
  }

  private var timerDisplay: String {
    return timerDisplayFromSeconds(
      seconds: context.state.secondsElapsed, showSeconds: context.state.showSeconds)
  }
}

extension MeditationLiveActivityView {
  fileprivate func glassLinkLabel(
    _ title: String,
    role: LiquidGlassButtonStyle.Role,
    reducesTransparency: Bool
  ) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(
          LiquidGlassTokens.surfaceFill(
            tint: role.tint(for: .prominent),
            reducesTransparency: reducesTransparency,
            fallback: role.fallbackTint(for: .prominent),
            opacity: 0.26
          )
        )
        .overlay(
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(
              LiquidGlassTokens.surfaceStroke(
                reducesTransparency: reducesTransparency,
                fallback: role.fallbackStroke(for: .prominent),
                tint: LiquidGlassTokens.prominentForeground,
                opacity: 0.32
              ),
              lineWidth: 1
            )
        )

      Text(title)
        .font(.system(.subheadline, design: .rounded).weight(.semibold))
        .foregroundStyle(role.foregroundColor(for: .prominent))
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
    }
    .frame(maxWidth: .infinity, minHeight: 38)
  }
}

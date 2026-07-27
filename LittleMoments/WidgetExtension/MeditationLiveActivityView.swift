import ActivityKit
import SwiftUI
import UIKit
import WidgetKit

struct MeditationLiveActivityView: View {
  let context: ActivityViewContext<MeditationLiveActivityAttributes>
  @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

  private let horizontalPadding: CGFloat = 16

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

    let content = ZStack(alignment: .bottom) {
      ContainerRelativeShape()
        .fill(fillStyle)
        .overlay {
          if !showsWidgetBackground {
            ContainerRelativeShape().stroke(baseStroke, lineWidth: 1)
          }
        }

      VStack(alignment: .leading, spacing: 12) {
        VStack(alignment: .leading, spacing: 2) {
          Text(context.state.isCompleted ? "Meditation complete" : "Meditating")
            .font(.caption2.weight(.semibold))
            .tracking(1)
            .textCase(.uppercase)
            .foregroundStyle(.secondary)

          LiveActivityElapsedTimeView(state: context.state)
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .monospacedDigit()
            .minimumScaleFactor(0.7)
            .lineLimit(1)
            .contentTransition(.numericText())
        }

        HStack(spacing: 10) {
          if let url = URL(string: "littlemoments://cancelSession") {
            Link(destination: url) {
              glassLinkLabel("Cancel", role: .neutral, reducesTransparency: reducesTransparency)
            }
          }

          if let url = URL(string: "littlemoments://finishSession") {
            Link(destination: url) {
              glassLinkLabel("Finish", role: .accent, reducesTransparency: reducesTransparency)
            }
          }
        }
      }
      .padding(.horizontal, horizontalPadding)
      .padding(.top, 14)
      .padding(.bottom, 12)

      if context.state.targetTimeInSeconds != nil {
        LiveActivityProgressView(state: context.state)
          .progressViewStyle(.linear)
          .tint(context.state.isCompleted ? LiquidGlassTokens.successTint : .accentColor)
          .frame(maxWidth: .infinity)
          .padding(.horizontal, 1)
          .accessibilityLabel("Session progress")
      }
    }

    content
      .containerBackground(for: .widget) { Color.clear }
  }

}

struct LiveActivityElapsedTimeView: View {
  let state: MeditationLiveActivityAttributes.ContentState

  @ViewBuilder
  var body: some View {
    if state.isCompleted {
      Text(
        timerDisplayFromSeconds(
          seconds: state.secondsElapsed,
          showSeconds: state.showSeconds
        )
      )
    } else if state.showSeconds {
      Text(state.startDate, style: .timer)
    } else {
      Text(state.startDate, style: .relative)
    }
  }
}

struct LiveActivityProgressView: View {
  let state: MeditationLiveActivityAttributes.ContentState

  @ViewBuilder
  var body: some View {
    if state.isCompleted, let targetTime = state.targetTimeInSeconds, targetTime > 0 {
      ProgressView(value: min(state.secondsElapsed / targetTime, 1.0))
        .labelsHidden()
    } else if let targetEndDate = state.targetEndDate, targetEndDate > state.startDate {
      ProgressView(
        timerInterval: state.startDate...targetEndDate,
        countsDown: false
      )
      .labelsHidden()
    } else {
      ProgressView(value: 0)
        .labelsHidden()
    }
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
        .padding(.vertical, 6)
    }
    .frame(maxWidth: .infinity, minHeight: 34)
  }
}

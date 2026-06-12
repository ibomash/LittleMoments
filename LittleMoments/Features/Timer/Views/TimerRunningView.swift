//
//  TimerRunningView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI
import UserNotifications

struct TimerRunningView: View {
  let buttonsPerRow = 4
  @StateObject var timerViewModel = TimerViewModel()
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @State private var liveActivityUpdateTimer: Timer?
  @State private var showCustomDurationSheet = false
  @AppStorage("lastCustomDurationMinutes") private var lastCustomDurationMinutes = 10
  @Environment(\.accessibilityReduceTransparency) private var reducesTransparency
  private let containerCornerRadius: CGFloat = 32

  var body: some View {
    GeometryReader { geometry in
      let isLandscape = geometry.size.width > geometry.size.height
      ZStack {
        backgroundSurface

        if isLandscape {
          HStack(spacing: 32) {
            timerColumn(for: geometry.size)

            controlsContainer
              .frame(maxWidth: geometry.size.width * 0.45)
          }
          .padding(.horizontal, 40)
          .padding(.vertical, 32)
        } else {
          VStack(spacing: 32) {
            timerColumn(for: geometry.size)

            controlsContainer
          }
          .padding(.horizontal, 24)
          .padding(.vertical, 48)
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    .onAppear {
      print("📱 TimerRunningView appeared - starting timer and Live Activity")

      timerViewModel.start()
      timerViewModel.startLiveActivity()
      UIApplication.shared.isIdleTimerDisabled = true
      if JustNowSettings.shared.ringBellAtStart {
        SoundManager.playSound()
      }

      // Apply any preset duration passed via deep link with a small delay
      // This ensures that any reset() calls from Live Activity notifications don't interfere
      if let preset = AppState.shared.pendingStartDurationSeconds {
        print("📱 Will apply preset duration: \(preset) seconds after delay")
        AppState.shared.pendingStartDurationSeconds = nil

        // Use a small delay to ensure Live Activity setup is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          print("📱 Applying preset duration: \(preset) seconds")
          timerViewModel.setDurationTarget(seconds: preset)
          print(
            "📱 Applied preset duration, scheduledAlert: \(timerViewModel.scheduledAlert?.name ?? "nil")"
          )
        }
      }

      // Update timer for Live Activity
      liveActivityUpdateTimer = Timer.scheduledTimer(
        withTimeInterval: 1.0,
        repeats: true
      ) { [weak timerViewModel] _ in
        Task { @MainActor in
          guard let timerViewModel = timerViewModel else { return }

          // Only update if the timer is active (not nil)
          if timerViewModel.timer != nil {
            timerViewModel.updateLiveActivity()
          } else {
            // If timer is no longer running, invalidate this update timer
            self.liveActivityUpdateTimer?.invalidate()
            self.liveActivityUpdateTimer = nil
          }
        }
      }
    }
    .sheet(isPresented: $showCustomDurationSheet) {
      CustomDurationSheet(
        mode: .running,
        initialMinutes: customDurationInitialMinutes,
        onApply: applyCustomDuration,
        onCancel: { showCustomDurationSheet = false }
      )
      .presentationDetents([.medium])
      .presentationDragIndicator(.visible)
      .presentationCornerRadius(32)
    }
    .onDisappear {
      print("📱 TimerRunningView disappeared - cleaning up timer resources")
      // Invalidate the live activity update timer
      liveActivityUpdateTimer?.invalidate()
      liveActivityUpdateTimer = nil

      // Remove any pending timer notification without clearing unrelated ones
      UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: ["timerNotification"]
      )

      // Reset the timer state (no HealthKit operations here)
      timerViewModel.reset()

      // Re-enable screen timeout
      UIApplication.shared.isIdleTimerDisabled = false
    }
  }
}

extension TimerRunningView {
  fileprivate var controlsContainer: some View {
    glassContainer {
      VStack(spacing: 24) {
        BellControlsGrid(
          timerViewModel: timerViewModel,
          onCustomDurationTapped: { showCustomDurationSheet = true }
        )
        .frame(maxWidth: .infinity, alignment: .leading)

        TimerControlButtons(timerViewModel: timerViewModel, presentationMode: presentationMode)
      }
    }
  }

  fileprivate var customDurationInitialMinutes: Int {
    if timerViewModel.hasCustomDurationTarget,
      let targetSeconds = timerViewModel.scheduledAlert?.targetTimeInSec
    {
      return max(Int(targetSeconds / 60), MeditationDuration.minimumMinutes)
    }
    return lastCustomDurationMinutes
  }

  fileprivate func applyCustomDuration(_ duration: MeditationDuration) {
    lastCustomDurationMinutes = duration.minutes
    timerViewModel.setDurationTarget(minutes: duration.minutes)
    showCustomDurationSheet = false
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  fileprivate func timerColumn(for size: CGSize) -> some View {
    VStack {
      Spacer(minLength: 0)
      TimerCircleView(timerViewModel: timerViewModel)
        .frame(
          width: min(size.width, size.height) * 0.5,
          height: min(size.width, size.height) * 0.5
        )
        .frame(minWidth: 180, maxWidth: 320, minHeight: 180, maxHeight: 320)
        .padding(.horizontal, 12)
      Spacer(minLength: 0)
    }
  }

  @ViewBuilder
  fileprivate var backgroundSurface: some View {
    if reducesTransparency {
      Color(UIColor.systemBackground).ignoresSafeArea()
    } else {
      LinearGradient(
        colors: [
          LiquidGlassTokens.primaryTint.opacity(0.18),
          Color(UIColor.systemBackground),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      ).ignoresSafeArea()
    }
  }

  fileprivate func glassContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
      .frame(maxWidth: .infinity)
      .padding(24)
      .background(
        RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
          .fill(
            reducesTransparency
              ? Color(UIColor.secondarySystemBackground)
              : Color.white.opacity(0.12)
          )
          .background(
            RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
              .fill(
                reducesTransparency
                  ? Color(UIColor.secondarySystemBackground)
                  : Color.white.opacity(0.05)
              )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
          .stroke(Color.white.opacity(reducesTransparency ? 0.18 : 0.25), lineWidth: 1)
      )
      .shadow(
        color: LiquidGlassTokens.shadowColor,
        radius: 20,
        y: LiquidGlassTokens.shadowOffsetY
      )
  }
}

// MARK: - Timer Circle View
struct TimerCircleView: View {
  @ObservedObject var timerViewModel: TimerViewModel

  var body: some View {
    TimelineView(.periodic(from: Date(), by: 0.1)) { _ in
      ZStack {
        Circle()
          .stroke(lineWidth: 10)
          .opacity(timerViewModel.hasEndTarget ? 0.2 : 0)
          .foregroundColor(LiquidGlassTokens.primaryTint)
          .animation(.linear, value: timerViewModel.hasEndTarget)

        Circle()
          .trim(from: 0, to: timerViewModel.progress)
          .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
          .foregroundColor(
            timerViewModel.isDone ? LiquidGlassTokens.successTint : LiquidGlassTokens.primaryTint
          )
          .rotationEffect(Angle(degrees: 270))
          .animation(.linear, value: timerViewModel.progress)

        Text("\(timerViewModel.timeElapsedFormatted)")
          .font(.largeTitle)
          .fontWeight(.bold)
      }
    }
  }
}

// MARK: - Bell Controls Grid
private enum TimerDurationGridItem {
  case preset(OneTimeScheduledBellAlert)
  case custom

  var id: String {
    switch self {
    case .preset(let option):
      return "preset-\(Int(option.targetTimeInSec))-\(option.name)"
    case .custom:
      return "custom"
    }
  }
}

struct BellControlsGrid: View {
  @ObservedObject var timerViewModel: TimerViewModel
  let onCustomDurationTapped: () -> Void
  let buttonsPerRow = 4

  private var gridItems: [TimerDurationGridItem] {
    timerViewModel.scheduledAlertOptions.map(TimerDurationGridItem.preset) + [.custom]
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Timer (minutes)")
        .font(.caption.weight(.semibold))
        .textCase(.uppercase)
        .foregroundStyle(Color.secondary)

      ForEach(
        Array(gridItems.chunked(into: buttonsPerRow).enumerated()),
        id: \.offset
      ) { _, row in
        HStack(spacing: 12) {
          ForEach(row, id: \.id) { item in
            gridButton(for: item)
          }

          if row.count < buttonsPerRow {
            ForEach(0..<(buttonsPerRow - row.count), id: \.self) { _ in
              Spacer()
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  private func gridButton(for item: TimerDurationGridItem) -> some View {
    switch item {
    case .preset(let option):
      Button {
        handleAlertSelection(option)
      } label: {
        Text(option.name)
      }
      .buttonStyle(.plain)
      .liquidGlassChip(isSelected: timerViewModel.scheduledAlert == option)
      .accessibilityIdentifier(
        timerViewModel.scheduledAlert == option
          ? "selected_duration_\(option.name)"
          : "duration_\(option.name)"
      )
      .accessibilityAddTraits(
        timerViewModel.scheduledAlert == option ? .isSelected : []
      )
    case .custom:
      Button {
        handleCustomSelection()
      } label: {
        customChipLabel
      }
      .buttonStyle(.plain)
      .liquidGlassChip(isSelected: timerViewModel.hasCustomDurationTarget)
      .accessibilityIdentifier("custom_duration_running_chip")
      .accessibilityLabel(customAccessibilityLabel)
      .accessibilityHint(customAccessibilityHint)
      .accessibilityAddTraits(timerViewModel.hasCustomDurationTarget ? .isSelected : [])
    }
  }

  @ViewBuilder
  private var customChipLabel: some View {
    if let label = timerViewModel.customDurationChipLabel {
      Text(label)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    } else {
      Image(systemName: "slider.horizontal.3")
        .font(.system(size: 18, weight: .semibold))
        .imageScale(.medium)
    }
  }

  private var customAccessibilityLabel: Text {
    if let label = timerViewModel.customDurationLabel {
      return Text("Custom duration, \(label), selected")
    }
    return Text("Custom duration")
  }

  private var customAccessibilityHint: Text {
    if timerViewModel.hasCustomDurationTarget {
      return Text("Clears the custom timer")
    }
    return Text("Opens custom duration settings")
  }

  @MainActor
  private func handleAlertSelection(_ scheduledAlertOption: OneTimeScheduledBellAlert) {
    if timerViewModel.scheduledAlert == scheduledAlertOption {
      timerViewModel.clearDurationTarget()
    } else {
      timerViewModel.setDurationTarget(seconds: Int(scheduledAlertOption.targetTimeInSec))
    }
  }

  @MainActor
  private func handleCustomSelection() {
    if timerViewModel.hasCustomDurationTarget {
      timerViewModel.clearDurationTarget()
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
    } else {
      onCustomDurationTapped()
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
  }
}

// MARK: - Timer Control Buttons
struct TimerControlButtons: View {
  @ObservedObject var timerViewModel: TimerViewModel
  var presentationMode: Binding<PresentationMode>

  var body: some View {
    HStack(spacing: 16) {
      Button {
        print("🔘 Cancel button tapped - ending Live Activity and resetting timer")
        timerViewModel.endLiveActivity(completed: false)
        timerViewModel.reset()
        presentationMode.wrappedValue.dismiss()
      } label: {
        Label("Cancel", systemImage: "xmark.circle.fill")
      }
      .accessibilityIdentifier("cancel_timer_button")
      .liquidGlassButtonStyle(.prominent, role: .destructive)

      Button {
        print("🔘 Complete button tapped - storing startDate for async health pipeline")
        timerViewModel.prepareSessionForFinish()
        print("🔘 Recording session history entry")
        timerViewModel.recordCompletedSession()
        print("🔘 Providing haptic feedback for session completion")
        LiveActivityManager.shared.provideSessionCompletionFeedback()
        print("🔘 Ending Live Activity with completed status")
        timerViewModel.endLiveActivity(completed: true)
        print("🔘 Dismissing timer view")
        presentationMode.wrappedValue.dismiss()
      } label: {
        Label("Complete", systemImage: "checkmark.circle.fill")
      }
      .accessibilityIdentifier("complete_timer_button")
      .liquidGlassButtonStyle(.prominent, role: .success)
    }
    .frame(maxWidth: .infinity)
  }
}

struct TimerRunningView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TimerRunningView()
        .previewInterfaceOrientation(.portrait)

      TimerRunningView()
        .previewInterfaceOrientation(.landscapeLeft)
    }
  }
}

extension Array {
  fileprivate func chunked(into size: Int) -> [[Element]] {
    guard size > 0 else { return [] }
    var chunks: [[Element]] = []
    var index = 0
    while index < count {
      let end = Swift.min(index + size, count)
      chunks.append(Array(self[index..<end]))
      index += size
    }
    return chunks
  }
}

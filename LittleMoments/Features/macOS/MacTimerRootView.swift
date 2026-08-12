import AppKit
import SwiftUI

@MainActor
struct MacTimerRootView: View {
  let model: MacSessionModel

  @AppStorage("lastCustomDurationMinutes") private var lastCustomDurationMinutes = 10
  @Environment(\.accessibilityReduceMotion) private var reducesMotion
  @Environment(\.accessibilityReduceTransparency) private var reducesTransparency
  @Namespace private var sessionTransition
  @State private var showsCustomDuration = false

  var body: some View {
    ZStack {
      backgroundSurface

      Group {
        if model.isRunning {
          MacRunningSessionView(
            model: model,
            transitionNamespace: sessionTransition,
            onChooseCustomDuration: showCustomDuration
          )
          .transition(sessionViewTransition)
        } else {
          MacSessionStartView(
            model: model,
            transitionNamespace: sessionTransition,
            onChooseCustomDuration: showCustomDuration
          )
          .transition(sessionViewTransition)
        }
      }
      .padding(40)
    }
    .frame(minWidth: 420, idealWidth: 460, minHeight: 520, idealHeight: 560)
    .animation(reducesMotion ? nil : .smooth(duration: 0.35), value: model.isRunning)
    .background(MainWindowCloseBridge(coordinator: .shared))
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        SettingsLink {
          Label("Settings", systemImage: "gearshape")
        }
        .help("Settings")
      }
    }
    .sheet(isPresented: $showsCustomDuration) {
      MacCustomDurationView(initialMinutes: customDurationInitialMinutes) { duration in
        lastCustomDurationMinutes = duration.minutes
        model.setDuration(seconds: duration.seconds)
      }
    }
    .alert(
      "Session History Wasn't Saved",
      isPresented: Binding(
        get: { model.errorMessage != nil },
        set: { isPresented in
          if !isPresented { model.errorMessage = nil }
        }
      )
    ) {
      Button("OK") { model.errorMessage = nil }
    } message: {
      Text(model.errorMessage ?? "")
    }
    .onAppear {
      MacTerminationCoordinator.shared.attach(model: model)
    }
  }

  private var sessionViewTransition: AnyTransition {
    guard !reducesMotion else { return .opacity }
    return .opacity.combined(with: .scale(scale: 0.97))
  }

  @ViewBuilder
  private var backgroundSurface: some View {
    if reducesTransparency {
      Color(nsColor: .windowBackgroundColor)
    } else {
      LinearGradient(
        colors: [
          Color.accentColor.opacity(model.isRunning ? 0.16 : 0.09),
          Color(nsColor: .windowBackgroundColor),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }
  }

  private var customDurationInitialMinutes: Int {
    if let selectedDurationSeconds = model.selectedDurationSeconds {
      return max(selectedDurationSeconds / 60, MeditationDuration.minimumMinutes)
    }
    return lastCustomDurationMinutes
  }

  private func showCustomDuration() {
    showsCustomDuration = true
  }
}

@MainActor
private struct MacSessionStartView: View {
  let model: MacSessionModel
  let transitionNamespace: Namespace.ID
  let onChooseCustomDuration: () -> Void

  var body: some View {
    VStack(spacing: 28) {
      Spacer(minLength: 20)

      ZStack {
        Circle()
          .fill(Color.accentColor.opacity(0.12))
          .matchedGeometryEffect(id: "session-halo", in: transitionNamespace)

        Image(systemName: "circle.dotted.circle")
          .font(.system(size: 72, weight: .ultraLight))
          .foregroundStyle(Color.accentColor)
          .symbolRenderingMode(.hierarchical)
      }
      .frame(width: 190, height: 190)
      .accessibilityHidden(true)

      VStack(spacing: 8) {
        Text("Take a little moment.")
          .font(.title2.weight(.semibold))
        Text("Set a timer, or simply begin.")
          .foregroundStyle(.secondary)
      }
      .multilineTextAlignment(.center)

      Spacer(minLength: 12)

      VStack(spacing: 14) {
        MacDurationMenu(
          model: model,
          onChooseCustomDuration: onChooseCustomDuration
        )

        Button {
          model.start()
        } label: {
          Label("Start Session", systemImage: "play.fill")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .keyboardShortcut(.defaultAction)
        .accessibilityIdentifier("start_session_button")
      }
      .frame(maxWidth: 280)
    }
  }
}

@MainActor
private struct MacRunningSessionView: View {
  let model: MacSessionModel
  let transitionNamespace: Namespace.ID
  let onChooseCustomDuration: () -> Void

  @AppStorage("showSeconds") private var showSeconds = true

  var body: some View {
    VStack(spacing: 28) {
      Spacer(minLength: 8)

      TimelineView(.periodic(from: .now, by: 1)) { context in
        VStack(spacing: 18) {
          timerFace(at: context.date)
          timerStatus(at: context.date)
        }
      }

      Spacer(minLength: 8)

      MacDurationMenu(
        model: model,
        onChooseCustomDuration: onChooseCustomDuration
      )

      HStack(spacing: 12) {
        Button("Cancel Session", role: .destructive) {
          model.cancel()
        }

        Button {
          model.complete()
        } label: {
          Label("Complete", systemImage: "checkmark")
        }
        .buttonStyle(.borderedProminent)
        .keyboardShortcut(.defaultAction)
      }
      .controlSize(.large)
      .accessibilityElement(children: .contain)
    }
  }

  private func timerFace(at date: Date) -> some View {
    ZStack {
      Circle()
        .fill(Color.accentColor.opacity(0.1))
        .matchedGeometryEffect(id: "session-halo", in: transitionNamespace)

      Circle()
        .stroke(Color.accentColor.opacity(model.targetDate == nil ? 0 : 0.16), lineWidth: 8)

      if model.targetDate != nil {
        Circle()
          .trim(from: 0, to: model.progress(at: date))
          .stroke(
            model.isDone(at: date) ? Color.green : Color.accentColor,
            style: StrokeStyle(lineWidth: 8, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
      }

      Text(
        MeditationSessionController.formatElapsed(
          model.elapsed(at: date),
          showSeconds: showSeconds
        )
      )
      .font(.system(size: 42, weight: .medium, design: .rounded))
      .monospacedDigit()
      .contentTransition(.numericText())
    }
    .frame(width: 210, height: 210)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Elapsed time")
    .accessibilityValue(
      MeditationSessionController.formatElapsed(
        model.elapsed(at: date),
        showSeconds: true
      )
    )
  }

  @ViewBuilder
  private func timerStatus(at date: Date) -> some View {
    if model.isDone(at: date) {
      Label("Moment complete", systemImage: "checkmark.circle.fill")
        .foregroundStyle(.green)
        .font(.headline)
    } else if let targetDate = model.targetDate {
      Text("Bell at \(targetDate.formatted(date: .omitted, time: .shortened))")
        .foregroundStyle(.secondary)
    } else {
      Text("Untimed session")
        .foregroundStyle(.secondary)
    }
  }
}

@MainActor
private struct MacDurationMenu: View {
  let model: MacSessionModel
  let onChooseCustomDuration: () -> Void

  var body: some View {
    Menu {
      durationButton(title: "Untimed", seconds: nil)
      Divider()

      ForEach(MacSessionModel.presetMinutes, id: \.self) { minutes in
        durationButton(title: "\(minutes) minutes", seconds: minutes * 60)
      }

      Divider()
      Button("Custom…", action: onChooseCustomDuration)
    } label: {
      Label(model.selectedDurationLabel, systemImage: "timer")
        .frame(minWidth: 130)
    }
    .menuIndicator(.visible)
    .fixedSize()
    .accessibilityLabel("Session duration")
    .accessibilityValue(model.selectedDurationLabel)
  }

  private func durationButton(title: String, seconds: Int?) -> some View {
    Button {
      model.setDuration(seconds: seconds)
    } label: {
      if model.selectedDurationSeconds == seconds {
        Label(title, systemImage: "checkmark")
      } else {
        Text(title)
      }
    }
  }
}

private struct MacCustomDurationView: View {
  let onApply: (MeditationDuration) -> Void

  @Environment(\.dismiss) private var dismiss
  @State private var rawMinutes: String
  @State private var validationMessage: String?

  init(
    initialMinutes: Int,
    onApply: @escaping (MeditationDuration) -> Void
  ) {
    self.onApply = onApply
    _rawMinutes = State(initialValue: String(initialMinutes))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      VStack(alignment: .leading, spacing: 6) {
        Text("Custom Duration")
          .font(.title2.weight(.semibold))
        Text("Enter a duration in whole minutes.")
          .foregroundStyle(.secondary)
      }

      TextField("Minutes", text: $rawMinutes)
        .textFieldStyle(.roundedBorder)
        .frame(width: 120)
        .onSubmit(apply)

      if let validationMessage {
        Text(validationMessage)
          .font(.callout)
          .foregroundStyle(.red)
      }

      HStack {
        Spacer()
        Button("Cancel", role: .cancel) { dismiss() }
        Button("Apply", action: apply)
          .buttonStyle(.borderedProminent)
          .keyboardShortcut(.defaultAction)
      }
    }
    .padding(24)
    .frame(width: 340)
  }

  private func apply() {
    switch MeditationDuration.parseMinutes(rawMinutes) {
    case .success(let duration):
      onApply(duration)
      dismiss()
    case .failure(let error):
      validationMessage = error.localizedDescription
    }
  }
}

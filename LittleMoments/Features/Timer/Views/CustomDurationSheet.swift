import SwiftUI

enum CustomDurationSheetMode: Equatable {
  case start
  case running

  var title: String { "Custom duration" }

  var subtitle: String {
    switch self {
    case .start:
      return "Choose when the bell should end this session."
    case .running:
      return "Choose when the bell should end this session. Your timer keeps running."
    }
  }

  func applyTitle(for duration: MeditationDuration) -> String {
    switch self {
    case .start:
      return "Start \(duration.shortLabel) session"
    case .running:
      return "Set bell for \(duration.shortLabel)"
    }
  }
}

struct CustomDurationSheet: View {
  let mode: CustomDurationSheetMode
  let onApply: (MeditationDuration) -> Void
  let onCancel: () -> Void

  @Environment(\.accessibilityReduceTransparency) private var reducesTransparency
  @FocusState private var isMinutesFieldFocused: Bool
  @State private var draftMinutes: Int
  @State private var minutesText: String
  @State private var validationMessage: String?
  @State private var lastHapticMinute: Int

  init(
    mode: CustomDurationSheetMode,
    initialMinutes: Int,
    onApply: @escaping (MeditationDuration) -> Void,
    onCancel: @escaping () -> Void
  ) {
    self.mode = mode
    self.onApply = onApply
    self.onCancel = onCancel
    _draftMinutes = State(initialValue: max(initialMinutes, MeditationDuration.minimumMinutes))
    _minutesText = State(initialValue: "\(max(initialMinutes, MeditationDuration.minimumMinutes))")
    _lastHapticMinute = State(initialValue: max(initialMinutes, MeditationDuration.minimumMinutes))
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        header
        durationReadout
        sliderSection
        textInputSection
        actions
      }
      .padding(.horizontal, 24)
      .padding(.top, 28)
      .padding(.bottom, 32)
    }
    .background(backgroundSurface)
    .accessibilityIdentifier("custom_duration_sheet")
    .toolbar {
      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("Done") { isMinutesFieldFocused = false }
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(mode.title)
        .font(.title2.weight(.bold))
      Text(mode.subtitle)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var durationReadout: some View {
    Text(currentDuration.shortLabel)
      .font(.system(.largeTitle, design: .rounded).weight(.bold))
      .minimumScaleFactor(0.7)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 24)
      .padding(.horizontal, 18)
      .background(
        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .fill(
            LiquidGlassTokens.surfaceFill(
              reducesTransparency: reducesTransparency,
              fallback: Color(UIColor.secondarySystemBackground),
              opacity: 0.20
            )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .stroke(
            LiquidGlassTokens.surfaceStroke(reducesTransparency: reducesTransparency),
            lineWidth: 1
          )
      )
      .accessibilityLabel(currentDuration.accessibilityLabel)
  }

  private var sliderSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Quick set")
        .font(.caption.weight(.semibold))
        .textCase(.uppercase)
        .foregroundStyle(.secondary)

      Slider(
        value: sliderValue,
        in: Double(
          MeditationDuration.sliderMinimumMinutes)...Double(
            MeditationDuration.sliderMaximumMinutes),
        step: 1
      )
      .accessibilityIdentifier("custom_duration_slider")
      .accessibilityValue(Text(currentDuration.accessibilityLabel))

      HStack {
        Text("1 min")
        Spacer()
        Text("2 hr")
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
  }

  private var textInputSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Minutes")
        .font(.caption.weight(.semibold))
        .textCase(.uppercase)
        .foregroundStyle(.secondary)

      TextField("Minutes", text: $minutesText)
        .keyboardType(.numberPad)
        .focused($isMinutesFieldFocused)
        .textFieldStyle(.roundedBorder)
        .font(.title3.monospacedDigit())
        .accessibilityIdentifier("custom_duration_minutes_field")
        .accessibilityHint("Enter a duration in minutes; values over 2 hours are allowed.")
        .onChange(of: minutesText) { _, newValue in
          updateDraftMinutes(from: newValue)
        }

      Text(validationMessage ?? "Enter minutes, or use the slider for 1 min–2 hr.")
        .font(.footnote)
        .foregroundStyle(validationMessage == nil ? Color.secondary : Color.red)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var actions: some View {
    VStack(spacing: 12) {
      Button {
        applyDuration()
      } label: {
        Label(mode.applyTitle(for: currentDuration), systemImage: "checkmark.circle.fill")
      }
      .accessibilityIdentifier("custom_duration_apply_button")
      .liquidGlassButtonStyle(.prominent, controlHeight: LiquidGlassTokens.primaryControlHeight)

      Button {
        onCancel()
      } label: {
        Text("Cancel")
          .frame(maxWidth: .infinity)
      }
      .accessibilityIdentifier("custom_duration_cancel_button")
      .liquidGlassButtonStyle(.subtle, role: .neutral)
    }
  }

  private var backgroundSurface: some View {
    Group {
      if reducesTransparency {
        Color(UIColor.systemBackground)
      } else {
        LinearGradient(
          colors: [
            LiquidGlassTokens.primaryTint.opacity(0.10),
            Color(UIColor.systemBackground),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      }
    }
    .ignoresSafeArea()
  }

  private var currentDuration: MeditationDuration {
    if let duration = try? MeditationDuration(minutes: draftMinutes) {
      return duration
    }
    return Self.minimumDuration ?? MeditationDuration.uncheckedMinimum
  }

  private static let minimumDuration = try? MeditationDuration(
    minutes: MeditationDuration.minimumMinutes
  )

  private var sliderValue: Binding<Double> {
    Binding(
      get: {
        Double(
          min(
            max(draftMinutes, MeditationDuration.sliderMinimumMinutes),
            MeditationDuration.sliderMaximumMinutes
          )
        )
      },
      set: { newValue in
        let minutes = MeditationDuration.clampedSliderMinutes(newValue)
        draftMinutes = minutes
        minutesText = "\(minutes)"
        validationMessage = nil
        provideSliderFeedbackIfNeeded(for: minutes)
      }
    )
  }

  private func updateDraftMinutes(from rawValue: String) {
    switch MeditationDuration.parseMinutes(rawValue) {
    case .success(let duration):
      draftMinutes = duration.minutes
      validationMessage = nil
    case .failure(let error):
      validationMessage = error.errorDescription
    }
  }

  private func applyDuration() {
    switch MeditationDuration.parseMinutes(minutesText) {
    case .success(let duration):
      validationMessage = nil
      isMinutesFieldFocused = false
      onApply(duration)
    case .failure(let error):
      validationMessage = error.errorDescription
    }
  }

  private func provideSliderFeedbackIfNeeded(for minutes: Int) {
    guard minutes != lastHapticMinute else { return }
    defer { lastHapticMinute = minutes }

    let shouldProvideFeedback =
      minutes.isMultiple(of: 5)
      || [30, 60, 120].contains(minutes)
    guard shouldProvideFeedback else { return }

    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }
}

struct CustomDurationSheet_Previews: PreviewProvider {
  static var previews: some View {
    CustomDurationSheet(mode: .start, initialMinutes: 25) { _ in
    } onCancel: {
    }
  }
}

import SwiftUI
import UIKit

enum CustomDurationSheetMode: Equatable {
  case start
  case running

  var title: String { "Custom duration" }

  var compactApplyTitle: String {
    switch self {
    case .start:
      return "Start"
    case .running:
      return "Set"
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
  @State private var draftMinutes: Int
  @State private var minutesText: String
  @State private var validationMessage: String?
  @State private var lastHapticMinute: Int
  @FocusState private var minutesFieldIsFocused: Bool

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
    VStack(alignment: .leading, spacing: 20) {
      header
      durationEditorSection
      projectedFinishSection
      sliderSection
    }
    .padding(.horizontal, 24)
    .padding(.top, 20)
    .padding(.bottom, 18)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(backgroundSurface)
    .toolbar {
      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("Done") {
          dismissKeyboard()
        }
      }
    }
    .accessibilityIdentifier("custom_duration_sheet")
  }

  private var header: some View {
    Text(mode.title)
      .font(.headline.weight(.bold))
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var durationEditorSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      durationControlRow
      if let validationMessage {
        Text(validationMessage)
          .font(.footnote)
          .foregroundStyle(Color.red)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }

  private var durationControlRow: some View {
    ViewThatFits(in: .horizontal) {
      HStack(alignment: .center, spacing: 10) {
        durationEntryField
        actionButtons
      }

      VStack(alignment: .leading, spacing: 12) {
        durationEntryField
        actionButtons
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }
  }

  private var durationEntryField: some View {
    HStack(alignment: .firstTextBaseline, spacing: 8) {
      TextField("", text: $minutesText)
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .multilineTextAlignment(.trailing)
        .font(.system(size: 34, weight: .bold, design: .default))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .focused($minutesFieldIsFocused)
        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .trailing)
        .accessibilityIdentifier("custom_duration_minutes_field")
        .accessibilityHint("Enter a duration in minutes; values over 1 hour can be typed.")
        .onChange(of: minutesText) { _, newValue in
          updateDraftMinutes(from: newValue)
        }

      Text("min")
        .font(.headline.weight(.semibold))
        .foregroundStyle(.secondary)
    }
    .padding(.horizontal, 18)
    .frame(minWidth: 132, maxWidth: .infinity)
    .frame(height: 72)
    .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    .onTapGesture {
      minutesFieldIsFocused = true
    }
    .background(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(
          LiquidGlassTokens.surfaceFill(
            reducesTransparency: reducesTransparency,
            fallback: Color(UIColor.secondarySystemBackground),
            opacity: 0.20
          )
        )
    )
    .overlay(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .stroke(
          LiquidGlassTokens.surfaceStroke(reducesTransparency: reducesTransparency),
          lineWidth: 1
        )
    )
    .accessibilityLabel(currentDuration.accessibilityLabel)
  }

  private var actionButtons: some View {
    HStack(spacing: 10) {
      Button {
        onCancel()
      } label: {
        Text("Cancel")
      }
      .accessibilityIdentifier("custom_duration_cancel_button")
      .liquidGlassButtonStyle(.subtle, role: .neutral, controlHeight: 72)
      .frame(width: 92)

      Button {
        applyDuration()
      } label: {
        Text(mode.compactApplyTitle)
      }
      .accessibilityIdentifier("custom_duration_apply_button")
      .accessibilityLabel(mode.applyTitle(for: currentDuration))
      .liquidGlassButtonStyle(.prominent, role: .success, controlHeight: 72)
      .frame(width: 78)
    }
  }

  private var sliderSection: some View {
    VStack(alignment: .leading, spacing: 8) {
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
        Text("1 hr")
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
  }

  private var projectedFinishSection: some View {
    TimelineView(.periodic(from: .now, by: 30)) { context in
      HStack(alignment: .firstTextBaseline, spacing: 8) {
        Image(systemName: "clock")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
          .accessibilityHidden(true)

        Text("Ends around")
          .font(.footnote.weight(.medium))
          .foregroundStyle(.secondary)

        Text(projectedFinishTime(from: context.date))
          .font(.footnote.weight(.semibold))
          .monospacedDigit()
          .foregroundStyle(.primary)
          .accessibilityIdentifier("custom_duration_projected_finish_time")
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .accessibilityElement(children: .combine)
      .accessibilityLabel("Projected finish time")
      .accessibilityValue("Ends around \(projectedFinishTime(from: context.date))")
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

  private func projectedFinishTime(from now: Date) -> String {
    let finishDate = now.addingTimeInterval(TimeInterval(currentDuration.seconds))
    return Self.finishTimeFormatter.string(from: finishDate)
  }

  private static let finishTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter
  }()

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
      dismissKeyboard()
      onApply(duration)
    case .failure(let error):
      validationMessage = error.errorDescription
    }
  }

  private func dismissKeyboard() {
    minutesFieldIsFocused = false
  }

  private func provideSliderFeedbackIfNeeded(for minutes: Int) {
    guard minutes != lastHapticMinute else { return }
    defer { lastHapticMinute = minutes }

    let shouldProvideFeedback =
      minutes.isMultiple(of: 5)
      || [30, 60].contains(minutes)
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

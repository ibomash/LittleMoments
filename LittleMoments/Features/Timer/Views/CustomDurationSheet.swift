import SwiftUI
import UIKit

enum CustomDurationSheetMode: Equatable {
  case start
  case running

  var title: String { "Custom duration" }

  var subtitle: String {
    switch self {
    case .start:
      return "Choose when the bell should end this session."
    case .running:
      return "Your timer keeps running while you adjust the bell."
    }
  }

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
    VStack(alignment: .leading, spacing: 18) {
      header
      durationEntryAndApplyRow
      sliderSection
      footerActions
    }
    .padding(.horizontal, 24)
    .padding(.top, 20)
    .padding(.bottom, 18)
    .frame(maxWidth: .infinity, alignment: .topLeading)
    .background(backgroundSurface)
    .accessibilityIdentifier("custom_duration_sheet")
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(mode.title)
        .font(.headline.weight(.bold))
      Text(mode.subtitle)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var durationEntryAndApplyRow: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .center, spacing: 12) {
        durationEntryCard

        Button {
          applyDuration()
        } label: {
          VStack(spacing: 3) {
            Image(systemName: "checkmark")
              .font(.system(size: 20, weight: .bold))
            Text(mode.compactApplyTitle)
              .font(.caption.weight(.semibold))
          }
        }
        .accessibilityIdentifier("custom_duration_apply_button")
        .accessibilityLabel(mode.applyTitle(for: currentDuration))
        .liquidGlassIconButtonStyle(variant: .prominent, role: .success, diameter: 68)
      }

      Text(validationMessage ?? "Tap the value to type, or use the slider for 1 min–2 hr.")
        .font(.footnote)
        .foregroundStyle(validationMessage == nil ? Color.secondary : Color.red)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var durationEntryCard: some View {
    HStack(alignment: .firstTextBaseline, spacing: 8) {
      SelectAllMinutesTextField(text: $minutesText)
        .frame(minHeight: 48)
        .accessibilityHint("Enter a duration in minutes; values over 2 hours are allowed.")
        .onChange(of: minutesText) { _, newValue in
          updateDraftMinutes(from: newValue)
        }

      Text("min")
        .font(.headline.weight(.semibold))
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 16)
    .padding(.horizontal, 18)
    .frame(maxWidth: .infinity, minHeight: 72)
    .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
        Text("2 hr")
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
  }

  private var footerActions: some View {
    Button {
      onCancel()
    } label: {
      Text("Cancel")
        .frame(maxWidth: .infinity)
    }
    .accessibilityIdentifier("custom_duration_cancel_button")
    .liquidGlassButtonStyle(.subtle, role: .neutral, controlHeight: 44)
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
      dismissKeyboard()
      onApply(duration)
    case .failure(let error):
      validationMessage = error.errorDescription
    }
  }

  private func dismissKeyboard() {
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
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

private struct SelectAllMinutesTextField: UIViewRepresentable {
  @Binding var text: String

  func makeUIView(context: Context) -> UITextField {
    let textField = UITextField()
    textField.delegate = context.coordinator
    textField.keyboardType = .numberPad
    textField.textAlignment = .right
    textField.font = UIFont.systemFont(ofSize: 34, weight: .bold)
    textField.adjustsFontForContentSizeCategory = true
    textField.minimumFontSize = 24
    textField.adjustsFontSizeToFitWidth = true
    textField.accessibilityIdentifier = "custom_duration_minutes_field"
    textField.addTarget(
      context.coordinator,
      action: #selector(Coordinator.textDidChange(_:)),
      for: .editingChanged
    )
    textField.inputAccessoryView = context.coordinator.makeToolbar()
    return textField
  }

  func updateUIView(_ textField: UITextField, context: Context) {
    if textField.text != text {
      textField.text = text
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(text: $text)
  }

  final class Coordinator: NSObject, UITextFieldDelegate {
    @Binding private var text: String

    init(text: Binding<String>) {
      _text = text
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
      DispatchQueue.main.async {
        textField.selectAll(nil)
      }
    }

    @objc func textDidChange(_ textField: UITextField) {
      text = textField.text ?? ""
    }

    @objc func doneTapped() {
      UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
      )
    }

    func makeToolbar() -> UIToolbar {
      let toolbar = UIToolbar()
      toolbar.items = [
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        UIBarButtonItem(
          title: "Done",
          style: .done,
          target: self,
          action: #selector(doneTapped)
        ),
      ]
      toolbar.sizeToFit()
      return toolbar
    }
  }
}

struct CustomDurationSheet_Previews: PreviewProvider {
  static var previews: some View {
    CustomDurationSheet(mode: .start, initialMinutes: 25) { _ in
    } onCancel: {
    }
  }
}

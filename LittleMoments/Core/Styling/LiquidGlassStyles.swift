import SwiftUI

/// Shared tokens that centralize the Liquid Glass palette and spacing choices so later phases
/// can swap in the system glass materials without touching every call site.
enum LiquidGlassTokens {
  static let prominentForeground = Color.white
  static let subtleForeground = Color.primary.opacity(0.85)

  static let primaryTint = Color.accentColor
  static let secondaryTint = Color.accentColor.opacity(0.35)

  static let neutralTint = Color(UIColor.systemGray4)
  static let neutralFallback = Color(UIColor.systemGray5)
  static let neutralStroke = Color.white.opacity(0.15)

  static let destructiveTint = Color(UIColor.systemRed)
  static let destructiveFallback = Color(UIColor.systemRed)
  static let destructiveStroke = Color.white.opacity(0.45)

  static let successTint = Color(UIColor.systemGreen)
  static let successFallback = Color(UIColor.systemGreen)
  static let successStroke = Color.white.opacity(0.45)

  static let accentOpacity: (base: Double, pressed: Double) = (0.50, 0.64)
  static let subtleOpacity: (base: Double, pressed: Double) = (0.24, 0.34)
  static let neutralOpacity: (base: Double, pressed: Double) = (0.26, 0.36)
  static let destructiveOpacity: (base: Double, pressed: Double) = (0.48, 0.62)
  static let successOpacity: (base: Double, pressed: Double) = (0.48, 0.62)

  static let prominentFallback = Color.accentColor
  static let prominentStrokeFallback = Color.white.opacity(0.4)
  static let subtleFallback = Color(UIColor.systemGray5)
  static let subtleStrokeFallback = Color.primary.opacity(0.2)

  static let shadowColor = Color.black.opacity(0.18)
  static let shadowRadius: CGFloat = 22
  static let shadowOffsetY: CGFloat = 8

  static let cornerRadius: CGFloat = 18
  static let verticalPadding: CGFloat = 14
  static let horizontalPadding: CGFloat = 18

  static let primaryControlHeight: CGFloat = 64

  static let chipCornerRadius: CGFloat = 14

  static func surfaceGradient(
    tint: Color = LiquidGlassTokens.primaryTint,
    opacity: Double = 0.18
  ) -> LinearGradient {
    LinearGradient(
      colors: [
        tint.opacity(opacity),
        tint.opacity(opacity * 0.45),
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  static func surfaceFill(
    tint: Color = LiquidGlassTokens.primaryTint,
    reducesTransparency: Bool,
    fallback: Color,
    opacity: Double = 0.18
  ) -> AnyShapeStyle {
    if reducesTransparency {
      return AnyShapeStyle(fallback)
    }
    return AnyShapeStyle(surfaceGradient(tint: tint, opacity: opacity))
  }

  static func surfaceStroke(
    reducesTransparency: Bool,
    fallback: Color = Color.white.opacity(0.18),
    tint: Color = Color.white,
    opacity: Double = 0.28
  ) -> AnyShapeStyle {
    if reducesTransparency {
      return AnyShapeStyle(fallback)
    }
    return AnyShapeStyle(tint.opacity(opacity))
  }
}

/// Transitional button style that approximates the Liquid Glass treatment. Once the production
/// SDK exposes `.buttonStyle(.glassProminent)`, we can update this wrapper in one place without
/// touching feature code.
struct LiquidGlassButtonStyle: ButtonStyle {
  enum Variant { case prominent, subtle }
  enum Role { case accent, neutral, destructive, success }

  var variant: Variant = .prominent
  var role: Role = .accent
  var controlHeight: CGFloat? = nil

  @Environment(\.accessibilityReduceTransparency) private var reducesTransparency

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .labelStyle(.titleAndIcon)
      .font(.headline)
      .padding(.vertical, LiquidGlassTokens.verticalPadding)
      .padding(.horizontal, LiquidGlassTokens.horizontalPadding)
      .frame(maxWidth: .infinity)
      .frame(height: controlHeight, alignment: .center)
      .contentShape(
        RoundedRectangle(cornerRadius: LiquidGlassTokens.cornerRadius, style: .continuous)
      )
      .tint(role.tint(for: variant))
      .foregroundStyle(role.foregroundColor(for: variant))
      .background(background(configuration.isPressed))
      .overlay(stroke(configuration.isPressed))
      .shadow(
        color: LiquidGlassTokens.shadowColor,
        radius: LiquidGlassTokens.shadowRadius,
        y: LiquidGlassTokens.shadowOffsetY
      )
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
  }

  private func background(_ isPressed: Bool) -> some View {
    RoundedRectangle(cornerRadius: LiquidGlassTokens.cornerRadius, style: .continuous)
      .fill(
        reducesTransparency
          ? role.fallbackTint(for: variant).opacity(isPressed ? 0.9 : 1.0)
          : role.tint(for: variant).opacity(role.opacity(for: variant, pressed: isPressed))
      )
  }

  private func stroke(_ isPressed: Bool) -> some View {
    RoundedRectangle(cornerRadius: LiquidGlassTokens.cornerRadius, style: .continuous)
      .stroke(
        (reducesTransparency ? role.fallbackStroke(for: variant) : role.stroke(for: variant))
          .opacity(isPressed ? 0.45 : 0.32),
        lineWidth: 1
      )
  }
}

extension LiquidGlassButtonStyle.Role {
  func tint(for variant: LiquidGlassButtonStyle.Variant) -> Color {
    switch (self, variant) {
    case (.accent, .prominent): return LiquidGlassTokens.primaryTint
    case (.accent, .subtle): return LiquidGlassTokens.secondaryTint
    case (.neutral, .prominent): return LiquidGlassTokens.neutralTint
    case (.neutral, .subtle): return LiquidGlassTokens.neutralTint
    case (.destructive, _): return LiquidGlassTokens.destructiveTint
    case (.success, _): return LiquidGlassTokens.successTint
    }
  }

  func fallbackTint(for variant: LiquidGlassButtonStyle.Variant) -> Color {
    switch (self, variant) {
    case (.accent, .prominent): return LiquidGlassTokens.prominentFallback
    case (.accent, .subtle): return LiquidGlassTokens.subtleFallback
    case (.neutral, _): return LiquidGlassTokens.neutralFallback
    case (.destructive, _): return LiquidGlassTokens.destructiveFallback
    case (.success, _): return LiquidGlassTokens.successFallback
    }
  }

  func stroke(for variant: LiquidGlassButtonStyle.Variant) -> Color {
    switch (self, variant) {
    case (.accent, .prominent): return LiquidGlassTokens.prominentForeground
    case (.accent, .subtle): return LiquidGlassTokens.primaryTint
    case (.neutral, _): return LiquidGlassTokens.neutralStroke
    case (.destructive, _): return LiquidGlassTokens.destructiveStroke
    case (.success, _): return LiquidGlassTokens.successStroke
    }
  }

  func fallbackStroke(for variant: LiquidGlassButtonStyle.Variant) -> Color {
    switch (self, variant) {
    case (.accent, .prominent): return LiquidGlassTokens.prominentStrokeFallback
    case (.accent, .subtle): return LiquidGlassTokens.subtleStrokeFallback
    case (.neutral, _): return LiquidGlassTokens.neutralStroke
    case (.destructive, _): return LiquidGlassTokens.destructiveStroke
    case (.success, _): return LiquidGlassTokens.successStroke
    }
  }

  func foregroundColor(for variant: LiquidGlassButtonStyle.Variant) -> Color {
    switch (self, variant) {
    case (.accent, .prominent): return LiquidGlassTokens.prominentForeground
    case (.accent, .subtle): return LiquidGlassTokens.subtleForeground
    case (.neutral, .prominent): return LiquidGlassTokens.prominentForeground
    case (.neutral, .subtle): return Color.secondary
    case (.destructive, _): return LiquidGlassTokens.prominentForeground
    case (.success, _): return LiquidGlassTokens.prominentForeground
    }
  }

  func opacity(for variant: LiquidGlassButtonStyle.Variant, pressed: Bool) -> Double {
    let table: (base: Double, pressed: Double)
    switch self {
    case .accent:
      table = LiquidGlassTokens.accentOpacity
    case .neutral:
      table = LiquidGlassTokens.neutralOpacity
    case .destructive:
      table = LiquidGlassTokens.destructiveOpacity
    case .success:
      table = LiquidGlassTokens.successOpacity
    }

    let value = pressed ? table.pressed : table.base
    if variant == .subtle {
      return pressed
        ? LiquidGlassTokens.subtleOpacity.pressed : LiquidGlassTokens.subtleOpacity.base
    }
    return value
  }
}

extension View {
  /// Applies the Liquid Glass wrapper so call-sites remain declarative and we can promote to the
  /// system `glass` styles when they ship.
  func liquidGlassButtonStyle(
    _ variant: LiquidGlassButtonStyle.Variant = .prominent,
    role: LiquidGlassButtonStyle.Role = .accent,
    controlHeight: CGFloat? = nil
  ) -> some View {
    buttonStyle(LiquidGlassButtonStyle(variant: variant, role: role, controlHeight: controlHeight))
  }
}

struct LiquidGlassIconButtonStyle: ButtonStyle {
  var variant: LiquidGlassButtonStyle.Variant = .subtle
  var role: LiquidGlassButtonStyle.Role = .accent
  var diameter: CGFloat = 60

  @Environment(\.accessibilityReduceTransparency) private var reducesTransparency

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 22, weight: .semibold))
      .foregroundStyle(role.iconForeground(for: variant))
      .frame(width: diameter, height: diameter)
      .contentShape(Circle())
      .background(
        Circle().fill(
          reducesTransparency
            ? role.fallbackTint(for: variant).opacity(configuration.isPressed ? 0.92 : 1.0)
            : role.tint(for: variant).opacity(
              role.opacity(for: variant, pressed: configuration.isPressed))
        )
      )
      .overlay(
        Circle().stroke(
          (reducesTransparency ? role.fallbackStroke(for: variant) : role.stroke(for: variant))
            .opacity(configuration.isPressed ? 0.5 : 0.35),
          lineWidth: 1
        )
      )
      .shadow(
        color: LiquidGlassTokens.shadowColor,
        radius: LiquidGlassTokens.shadowRadius,
        y: LiquidGlassTokens.shadowOffsetY / 2
      )
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
  }
}

extension LiquidGlassButtonStyle.Role {
  fileprivate func iconForeground(for variant: LiquidGlassButtonStyle.Variant) -> Color {
    switch (self, variant) {
    case (.accent, .prominent): return LiquidGlassTokens.prominentForeground
    case (.accent, .subtle): return LiquidGlassTokens.primaryTint
    case (.neutral, .prominent): return LiquidGlassTokens.prominentForeground
    case (.neutral, .subtle): return Color.secondary
    case (.destructive, _): return LiquidGlassTokens.prominentForeground
    case (.success, _): return LiquidGlassTokens.prominentForeground
    }
  }
}

extension View {
  func liquidGlassIconButtonStyle(
    variant: LiquidGlassButtonStyle.Variant = .subtle,
    role: LiquidGlassButtonStyle.Role = .accent,
    diameter: CGFloat = 60
  ) -> some View {
    buttonStyle(LiquidGlassIconButtonStyle(variant: variant, role: role, diameter: diameter))
  }
}

private struct LiquidGlassChipModifier: ViewModifier {
  var isSelected: Bool
  @Environment(\.accessibilityReduceTransparency) private var reducesTransparency

  func body(content: Content) -> some View {
    let role: LiquidGlassButtonStyle.Role = isSelected ? .accent : .neutral
    let variant: LiquidGlassButtonStyle.Variant = isSelected ? .prominent : .subtle

    return
      content
      .font(.system(.callout, design: .rounded).weight(.semibold))
      .frame(maxWidth: .infinity)
      .padding(.vertical, 10)
      .padding(.horizontal, 6)
      .foregroundStyle(role.foregroundColor(for: variant))
      .background(
        RoundedRectangle(cornerRadius: LiquidGlassTokens.chipCornerRadius, style: .continuous)
          .fill(
            reducesTransparency
              ? role.fallbackTint(for: variant).opacity(isSelected ? 0.9 : 1.0)
              : role.tint(for: variant).opacity(role.opacity(for: variant, pressed: isSelected))
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: LiquidGlassTokens.chipCornerRadius, style: .continuous)
          .stroke(
            (reducesTransparency ? role.fallbackStroke(for: variant) : role.stroke(for: variant))
              .opacity(isSelected ? 0.45 : 0.25),
            lineWidth: 1
          )
      )
  }
}

extension View {
  func liquidGlassChip(isSelected: Bool) -> some View {
    modifier(LiquidGlassChipModifier(isSelected: isSelected))
  }
}

#if DEBUG
  struct LiquidGlassButtonStylePreviews: PreviewProvider {
    static var previews: some View {
      VStack(spacing: 20) {
        Button("Primary") {}
          .liquidGlassButtonStyle(.prominent)

        Button("Secondary") {}
          .liquidGlassButtonStyle(.subtle)

        Button("Destructive") {}
          .liquidGlassButtonStyle(.prominent, role: .destructive)

        HStack(spacing: 20) {
          Button(action: {}) { Image(systemName: "gearshape.fill") }
            .liquidGlassIconButtonStyle(variant: .subtle)

          Button(action: {}) { Image(systemName: "play.fill") }
            .liquidGlassIconButtonStyle(variant: .prominent)
        }

        HStack(spacing: 12) {
          Text("5 sec")
            .liquidGlassChip(isSelected: true)

          Text("10")
            .liquidGlassChip(isSelected: false)
        }
      }
      .padding()
      .previewLayout(.sizeThatFits)
    }
  }
#endif

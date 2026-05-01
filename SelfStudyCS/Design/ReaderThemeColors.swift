//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import UIKit

struct ReaderPalette: Equatable, Sendable {
  let background: Color
  let secondaryBackground: Color
  let primaryText: Color
  let secondaryText: Color
  let accent: Color
  let codeBackground: Color
}

enum ReaderPaletteResolver {
  static func palette(theme: ReaderTheme, colorScheme: ColorScheme) -> ReaderPalette {
    switch theme {
    case .system:
      return colorScheme == .dark ? dark : light
    case .light:
      return light
    case .dark:
      return dark
    case .sepia:
      return sepia
    }
  }

  /// Warm paper-like surfaces and softened type for long-form reading (not stark white / pure black).
  private static let light = ReaderPalette(
    background: Color(red: 0.978, green: 0.965, blue: 0.945),
    secondaryBackground: Color(red: 0.96, green: 0.948, blue: 0.925),
    primaryText: Color(red: 0.12, green: 0.11, blue: 0.1),
    secondaryText: Color(red: 0.38, green: 0.35, blue: 0.32),
    accent: Color.accentColor,
    codeBackground: Color(red: 0.93, green: 0.915, blue: 0.885)
  )

  private static let dark = ReaderPalette(
    background: Color(red: 0.11, green: 0.11, blue: 0.12),
    secondaryBackground: Color(red: 0.15, green: 0.15, blue: 0.16),
    primaryText: Color(red: 0.93, green: 0.92, blue: 0.9),
    secondaryText: Color(red: 0.68, green: 0.66, blue: 0.62),
    accent: Color.accentColor,
    codeBackground: Color(red: 0.2, green: 0.2, blue: 0.22)
  )

  private static let sepia = ReaderPalette(
    background: Color(red: 0.965, green: 0.935, blue: 0.855),
    secondaryBackground: Color(red: 0.925, green: 0.89, blue: 0.78),
    primaryText: Color(red: 0.19, green: 0.15, blue: 0.1),
    secondaryText: Color(red: 0.36, green: 0.3, blue: 0.22),
    accent: Color(red: 0.42, green: 0.3, blue: 0.18),
    codeBackground: Color(red: 0.895, green: 0.855, blue: 0.74)
  )
}

private struct ReaderPaletteKey: EnvironmentKey {
  static let defaultValue = ReaderPaletteResolver.palette(theme: .system, colorScheme: .light)
}

extension EnvironmentValues {
  var readerPalette: ReaderPalette {
    get { self[ReaderPaletteKey.self] }
    set { self[ReaderPaletteKey.self] = newValue }
  }
}

/// Keeps large navigation titles visible with `toolbarBackground` (SwiftUI can otherwise wash out `largeTitleTextAttributes`).
enum ReaderNavigationBarAppearance {
  @MainActor
  static func apply(palette: ReaderPalette) {
    let bg = UIColor(palette.background)
    let fg = UIColor(palette.primaryText)
    let tint = UIColor(palette.accent)

    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = bg
    appearance.titleTextAttributes = [.foregroundColor: fg]
    appearance.largeTitleTextAttributes = [.foregroundColor: fg]
    appearance.shadowColor = .clear

    let bar = UINavigationBar.appearance()
    bar.standardAppearance = appearance
    bar.scrollEdgeAppearance = appearance
    bar.compactAppearance = appearance
    bar.compactScrollEdgeAppearance = appearance
    bar.tintColor = tint
  }
}

extension View {
  func readerPalette(_ palette: ReaderPalette) -> some View {
    environment(\.readerPalette, palette)
  }

  /// Hides the system list/form scroll surface and paints the screen with the reader background.
  func readerScreenBackground() -> some View {
    modifier(ReaderScreenBackgroundModifier())
  }

  /// Navigation bar matches reader background (apply on each tab’s `NavigationStack`).
  func readerNavigationChrome() -> some View {
    modifier(ReaderNavigationChromeModifier())
  }
}

private struct ReaderScreenBackgroundModifier: ViewModifier {
  @Environment(\.readerPalette) private var palette

  func body(content: Content) -> some View {
    content
      .scrollContentBackground(.hidden)
      .background(palette.background)
  }
}

private struct ReaderNavigationChromeModifier: ViewModifier {
  @Environment(\.readerPalette) private var palette

  func body(content: Content) -> some View {
    content
      .toolbarBackground(palette.background, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
  }
}

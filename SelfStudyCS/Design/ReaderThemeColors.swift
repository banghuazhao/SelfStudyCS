//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

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

  private static let light = ReaderPalette(
    background: Color(.systemBackground),
    secondaryBackground: Color(.secondarySystemBackground),
    primaryText: Color(.label),
    secondaryText: Color(.secondaryLabel),
    accent: Color.accentColor,
    codeBackground: Color(.systemGray6)
  )

  private static let dark = ReaderPalette(
    background: Color(.systemBackground),
    secondaryBackground: Color(.secondarySystemBackground),
    primaryText: Color(.label),
    secondaryText: Color(.secondaryLabel),
    accent: Color.accentColor,
    codeBackground: Color(.systemGray5)
  )

  private static let sepia = ReaderPalette(
    background: Color(red: 0.97, green: 0.94, blue: 0.86),
    secondaryBackground: Color(red: 0.93, green: 0.89, blue: 0.78),
    primaryText: Color(red: 0.2, green: 0.16, blue: 0.11),
    secondaryText: Color(red: 0.35, green: 0.3, blue: 0.22),
    accent: Color(red: 0.45, green: 0.32, blue: 0.2),
    codeBackground: Color(red: 0.9, green: 0.86, blue: 0.75)
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

extension View {
  func readerPalette(_ palette: ReaderPalette) -> some View {
    environment(\.readerPalette, palette)
  }
}

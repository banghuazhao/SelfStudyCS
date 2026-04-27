//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

/// Dedicated appearance screen so colors always come from `ReaderPalette` (navigation-link pickers can flash wrong system chrome).
struct AppearanceSettingsView: View {
  @AppStorage(ReaderAppStorageKey.theme) private var themeRaw = ReaderPreferenceDefaults.theme

  @Environment(\.readerPalette) private var palette

  var body: some View {
    List {
      Section {
        ForEach(ReaderTheme.allCases) { theme in
          Button {
            themeRaw = theme.rawValue
          } label: {
            ThemeOptionRow(theme: theme, isSelected: themeRaw == theme.rawValue)
          }
          .buttonStyle(.plain)
          .listRowBackground(palette.secondaryBackground)
        }
      } header: {
        Text("Theme", comment: "Appearance section header")
      } footer: {
        Text(
          String(
            localized:
              "Tap a theme to apply it everywhere. The preview below shows body text, secondary text, code surfaces, and accent for your current choice.",
            comment: "Appearance theme section footer"
          )
        )
      }

      Section {
        ThemeExampleSamplePanel()
          .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
          .listRowBackground(Color.clear)
      } header: {
        Text("Example", comment: "Sample preview of reader colors")
      } footer: {
        Text(
          String(
            localized:
              "“Match System” uses a light palette when the device is in light mode and a dark palette when the device is in dark mode.",
            comment: "Explains match system theme"
          )
        )
      }
    }
    .listStyle(.insetGrouped)
    .readerScreenBackground()
    .navigationTitle(String(localized: "Appearance"))
    .navigationBarTitleDisplayMode(.inline)
    .readerNavigationChrome()
    .background(palette.background)
  }
}

// MARK: - Theme row

private struct ThemeOptionRow: View {
  let theme: ReaderTheme
  let isSelected: Bool

  @Environment(\.readerPalette) private var palette

  var body: some View {
    HStack(spacing: 14) {
      ThemePreviewSwatch(theme: theme)
        .frame(width: 56, height: 40)

      VStack(alignment: .leading, spacing: 2) {
        Text(theme.title)
          .font(.body.weight(.medium))
          .foregroundStyle(palette.primaryText)
        Text(subtitle(for: theme))
          .font(.caption)
          .foregroundStyle(palette.secondaryText)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 8)

      if isSelected {
        Image(systemName: "checkmark.circle.fill")
          .font(.title3)
          .foregroundStyle(palette.accent)
          .accessibilityLabel(String(localized: "Selected"))
      }
    }
    .padding(.vertical, 6)
    .contentShape(Rectangle())
  }

  private func subtitle(for theme: ReaderTheme) -> String {
    switch theme {
    case .system:
      return String(
        localized: "Light or dark reader palettes follow the device appearance.",
        comment: "Subtitle for Match System theme"
      )
    case .light:
      return String(
        localized: "Warm paper-like backgrounds regardless of device mode.",
        comment: "Subtitle for Light theme"
      )
    case .dark:
      return String(
        localized: "Soft dark surfaces for low-light reading.",
        comment: "Subtitle for Dark theme"
      )
    case .sepia:
      return String(
        localized: "Amber paper tone, similar to warm e-reader modes.",
        comment: "Subtitle for Sepia theme"
      )
    }
  }
}

// MARK: - Swatch (each option shows its own palette, not the live app palette)

private struct ThemePreviewSwatch: View {
  let theme: ReaderTheme

  @Environment(\.colorScheme) private var colorScheme

  private var splitSystemSwatch: some View {
    HStack(spacing: 0) {
      ReaderPaletteResolver.palette(theme: .light, colorScheme: .light)
        .background
      ReaderPaletteResolver.palette(theme: .dark, colorScheme: .dark)
        .background
    }
  }

  private var solidSwatch: Color {
    ReaderPaletteResolver.palette(theme: theme, colorScheme: colorScheme).background
  }

  var body: some View {
    swatchCore
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .strokeBorder(paletteOutlineColor, lineWidth: 1)
    )
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(theme.title)
  }

  @ViewBuilder
  private var swatchCore: some View {
    if theme == .system {
      splitSystemSwatch
    } else {
      solidSwatch
    }
  }

  private var paletteOutlineColor: Color {
    ReaderPaletteResolver.palette(theme: theme, colorScheme: colorScheme)
      .primaryText
      .opacity(0.15)
  }
}

// MARK: - Live example panel (follows selected theme + effective color scheme)

private struct ThemeExampleSamplePanel: View {
  @AppStorage(ReaderAppStorageKey.theme) private var themeRaw = ReaderPreferenceDefaults.theme
  @Environment(\.colorScheme) private var colorScheme

  private var panelPalette: ReaderPalette {
    ReaderPaletteResolver.palette(
      theme: ReaderTheme(rawValue: themeRaw) ?? .system,
      colorScheme: colorScheme
    )
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "The quick brown fox", comment: "Sample title text for theme preview"))
        .font(.title3.weight(.semibold))
        .foregroundStyle(panelPalette.primaryText)

      Text(
        String(
          localized:
            "Secondary text uses a softer color. Lists and cards use the elevated surface behind this panel.",
          comment: "Sample secondary text for theme preview"
        )
      )
      .font(.subheadline)
      .foregroundStyle(panelPalette.secondaryText)

      HStack(alignment: .center, spacing: 10) {
        Text("`inline code`")
          .font(.caption.monospaced())
          .foregroundStyle(panelPalette.primaryText)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(panelPalette.codeBackground, in: RoundedRectangle(cornerRadius: 6))

        Spacer(minLength: 0)

        Text(String(localized: "Accent", comment: "Sample accent label"))
          .font(.caption.weight(.semibold))
          .foregroundStyle(panelPalette.accent)
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(panelPalette.secondaryBackground, in: RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .strokeBorder(panelPalette.primaryText.opacity(0.12), lineWidth: 1)
    )
  }
}

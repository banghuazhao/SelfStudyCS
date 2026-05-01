//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import UIKit

struct RootTabView: View {
  @State private var appModel = AppViewModel()
  @AppStorage(ReaderAppStorageKey.languageMode) private var languageMode = ReaderPreferenceDefaults.languageMode
  @AppStorage(ReaderAppStorageKey.theme) private var themeRaw = ReaderPreferenceDefaults.theme

  @Environment(\.colorScheme) private var colorScheme

  private var resolvedTheme: ReaderTheme {
    ReaderTheme(rawValue: themeRaw) ?? .system
  }

  private var palette: ReaderPalette {
    ReaderPaletteResolver.palette(theme: resolvedTheme, colorScheme: colorScheme)
  }

  /// Keeps `Color.primary` / `.secondary` aligned with Light / Dark / Sepia reader themes.
  private var preferredSystemColorScheme: ColorScheme? {
    switch resolvedTheme {
    case .system:
      return nil
    case .light, .sepia:
      return .light
    case .dark:
      return .dark
    }
  }

  private var contentLocale: Locale {
    switch ContentLanguageMode(rawValue: languageMode) ?? .english {
    case .english:
      return Locale(identifier: "en")
    case .chinese:
      return Locale(identifier: "zh-Hans")
    case .system:
      return Locale.current
    }
  }

  /// Matches `preferredColorScheme` / reader theme so UIKit nav bar resolution stays aligned with SwiftUI.
  private var navigationBarUserInterfaceStyle: UIUserInterfaceStyle {
    switch resolvedTheme {
    case .light, .sepia:
      return .light
    case .dark:
      return .dark
    case .system:
      return colorScheme == .dark ? .dark : .light
    }
  }

  /// Matches reader Light/Dark/Sepia so `UINavigationBar` tinting and materials follow the tab stack.
  private var readerToolbarColorScheme: ColorScheme {
    switch resolvedTheme {
    case .light, .sepia:
      return .light
    case .dark:
      return .dark
    case .system:
      return colorScheme
    }
  }

  var body: some View {
    TabView {
      LibraryView(appModel: appModel)
        .tabItem {
          Label(String(localized: "Library"), systemImage: "books.vertical.fill")
        }

      BookmarksView()
        .tabItem {
          Label(String(localized: "Bookmarks"), systemImage: "bookmark.fill")
        }

      MyGuidesView()
        .tabItem {
          Label(String(localized: "My guides"), systemImage: "square.and.pencil")
        }

      ReaderSettingsView()
        .tabItem {
          Label(String(localized: "Settings"), systemImage: "gearshape.fill")
        }
    }
    .tint(palette.accent)
    .toolbarBackground(palette.secondaryBackground, for: .tabBar)
    .toolbarBackground(.visible, for: .tabBar)
    .preferredColorScheme(preferredSystemColorScheme)
    .toolbarColorScheme(readerToolbarColorScheme, for: .navigationBar)
    .environment(\.readerPalette, palette)
    .environment(\.locale, contentLocale)
    .onAppear {
      ReaderNavigationBarAppearance.apply(
        palette: palette,
        userInterfaceStyle: navigationBarUserInterfaceStyle
      )
      appModel.refreshCatalog()
    }
    .onChange(of: themeRaw) { _, _ in
      ReaderNavigationBarAppearance.apply(
        palette: ReaderPaletteResolver.palette(theme: resolvedTheme, colorScheme: colorScheme),
        userInterfaceStyle: navigationBarUserInterfaceStyle
      )
    }
    .onChange(of: colorScheme) { _, _ in
      ReaderNavigationBarAppearance.apply(
        palette: ReaderPaletteResolver.palette(theme: resolvedTheme, colorScheme: colorScheme),
        userInterfaceStyle: navigationBarUserInterfaceStyle
      )
    }
    .onChange(of: languageMode) { _, _ in
      appModel.refreshCatalog()
      let paletteNow = ReaderPaletteResolver.palette(
        theme: resolvedTheme,
        colorScheme: colorScheme
      )
      let barStyle = navigationBarUserInterfaceStyle
      Task { @MainActor in
        ReaderNavigationBarAppearance.apply(
          palette: paletteNow,
          userInterfaceStyle: barStyle
        )
      }
    }
  }
}

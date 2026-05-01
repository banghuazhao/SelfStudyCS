//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

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

  var body: some View {
    TabView {
      LibraryView(appModel: appModel)
        .tabItem {
          Label("Library", systemImage: "books.vertical.fill")
        }

      BookmarksView()
        .tabItem {
          Label("Bookmarks", systemImage: "bookmark.fill")
        }

      MyGuidesView()
        .tabItem {
          Label("My guides", systemImage: "square.and.pencil")
        }

      ReaderSettingsView()
        .tabItem {
          Label("Settings", systemImage: "gearshape.fill")
        }
    }
    .tint(palette.accent)
    .toolbarBackground(palette.secondaryBackground, for: .tabBar)
    .toolbarBackground(.visible, for: .tabBar)
    .preferredColorScheme(preferredSystemColorScheme)
    .environment(\.readerPalette, palette)
    .onAppear {
      ReaderNavigationBarAppearance.apply(palette: palette)
      appModel.refreshCatalog()
    }
    .onChange(of: themeRaw) { _, _ in
      ReaderNavigationBarAppearance.apply(
        palette: ReaderPaletteResolver.palette(theme: resolvedTheme, colorScheme: colorScheme)
      )
    }
    .onChange(of: colorScheme) { _, _ in
      ReaderNavigationBarAppearance.apply(
        palette: ReaderPaletteResolver.palette(theme: resolvedTheme, colorScheme: colorScheme)
      )
    }
    .onChange(of: languageMode) { _, _ in
      appModel.refreshCatalog()
    }
  }
}

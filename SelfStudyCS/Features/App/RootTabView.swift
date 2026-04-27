//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct RootTabView: View {
  @State private var appModel = AppViewModel()
  @AppStorage(ReaderAppStorageKey.languageMode) private var languageMode = ReaderPreferenceDefaults.languageMode

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

      ReaderSettingsView()
        .tabItem {
          Label("Settings", systemImage: "gearshape.fill")
        }
    }
    .tint(.accentColor)
    .onAppear {
      appModel.refreshCatalog()
    }
    .onChange(of: languageMode) { _, _ in
      appModel.refreshCatalog()
    }
  }
}

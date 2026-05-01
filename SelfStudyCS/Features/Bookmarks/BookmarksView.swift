//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import Observation
import SQLiteData
import SwiftUI

@Observable @MainActor
private final class BookmarksViewModel {
  @ObservationIgnored
  @FetchAll(BookmarkRecord.order { $0.createdAt.desc() })
  var bookmarks: [BookmarkRecord]

  @ObservationIgnored
  @Dependency(\.defaultDatabase) var database

  func remove(_ record: BookmarkRecord) {
    do {
      try database.write { db in
        try BookmarkRecord
          .where { $0.id.eq(record.id) }
          .delete()
          .execute(db)
      }
    } catch {
      #if DEBUG
        print("Remove bookmark failed: \(error)")
      #endif
    }
  }
}

struct BookmarksView: View {
  @AppStorage(ReaderAppStorageKey.languageMode) private var languageMode = ReaderPreferenceDefaults.languageMode
  @State private var model = BookmarksViewModel()

  @Environment(\.readerPalette) private var palette

  private func readerDestination(for record: BookmarkRecord) -> ReaderDocument {
    if let id = UserGuideRecord.parseId(fromDocumentPath: record.documentPath) {
      return .userGuide(id: id)
    }
    let mode = ContentLanguageMode(rawValue: languageMode) ?? .english
    if let hit = DocumentCatalog.catalogEntry(matchingStoredPath: record.documentPath, language: mode) {
      return .bundled(hit)
    }
    return .bundled(
      CatalogEntry(
        documentPath: record.documentPath,
        displayTitle: record.displayTitle,
        sectionTitle: String(localized: "Bookmarks")
      )
    )
  }

  var body: some View {
    NavigationStack {
      Group {
        if model.bookmarks.isEmpty {
          ContentUnavailableView(
            "No bookmarks yet",
            systemImage: "bookmark",
            description: Text("Save chapters from the reader to find them here.")
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(palette.background)
        } else {
          List {
            ForEach(model.bookmarks) { record in
              NavigationLink(value: readerDestination(for: record)) {
                Text(record.displayTitle)
                  .font(.body.weight(.medium))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.vertical, 6)
              }
              .listRowBackground(palette.secondaryBackground)
            }
            .onDelete { indexSet in
              indexSet.map { model.bookmarks[$0] }.forEach(model.remove)
            }
          }
          .listStyle(.insetGrouped)
          .readerScreenBackground()
        }
      }
      .navigationTitle("Bookmarks")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(for: ReaderDocument.self) { doc in
        ReaderView(document: doc)
      }
      .readerNavigationChrome()
    }
    .background(palette.background)
  }
}

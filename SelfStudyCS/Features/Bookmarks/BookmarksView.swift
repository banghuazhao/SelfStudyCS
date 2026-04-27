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
  @State private var model = BookmarksViewModel()

  private func entry(for record: BookmarkRecord) -> CatalogEntry? {
    let mode = ReaderPreferenceDefaults.contentLanguageMode
    let all = DocumentCatalog.build(language: mode)
    for section in all {
      if let hit = section.entries.first(where: { $0.documentPath == record.documentPath }) {
        return hit
      }
    }
    return CatalogEntry(
      documentPath: record.documentPath,
      displayTitle: record.displayTitle,
      sectionTitle: String(localized: "Bookmarks")
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
        } else {
          List {
            ForEach(model.bookmarks) { record in
              if let entry = entry(for: record) {
                NavigationLink(value: entry) {
                  Text(record.displayTitle)
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                }
              }
            }
            .onDelete { indexSet in
              indexSet.map { model.bookmarks[$0] }.forEach(model.remove)
            }
          }
          .listStyle(.insetGrouped)
        }
      }
      .navigationTitle("Bookmarks")
      .navigationBarTitleDisplayMode(.large)
      .navigationDestination(for: CatalogEntry.self) { entry in
        ReaderView(entry: entry)
      }
    }
  }
}

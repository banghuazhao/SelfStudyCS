//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import SQLiteData

@Observable @MainActor
final class AppViewModel {
  @ObservationIgnored
  @FetchAll(ReadingProgressRecord.order { $0.updatedAt.desc() })
  var readingProgress: [ReadingProgressRecord]

  @ObservationIgnored
  @Dependency(\.defaultDatabase) private var database

  private(set) var catalog: [CatalogSection] = []

  func refreshCatalog() {
    catalog = DocumentCatalog.build(language: ReaderPreferenceDefaults.contentLanguageMode)
  }

  /// Most recently read document (bundled or user guide), for the Library “Continue” row.
  var continueReadingPresentation: (document: ReaderDocument, title: String, subtitle: String)? {
    guard let path = readingProgress.first?.documentPath else { return nil }
    if let ugId = UserGuideRecord.parseId(fromDocumentPath: path) {
      var title = String(localized: "Untitled guide")
      try? database.read { db in
        if let g = try UserGuideRecord.where { $0.id.eq(ugId) }.fetchOne(db) {
          title = g.title.isEmpty ? String(localized: "Untitled guide") : g.title
        }
      }
      return (
        .userGuide(id: ugId),
        title,
        String(localized: "My guides")
      )
    }
    let mode = ReaderPreferenceDefaults.contentLanguageMode
    let all = DocumentCatalog.build(language: mode)
    for section in all {
      if let hit = section.entries.first(where: { $0.documentPath == path }) {
        return (.bundled(hit), hit.displayTitle, hit.sectionTitle)
      }
    }
    return nil
  }
}

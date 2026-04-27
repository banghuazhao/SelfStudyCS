//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import Observation
import SQLiteData

@Observable @MainActor
final class AppViewModel {
  @ObservationIgnored
  @FetchAll(ReadingProgressRecord.order { $0.updatedAt.desc() })
  var readingProgress: [ReadingProgressRecord]

  private(set) var catalog: [CatalogSection] = []

  func refreshCatalog() {
    catalog = DocumentCatalog.build(language: ReaderPreferenceDefaults.contentLanguageMode)
  }

  var continueReadingEntry: CatalogEntry? {
    guard let path = readingProgress.first?.documentPath else { return nil }
    let mode = ReaderPreferenceDefaults.contentLanguageMode
    let all = DocumentCatalog.build(language: mode)
    for section in all {
      if let hit = section.entries.first(where: { $0.documentPath == path }) {
        return hit
      }
    }
    return nil
  }
}

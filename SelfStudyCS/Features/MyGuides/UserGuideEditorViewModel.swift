//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import SQLiteData

@Observable @MainActor
final class UserGuideEditorViewModel {
  var title: String = ""
  var markdownBody: String = ""

  private let guideId: Int?

  @ObservationIgnored
  @Dependency(\.defaultDatabase) private var database

  init(guideId: Int?) {
    self.guideId = guideId
  }

  func loadIfNeeded() {
    guard let guideId else { return }
    do {
      try database.read { db in
        if let g = try UserGuideRecord.where { $0.id.eq(guideId) }.fetchOne(db) {
          title = g.title
          markdownBody = g.markdownBody
        }
      }
    } catch {
      #if DEBUG
        print("Load guide for edit failed: \(error)")
      #endif
    }
  }

  func save() throws {
    let now = Date()
    try database.write { db in
      if let guideId {
        guard var row = try UserGuideRecord.where { $0.id.eq(guideId) }.fetchOne(db) else { return }
        row.title = title
        row.markdownBody = markdownBody
        row.updatedAt = now
        try UserGuideRecord.update(row).execute(db)
      } else {
        try UserGuideRecord.insert {
          UserGuideRecord.Draft(
            title: title,
            markdownBody: markdownBody,
            createdAt: now,
            updatedAt: now
          )
        }
        .execute(db)
      }
    }
  }
}

//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SQLiteData

@Table("user_guides")
nonisolated struct UserGuideRecord: Identifiable, Hashable, Sendable {
  let id: Int
  var title: String
  var markdownBody: String
  var createdAt: Date
  var updatedAt: Date

  /// Stable key shared with `bookmarks` and `reading_progress`.
  nonisolated static let pathPrefix = "userguide:"

  nonisolated static func documentPath(for id: Int) -> String {
    "\(pathPrefix)\(id)"
  }

  nonisolated static func parseId(fromDocumentPath path: String) -> Int? {
    guard path.hasPrefix(pathPrefix) else { return nil }
    return Int(path.dropFirst(pathPrefix.count))
  }
}

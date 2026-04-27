//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SQLiteData

@Table("bookmarks")
nonisolated struct BookmarkRecord: Identifiable, Hashable, Sendable {
  let id: Int
  var documentPath: String
  var displayTitle: String
  var createdAt: Date
}

//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SQLiteData

@Table("reading_progress")
nonisolated struct ReadingProgressRecord: Identifiable, Hashable, Sendable {
  let id: Int
  var documentPath: String
  var scrollOffsetY: Double
  var updatedAt: Date
}

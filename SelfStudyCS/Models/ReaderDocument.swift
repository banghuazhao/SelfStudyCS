//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

/// What to open in the reader: bundled catalog entry or a user-authored guide stored in SQLite.
enum ReaderDocument: Hashable, Sendable {
  case bundled(CatalogEntry)
  case userGuide(id: Int)

  var documentPath: String {
    switch self {
    case .bundled(let entry):
      return entry.documentPath
    case .userGuide(let id):
      return UserGuideRecord.documentPath(for: id)
    }
  }

  var isUserGuide: Bool {
    if case .userGuide = self { return true }
    return false
  }
}

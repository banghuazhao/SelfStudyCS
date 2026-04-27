//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

enum MarkdownTitleExtractor {
  /// First ATX heading (`# …`) in the source, for navigation (not the filename).
  static func firstHeading(from markdown: String) -> String? {
    for line in markdown.split(separator: "\n", omittingEmptySubsequences: false) {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      guard trimmed.hasPrefix("#") else { continue }
      var rest = trimmed.drop(while: { $0 == "#" })
      rest = rest.drop(while: { $0 == " " || $0 == "\t" })
      let title = String(rest).trimmingCharacters(in: .whitespacesAndNewlines)
      if !title.isEmpty { return title }
    }
    return nil
  }
}

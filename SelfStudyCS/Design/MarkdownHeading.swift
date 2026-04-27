//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

nonisolated struct MarkdownHeading: Identifiable, Hashable, Sendable {
  let id: String
  let level: Int
  let title: String
}

enum MarkdownHeadingParser {
  private static let regex = try! NSRegularExpression(
    pattern: "^(#{1,6})\\s+(.+)$",
    options: [.anchorsMatchLines]
  )

  static func headings(in markdown: String) -> [MarkdownHeading] {
    let range = NSRange(markdown.startIndex..., in: markdown)
    let matches = regex.matches(in: markdown, options: [], range: range)
    var result: [MarkdownHeading] = []
    result.reserveCapacity(matches.count)
    for (idx, match) in matches.enumerated() {
      guard match.numberOfRanges >= 3,
        let levelRange = Range(match.range(at: 1), in: markdown),
        let titleRange = Range(match.range(at: 2), in: markdown)
      else { continue }
      let level = markdown[levelRange].count
      let title = String(markdown[titleRange]).trimmingCharacters(in: .whitespaces)
      let id = "h-\(idx)-\(title.hashValue)"
      result.append(MarkdownHeading(id: id, level: level, title: title))
    }
    return result
  }

  static func splitSections(markdown: String) -> [(heading: MarkdownHeading?, body: String)] {
    let lines = markdown.split(separator: "\n", omittingEmptySubsequences: false)
    var sections: [(MarkdownHeading?, String)] = []
    var currentHeading: MarkdownHeading?
    var currentLines: [Substring] = []
    var headingIndex = 0

    func flush() {
      let body = currentLines.joined(separator: "\n")
      if !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || currentHeading != nil {
        sections.append((currentHeading, body))
      }
      currentLines = []
    }

    for line in lines {
      if let h = parseHeadingLine(String(line), index: &headingIndex) {
        flush()
        currentHeading = h
      }
      currentLines.append(line)
    }
    flush()
    if sections.isEmpty, !markdown.isEmpty {
      return [(nil, markdown)]
    }
    return sections
  }

  private static func parseHeadingLine(_ line: String, index: inout Int) -> MarkdownHeading? {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    guard trimmed.hasPrefix("#") else { return nil }
    let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
    guard let hashes = parts.first, hashes.allSatisfy({ $0 == "#" }),
      hashes.count <= 6,
      parts.count == 2
    else { return nil }
    let title = String(parts[1])
    let id = "h-\(index)-\(title.hashValue)"
    index += 1
    return MarkdownHeading(id: id, level: hashes.count, title: title)
  }
}

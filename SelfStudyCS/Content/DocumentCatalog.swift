//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

nonisolated struct CatalogEntry: Identifiable, Hashable, Sendable {
  var id: String { documentPath }
  /// Path relative to the `Docs` folder, e.g. `操作系统/MIT6.S081.md`
  let documentPath: String
  let displayTitle: String
  let sectionTitle: String
}

nonisolated struct CatalogSection: Identifiable, Hashable, Sendable {
  var id: String { title }
  let title: String
  let entries: [CatalogEntry]
}

enum DocumentCatalog {
  static func build(language: ContentLanguageMode) -> [CatalogSection] {
    let catalogFiles = BundledDocsLocator.allCatalogMarkdownFileURLs()
    let prefersEnglish = language.resolvesToEnglish()

    var groups: [String: [URL]] = [:]
    for pair in catalogFiles {
      let key = stemKey(forRelativePath: pair.documentPath)
      groups[key, default: []].append(pair.url)
    }

    var entries: [CatalogEntry] = []
    for (stem, fileURLs) in groups {
      guard let chosen = resolveURL(in: fileURLs, prefersEnglish: prefersEnglish) else { continue }
      guard let relative = BundledDocsLocator.pathRelativeToDocs(from: chosen) else { continue }
      let section = sectionTitle(stem: stem, relative: relative, prefersEnglish: prefersEnglish)
      let title = displayTitle(fromRelativePath: relative, prefersEnglish: prefersEnglish)
      entries.append(
        CatalogEntry(
          documentPath: relative,
          displayTitle: title,
          sectionTitle: section
        )
      )
    }

    let grouped = Dictionary(grouping: entries, by: \.sectionTitle)
    let sections = grouped.keys.sorted { a, b in
      let aTpl = grouped[a]!.contains { $0.documentPath.hasPrefix("Template/") }
      let bTpl = grouped[b]!.contains { $0.documentPath.hasPrefix("Template/") }
      if aTpl != bTpl { return !aTpl && bTpl }
      return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
    }
    return sections.map { key in
      CatalogSection(
        title: key,
        entries: grouped[key, default: []].sorted {
          $0.displayTitle.localizedCaseInsensitiveCompare($1.displayTitle) == .orderedAscending
        }
      )
    }
  }

  private static func stemKey(forRelativePath relative: String) -> String {
    var s = relative
    if s.hasSuffix(".md") {
      s.removeLast(3)
    }
    if s.hasSuffix(".en") {
      s.removeLast(3)
    }
    return s
  }

  private static func resolveURL(in urls: [URL], prefersEnglish: Bool) -> URL? {
    let english = urls.filter { $0.lastPathComponent.contains(".en.md") }
    let chinese = urls.filter { !$0.lastPathComponent.contains(".en.md") }
    if prefersEnglish {
      return english.first ?? chinese.first
    }
    return chinese.first ?? english.first
  }

  private static func sectionTitle(stem: String, relative: String, prefersEnglish: Bool) -> String {
    let parts = stem.split(separator: "/").map(String.init)
    if parts.count >= 2 {
      return DocsEnglishTitles.folderDisplayName(
        parts[0],
        prefersEnglish: prefersEnglish
      )
    }
    return DocsEnglishTitles.rootOverviewSectionTitle
  }

  private static func displayTitle(fromRelativePath relative: String, prefersEnglish: Bool) -> String {
    let name = (relative as NSString).lastPathComponent
    var base = name
    if base.hasSuffix(".md") {
      base.removeLast(3)
    }
    if base.hasSuffix(".en") {
      base.removeLast(3)
    }
    return DocsEnglishTitles.chapterDisplayTitle(
      fileStem: base,
      relativePath: relative,
      prefersEnglish: prefersEnglish
    )
  }
}

enum MarkdownBundleLoader {
  static func loadString(documentPath: String) -> String? {
    guard documentPath.lowercased().hasSuffix(".md") else { return nil }
    guard let url = BundledDocsLocator.fileURL(documentPath: documentPath) else { return nil }
    return try? String(contentsOf: url, encoding: .utf8)
  }
}

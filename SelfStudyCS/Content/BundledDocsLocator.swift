//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

/// Resolves bundled content folders and lists markdown files.
/// `Bundle.urls(forResourcesWithExtension:subdirectory:)` is unreliable for folder references with nested folders, so we enumerate with FileManager.
enum BundledDocsLocator {
  private static let docsFolderName = "Docs"
  private static let templateFolderName = "Template"

  static var docsDirectoryURL: URL? {
    directoryURL(named: docsFolderName)
  }

  static var templateDirectoryURL: URL? {
    directoryURL(named: templateFolderName)
  }

  private static func directoryURL(named name: String) -> URL? {
    if let url = Bundle.main.url(forResource: name, withExtension: nil) {
      var isDir: ObjCBool = false
      if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
        return url.standardizedFileURL
      }
    }
    let fallback = Bundle.main.bundleURL.appendingPathComponent(name, isDirectory: true)
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: fallback.path, isDirectory: &isDir), isDir.boolValue {
      return fallback.standardizedFileURL
    }
    return nil
  }

  /// Paths under `Docs` only (unchanged), for backwards-compatible relative paths.
  static func allMarkdownFileURLs() -> [URL] {
    guard let root = docsDirectoryURL else { return [] }
    return markdownFilesUnder(root: root)
  }

  /// Library entries: `Docs` paths as today, plus `Template/…` for bundled writing templates.
  static func allCatalogMarkdownFileURLs() -> [(documentPath: String, url: URL)] {
    var out: [(String, URL)] = []
    if let root = docsDirectoryURL {
      for url in markdownFilesUnder(root: root) {
        if let rel = pathRelative(root: root, from: url) {
          out.append((rel, url))
        }
      }
    }
    if let root = templateDirectoryURL {
      for url in markdownFilesUnder(root: root) {
        if url.lastPathComponent.lowercased() == "readme.md" { continue }
        if let rel = pathRelative(root: root, from: url) {
          out.append(("\(templateFolderName)/\(rel)", url))
        }
      }
    }
    return out
  }

  private static func markdownFilesUnder(root: URL) -> [URL] {
    guard let enumerator = FileManager.default.enumerator(
      at: root,
      includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles]
    ) else { return [] }
    var urls: [URL] = []
    for case let url as URL in enumerator {
      if url.pathExtension.lowercased() == "md" {
        urls.append(url)
      }
    }
    return urls
  }

  static func pathRelativeToDocs(from fileURL: URL) -> String? {
    guard let root = docsDirectoryURL else { return nil }
    return pathRelative(root: root, from: fileURL)
  }

  private static func pathRelative(root: URL, from fileURL: URL) -> String? {
    let rootPath = root.path
    let filePath = fileURL.standardizedFileURL.path
    guard filePath.hasPrefix(rootPath) else { return nil }
    var rel = String(filePath.dropFirst(rootPath.count))
    while rel.hasPrefix("/") { rel.removeFirst() }
    return rel.isEmpty ? nil : rel
  }

  /// Resolves a catalog `documentPath` (e.g. `操作系统/CS162.md` or `Template/template.en.md`).
  static func fileURL(documentPath: String) -> URL? {
    if documentPath.hasPrefix("\(templateFolderName)/") {
      guard let root = templateDirectoryURL else { return nil }
      let rest = String(documentPath.dropFirst(templateFolderName.count + 1))
      let parts = rest.split(separator: "/").map(String.init)
      guard !parts.isEmpty else { return nil }
      return parts.reduce(root) { $0.appendingPathComponent($1) }
    }
    return fileURL(documentPathRelativeToDocs: documentPath)
  }

  static func fileURL(documentPathRelativeToDocs: String) -> URL? {
    guard let root = docsDirectoryURL else { return nil }
    let parts = documentPathRelativeToDocs.split(separator: "/").map(String.init)
    guard !parts.isEmpty else { return nil }
    return parts.reduce(root) { $0.appendingPathComponent($1) }
  }
}

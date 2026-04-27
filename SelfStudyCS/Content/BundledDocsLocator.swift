//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

/// Resolves the on-disk `Docs` folder inside the app bundle and lists markdown files.
/// `Bundle.urls(forResourcesWithExtension:subdirectory:)` is unreliable for folder references with nested folders, so we enumerate with FileManager.
enum BundledDocsLocator {
  private static let docsFolderName = "Docs"

  static var docsDirectoryURL: URL? {
    if let url = Bundle.main.url(forResource: docsFolderName, withExtension: nil) {
      var isDir: ObjCBool = false
      if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
        return url.standardizedFileURL
      }
    }
    let fallback = Bundle.main.bundleURL.appendingPathComponent(docsFolderName, isDirectory: true)
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: fallback.path, isDirectory: &isDir), isDir.boolValue {
      return fallback.standardizedFileURL
    }
    return nil
  }

  static func allMarkdownFileURLs() -> [URL] {
    guard let root = docsDirectoryURL else { return [] }
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
    let rootPath = root.path
    let filePath = fileURL.standardizedFileURL.path
    guard filePath.hasPrefix(rootPath) else { return nil }
    var rel = String(filePath.dropFirst(rootPath.count))
    while rel.hasPrefix("/") { rel.removeFirst() }
    return rel.isEmpty ? nil : rel
  }

  static func fileURL(documentPathRelativeToDocs: String) -> URL? {
    guard let root = docsDirectoryURL else { return nil }
    let parts = documentPathRelativeToDocs.split(separator: "/").map(String.init)
    guard !parts.isEmpty else { return nil }
    return parts.reduce(root) { $0.appendingPathComponent($1) }
  }
}

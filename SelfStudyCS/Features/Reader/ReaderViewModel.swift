//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import SQLiteData

@Observable @MainActor
final class ReaderViewModel {
  let document: ReaderDocument

  /// `true` until the current `loadContent()` finishes (avoids a flash of the empty / error UI).
  private(set) var isLoading = true
  private(set) var markdown: String = ""
  /// First `#` heading in the file (preferred navigation title; not the filename).
  private(set) var navigationTitle: String = ""
  private(set) var headings: [MarkdownHeading] = []
  private(set) var restoredOffsetY: CGFloat = 0
  var isBookmarked = false
  private(set) var latestScrollOffsetY: CGFloat = 0

  @ObservationIgnored
  @Dependency(\.defaultDatabase) private var database

  private var progressSaveTask: Task<Void, Never>?

  /// Paths that may hold progress/bookmarks for this document (ZH vs EN file names).
  private var bundledProgressPaths: [String] {
    guard case .bundled(let entry) = document else { return [] }
    let mode = ReaderPreferenceDefaults.contentLanguageMode
    let resolved = DocumentCatalog.resolvedBundledDocumentPath(
      storedPath: entry.documentPath,
      language: mode
    )
    return Array(Set([entry.documentPath, resolved]))
  }

  /// Primary path used when saving progress and bookmarks for bundled chapters.
  private var storageDocumentPath: String {
    switch document {
    case .bundled(let entry):
      let mode = ReaderPreferenceDefaults.contentLanguageMode
      return DocumentCatalog.resolvedBundledDocumentPath(
        storedPath: entry.documentPath,
        language: mode
      )
    case .userGuide(let id):
      return UserGuideRecord.documentPath(for: id)
    }
  }

  init(document: ReaderDocument) {
    self.document = document
  }

  init(entry: CatalogEntry) {
    self.document = .bundled(entry)
  }

  var isUserGuide: Bool {
    document.isUserGuide
  }

  func loadContent() {
    isLoading = true
    defer { isLoading = false }

    switch document {
    case .bundled(let entry):
      let mode = ReaderPreferenceDefaults.contentLanguageMode
      let path = DocumentCatalog.resolvedBundledDocumentPath(
        storedPath: entry.documentPath,
        language: mode
      )
      markdown = MarkdownBundleLoader.loadString(documentPath: path) ?? ""
      let titleFallback =
        DocumentCatalog.catalogEntry(matchingStoredPath: entry.documentPath, language: mode)?
        .displayTitle ?? entry.displayTitle
      navigationTitle =
        MarkdownTitleExtractor.firstHeading(from: markdown) ?? titleFallback
    case .userGuide(let id):
      markdown = ""
      navigationTitle = String(localized: "Guide")
      do {
        try database.read({ db in
          if let g = try UserGuideRecord.where { $0.id.eq(id) }.fetchOne(db) {
            markdown = g.markdownBody
            navigationTitle =
              MarkdownTitleExtractor.firstHeading(from: markdown) ?? g.title
          }
        })
      } catch {
        #if DEBUG
          print("Load user guide failed: \(error)")
        #endif
      }
    }
    headings = MarkdownHeadingParser.headings(in: markdown)
    loadProgressAndBookmarkState()
  }

  func reloadContent() {
    loadContent()
  }

  private func loadProgressAndBookmarkState() {
    let paths: [String]
    switch document {
    case .bundled:
      paths = bundledProgressPaths
    case .userGuide:
      paths = [document.documentPath]
    }
    do {
      try database.read({ db in
        var restored: CGFloat = 0
        for p in paths {
          if let row = try ReadingProgressRecord.where { $0.documentPath.eq(p) }.fetchOne(db) {
            restored = CGFloat(row.scrollOffsetY)
            break
          }
        }
        restoredOffsetY = restored

        var bookmarked = false
        for p in paths {
          if try BookmarkRecord.where { $0.documentPath.eq(p) }.fetchOne(db) != nil {
            bookmarked = true
            break
          }
        }
        isBookmarked = bookmarked
      })
    } catch {
      #if DEBUG
        print("Load progress failed: \(error)")
      #endif
    }
  }

  func recordScroll(offsetY: CGFloat) {
    latestScrollOffsetY = offsetY
    scheduleProgressSave(offsetY: offsetY)
  }

  func flushProgress() {
    progressSaveTask?.cancel()
    persistProgress(offsetY: latestScrollOffsetY)
  }

  private func scheduleProgressSave(offsetY: CGFloat) {
    progressSaveTask?.cancel()
    progressSaveTask = Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(500))
      guard !Task.isCancelled else { return }
      persistProgress(offsetY: offsetY)
    }
  }

  private func persistProgress(offsetY: CGFloat) {
    let primary = storageDocumentPath
    let siblings: [String]
    switch document {
    case .bundled:
      siblings = bundledProgressPaths
    case .userGuide:
      siblings = [primary]
    }
    do {
      try database.write({ db in
        for p in siblings where p != primary {
          try ReadingProgressRecord.where { $0.documentPath.eq(p) }.delete().execute(db)
        }
        let y = Double(offsetY)
        let now = Date()
        if var row = try ReadingProgressRecord.where { $0.documentPath.eq(primary) }.fetchOne(db) {
          row.scrollOffsetY = y
          row.updatedAt = now
          try ReadingProgressRecord.update(row).execute(db)
        } else {
          try ReadingProgressRecord.insert {
            ReadingProgressRecord.Draft(documentPath: primary, scrollOffsetY: y, updatedAt: now)
          }
          .execute(db)
        }
      })
    } catch {
      #if DEBUG
        print("Save progress failed: \(error)")
      #endif
    }
  }

  func toggleBookmark(displayTitle: String) {
    let primary = storageDocumentPath
    let siblings: [String]
    switch document {
    case .bundled:
      siblings = bundledProgressPaths
    case .userGuide:
      siblings = [primary]
    }
    do {
      try database.write({ db in
        var hadBookmark = false
        for p in siblings {
          if try BookmarkRecord.where { $0.documentPath.eq(p) }.fetchOne(db) != nil {
            hadBookmark = true
            break
          }
        }
        if hadBookmark {
          for p in siblings {
            try BookmarkRecord.where { $0.documentPath.eq(p) }.delete().execute(db)
          }
          isBookmarked = false
        } else {
          try BookmarkRecord.insert {
            BookmarkRecord.Draft(
              documentPath: primary,
              displayTitle: displayTitle,
              createdAt: Date()
            )
          }
          .execute(db)
          isBookmarked = true
        }
      })
    } catch {
      #if DEBUG
        print("Bookmark toggle failed: \(error)")
      #endif
    }
  }
}

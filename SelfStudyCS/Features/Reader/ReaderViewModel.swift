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
    switch document {
    case .bundled(let entry):
      markdown = MarkdownBundleLoader.loadString(documentPath: entry.documentPath) ?? ""
      navigationTitle =
        MarkdownTitleExtractor.firstHeading(from: markdown) ?? entry.displayTitle
    case .userGuide(let id):
      markdown = ""
      navigationTitle = String(localized: "Guide")
      do {
        try database.read { db in
          if let g = try UserGuideRecord.where { $0.id.eq(id) }.fetchOne(db) {
            markdown = g.markdownBody
            navigationTitle =
              MarkdownTitleExtractor.firstHeading(from: markdown) ?? g.title
          }
        }
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
    let path = document.documentPath
    do {
      try database.read { db in
        if let p = try ReadingProgressRecord.where { $0.documentPath.eq(path) }.fetchOne(db) {
          restoredOffsetY = CGFloat(p.scrollOffsetY)
        } else {
          restoredOffsetY = 0
        }
        isBookmarked =
          try BookmarkRecord.where { $0.documentPath.eq(path) }.fetchOne(db) != nil
      }
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
    let path = document.documentPath
    do {
      try database.write { db in
        let y = Double(offsetY)
        let now = Date()
        if var row = try ReadingProgressRecord.where { $0.documentPath.eq(path) }.fetchOne(db) {
          row.scrollOffsetY = y
          row.updatedAt = now
          try ReadingProgressRecord.update(row).execute(db)
        } else {
          try ReadingProgressRecord.insert {
            ReadingProgressRecord.Draft(documentPath: path, scrollOffsetY: y, updatedAt: now)
          }
          .execute(db)
        }
      }
    } catch {
      #if DEBUG
        print("Save progress failed: \(error)")
      #endif
    }
  }

  func toggleBookmark(displayTitle: String) {
    let path = document.documentPath
    do {
      try database.write { db in
        if let row = try BookmarkRecord.where { $0.documentPath.eq(path) }.fetchOne(db) {
          try BookmarkRecord
            .where { $0.id.eq(row.id) }
            .delete()
            .execute(db)
          isBookmarked = false
        } else {
          try BookmarkRecord.insert {
            BookmarkRecord.Draft(
              documentPath: path,
              displayTitle: displayTitle,
              createdAt: Date()
            )
          }
          .execute(db)
        }
      }
    } catch {
      #if DEBUG
        print("Bookmark toggle failed: \(error)")
      #endif
    }
  }
}

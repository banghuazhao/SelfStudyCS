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
  let entry: CatalogEntry

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

  init(entry: CatalogEntry) {
    self.entry = entry
  }

  func loadContent() {
    markdown = MarkdownBundleLoader.loadString(documentPath: entry.documentPath) ?? ""
    navigationTitle =
      MarkdownTitleExtractor.firstHeading(from: markdown) ?? entry.displayTitle
    headings = MarkdownHeadingParser.headings(in: markdown)
    loadProgressAndBookmarkState()
  }

  private func loadProgressAndBookmarkState() {
    do {
      try database.read { db in
        if let p = try ReadingProgressRecord.where { $0.documentPath.eq(entry.documentPath) }.fetchOne(db) {
          restoredOffsetY = CGFloat(p.scrollOffsetY)
        } else {
          restoredOffsetY = 0
        }
        isBookmarked =
          try BookmarkRecord.where { $0.documentPath.eq(entry.documentPath) }.fetchOne(db) != nil
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
    let path = entry.documentPath
    progressSaveTask = Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(500))
      guard !Task.isCancelled else { return }
      persistProgress(offsetY: offsetY)
    }
  }

  private func persistProgress(offsetY: CGFloat) {
    let path = entry.documentPath
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
    do {
      try database.write { db in
        if let row = try BookmarkRecord.where { $0.documentPath.eq(entry.documentPath) }.fetchOne(db) {
          try BookmarkRecord
            .where { $0.id.eq(row.id) }
            .delete()
            .execute(db)
          isBookmarked = false
        } else {
          try BookmarkRecord.insert {
            BookmarkRecord.Draft(
              documentPath: entry.documentPath,
              displayTitle: displayTitle,
              createdAt: Date()
            )
          }
          .execute(db)
          isBookmarked = true
        }
      }
    } catch {
      #if DEBUG
        print("Bookmark toggle failed: \(error)")
      #endif
    }
  }
}

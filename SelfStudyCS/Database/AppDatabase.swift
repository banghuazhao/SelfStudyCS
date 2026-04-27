//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import GRDB
import SQLiteData

enum AppDatabase {
  static func makeWriter() throws -> any DatabaseWriter {
    let folder = try FileManager.default.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    .appendingPathComponent("SelfStudyCS", isDirectory: true)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    let dbURL = folder.appendingPathComponent("reader.sqlite")
    let pool = try DatabasePool(path: dbURL.path)
    var migrator = DatabaseMigrator()
    migrator.registerMigration("20260427120000_initial") { db in
      try #sql(
        """
        CREATE TABLE "bookmarks" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT,
          "documentPath" TEXT NOT NULL UNIQUE,
          "displayTitle" TEXT NOT NULL,
          "createdAt" TEXT NOT NULL
        ) STRICT
        """
      )
      .execute(db)

      try #sql(
        """
        CREATE TABLE "reading_progress" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT,
          "documentPath" TEXT NOT NULL UNIQUE,
          "scrollOffsetY" REAL NOT NULL DEFAULT 0,
          "updatedAt" TEXT NOT NULL
        ) STRICT
        """
      )
      .execute(db)
    }

    migrator.registerMigration("20260429200000_user_guides") { db in
      try #sql(
        """
        CREATE TABLE "user_guides" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT,
          "title" TEXT NOT NULL,
          "markdownBody" TEXT NOT NULL,
          "createdAt" TEXT NOT NULL,
          "updatedAt" TEXT NOT NULL
        ) STRICT
        """
      )
      .execute(db)
    }

    try migrator.migrate(pool)
    return pool
  }
}

//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import Observation
import SQLiteData
import SwiftUI

@Observable @MainActor
private final class MyGuidesViewModel {
  @ObservationIgnored
  @FetchAll(UserGuideRecord.order { $0.updatedAt.desc() })
  var guides: [UserGuideRecord]

  @ObservationIgnored
  @Dependency(\.defaultDatabase) var database

  func delete(at offsets: IndexSet) {
    let ids = offsets.map { guides[$0].id }
    for id in ids {
      deleteGuide(id: id)
    }
  }

  func deleteGuide(id: Int) {
    let path = UserGuideRecord.documentPath(for: id)
    do {
      try database.write { db in
        try UserGuideRecord
          .where { $0.id.eq(id) }
          .delete()
          .execute(db)
        try BookmarkRecord
          .where { $0.documentPath.eq(path) }
          .delete()
          .execute(db)
        try ReadingProgressRecord
          .where { $0.documentPath.eq(path) }
          .delete()
          .execute(db)
      }
    } catch {
      #if DEBUG
        print("Delete guide failed: \(error)")
      #endif
    }
  }
}

struct MyGuidesView: View {
  @State private var model = MyGuidesViewModel()
  @State private var showNewGuide = false

  @Environment(\.readerPalette) private var palette

  var body: some View {
    NavigationStack {
      Group {
        if model.guides.isEmpty {
          ContentUnavailableView(
            String(localized: "No guides yet"),
            systemImage: "square.and.pencil",
            description: Text(
              String(
                localized:
                  "Create a guide to write your own notes in Markdown. They are saved on this device."
              )
            )
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(palette.background)
        } else {
          List {
            ForEach(model.guides) { guide in
              NavigationLink(value: ReaderDocument.userGuide(id: guide.id)) {
                VStack(alignment: .leading, spacing: 4) {
                  Text(guide.title.isEmpty ? String(localized: "Untitled") : guide.title)
                    .font(.body.weight(.medium))
                  Text(guide.updatedAt, format: .dateTime.day().month().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
              }
              .listRowBackground(palette.secondaryBackground)
            }
            .onDelete { model.delete(at: $0) }
          }
          .listStyle(.insetGrouped)
          .readerScreenBackground()
        }
      }
      .navigationTitle(String(localized: "My guides"))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showNewGuide = true
          } label: {
            Label(String(localized: "New course", comment: "Toolbar create course guide"), systemImage: "plus")
          }
        }
      }
      .navigationDestination(for: ReaderDocument.self) { doc in
        ReaderView(document: doc)
      }
      .readerNavigationChrome()
      .sheet(isPresented: $showNewGuide) {
        NavigationStack {
          UserGuideEditorView(guideId: nil)
        }
        .environment(\.readerPalette, palette)
        .readerNavigationChrome()
      }
    }
    .background(palette.background)
  }
}

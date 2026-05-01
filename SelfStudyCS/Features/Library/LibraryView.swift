//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct LibraryView: View {
  @Bindable var appModel: AppViewModel
  @State private var query = ""

  @Environment(\.readerPalette) private var palette

  private var filteredSections: [CatalogSection] {
    let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !q.isEmpty else { return appModel.catalog }
    return appModel.catalog.compactMap { section in
      let hits = section.entries.filter {
        $0.displayTitle.localizedCaseInsensitiveContains(q)
          || $0.documentPath.localizedCaseInsensitiveContains(q)
      }
      guard !hits.isEmpty else { return nil }
      return CatalogSection(title: section.title, entries: hits)
    }
  }

  var body: some View {
    NavigationStack {
      List {
        if let cont = appModel.continueReadingPresentation {
          Section {
            NavigationLink(value: cont.document) {
              ContinueReadingRow(
                title: cont.title,
                subtitle: cont.subtitle,
                showBookmark: appModel.isPathBookmarked(cont.document.documentPath)
              )
            }
            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            .listRowBackground(palette.secondaryBackground)
          } header: {
            Text("Continue")
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(.secondary)
              .textCase(nil)
          }
        }

        ForEach(filteredSections) { section in
          Section {
            ForEach(section.entries) { entry in
              NavigationLink(value: entry) {
                LibraryEntryRow(
                  title: entry.displayTitle,
                  showBookmark: appModel.isPathBookmarked(entry.documentPath)
                )
              }
              .listRowBackground(palette.secondaryBackground)
            }
          } header: {
            Text(section.title)
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(.secondary)
              .textCase(nil)
          }
        }
      }
      .listStyle(.insetGrouped)
      .readerScreenBackground()
      .navigationTitle("Library")
      .navigationBarTitleDisplayMode(.inline)
      .searchable(text: $query, prompt: "Search chapters")
      .navigationDestination(for: CatalogEntry.self) { entry in
        ReaderView(entry: entry)
      }
      .navigationDestination(for: ReaderDocument.self) { doc in
        ReaderView(document: doc)
      }
      .readerNavigationChrome()
    }
    .background(palette.background)
  }
}

private struct LibraryEntryRow: View {
  let title: String
  let showBookmark: Bool
  @Environment(\.readerPalette) private var palette

  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      Text(title)
        .font(.body.weight(.medium))
        .foregroundStyle(.primary)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)

      if showBookmark {
        Image(systemName: "bookmark.fill")
          .font(.body.weight(.semibold))
          .foregroundStyle(palette.accent)
          .accessibilityLabel(String(localized: "Bookmarked"))
      }
    }
    .padding(.vertical, 6)
  }
}

private struct ContinueReadingRow: View {
  let title: String
  let subtitle: String
  var showBookmark: Bool = false
  @Environment(\.readerPalette) private var palette

  var body: some View {
    HStack(spacing: 14) {
      Image(systemName: "play.circle.fill")
        .font(.title2)
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(.tint)
      VStack(alignment: .leading, spacing: 2) {
        Text("Continue reading")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
        Text(title)
          .font(.headline)
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer(minLength: 0)
      if showBookmark {
        Image(systemName: "bookmark.fill")
          .font(.body.weight(.semibold))
          .foregroundStyle(palette.accent)
          .accessibilityLabel(String(localized: "Bookmarked"))
      }
    }
    .padding(.vertical, 4)
  }
}

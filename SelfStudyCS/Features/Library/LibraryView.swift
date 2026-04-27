//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct LibraryView: View {
  @Bindable var appModel: AppViewModel
  @State private var query = ""

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
        if let entry = appModel.continueReadingEntry {
          Section {
            NavigationLink(value: entry) {
              ContinueReadingRow(title: entry.displayTitle, subtitle: entry.sectionTitle)
            }
            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
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
                Text(entry.displayTitle)
                  .font(.body.weight(.medium))
                  .foregroundStyle(.primary)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.vertical, 6)
              }
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
      .navigationTitle("Library")
      .navigationBarTitleDisplayMode(.large)
      .searchable(text: $query, prompt: "Search chapters")
      .navigationDestination(for: CatalogEntry.self) { entry in
        ReaderView(entry: entry)
      }
    }
  }
}

private struct ContinueReadingRow: View {
  let title: String
  let subtitle: String

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
    }
    .padding(.vertical, 4)
  }
}

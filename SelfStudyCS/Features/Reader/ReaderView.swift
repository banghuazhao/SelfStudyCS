//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import UIKit
import WebKit

struct ReaderView: View {
  let document: ReaderDocument

  @AppStorage(ReaderAppStorageKey.fontScale) private var fontScale = ReaderPreferenceDefaults.fontScale
  @AppStorage(ReaderAppStorageKey.lineSpacing) private var lineSpacing = ReaderPreferenceDefaults.lineSpacing
  @AppStorage(ReaderAppStorageKey.languageMode) private var languageMode = ReaderPreferenceDefaults.languageMode

  @Environment(\.readerPalette) private var palette
  @State private var model: ReaderViewModel
  @State private var showTOC = false
  @State private var showEditor = false
  @State private var scrollNavigator: (token: Int, fragment: String)?
  @State private var scrollNonce = 0

  init(document: ReaderDocument) {
    self.document = document
    _model = State(wrappedValue: ReaderViewModel(document: document))
  }

  init(entry: CatalogEntry) {
    self.document = .bundled(entry)
    _model = State(wrappedValue: ReaderViewModel(entry: entry))
  }

  private var baseFontSize: CGFloat {
    CGFloat(17 * fontScale)
  }

  private var userGuideIdForEditor: Int? {
    if case .userGuide(let id) = document { return id }
    return nil
  }

  var body: some View {
    Group {
      if model.isLoading {
        ProgressView()
          .tint(palette.accent)
          .controlSize(.large)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if model.markdown.isEmpty {
        ContentUnavailableView(
          emptyTitle,
          systemImage: "doc.text",
          description: Text(emptyDescription)
        )
      } else {
        MarkdownTextView(
          markdown: model.markdown,
          baseFontSize: baseFontSize,
          lineSpacing: CGFloat(lineSpacing),
          textColor: UIColor(palette.primaryText),
          backgroundColor: UIColor(palette.background),
          codeBackground: UIColor(palette.codeBackground),
          accentColor: UIColor(palette.accent),
          restoredOffsetY: model.restoredOffsetY,
          scrollRequest: scrollNavigator,
          onScrollRequestHandled: { scrollNavigator = nil },
          onScrollOffsetChange: { y in
            model.recordScroll(offsetY: y)
          }
        )
        .ignoresSafeArea(edges: .bottom)
      }
    }
    .background(palette.background)
    .navigationTitle(
      model.isLoading
        ? String(localized: "Loading…", comment: "Reader navigation title while chapter loads")
        : model.navigationTitle
    )
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        if let id = userGuideIdForEditor {
          Button {
            showEditor = true
          } label: {
            Label("Edit", systemImage: "square.and.pencil")
          }
        }
        if !model.isLoading, !model.headings.isEmpty {
          Button {
            showTOC = true
          } label: {
            Label("Table of contents", systemImage: "list.bullet")
          }
        }
        if !model.isLoading {
          Button {
            model.toggleBookmark(displayTitle: model.navigationTitle)
          } label: {
            Label(
              model.isBookmarked ? "Remove bookmark" : "Bookmark",
              systemImage: model.isBookmarked ? "bookmark.fill" : "bookmark"
            )
          }
        }
      }
    }
    .sheet(isPresented: $showTOC) {
      NavigationStack {
        List(model.headings) { heading in
          Button {
            scrollNonce += 1
            scrollNavigator = (scrollNonce, heading.title)
            showTOC = false
          } label: {
            Text(heading.title)
              .font(.body)
              .multilineTextAlignment(.leading)
              .padding(.leading, CGFloat(max(0, heading.level - 1)) * 12)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .listRowBackground(palette.secondaryBackground)
        }
        .listStyle(.insetGrouped)
        .readerScreenBackground()
        .navigationTitle("Contents")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Done") { showTOC = false }
          }
        }
      }
      .environment(\.readerPalette, palette)
      .readerNavigationChrome()
      .presentationDetents([.medium, .large])
    }
    .sheet(isPresented: $showEditor) {
      if let id = userGuideIdForEditor {
        NavigationStack {
          UserGuideEditorView(guideId: id) {
            model.reloadContent()
          }
        }
        .environment(\.readerPalette, palette)
        .readerNavigationChrome()
      }
    }
    .task(id: languageMode) {
      model.loadContent()
    }
    .onDisappear {
      model.flushProgress()
    }
    .readerNavigationChrome()
  }

  private var emptyTitle: String {
    model.isUserGuide
      ? String(localized: "Nothing here yet")
      : String(localized: "Couldn’t load chapter")
  }

  private var emptyDescription: String {
    model.isUserGuide
      ? String(localized: "Tap Edit to add Markdown, or write a title and body in My Guides.")
      : String(localized: "This file may be missing from the app bundle.")
  }
}

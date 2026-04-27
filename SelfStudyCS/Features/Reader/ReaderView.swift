//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import UIKit
import WebKit

struct ReaderView: View {
  let entry: CatalogEntry

  @AppStorage(ReaderAppStorageKey.fontScale) private var fontScale = ReaderPreferenceDefaults.fontScale
  @AppStorage(ReaderAppStorageKey.lineSpacing) private var lineSpacing = ReaderPreferenceDefaults.lineSpacing
  @AppStorage(ReaderAppStorageKey.theme) private var themeRaw = ReaderPreferenceDefaults.theme

  @Environment(\.colorScheme) private var colorScheme
  @State private var model: ReaderViewModel
  @State private var showTOC = false
  @State private var scrollNavigator: (token: Int, fragment: String)?
  @State private var scrollNonce = 0

  init(entry: CatalogEntry) {
    self.entry = entry
    _model = State(wrappedValue: ReaderViewModel(entry: entry))
  }

  private var resolvedTheme: ReaderTheme {
    ReaderTheme(rawValue: themeRaw) ?? .system
  }

  private var palette: ReaderPalette {
    ReaderPaletteResolver.palette(theme: resolvedTheme, colorScheme: colorScheme)
  }

  private var baseFontSize: CGFloat {
    CGFloat(17 * fontScale)
  }

  var body: some View {
    Group {
      if model.markdown.isEmpty {
        ContentUnavailableView(
          "Couldn’t load chapter",
          systemImage: "doc.text.magnifyingglass",
          description: Text("This file may be missing from the app bundle.")
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
    .navigationTitle(model.navigationTitle)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        if !model.headings.isEmpty {
          Button {
            showTOC = true
          } label: {
            Label("Table of contents", systemImage: "list.bullet")
          }
        }
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
        }
        .navigationTitle("Contents")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Done") { showTOC = false }
          }
        }
      }
      .presentationDetents([.medium, .large])
    }
    .task {
      model.loadContent()
    }
    .onDisappear {
      model.flushProgress()
    }
  }
}

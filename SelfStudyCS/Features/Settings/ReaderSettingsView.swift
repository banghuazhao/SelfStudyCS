//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct ReaderSettingsView: View {
  @AppStorage(ReaderAppStorageKey.fontScale) private var fontScale = ReaderPreferenceDefaults.fontScale
  @AppStorage(ReaderAppStorageKey.lineSpacing) private var lineSpacing = ReaderPreferenceDefaults.lineSpacing
  @AppStorage(ReaderAppStorageKey.theme) private var themeRaw = ReaderPreferenceDefaults.theme
  @AppStorage(ReaderAppStorageKey.languageMode) private var languageRaw = ReaderPreferenceDefaults.languageMode

  var body: some View {
    NavigationStack {
      Form {
        Section {
          VStack(alignment: .leading, spacing: 10) {
            HStack {
              Text("Text size")
                .font(.body.weight(.medium))
              Spacer()
              Text(String(format: "%.0f%%", fontScale * 100))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }
            Slider(value: $fontScale, in: 0.85...1.45, step: 0.05)
              .tint(.accentColor)
          }
          .padding(.vertical, 4)

          VStack(alignment: .leading, spacing: 10) {
            HStack {
              Text("Line spacing")
                .font(.body.weight(.medium))
              Spacer()
              Text(String(format: "%.2f×", lineSpacing))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }
            Slider(value: $lineSpacing, in: 1.05...1.6, step: 0.05)
          }
          .padding(.vertical, 4)
        } header: {
          Text("Reading comfort")
        } footer: {
          Text("Adjust typography to match how you like to read long technical chapters.")
        }

        Section {
          Picker("Appearance", selection: $themeRaw) {
            ForEach(ReaderTheme.allCases) { theme in
              Text(theme.title).tag(theme.rawValue)
            }
          }
          .pickerStyle(.navigationLink)

          Picker("Language", selection: $languageRaw) {
            ForEach(ContentLanguageMode.allCases) { mode in
              Text(mode.title).tag(mode.rawValue)
            }
          }
          .pickerStyle(.navigationLink)
        } header: {
          Text("Content")
        } footer: {
          Text(
            "English uses files ending in .en.md when available. Chinese uses the primary .md file. The library refreshes when language changes."
          )
        }

        Section {
          LabeledContent("Version", value: "1.0")
          LabeledContent("Content", value: String(localized: "CS Self-Learning (bundled)"))

          VStack(alignment: .leading, spacing: 10) {
            Text(
              String(
                localized:
                  "Course notes come from the open CS Self-Learning guide by PKUFlyingPig and contributors.",
                comment: "Attribution to original repository author"
              )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Link(
              String(localized: "CS Self-Learning on GitHub"),
              destination: URL(string: "https://github.com/PKUFlyingPig/cs-self-learning")!
            )
            .font(.subheadline)

            Link(
              String(localized: "Read online — csdiy.wiki"),
              destination: URL(string: "https://csdiy.wiki")!
            )
            .font(.subheadline)
          }
          .padding(.vertical, 4)
        } header: {
          Text("About")
        } footer: {
          Text(
            String(
              localized:
                "Use My guides to write notes stored on this device. The bundled “Course template” in the library is a reference for Markdown structure; to ship new pages inside the app, add files under Docs and rebuild.",
              comment: "Explains My guides vs bundled Template/Docs"
            )
          )
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

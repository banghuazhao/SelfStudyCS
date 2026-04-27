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
          LabeledContent("Content", value: "CS Self-Learning (bundled)")
        } header: {
          Text("About")
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

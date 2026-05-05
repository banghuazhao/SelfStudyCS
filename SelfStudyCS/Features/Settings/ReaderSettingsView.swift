//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import StoreKit

struct ReaderSettingsView: View {
  @AppStorage(ReaderAppStorageKey.fontScale) private var fontScale = ReaderPreferenceDefaults.fontScale
  @AppStorage(ReaderAppStorageKey.lineSpacing) private var lineSpacing = ReaderPreferenceDefaults.lineSpacing
  @AppStorage(ReaderAppStorageKey.theme) private var themeRaw = ReaderPreferenceDefaults.theme
  @AppStorage(ReaderAppStorageKey.languageMode) private var languageRaw = ReaderPreferenceDefaults.languageMode

  @Environment(\.readerPalette) private var palette
  @Environment(\.requestReview) private var requestReview

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
          NavigationLink {
            AppearanceSettingsView()
          } label: {
            HStack {
              Text("Appearance")
              Spacer()
              Text(ReaderTheme(rawValue: themeRaw)?.title ?? "—")
                .foregroundStyle(palette.secondaryText)
            }
          }
          .listRowBackground(palette.secondaryBackground)

          NavigationLink {
            ContentLanguageSettingsView(languageRaw: $languageRaw)
          } label: {
            HStack {
              Text("Language")
              Spacer()
              Text(
                ContentLanguageMode(rawValue: languageRaw)?.title ?? "—"
              )
              .foregroundStyle(palette.secondaryText)
            }
          }
          .listRowBackground(palette.secondaryBackground)
        } header: {
          Text("Content")
        } footer: {
          Text(
            "English uses files ending in .en.md when available. Chinese uses the primary .md file. The library refreshes when language changes."
          )
        }

        Section {
          Button {
            requestReview()
          } label: {
            Label(String(localized: "Rate on the App Store"), systemImage: "star.fill")
          }
          .listRowBackground(palette.secondaryBackground)

          ShareLink(
            item: AppDistributionLinks.appStoreListingURL,
            subject: Text("Self-Study CS"),
            message: Text(String(localized: "Help others discover this reader."))
          ) {
            Label(String(localized: "Share Self-Study CS"), systemImage: "square.and.arrow.up")
          }
          .listRowBackground(palette.secondaryBackground)

          NavigationLink {
            PrivacyPolicyView()
          } label: {
            Label(String(localized: "Privacy"), systemImage: "hand.raised.fill")
          }
          .listRowBackground(palette.secondaryBackground)
        } header: {
          Text(String(localized: "Support"))
        } footer: {
          Text(String(localized: "Love the app? A quick rating helps a lot."))
        }

        Section {
          LabeledContent(
            String(localized: "Version"),
            value: AppReleaseInfo.fullVersionLabel
          )
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

        TabScrollBanner.listBottomSection()
      }
      .readerScreenBackground()
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .readerNavigationChrome()
    }
    .background(palette.background)
  }
}

// MARK: - Language (custom stack; avoids `Picker(.navigationLink)` bar ignoring reader chrome)

private struct ContentLanguageSettingsView: View {
  @Binding var languageRaw: String

  @Environment(\.readerPalette) private var palette

  var body: some View {
    List {
      Section {
        ForEach(ContentLanguageMode.allCases) { mode in
          Button {
            languageRaw = mode.rawValue
          } label: {
            HStack {
              Text(mode.title)
                .foregroundStyle(palette.primaryText)
              Spacer()
              if mode.rawValue == languageRaw {
                Image(systemName: "checkmark")
                  .font(.body.weight(.semibold))
                  .foregroundStyle(palette.accent)
              }
            }
          }
          .buttonStyle(.plain)
          .listRowBackground(palette.secondaryBackground)
        }
      }
    }
    .listStyle(.insetGrouped)
    .readerScreenBackground()
    .navigationTitle("Language")
    .navigationBarTitleDisplayMode(.inline)
    .readerNavigationChrome()
  }
}

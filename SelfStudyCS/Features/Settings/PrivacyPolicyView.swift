//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct PrivacyPolicyView: View {
  @Environment(\.readerPalette) private var palette

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text(String(localized: "This app is designed for offline reading and your own notes.", comment: "Privacy intro"))
          .font(.body)

        Text(String(localized: "Data on your device", comment: "Privacy section title"))
          .font(.headline)
          .foregroundStyle(palette.primaryText)
        Text(
          String(
            localized:
              "Bookmarks, reading progress, reader settings, and My guides content are stored locally in a database on this device. They are not uploaded to our servers because this app does not provide its own cloud service.",
            comment: "Privacy local data explanation"
          )
        )
        .font(.subheadline)
        .foregroundStyle(palette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

        Text(String(localized: "Bundled course materials", comment: "Privacy section title"))
          .font(.headline)
          .foregroundStyle(palette.primaryText)
        Text(
          String(
            localized:
              "Chapter text ships inside the app from the open CS Self-Learning project. Opening links in Safari (for example from Settings) follows that website’s policies.",
            comment: "Privacy bundled content"
          )
        )
        .font(.subheadline)
        .foregroundStyle(palette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

        Text(String(localized: "Analytics and ads", comment: "Privacy section title"))
          .font(.headline)
          .foregroundStyle(palette.primaryText)
        Text(
          String(
            localized:
              "We do not run in-app advertising or cross-app tracking. Apple may collect standard App Store diagnostics according to your device settings.",
            comment: "Privacy analytics"
          )
        )
        .font(.subheadline)
        .foregroundStyle(palette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

        Link(String(localized: "Project & attribution"), destination: AppDistributionLinks.openSourceProjectURL)
          .font(.subheadline.weight(.medium))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(20)
    }
    .background(palette.background)
    .navigationTitle(String(localized: "Privacy"))
    .navigationBarTitleDisplayMode(.inline)
    .readerNavigationChrome()
  }
}

//
// Created by Banghua Zhao on 06/05/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

/// Banner block that sits **inside** a scrolling container (`List` / `Form` / `ScrollView`) so it moves with content instead of sticking above the tab bar.
enum TabScrollBanner {
  /// Use as the **last** section in a `List` or `Form`.
  @ViewBuilder
  static func listBottomSection() -> some View {
    if !AdConfiguration.bannerAdUnitID.isEmpty {
      Section {
        InlineAdaptiveBannerView(adUnitID: AdConfiguration.bannerAdUnitID)
          .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 16, trailing: 0))
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
      }
    }
  }
}

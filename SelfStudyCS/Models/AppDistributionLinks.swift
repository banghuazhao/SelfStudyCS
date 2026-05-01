//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

/// Replace `appStoreProductID` with your numeric App Store Connect ID before release.
enum AppDistributionLinks {
  static let appStoreProductID = "6765632695"

  /// Public App Store listing (for sharing). Update the product ID when the app is live.
  static var appStoreListingURL: URL {
    URL(string: "https://apps.apple.com/app/id\(appStoreProductID)")!
  }

  /// CS Self-Learning source project (attribution; also linked from Settings → About).
  static let openSourceProjectURL = URL(string: "https://github.com/PKUFlyingPig/cs-self-learning")!
}

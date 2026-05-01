//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

/// Central place for App Store–visible version strings (from Info.plist / build settings).
enum AppReleaseInfo {
  static var marketingVersion: String {
    (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
      .flatMap { $0.isEmpty ? nil : $0 } ?? "—"
  }

  static var buildNumber: String {
    (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
      .flatMap { $0.isEmpty ? nil : $0 } ?? "—"
  }

  /// Shown in Settings; matches what App Store Connect uses for display.
  static var fullVersionLabel: String {
    "\(marketingVersion) (\(buildNumber))"
  }
}

//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SwiftUI

/// Keys align with `@AppStorage` in SwiftUI (backed by `UserDefaults.standard`).
enum ReaderAppStorageKey {
  static let fontScale = "SelfStudyCS.reader.fontScale"
  static let lineSpacing = "SelfStudyCS.reader.lineSpacing"
  static let theme = "SelfStudyCS.reader.theme"
  static let languageMode = "SelfStudyCS.reader.languageMode"
}

enum ReaderPreferenceDefaults {
  static let fontScale: Double = 1.0
  static let lineSpacing: Double = 1.25
  static let theme: String = ReaderTheme.system.rawValue
  static let languageMode: String = ContentLanguageMode.english.rawValue

  static func register() {
    UserDefaults.standard.register(defaults: [
      ReaderAppStorageKey.fontScale: fontScale,
      ReaderAppStorageKey.lineSpacing: lineSpacing,
      ReaderAppStorageKey.theme: theme,
      ReaderAppStorageKey.languageMode: languageMode,
    ])
  }

  static var contentLanguageMode: ContentLanguageMode {
    let raw =
      UserDefaults.standard.string(forKey: ReaderAppStorageKey.languageMode)
      ?? ContentLanguageMode.english.rawValue
    return ContentLanguageMode(rawValue: raw) ?? .english
  }
}

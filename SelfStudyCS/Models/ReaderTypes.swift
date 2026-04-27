//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

enum ReaderTheme: String, CaseIterable, Identifiable, Sendable {
  case system
  case light
  case dark
  case sepia

  var id: String { rawValue }

  var title: String {
    switch self {
    case .system: String(localized: "Match System")
    case .light: String(localized: "Light")
    case .dark: String(localized: "Dark")
    case .sepia: String(localized: "Sepia")
    }
  }
}

enum ContentLanguageMode: String, CaseIterable, Identifiable, Sendable {
  case english
  case chinese
  case system

  var id: String { rawValue }

  var title: String {
    switch self {
    case .english: String(localized: "English")
    case .chinese: String(localized: "Chinese")
    case .system: String(localized: "Match System")
    }
  }

  func resolvesToEnglish(locale: Locale = .current) -> Bool {
    switch self {
    case .english:
      return true
    case .chinese:
      return false
    case .system:
      guard let code = locale.language.languageCode?.identifier else { return true }
      return !code.hasPrefix("zh")
    }
  }
}

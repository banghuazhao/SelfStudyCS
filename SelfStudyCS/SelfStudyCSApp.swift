//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

@main
struct SelfStudyCSApp: App {
  init() {
    ReaderPreferenceDefaults.register()
    prepareDependencies {
      $0.defaultDatabase = try! AppDatabase.makeWriter()
    }
  }

  var body: some Scene {
    WindowGroup {
      RootTabView()
    }
  }
}

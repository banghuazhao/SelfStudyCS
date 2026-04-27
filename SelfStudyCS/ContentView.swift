//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

struct ContentView: View {
  var body: some View {
    RootTabView()
  }
}

#Preview {
  let _ = ReaderPreferenceDefaults.register()
  let _ = prepareDependencies {
    $0.defaultDatabase = try! AppDatabase.makeWriter()
  }
  ContentView()
}

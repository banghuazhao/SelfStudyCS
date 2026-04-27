//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct UserGuideEditorView: View {
  let guideId: Int?
  var onSaved: () -> Void

  @Environment(\.dismiss) private var dismiss
  @State private var model: UserGuideEditorViewModel

  init(guideId: Int?, onSaved: @escaping () -> Void = {}) {
    self.guideId = guideId
    self.onSaved = onSaved
    _model = State(wrappedValue: UserGuideEditorViewModel(guideId: guideId))
  }

  var body: some View {
    Form {
      Section {
        TextField(String(localized: "Title"), text: $model.title)
      }

      Section {
        TextEditor(text: $model.markdownBody)
          .frame(minHeight: 240)
      } header: {
        Text("Markdown")
      }
    }
    .navigationTitle(
      guideId == nil
        ? String(localized: "New guide")
        : String(localized: "Edit guide")
    )
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(String(localized: "Cancel")) { dismiss() }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(String(localized: "Save")) {
          do {
            try model.save()
            onSaved()
            dismiss()
          } catch {
            #if DEBUG
              print("Save guide failed: \(error)")
            #endif
          }
        }
      }
    }
    .task {
      model.loadIfNeeded()
    }
  }
}

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
    @Bindable var vm = model

    return Form {
      Section {
        TextField(String(localized: "Course code", comment: "e.g. CS162"), text: $vm.draft.courseCode)
          .textInputAutocapitalization(.characters)
        TextField(String(localized: "Course name", comment: "e.g. Operating systems"), text: $vm.draft.courseName)
      } header: {
        Text("Course", comment: "User guide template section")
      } footer: {
        Text(
          String(
            localized: "Together these become the top heading: # Code: Name",
            comment: "Footer for course identity fields"
          )
        )
      }

      Section {
        TextField(String(localized: "Offered by", comment: "Optional field label"), text: $vm.draft.offeredBy)
        TextField(String(localized: "Prerequisites", comment: "Optional field label"), text: $vm.draft.prerequisites)
        TextField(
          String(localized: "Programming languages", comment: "Optional field label"),
          text: $vm.draft.programmingLanguages
        )
        Stepper(value: $vm.draft.difficultyStars, in: 1...5) {
          HStack {
            Text(String(localized: "Difficulty", comment: "Star difficulty"))
            Spacer()
            Text(String(repeating: "🌟", count: vm.draft.difficultyStars))
              .accessibilityLabel(
                String(localized: "Difficulty", comment: "A11y difficulty")
                + " \(vm.draft.difficultyStars)/5"
              )
          }
        }
        TextField(String(localized: "Class hour", comment: "Optional field label"), text: $vm.draft.classHour)
      } header: {
        Text("Descriptions", comment: "User guide template section")
      } footer: {
        Text(
          String(
            localized: "All fields in this section are optional. Leave blank to show an empty bullet in the guide.",
            comment: "Descriptions section footer"
          )
        )
      }

      Section {
        TextEditor(text: $vm.draft.descriptionProse)
          .frame(minHeight: 120)
      } header: {
        Text("Introduction", comment: "Prose under Descriptions")
      } footer: {
        Text(
          String(
            localized:
              "Optional: your overview replaces the HTML comment block from the template. Leave empty to keep the comment placeholder in the saved Markdown.",
            comment: "Introduction footer"
          )
        )
      }

      Section {
        TextField(String(localized: "Course website", comment: "Optional URL or text"), text: $vm.draft.courseWebsite)
        TextField(String(localized: "Recordings", comment: "Optional field label"), text: $vm.draft.recordings)
        TextField(String(localized: "Textbooks", comment: "Optional field label"), text: $vm.draft.textbooks)
        TextField(String(localized: "Assignments", comment: "Optional field label"), text: $vm.draft.assignments)
      } header: {
        Text("Course resources", comment: "User guide template section")
      } footer: {
        Text(
          String(
            localized: "Optional fields for links or notes about course materials.",
            comment: "Course resources footer"
          )
        )
      }

      Section {
        TextEditor(text: $vm.draft.personalResourcesMarkdown)
          .frame(minHeight: 84)
      } header: {
        Text("Personal resources", comment: "User guide template section")
      } footer: {
        Text(
          String(
            localized:
              "Optional. Leave empty to use the template line with @XXX and a GitHub link placeholder.",
            comment: "Personal resources footer"
          )
        )
      }
    }
    .readerScreenBackground()
    .navigationTitle(
      guideId == nil
        ? String(localized: "New course", comment: "New user guide editor title")
        : String(localized: "Edit course", comment: "Edit user guide editor title")
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

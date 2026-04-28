//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import SQLiteData

@Observable @MainActor
final class EditableGuideTemplate {
  var courseCode = ""
  var courseName = ""
  var offeredBy = ""
  var prerequisites = ""
  var programmingLanguages = ""
  var difficultyStars = 3
  var classHour = ""
  var descriptionProse = ""
  var courseWebsite = ""
  var recordings = ""
  var textbooks = ""
  var assignments = ""
  var personalResourcesMarkdown = ""

  static func from(_ form: GuideCourseTemplateForm) -> EditableGuideTemplate {
    let e = EditableGuideTemplate()
    e.courseCode = form.courseCode
    e.courseName = form.courseName
    e.offeredBy = form.offeredBy
    e.prerequisites = form.prerequisites
    e.programmingLanguages = form.programmingLanguages
    e.difficultyStars = form.difficultyStars
    e.classHour = form.classHour
    e.descriptionProse = form.descriptionProse
    e.courseWebsite = form.courseWebsite
    e.recordings = form.recordings
    e.textbooks = form.textbooks
    e.assignments = form.assignments
    e.personalResourcesMarkdown = form.personalResourcesMarkdown
    return e
  }

  func toForm() -> GuideCourseTemplateForm {
    var f = GuideCourseTemplateForm()
    f.courseCode = courseCode
    f.courseName = courseName
    f.offeredBy = offeredBy
    f.prerequisites = prerequisites
    f.programmingLanguages = programmingLanguages
    f.difficultyStars = difficultyStars
    f.classHour = classHour
    f.descriptionProse = descriptionProse
    f.courseWebsite = courseWebsite
    f.recordings = recordings
    f.textbooks = textbooks
    f.assignments = assignments
    f.personalResourcesMarkdown = personalResourcesMarkdown
    f.normalizeDifficulty()
    return f
  }
}

@Observable @MainActor
final class UserGuideEditorViewModel {
  var draft = EditableGuideTemplate()
  private let guideId: Int?

  @ObservationIgnored
  @Dependency(\.defaultDatabase) private var database

  init(guideId: Int?) {
    self.guideId = guideId
  }

  func loadIfNeeded() {
    guard let guideId else {
      draft = EditableGuideTemplate()
      return
    }
    do {
      try database.read { db in
        guard let g = try UserGuideRecord.where { $0.id.eq(guideId) }.fetchOne(db) else {
          return
        }
        let trimmedPayload = g.templatePayload.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPayload.isEmpty {
          if g.markdownBody.contains("## Descriptions") {
            let imported = GuideCourseTemplateImporter.form(
              fromMarkdown: g.markdownBody,
              fallbackTitle: g.title
            )
            draft = EditableGuideTemplate.from(imported)
          } else {
            var fresh = GuideCourseTemplateForm()
            fresh.courseName = g.title
            fresh.descriptionProse = g.markdownBody.trimmingCharacters(in: .whitespacesAndNewlines)
            draft = EditableGuideTemplate.from(fresh)
          }
        } else if let form = try? GuideCourseTemplateForm.decode(from: trimmedPayload) {
          draft = EditableGuideTemplate.from(form)
        } else {
          draft = EditableGuideTemplate()
        }
      }
    } catch {
      #if DEBUG
        print("Load guide for edit failed: \(error)")
      #endif
    }
  }

  func save() throws {
    let form = draft.toForm()
    let json = try form.encodeToJSONString()
    let markdown = form.renderMarkdown()
    let listTitle = form.displayListTitle
    let now = Date()
    try database.write { db in
      if let guideId {
        guard var row = try UserGuideRecord.where { $0.id.eq(guideId) }.fetchOne(db) else { return }
        row.title = listTitle
        row.markdownBody = markdown
        row.templatePayload = json
        row.updatedAt = now
        try UserGuideRecord.update(row).execute(db)
      } else {
        try UserGuideRecord.insert {
          UserGuideRecord.Draft(
            title: listTitle,
            markdownBody: markdown,
            templatePayload: json,
            createdAt: now,
            updatedAt: now
          )
        }
        .execute(db)
      }
    }
  }
}

//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

/// Best-effort fill of `GuideCourseTemplateForm` from Markdown saved before structured storage existed.
enum GuideCourseTemplateImporter {
  static func form(fromMarkdown markdown: String, fallbackTitle: String) -> GuideCourseTemplateForm {
    var form = GuideCourseTemplateForm()
    let lines = markdown.components(separatedBy: "\n")
    var inResources = false
    var inPersonal = false

    for line in lines {
      let t = line.trimmingCharacters(in: .whitespaces)

      if t.hasPrefix("# ") {
        let rest = String(t.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        if let colon = rest.firstIndex(of: ":") {
          form.courseCode = String(rest[..<colon]).trimmingCharacters(in: .whitespaces)
          form.courseName = String(rest[rest.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
        } else {
          form.courseName = rest
        }
        continue
      }

      if t == "## Descriptions" { inResources = false; inPersonal = false; continue }
      if t == "## Course Resources" { inResources = true; inPersonal = false; continue }
      if t == "## Personal Resources" { inResources = false; inPersonal = true; continue }

      if inPersonal {
        if !t.isEmpty {
          form.personalResourcesMarkdown +=
            (form.personalResourcesMarkdown.isEmpty ? "" : "\n") + line
        }
        continue
      }

      if inResources {
        if let v = bulletValue(t, label: "Course Website") { form.courseWebsite = v; continue }
        if let v = bulletValue(t, label: "Recordings") { form.recordings = v; continue }
        if let v = bulletValue(t, label: "Textbooks") { form.textbooks = v; continue }
        if let v = bulletValue(t, label: "Assignments") { form.assignments = v; continue }
        continue
      }

      if let v = bulletValue(t, label: "Offered by") { form.offeredBy = v; continue }
      if let v = bulletValue(t, label: "Prerequisites") { form.prerequisites = v; continue }
      if let v = bulletValue(t, label: "Programming Languages") { form.programmingLanguages = v; continue }
      if let v = difficultyStars(from: t) { form.difficultyStars = v; continue }
      if let v = bulletValue(t, label: "Class Hour") { form.classHour = v; continue }
    }

    if form.courseName.isEmpty, form.courseCode.isEmpty {
      form.courseName = fallbackTitle
    }

    return form
  }

  private static func bulletValue(_ line: String, label: String) -> String? {
    let prefix = "- \(label):"
    let prefixBold = "- **\(label)**:"
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    if trimmed.hasPrefix(prefix) {
      return String(trimmed.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
    }
    if trimmed.hasPrefix(prefixBold) {
      return String(trimmed.dropFirst(prefixBold.count)).trimmingCharacters(in: .whitespaces)
    }
    return nil
  }

  private static func difficultyStars(from line: String) -> Int? {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    guard trimmed.hasPrefix("- Difficulty:") || trimmed.hasPrefix("- **Difficulty**:") else { return nil }
    let count = trimmed.filter { $0 == "🌟" }.count
    return count > 0 ? min(5, max(1, count)) : nil
  }
}

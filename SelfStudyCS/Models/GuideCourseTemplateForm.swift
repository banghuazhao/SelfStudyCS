//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

/// Form data for the bundled English course outline (CS Self-Learning style). Serialized to JSON in `user_guides.templatePayload` and rendered to Markdown for the reader.
struct GuideCourseTemplateForm: Codable, Equatable, Sendable {
  var courseCode: String = ""
  var courseName: String = ""

  var offeredBy: String = ""
  var prerequisites: String = ""
  var programmingLanguages: String = ""
  /// 1...5 maps to 🌟 repeats.
  var difficultyStars: Int = 3
  var classHour: String = ""

  /// Freeform prose under **Descriptions** (replaces the HTML comment block when non-empty).
  var descriptionProse: String = ""

  var courseWebsite: String = ""
  var recordings: String = ""
  var textbooks: String = ""
  var assignments: String = ""

  /// Body of **Personal Resources** (single paragraph / markdown line).
  var personalResourcesMarkdown: String = ""

  var displayListTitle: String {
    let code = courseCode.trimmingCharacters(in: .whitespacesAndNewlines)
    let name = courseName.trimmingCharacters(in: .whitespacesAndNewlines)
    if !code.isEmpty, !name.isEmpty { return "\(code): \(name)" }
    if !name.isEmpty { return name }
    if !code.isEmpty { return code }
    return String(localized: "Untitled", comment: "User guide list title when empty")
  }

  mutating func normalizeDifficulty() {
    difficultyStars = min(5, max(1, difficultyStars))
  }

  func encodeToJSONString() throws -> String {
    var copy = self
    copy.normalizeDifficulty()
    let data = try JSONEncoder().encode(copy)
    return String(data: data, encoding: .utf8) ?? "{}"
  }

  static func decode(from json: String) throws -> GuideCourseTemplateForm {
    guard let data = json.data(using: .utf8), !json.isEmpty else { return GuideCourseTemplateForm() }
    var form = try JSONDecoder().decode(GuideCourseTemplateForm.self, from: data)
    form.normalizeDifficulty()
    return form
  }

  /// Renders the canonical Markdown document for the reader and bookmarks.
  func renderMarkdown() -> String {
    var copy = self
    copy.normalizeDifficulty()
    let stars = String(repeating: "🌟", count: copy.difficultyStars)

    let code = copy.courseCode.trimmingCharacters(in: .whitespacesAndNewlines)
    let name = copy.courseName.trimmingCharacters(in: .whitespacesAndNewlines)
    let heading: String
    if code.isEmpty, name.isEmpty {
      heading = "# Course Code: Course Name"
    } else if code.isEmpty {
      heading = "# \(name)"
    } else if name.isEmpty {
      heading = "# \(code)"
    } else {
      heading = "# \(code): \(name)"
    }

    let prose = copy.descriptionProse.trimmingCharacters(in: .whitespacesAndNewlines)
    let commentBlock = """
    <!--
            Introduce the course in a paragraph or two, including but not limited to:
            (1) The technical knowledge covered in lectures
            (2) Its differences and features compared to similar courses
            (3) Your personal experiences and feelings after studying this course
            (4) Caveats about studying this course on your own (pitfalls, difficulty warnings, etc.)
            (5) ... ...
    -->
    """

    let personal = copy.personalResourcesMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)
    let personalSection =
      personal.isEmpty
      ? "All the resources and assignments used by @XXX in this course are maintained in [user/repo - GitHub](https://github.com/user/repo)."
      : personal

    func bullet(_ label: String, _ value: String) -> String {
      "- \(label): \(value)"
    }

    var parts: [String] = []
    parts.append(heading)
    parts.append("")
    parts.append("## Descriptions")
    parts.append("")
    parts.append(bullet("Offered by", copy.offeredBy))
    parts.append(bullet("Prerequisites", copy.prerequisites))
    parts.append(bullet("Programming Languages", copy.programmingLanguages))
    parts.append(bullet("Difficulty", stars))
    parts.append(bullet("Class Hour", copy.classHour))
    parts.append("")
    if prose.isEmpty {
      parts.append(commentBlock)
    } else {
      parts.append(prose)
    }
    parts.append("")
    parts.append("## Course Resources")
    parts.append("")
    parts.append(bullet("Course Website", copy.courseWebsite))
    parts.append(bullet("Recordings", copy.recordings))
    parts.append(bullet("Textbooks", copy.textbooks))
    parts.append(bullet("Assignments", copy.assignments))
    parts.append("")
    parts.append("## Personal Resources")
    parts.append("")
    parts.append(personalSection)
    parts.append("")
    return parts.joined(separator: "\n")
  }
}
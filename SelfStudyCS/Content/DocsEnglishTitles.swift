//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

/// Display names for bundled `Docs` paths. Folder names on disk stay Chinese; the UI can show English when that is the app default.
enum DocsEnglishTitles {
  nonisolated static let rootOverviewSectionTitle = "Overview"

  /// On-disk folder name for bundled markdown templates (must match `BundledDocsLocator`).
  private static let bundledTemplateFolderName = "Template"

  private static let chineseFolderToEnglish: [String: String] = [
    "人工智能": "Artificial Intelligence",
    "体系结构": "Computer Architecture",
    "并行与分布式系统": "Parallel & Distributed Systems",
    "必学工具": "Essential Tools",
    "操作系统": "Operating Systems",
    "数学基础": "Mathematical Foundations",
    "数学进阶": "Advanced Mathematics",
    "数据库系统": "Database Systems",
    "数据科学": "Data Science",
    "数据结构与算法": "Data Structures & Algorithms",
    "机器学习": "Machine Learning",
    "机器学习系统": "Machine Learning Systems",
    "机器学习进阶": "Advanced Machine Learning",
    "深度学习": "Deep Learning",
    "深度生成模型": "Deep Generative Models",
    "电子基础": "Electronics Fundamentals",
    "系统安全": "Systems Security",
    "编程入门": "Programming",
    "编程语言设计与分析": "Programming Languages",
    "编译原理": "Compilers",
    "计算机图形学": "Computer Graphics",
    "计算机系统基础": "Computer Systems",
    "计算机网络": "Computer Networks",
    "软件工程": "Software Engineering",
    "Web开发": "Web Development",
  ]

  /// Chinese titles for root-level `.md` files (stem without `.md` / `.en`).
  private static let rootMarkdownStemToEnglish: [String: String] = [
    "CS学习规划": "CS Study Plan",
    "使用指南": "User Guide",
    "后记": "Afterword",
    "好书推荐": "Recommended Books",
  ]

  static func folderDisplayName(_ folderComponent: String, prefersEnglish: Bool) -> String {
    if folderComponent == bundledTemplateFolderName {
      return prefersEnglish
        ? String(localized: "Course template", comment: "Library section for writing templates")
        : String(localized: "课程模板", comment: "Library section for writing templates")
    }
    guard prefersEnglish else { return folderComponent }
    return chineseFolderToEnglish[folderComponent] ?? folderComponent
  }

  static func chapterDisplayTitle(
    fileStem: String,
    relativePath: String,
    prefersEnglish: Bool
  ) -> String {
    let parent = (relativePath as NSString).deletingLastPathComponent
    if parent == bundledTemplateFolderName, fileStem == "template" {
      return prefersEnglish
        ? String(localized: "Sample course entry", comment: "Template doc title in library")
        : String(localized: "课程条目示例", comment: "Template doc title in library")
    }

    let spaced = fileStem.replacingOccurrences(of: "_", with: " ")
    guard prefersEnglish else { return spaced }
    guard parent.isEmpty else { return spaced }
    return rootMarkdownStemToEnglish[fileStem] ?? spaced
  }
}

//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import XCTest

final class ScreenshotUITests: XCTestCase {
  var app: XCUIApplication!

  private func firstLibraryRow(matching ids: [String]) -> XCUIElement? {
    for id in ids {
      let el = app.descendants(matching: .any).matching(identifier: id).firstMatch
      if el.waitForExistence(timeout: 3) { return el }
    }
    return nil
  }

  /// iPhone uses a bottom tab bar; iPad `TabView` often uses a leading sidebar with no `tabBar` in the hierarchy.
  private func waitForLibraryScreen() {
    XCTAssertTrue(
      app.navigationBars["Library"].waitForExistence(timeout: 20),
      "Library should be the initial tab"
    )
  }

  private func selectMainTab(_ title: String) {
    let fromTabBar = app.tabBars.buttons[title]
    if fromTabBar.waitForExistence(timeout: 2.5) {
      fromTabBar.tap()
      return
    }

    for splitIdx in 0 ..< min(app.splitGroups.count, 3) {
      let split = app.splitGroups.element(boundBy: splitIdx)
      let btn = split.buttons[title]
      if btn.waitForExistence(timeout: 1) {
        btn.tap()
        return
      }
      let cell = split.cells.containing(NSPredicate(format: "label == %@", title)).firstMatch
      if cell.waitForExistence(timeout: 1) {
        cell.tap()
        return
      }
    }

    let outlineBtn = app.outlines.buttons[title].firstMatch
    if outlineBtn.waitForExistence(timeout: 2) {
      outlineBtn.tap()
      return
    }

    let generic = app.buttons[title]
    XCTAssertTrue(generic.firstMatch.waitForExistence(timeout: 8), "Could not find tab \(title)")
    generic.firstMatch.tap()
  }

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
    app.launch()
  }

  /// iPhone 6.7″ class — export with `scripts/export_app_store_screenshots.sh`.
  func testAppStoreScreenshots() throws {
    try runAppStoreScreenshotFlow()
  }

  /// iPad Pro 13″ — export with `scripts/export_app_store_screenshots_ipad.sh`.
  func testAppStoreScreenshots_iPad() throws {
    try runAppStoreScreenshotFlow()
  }

  private func runAppStoreScreenshotFlow() throws {
    waitForLibraryScreen()
    let libraryBar = app.navigationBars["Library"]
    attachScreenshot(named: "01-Library")

    let sampleChapterIds = [
      "library.row.数学进阶.6.042J.en.md",
      "library.row.数学进阶.6.042J.md",
    ]
    var chapterRow = firstLibraryRow(matching: sampleChapterIds)
    if chapterRow == nil {
      let search = app.searchFields.firstMatch
      XCTAssertTrue(search.waitForExistence(timeout: 5))
      search.tap()
      search.typeText("6.042J")
      chapterRow = firstLibraryRow(matching: sampleChapterIds)
    }
    XCTAssertNotNil(chapterRow, "Expected MIT 6.042J in catalog")
    chapterRow!.tap()

    let leftLibrary = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "exists == false"),
      object: libraryBar
    )
    let navWait = XCTWaiter.wait(for: [leftLibrary], timeout: 20)
    XCTAssertEqual(navWait, .completed, "Should open a chapter from Library")

    let bookmarkQuery = app.descendants(matching: .any).matching(identifier: "ReaderToolbar.bookmark")
    XCTAssertTrue(bookmarkQuery.firstMatch.waitForExistence(timeout: 45))
    attachScreenshot(named: "02-Reader")

    let tocButton = app.descendants(matching: .any).matching(identifier: "ReaderToolbar.tableOfContents").firstMatch
    if tocButton.waitForExistence(timeout: 5) {
      tocButton.tap()
      XCTAssertTrue(app.navigationBars["Contents"].waitForExistence(timeout: 8))
      attachScreenshot(named: "03-TableOfContents")
      app.buttons["Done"].tap()
    }

    selectMainTab("Bookmarks")
    XCTAssertTrue(app.navigationBars["Bookmarks"].waitForExistence(timeout: 8))
    attachScreenshot(named: "04-Bookmarks")

    selectMainTab("My guides")
    XCTAssertTrue(app.navigationBars["My guides"].waitForExistence(timeout: 8))
    attachScreenshot(named: "05-MyGuides")

    selectMainTab("Settings")
    XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 8))
    attachScreenshot(named: "06-Settings")
  }

  private func attachScreenshot(named name: String) {
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}

//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//
// WKWebView-based markdown renderer.
// Replaces the old UITextView + AttributedString approach, which didn't correctly
// render list items, heading spacing, or block-level paragraph breaks.
//

import Foundation
import SwiftUI
import UIKit
import WebKit

struct MarkdownTextView: UIViewRepresentable {
  var markdown: String
  var baseFontSize: CGFloat
  var lineSpacing: CGFloat
  var textColor: UIColor
  var backgroundColor: UIColor
  var codeBackground: UIColor
  var accentColor: UIColor
  var restoredOffsetY: CGFloat
  var scrollRequest: (token: Int, fragment: String)?
  var onScrollRequestHandled: () -> Void
  var onScrollOffsetChange: (CGFloat) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(onScrollOffsetChange: onScrollOffsetChange)
  }

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    config.userContentController.add(context.coordinator, name: "scrollChanged")

    let webView = WKWebView(frame: .zero, configuration: config)
    webView.isOpaque = false
    webView.scrollView.contentInsetAdjustmentBehavior = .automatic
    webView.navigationDelegate = context.coordinator
    context.coordinator.webView = webView

    loadPage(into: webView, coordinator: context.coordinator)
    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {
    let coord = context.coordinator
    coord.onScrollOffsetChange = onScrollOffsetChange
    coord.pendingOffsetY = restoredOffsetY

    if coord.lastMarkdown != markdown {
      coord.lastMarkdown = markdown
      coord.didRestoreScroll = false
      coord.handledScrollToken = -1
      loadPage(into: webView, coordinator: coord)
      return
    }

    // Style-only update: inject JS rather than reloading
    let sk = styleKey
    if coord.lastStyleKey != sk {
      coord.lastStyleKey = sk
      let js = """
        if(window.updateStyle){
          window.updateStyle(
            '\(backgroundColor.cssHex())',
            '\(textColor.cssHex())',
            '\(accentColor.cssHex())',
            '\(codeBackground.cssHex())',
            \(Int(baseFontSize)),
            \(String(format: "%.2f", lineSpacing))
          );
        }
        """
      webView.evaluateJavaScript(js, completionHandler: nil)
    }

    // TOC fragment scroll
    if let req = scrollRequest, !req.fragment.isEmpty,
      coord.handledScrollToken != req.token
    {
      coord.handledScrollToken = req.token
      let escaped = req.fragment
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "'", with: "\\'")
      webView.evaluateJavaScript("window.scrollToFragment('\(escaped)');", completionHandler: nil)
      DispatchQueue.main.async { onScrollRequestHandled() }
    }
  }

  static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
    webView.configuration.userContentController.removeScriptMessageHandler(forName: "scrollChanged")
  }

  // MARK: - Private helpers

  private func loadPage(into webView: WKWebView, coordinator: Coordinator) {
    coordinator.lastStyleKey = styleKey
    let html = MarkdownHTMLConverter.buildPage(
      markdown: markdown,
      bgColor: backgroundColor.cssHex(),
      textColor: textColor.cssHex(),
      linkColor: accentColor.cssHex(),
      codeBgColor: codeBackground.cssHex(),
      fontSize: baseFontSize,
      lineSpacing: lineSpacing
    )
    webView.loadHTMLString(html, baseURL: nil)
  }

  private var styleKey: String {
    "\(backgroundColor.cssHex())\(textColor.cssHex())\(accentColor.cssHex())\(codeBackground.cssHex())\(Int(baseFontSize))\(String(format: "%.2f", lineSpacing))"
  }

  // MARK: - Coordinator

  final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    var lastMarkdown = ""
    var lastStyleKey = ""
    var didRestoreScroll = false
    var handledScrollToken = -1
    var pendingOffsetY: CGFloat = 0
    var onScrollOffsetChange: (CGFloat) -> Void
    weak var webView: WKWebView?

    init(onScrollOffsetChange: @escaping (CGFloat) -> Void) {
      self.onScrollOffsetChange = onScrollOffsetChange
    }

    func userContentController(
      _ userContentController: WKUserContentController,
      didReceive message: WKScriptMessage
    ) {
      if message.name == "scrollChanged", let y = message.body as? Double {
        onScrollOffsetChange(CGFloat(y))
      }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      guard !didRestoreScroll else { return }
      didRestoreScroll = true
      let y = pendingOffsetY
      guard y > 1 else { return }
      webView.evaluateJavaScript("window.scrollTo(0, \(y));", completionHandler: nil)
    }
  }
}

// MARK: - UIColor → CSS hex

private extension UIColor {
  func cssHex() -> String {
    let resolved = resolvedColor(with: UITraitCollection.current)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
    func c(_ v: CGFloat) -> Int { Int(min(max(v, 0), 1) * 255 + 0.5) }
    return String(format: "#%02X%02X%02X", c(r), c(g), c(b))
  }
}

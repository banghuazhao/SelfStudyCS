//
// Created by Banghua Zhao on 27/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//
// Converts a subset of CommonMark/GFM to an HTML page suitable for WKWebView.
// Handles: ATX/setext headings, fenced code, bullet/ordered lists, blockquotes,
//          tables, paragraphs, HRs, and inline bold/italic/code/link/image.
//

import Foundation

enum MarkdownHTMLConverter {

  // MARK: - Public entry point

  /// Builds a complete, self-contained HTML page from markdown.
  static func buildPage(
    markdown: String,
    bgColor: String,
    textColor: String,
    linkColor: String,
    codeBgColor: String,
    fontSize: CGFloat,
    lineSpacing: CGFloat
  ) -> String {
    let body = htmlBody(from: markdown)
    return """
      <!DOCTYPE html>
      <html>
      <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
      <style>
      \(css(bgColor: bgColor, textColor: textColor, linkColor: linkColor, codeBgColor: codeBgColor, fontSize: fontSize, lineSpacing: lineSpacing))
      </style>
      </head>
      <body>
      \(body)
      </body>
      <script>
      (function(){
        window.addEventListener('scroll',function(){
          window.webkit.messageHandlers.scrollChanged.postMessage(window.scrollY);
        },{passive:true});

        window.scrollToFragment = function(text) {
          var els = document.querySelectorAll('h1,h2,h3,h4,h5,h6');
          for (var i=0;i<els.length;i++){
            if(els[i].textContent.indexOf(text) !== -1){
              els[i].scrollIntoView({behavior:'instant',block:'start'});
              return;
            }
          }
        };

        window.updateStyle = function(bg, text, link, codeBg, fontSize, lineSpacing) {
          var r = document.documentElement;
          r.style.setProperty('--bg-color', bg);
          r.style.setProperty('--text-color', text);
          r.style.setProperty('--link-color', link);
          r.style.setProperty('--code-bg', codeBg);
          r.style.setProperty('--font-size', fontSize + 'px');
          r.style.setProperty('--line-spacing', lineSpacing);
          document.body.style.backgroundColor = bg;
          document.documentElement.style.backgroundColor = bg;
        };
      })();
      </script>
      </html>
      """
  }

  // MARK: - CSS

  private static func css(
    bgColor: String, textColor: String, linkColor: String,
    codeBgColor: String, fontSize: CGFloat, lineSpacing: CGFloat
  ) -> String {
    """
    :root {
      --bg-color: \(bgColor);
      --text-color: \(textColor);
      --link-color: \(linkColor);
      --code-bg: \(codeBgColor);
      --font-size: \(Int(fontSize))px;
      --line-spacing: \(String(format: "%.2f", lineSpacing));
    }
    * { box-sizing: border-box; }
    html {
      font-size: var(--font-size);
      background-color: var(--bg-color);
    }
    body {
      background-color: var(--bg-color);
      color: var(--text-color);
      font-family: -apple-system, BlinkMacSystemFont, 'San Francisco', 'Helvetica Neue', sans-serif;
      font-size: 1rem;
      line-height: var(--line-spacing);
      padding: 16px 16px 80px 16px;
      margin: 0;
      word-wrap: break-word;
      overflow-wrap: break-word;
      -webkit-text-size-adjust: none;
    }
    h1 { font-size: 1.75em; margin: 1.3em 0 0.5em; }
    h2 { font-size: 1.4em; margin: 1.2em 0 0.4em; border-bottom: 1px solid rgba(128,128,128,0.2); padding-bottom: 0.25em; }
    h3 { font-size: 1.15em; margin: 1em 0 0.35em; }
    h4, h5, h6 { font-size: 1em; margin: 0.9em 0 0.3em; }
    h1:first-child, h2:first-child, h3:first-child { margin-top: 0.3em; }
    p { margin: 0.75em 0; }
    ul, ol { padding-left: 1.6em; margin: 0.6em 0; }
    li { margin: 0.3em 0; }
    pre {
      background-color: var(--code-bg);
      padding: 1em;
      border-radius: 6px;
      overflow-x: auto;
      margin: 0.8em 0;
      font-size: 0.85em;
    }
    code { font-family: 'Menlo', 'Courier New', monospace; }
    pre code { background: none; padding: 0; font-size: inherit; }
    :not(pre) > code {
      background-color: var(--code-bg);
      padding: 0.15em 0.4em;
      border-radius: 3px;
      font-size: 0.88em;
    }
    blockquote {
      border-left: 3px solid rgba(128,128,128,0.4);
      margin: 0.8em 0;
      padding: 0.4em 0 0.4em 1em;
      opacity: 0.8;
      font-style: italic;
    }
    blockquote p { margin: 0; }
    .table-wrap { overflow-x: auto; margin: 0.8em 0; }
    table { border-collapse: collapse; min-width: 100%; }
    th, td { border: 1px solid rgba(128,128,128,0.3); padding: 0.45em 0.7em; text-align: left; }
    th { background-color: rgba(128,128,128,0.1); font-weight: 600; }
    a { color: var(--link-color); text-decoration: none; }
    a:hover { text-decoration: underline; }
    hr { border: none; border-top: 1px solid rgba(128,128,128,0.25); margin: 1.5em 0; }
    img { max-width: 100%; height: auto; border-radius: 4px; }
    strong { font-weight: 600; }
    """
  }

  // MARK: - Block types

  private indirect enum Block {
    case heading(level: Int, html: String)
    case paragraph(html: String)
    case bulletList(items: [String])
    case orderedList(items: [String])
    case codeBlock(lang: String, code: String)
    case blockquote(innerHTML: String)
    case table(headers: [String], aligns: [TableAlign], rows: [[String]])
    case hr
  }

  private enum TableAlign { case left, center, right, none }

  // MARK: - Block parser

  static func htmlBody(from markdown: String) -> String {
    let lines = markdown
      .replacingOccurrences(of: "\r\n", with: "\n")
      .replacingOccurrences(of: "\r", with: "\n")
      .components(separatedBy: "\n")
    return parseBlocks(lines).map(renderBlock).joined(separator: "\n")
  }

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  private static func parseBlocks(_ lines: [String]) -> [Block] {
    var blocks: [Block] = []
    var i = 0
    var paraLines: [String] = []

    func flushPara() {
      guard !paraLines.isEmpty else { return }
      blocks.append(.paragraph(html: inlineFormat(paraLines.joined(separator: " "))))
      paraLines = []
    }

    while i < lines.count {
      let line = lines[i]
      let trimmed = line.trimmingCharacters(in: .whitespaces)

      // Fenced code block
      if trimmed.hasPrefix("```") || trimmed.hasPrefix("~~~") {
        flushPara()
        let fence: Character = trimmed.first!
        let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        var codeLines: [String] = []
        i += 1
        while i < lines.count {
          let cl = lines[i]
          if cl.trimmingCharacters(in: .whitespaces).first == fence
            && cl.trimmingCharacters(in: .whitespaces).hasPrefix(String(repeating: String(fence), count: 3))
          { i += 1; break }
          codeLines.append(cl); i += 1
        }
        blocks.append(.codeBlock(lang: lang, code: codeLines.joined(separator: "\n")))
        continue
      }

      // Blank line
      if trimmed.isEmpty { flushPara(); i += 1; continue }

      // Horizontal rule (must come before setext-heading-under-line check)
      if isHR(trimmed) { flushPara(); blocks.append(.hr); i += 1; continue }

      // ATX heading
      if let h = parseATXHeading(trimmed) {
        flushPara()
        blocks.append(.heading(level: h.level, html: inlineFormat(h.text)))
        i += 1; continue
      }

      // Setext heading (underline with === or ---)
      if i + 1 < lines.count {
        let under = lines[i + 1].trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty, under.count >= 2, under.allSatisfy({ $0 == "=" }) {
          flushPara()
          blocks.append(.heading(level: 1, html: inlineFormat(trimmed)))
          i += 2; continue
        }
        if !trimmed.isEmpty, under.count >= 2, under.allSatisfy({ $0 == "-" }),
           parseListItem(line) == nil
        {
          flushPara()
          blocks.append(.heading(level: 2, html: inlineFormat(trimmed)))
          i += 2; continue
        }
      }

      // Blockquote
      if trimmed.hasPrefix(">") {
        flushPara()
        var bqLines: [String] = [bqStrip(trimmed)]
        i += 1
        while i < lines.count {
          let t = lines[i].trimmingCharacters(in: .whitespaces)
          if t.hasPrefix(">") { bqLines.append(bqStrip(t)); i += 1 }
          else if t.isEmpty { break }
          else { bqLines.append(t); i += 1 }
        }
        let inner = bqLines.map { inlineFormat($0) }.joined(separator: " ")
        blocks.append(.blockquote(innerHTML: inner))
        continue
      }

      // Table (line must start with |)
      if isTableRow(trimmed) {
        flushPara()
        var tLines = [trimmed]; i += 1
        while i < lines.count, isTableRow(lines[i].trimmingCharacters(in: .whitespaces)) {
          tLines.append(lines[i].trimmingCharacters(in: .whitespaces)); i += 1
        }
        if let tbl = parseTable(tLines) { blocks.append(tbl) }
        else { blocks.append(.paragraph(html: inlineFormat(tLines.joined(separator: " ")))) }
        continue
      }

      // List item
      if let item = parseListItem(line) {
        flushPara()
        let ordered = item.ordered
        var items = [item.text]; i += 1
        while i < lines.count {
          let nl = lines[i]
          let nt = nl.trimmingCharacters(in: .whitespaces)
          if let next = parseListItem(nl), next.ordered == ordered {
            items.append(next.text); i += 1
          } else if nt.isEmpty {
            var j = i + 1
            while j < lines.count, lines[j].trimmingCharacters(in: .whitespaces).isEmpty { j += 1 }
            if j < lines.count, let ni = parseListItem(lines[j]), ni.ordered == ordered { i = j }
            else { break }
          } else if !nt.isEmpty, parseListItem(nl) == nil, !isHR(nt), parseATXHeading(nt) == nil {
            items[items.count - 1] += " " + nt; i += 1
          } else { break }
        }
        let htmlItems = items.map { inlineFormat($0) }
        blocks.append(ordered ? .orderedList(items: htmlItems) : .bulletList(items: htmlItems))
        continue
      }

      // Regular paragraph line
      paraLines.append(trimmed); i += 1
    }

    flushPara()
    return blocks
  }

  // MARK: - Block helpers

  private static func isHR(_ t: String) -> Bool {
    let s = t.filter { !$0.isWhitespace }
    guard s.count >= 3 else { return false }
    return Set(s).count == 1 && (s.first == "-" || s.first == "*" || s.first == "_")
  }

  private static func parseATXHeading(_ t: String) -> (level: Int, text: String)? {
    guard t.hasPrefix("#") else { return nil }
    var level = 0; var idx = t.startIndex
    while idx < t.endIndex, t[idx] == "#" { level += 1; idx = t.index(after: idx) }
    guard level <= 6, idx < t.endIndex, t[idx] == " " else { return nil }
    return (level, String(t[t.index(after: idx)...]).trimmingCharacters(in: .whitespaces))
  }

  private static func isTableRow(_ t: String) -> Bool { t.hasPrefix("|") }

  private static func parseTable(_ tLines: [String]) -> Block? {
    guard tLines.count >= 2 else { return nil }
    func cells(_ s: String) -> [String] {
      var c = s.trimmingCharacters(in: .whitespaces)
      if c.hasPrefix("|") { c = String(c.dropFirst()) }
      if c.hasSuffix("|") { c = String(c.dropLast()) }
      return c.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    func align(_ cell: String) -> TableAlign {
      let c = cell.trimmingCharacters(in: .init(charactersIn: "- "))
      if c.hasPrefix(":") && c.hasSuffix(":") { return .center }
      if c.hasSuffix(":") { return .right }
      if c.hasPrefix(":") { return .left }
      return .none
    }
    let sep = cells(tLines[1])
    guard sep.allSatisfy({ $0.allSatisfy({ $0 == "-" || $0 == ":" || $0 == " " }) }) else { return nil }
    return .table(
      headers: cells(tLines[0]).map { inlineFormat($0) },
      aligns: sep.map { align($0) },
      rows: tLines.dropFirst(2).map { cells($0).map { inlineFormat($0) } }
    )
  }

  private struct ListItem { let text: String; let ordered: Bool }

  private static func parseListItem(_ line: String) -> ListItem? {
    var idx = line.startIndex; var indent = 0
    while idx < line.endIndex, indent < 4 {
      if line[idx] == " " { indent += 1; idx = line.index(after: idx) }
      else if line[idx] == "\t" { indent += 4; idx = line.index(after: idx) }
      else { break }
    }
    guard idx < line.endIndex else { return nil }
    let c = line[idx]
    // Unordered: - + *
    if c == "-" || c == "+" || c == "*" {
      let next = line.index(after: idx)
      guard next < line.endIndex else { return nil }
      let nc = line[next]
      if nc == " " || nc == "\t" {
        let rest = String(line[line.index(after: next)...]).trimmingCharacters(in: .whitespaces)
        return ListItem(text: rest, ordered: false)
      }
      return nil
    }
    // Ordered: 1. 2. ...
    var j = idx; var digits = 0
    while j < line.endIndex, digits < 9, line[j] >= "0", line[j] <= "9" { digits += 1; j = line.index(after: j) }
    guard digits > 0, j < line.endIndex, line[j] == "." else { return nil }
    j = line.index(after: j)
    guard j < line.endIndex, line[j] == " " || line[j] == "\t" else { return nil }
    let rest = String(line[line.index(after: j)...]).trimmingCharacters(in: .whitespaces)
    return ListItem(text: rest, ordered: true)
  }

  private static func bqStrip(_ t: String) -> String {
    var s = t
    if s.hasPrefix(">") { s = String(s.dropFirst()) }
    return s.trimmingCharacters(in: .whitespaces)
  }

  // MARK: - Block renderer

  private static func renderBlock(_ block: Block) -> String {
    switch block {
    case .heading(let lvl, let html):
      return "<h\(lvl)>\(html)</h\(lvl)>"
    case .paragraph(let html):
      return "<p>\(html)</p>"
    case .bulletList(let items):
      return "<ul>\n" + items.map { "<li>\($0)</li>" }.joined(separator: "\n") + "\n</ul>"
    case .orderedList(let items):
      return "<ol>\n" + items.map { "<li>\($0)</li>" }.joined(separator: "\n") + "\n</ol>"
    case .codeBlock(let lang, let code):
      let cls = lang.isEmpty ? "" : " class=\"language-\(lang)\""
      return "<pre><code\(cls)>\(htmlEscape(code))</code></pre>"
    case .blockquote(let inner):
      return "<blockquote><p>\(inner)</p></blockquote>"
    case .table(let headers, let aligns, let rows):
      var h = "<div class=\"table-wrap\"><table>\n<thead>\n<tr>"
      for (i, hdr) in headers.enumerated() { h += "<th\(alignAttr(aligns, i))>\(hdr)</th>" }
      h += "</tr>\n</thead>\n<tbody>\n"
      for row in rows {
        h += "<tr>"
        for (i, cell) in row.enumerated() { h += "<td\(alignAttr(aligns, i))>\(cell)</td>" }
        h += "</tr>\n"
      }
      return h + "</tbody>\n</table></div>"
    case .hr:
      return "<hr>"
    }
  }

  private static func alignAttr(_ aligns: [TableAlign], _ i: Int) -> String {
    guard i < aligns.count else { return "" }
    switch aligns[i] {
    case .left:   return " style=\"text-align:left\""
    case .center: return " style=\"text-align:center\""
    case .right:  return " style=\"text-align:right\""
    case .none:   return ""
    }
  }

  // MARK: - Inline formatter

  static func inlineFormat(_ raw: String) -> String {
    // Step 1: protect inline code spans from further processing
    var s = raw
    var codePairs: [(placeholder: String, html: String)] = []
    let codeRe = try! NSRegularExpression(pattern: "`([^`]+)`")
    let ns = s as NSString
    let matches = codeRe.matches(in: s, range: NSRange(location: 0, length: ns.length)).reversed()
    for (idx, m) in matches.enumerated() {
      guard let fullR = Range(m.range, in: s), let innerR = Range(m.range(at: 1), in: s) else { continue }
      let inner = htmlEscape(String(s[innerR]))
      let key = "\u{FFFE}C\(idx)\u{FFFE}"
      codePairs.append((key, "<code>\(inner)</code>"))
      s.replaceSubrange(fullR, with: key)
    }

    // Step 2: HTML-escape plain text (& < > ")
    s = htmlEscape(s)

    // Step 3: inline markdown → HTML (order matters: images before links, bold+italic before bold)
    // Images
    s = s.replacingOccurrences(of: #"!\[([^\]]*)\]\(([^)]*)\)"#,
      with: "<img src=\"$2\" alt=\"$1\">", options: .regularExpression)
    // Links
    s = s.replacingOccurrences(of: #"\[([^\]]+)\]\(([^)]+)\)"#,
      with: "<a href=\"$2\">$1</a>", options: .regularExpression)
    // Bold + italic ***
    s = s.replacingOccurrences(of: #"\*\*\*([^*]+)\*\*\*"#,
      with: "<strong><em>$1</em></strong>", options: .regularExpression)
    // Bold **
    s = s.replacingOccurrences(of: #"\*\*([^*]+)\*\*"#,
      with: "<strong>$1</strong>", options: .regularExpression)
    // Bold __
    s = s.replacingOccurrences(of: #"__([^_]+)__"#,
      with: "<strong>$1</strong>", options: .regularExpression)
    // Italic *  (skip lone * used as list marker — by this point list markers are gone from inline context)
    s = s.replacingOccurrences(of: #"\*([^*\s][^*]*[^*\s]|\S)\*"#,
      with: "<em>$1</em>", options: .regularExpression)
    // Italic _  (don't match inside words like snake_case)
    s = s.replacingOccurrences(of: #"(?<![a-zA-Z0-9])_([^_\n]+)_(?![a-zA-Z0-9])"#,
      with: "<em>$1</em>", options: .regularExpression)

    // Step 4: restore code spans
    for (key, html) in codePairs { s = s.replacingOccurrences(of: key, with: html) }
    return s
  }

  static func htmlEscape(_ text: String) -> String {
    text
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
      .replacingOccurrences(of: "\"", with: "&quot;")
  }
}

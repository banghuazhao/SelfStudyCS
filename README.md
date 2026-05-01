# SelfStudyCS

Native **iOS** reader for [**CS Self-Learning**](https://github.com/PKUFlyingPig/cs-self-learning)—the open computer-science self-study guide. This repository contains the **Swift / SwiftUI** app; the bundled **Markdown chapters** under `Docs/` come from that upstream project.

**Repository:** [github.com/banghuazhao/SelfStudyCS](https://github.com/banghuazhao/SelfStudyCS)

## Features

- **Library** — Browse bundled topics; **English** (`.en.md` where available) and **Chinese** primary chapters; search and continue reading.
- **Reader** — Themes (light, dark, sepia), typography controls, table of contents, **bookmarks**, scroll progress.
- **My guides** — Your own **course-style notes**, structured fields + generated Markdown, stored in **SQLite** on device.
- **Settings** — Appearance, content language, attribution links, privacy, App Store support actions.

## Requirements

- Xcode 16+ (project targets **iOS 18.0** and up).
- Open `SelfStudyCS.xcodeproj`, select scheme **SelfStudyCS**, run on Simulator or device.

## Course materials & attribution (books / text)

All **course notes, chapter text, and catalog structure** bundled in this app are from the community project **CS Self-Learning**:

| | Link |
|---|------|
| **Source repository** | [PKUFlyingPig/cs-self-learning](https://github.com/PKUFlyingPig/cs-self-learning) |
| **Maintainer** | [PKUFlyingPig](https://github.com/PKUFlyingPig) and [contributors](https://github.com/PKUFlyingPig/cs-self-learning/graphs/contributors) |
| **Read online** | [csdiy.wiki](https://csdiy.wiki) |

**License & reuse:** Those materials are **not** original to this app. If you redistribute the bundled `Docs/` content or ship derivatives, you **must** comply with the **upstream repository’s license** and **give proper credit** to CS Self-Learning and its authors. See the upstream repo for the exact license text and citation expectations.

This app is a **reader and note-taking shell**; it does not replace or supersede the official CS Self-Learning project—support that project if you rely on their work.

## App Store / distribution

- **Listing copy (English + 简体中文):** **[APP_STORE_CONNECT_LISTING.md](APP_STORE_CONNECT_LISTING.md)** — App Store Connect fields, privacy hints, review notes.
- **Minimum iOS:** 18.0 (deployment target in Xcode).
- **Archive:** Scheme `SelfStudyCS`, configuration **Release**, **Product → Archive**. Release uses `-O`, strips Swift symbols, and validates for distribution (signing team required).
- **Versions:** `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the target’s build settings; bump build for every upload. Settings → About shows the bundled version string.
- **Export compliance:** `ITSAppUsesNonExemptEncryption` is **NO** in the generated Info.plist (standard HTTPS / OS crypto only unless you change the app).
- **Privacy manifest:** `SelfStudyCS/PrivacyInfo.xcprivacy` (e.g. **UserDefaults** for reader preferences, reason `CA92.1`). Extend if you add SDKs that trigger new “required reason” APIs.
- **Display name (device):** **Self-Study CS**; **Bundle ID:** `com.appsbay.SelfStudyCS` (adjust for your Apple Developer account if needed).
- **In-app Store URL:** Set **`AppDistributionLinks.appStoreProductID`** in code to your live App Store numeric ID so Share works.
- **Screenshots:** Library, Reader (theme + TOC), Bookmarks, My guides, Settings (Support + Appearance); include **iPad** sizes if you ship universal.
- **Localization:** `Localizable.xcstrings` includes **Simplified Chinese** for key chrome strings; **Content language** in Settings switches bundled chapter files.

## My guides (your notes)

The **My guides** tab stores **your** notes locally: structured fields inspired by the bundled template, plus generated Markdown for reading. Data lives in **SQLite** on the device (no app-provided cloud).

## Custom chapters (`Template` + `Docs`)

- **`Template/`** — Reference `template.md` / `template.en.md`; appears in the library as **Course template** / **课程模板**.
- **`Docs/`** — Bundled CS Self-Learning chapters; to **change shipped content**, edit/add Markdown under `Docs/` (same layout as upstream) and **rebuild**.

To **contribute improvements to the book itself**, use the **[upstream CS Self-Learning](https://github.com/PKUFlyingPig/cs-self-learning)** process (e.g. `template.md`, `mkdocs.yml`, contributing guide there)—do not assume this app repo is the canonical book project.

## Repo layout (short)

- `SelfStudyCS/` — App sources, assets, `PrivacyInfo.xcprivacy`, `Localizable.xcstrings`
- `Docs/` — Bundled Markdown catalog (from CS Self-Learning)
- `Template/` — Writing templates
- `SelfStudyCS.xcodeproj` — Xcode project

---

**Summary:** This repository hosts the **Self-Study CS** iOS app. **All bundled course chapters** in `Docs/` come from **[CS Self-Learning](https://github.com/PKUFlyingPig/cs-self-learning)**—credit that project and respect its **license** when you copy, redistribute, or build upon the book material.

# SelfStudyCS (iOS)

Native reader for the [**CS Self-Learning**](https://github.com/PKUFlyingPig/cs-self-learning) guide: bundled Markdown chapters, bookmarks, reading progress, themes, and a table of contents.

## App Store / distribution

- **Minimum iOS:** 18.0 (set in Xcode project deployment target).
- **Archive:** Scheme `SelfStudyCS`, configuration **Release**, **Product → Archive**. Release builds disable SwiftUI previews, enable `-O`, strip Swift symbols, and run store validation (`CODE_SIGN_IDENTITY` / team must be valid on your machine).
- **Versions:** `MARKETING_VERSION` (user-facing) and `CURRENT_PROJECT_VERSION` (build) live in the target’s **General** / build settings; bump the build number for every App Store upload. Settings → About shows `AppReleaseInfo.fullVersionLabel`.
- **Export compliance:** `ITSAppUsesNonExemptEncryption` is set to **NO** (no custom encryption beyond standard HTTPS / OS APIs). Adjust in target build settings if that changes.
- **Privacy manifest:** `SelfStudyCS/PrivacyInfo.xcprivacy` declares **UserDefaults** (`CA92.1`) for reader preferences. If Xcode or App Store Connect reports missing required-reason APIs after linking updates, add the listed categories there.
- **Display name:** **Self-Study CS** (`CFBundleDisplayName`); bundle id: `com.appsbay.SelfStudyCS` (change for your org before shipping).
- **Third-party content & branding:** The bundled catalog follows **CS Self-Learning** licensing; keep copyright / attribution in the app and App Store description aligned with upstream (see **Credits**).

## My guides (your notes)

The **My guides** tab lets you create **course-style notes** using the same section layout as the English template (course heading, Descriptions bullets, introduction, Course Resources, Personal Resources). Fields are optional where noted; the app saves **structured data** plus generated Markdown for reading. Everything is stored in SQLite on device.

## Credits

The course catalog and text are from **CS Self-Learning**, maintained by **[PKUFlyingPig](https://github.com/PKUFlyingPig)** and contributors. Please cite that project and follow its license when redistributing content. Online edition: [csdiy.wiki](https://csdiy.wiki).

## Custom chapters (Template)

The **`Template`** folder next to this target holds `template.md` / `template.en.md`. It is bundled for reference and appears under **Course template** (or **课程模板**) at the end of the library.

To ship your own notes in the app:

1. Copy a template (or start from the samples in `Template/`).
2. Add your `.md` / `.en.md` files under the **`Docs`** folder (same structure as the upstream guide).
3. Rebuild the app so the new files are included in the bundle.

For contributing back to the original book, follow the upstream [contributing instructions](https://github.com/PKUFlyingPig/cs-self-learning) (e.g. `template.md` and `mkdocs.yml` there).

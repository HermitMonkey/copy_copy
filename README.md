# ⌘ copy_copy (Phoenix)

A privacy-first, local-first macOS clipboard manager equipped with on-device AI summarization and a Zero-Knowledge End-to-End Encrypted (E2EE) cloud sync architecture.

## Core Features
* **Zero-Latency Ingestion:** Captures clipboard history instantly with tactile native audio feedback.
* **On-Device NLP Engine:** Pure-Dart extractive summarization generates instant TL;DRs for long articles using zero API calls.
* **Smart Enrichment:** Automatically extracts page titles, hero images, and parses contextual image galleries from URLs.
* **Smart Attachments:** Intercepts PDF URLs and generates clickable Material Document Cards, bypassing memory-heavy HTML scrapers.
* **Mac Polish:** Global Hotkeys (`CMD+Shift+V`), Native System Tray integration, and macOS Launch-at-Login support.
* **Pro License:** Freemium tier system — 50 items free, unlimited with a Pro license key (see Settings → Pro).

## Security & Sync Architecture (In Progress)
The Phoenix architecture is designed to sync data between macOS and Android without traditional user accounts, while keeping Firebase completely blind to the payload.

1. **Zero-Knowledge Encryption:** Data is encrypted locally using an AES-256-GCM key stored in the macOS Secure Enclave / Android Keystore.
2. **Passwordless Pairing:** The Mac app generates a secure, 5-minute TTL QR Code containing a hashed pairing secret and the AES key. 
3. **Custom Auth Tokens:** The Android app scans the QR code and calls a Firebase Cloud Function, which verifies the secret and mints a Custom Auth Token, unifying both devices under a single Firebase UID.
4. **Offline-First Isar DB:** Bi-directional sync utilizes soft-delete (`isDeleted`) flags to ensure offline devices maintain perfect state consistency when reconnecting.
5. **Data Sovereignty:** Features a 1-click JSON export to local storage and a "Nuclear Wipe" protocol that instantly drops the Isar tables and fires a batch delete to the Firestore cloud.

---

## Distribution Strategy

### Mac App Store vs. Direct (Free-Range) Release

| Concern | Mac App Store | Direct Distribution |
|---|---|---|
| **Reach** | Built-in storefront, search discovery | Manual — Gumroad, your own site, Product Hunt |
| **Revenue cut** | Apple takes **30 %** (15 % Small Business Program) | **0 %** — you keep everything |
| **Sandboxing** | **Required.** Background clipboard access (`NSPasteboard` polling), global hotkeys, and `launch_at_startup` all require special entitlements or are outright prohibited | No sandbox — all features work as-is |
| **Entitlement pain** | `com.apple.security.temporary-exception.apple-events` needed for clipboard; global hotkeys via `hotkey_manager` are rejected under sandbox | Not needed |
| **Review time** | 24 – 72 h per build; rejections for background clipboard access are **common** | Instant |
| **Notarization** | Bundled in submission process | Must manually notarize via `xcrun notarytool` — required since macOS 10.15 |
| **Auto-updates** | Handled by the App Store | Must ship your own update mechanism (Sparkle framework or a custom endpoint) |
| **Trial / Pricing flexibility** | Only via in-app purchase or free + IAP; license-key models are **disallowed** | Full flexibility — one-time purchase, subscription, free trial, license keys |

**Recommendation:** Given that the app relies on background clipboard monitoring, a system-tray icon, global hotkeys, and `launch_at_startup`, the App Store sandbox makes submission risky and feature-limiting. **Direct distribution is the stronger choice for v1.** After the feature set is locked and Apple's entitlement process is better understood, a sandboxed App Store build can be maintained as a separate target.

### Architectural requirements for direct distribution
1. **Notarization pipeline** — add a CI step: `xcode build → codesign → xcrun notarytool submit`.
2. **Sparkle auto-updater** — add the [sparkle_flutter](https://pub.dev/packages/sparkle_flutter) package (or native Swift bridge) so users receive in-app update prompts.
3. **Crash reporting** — integrate Sentry or Firebase Crashlytics (already a dependency) to monitor field crashes without App Store analytics.

---

## Monetization (No App Store)

### Freemium + License Key (implemented)
The app ships with a **free tier** (50 clipboard items) and a **Pro tier** (1,000 items + cloud sync) unlocked by a license key in the format `CCPRO-XXXX-XXXX-XXXX`.

**Recommended storefront:** [Gumroad](https://gumroad.com) — zero monthly fee, generates license keys natively, and handles EU VAT.

**License activation flow (current):**
```
User buys on Gumroad → receives key by email → opens Settings →
enters CCPRO-XXXX-XXXX-XXXX → LicenseService validates format → Pro unlocked locally
```

**To add server-side seat enforcement** (prevent key sharing), replace the local format check in `LicenseService.activate()` with a call to the [Gumroad License API](https://gumroad.com/api#licenses) or your own Cloud Function.

### Pricing Signals from the Market
| Product | Price | Model |
|---|---|---|
| Paste | $4.99/month | Subscription |
| CleanMaster for Mac | $29.99 one-time | One-time |
| Raycast Pro | $8/month | Subscription |
| **copy_copy Pro (suggested)** | **$9.99 one-time** | One-time purchase |

A one-time price with no subscription is a strong differentiator in a market fatigued by SaaS pricing. Offer a 14-day free trial via a time-limited key generated on your server.

### Additional Revenue Streams (post-v1)
* **Pro Lifetime Bundle** — charge a premium for a lifetime license at ~$24.99.
* **Enterprise / Team Pack** — 5-seat license for teams at $29.99.
* **Tip Jar** — voluntary payment page for open-source enthusiasts.

---

## Is There a Market Need?

Yes. The clipboard manager category on macOS is populated but not saturated, and copy_copy has a distinct privacy-first position:

| Differentiator | Competitors lacking it |
|---|---|
| Zero cloud scraping by default | Paste, Alfred |
| On-device NLP summarization (no API key) | All |
| E2EE cross-device sync (not iCloud) | All |
| Smart Collections with keyword rules | Most |
| One-time pricing | Paste (subscription) |

The primary risk is **discoverability without the App Store**. Mitigate this with a Product Hunt launch, targeted communities (r/MacApps, Hacker News "Show HN"), and a short YouTube demo.

---

## Suggested Functionality & Flow Improvements

### Implemented in this release
- ✅ **Bug fix — Vault Notes filter:** clicking the "Vault Notes" card now correctly filters to `contentType == 'note'` instead of returning zero results.
- ✅ **Content-type icons in the sidebar:** URLs show a blue link icon, code snippets a green `</>` icon, notes an orange pencil, and plain text a purple clipboard icon — making the feed scannable at a glance.
- ✅ **Copy audio feedback:** tapping the "Copy" button in the MagazineInspector now plays the same satisfying audio cue as a background copy.
- ✅ **Free-tier progress bar:** a slim indicator at the base of the sidebar shows how close a free user is to the 50-item limit, with an orange warning at 80 % capacity.
- ✅ **Freemium LicenseService:** all history-limit logic now flows through `LicenseService.historyLimit`, making it trivial to adjust tier limits without touching clipboard capture code.

### Backlog (recommended next steps)
- **Favourite / Star items** — add an `isFavorited` boolean to `ClipboardItem` (requires `build_runner` codegen). Starred items appear at the top of the feed and are exempt from the automatic oldest-first eviction.
- **Sensitive item masking** — items flagged `isSensitive = true` should show `••••••••` in the sidebar feed instead of raw content.
- **Rich-text paste** — detect and render Markdown in the MagazineInspector for code blocks and formatted notes.
- **Drag-to-reorder Smart Collections** — replace the static grid with a `ReorderableGridView`.
- **Onboarding checklist** — a dismissible first-run overlay showing the three key gestures: hotkey summon, swipe-to-delete, and Smart Collection creation.
- **Sparkle auto-update integration** — essential for shipping without the App Store.
- **Time-limited trial key server** — a lightweight Cloud Function that issues a 14-day `CCPRO-XXXX-XXXX-XXXX` key on sign-up email, replacing the permanent demo-key approach.

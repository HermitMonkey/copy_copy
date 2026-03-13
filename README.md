# copy_copy 📋

A high-finesse, cross-platform, local-first clipboard manager built with Flutter.

`copy_copy` acts as a premium workspace for your copied data. Instead of relying on slow and expensive AI models, it uses "Non-AI Intelligence" (robust heuristics, Regex, and OpenGraph scraping) to instantly categorize, enrich, and format your clipboard history into a beautiful, magazine-style reader.

## 🚀 Key Features

* **Zero-Latency Capture:** Clipboard events are written instantly to a local Isar database, ensuring zero lag between copying and viewing.
* **Non-AI Intelligence:** Automatically classifies links, code snippets, and plaintext. Uses local heuristics to group items into "Smart Folders" (e.g., Medical Research, GitHub Repos) without touching a cloud LLM.
* **Premium Phoenix Dashboard:** A dark-mode optimized, native-feeling workspace featuring a GitHub-style composition bar and a distraction-free "Magazine View" for reading scraped articles.
* **End-to-End Encryption (E2EE):** Cloud synchronization via Firebase Firestore, but the raw clipboard body is encrypted locally using **AES-256-GCM** before it ever leaves the device. The cloud acts as a blind mirror.
* **Global Hotkeys:** Summon the workspace instantly from anywhere on macOS using `Cmd + Shift + V` (powered by native window management).

## 🏗 Architecture & Pivot

**The Pivot:** Initial versions of this project attempted to integrate local, on-device C++ AI models (like Llama.cpp) for text analysis. This approach was abandoned in favor of strict, lightweight heuristics. The result is an app that consumes significantly less battery, compiles cleanly across macOS and Android, and processes data instantly.

**The Data Flow:**
1. **Listen:** Native clipboard watcher triggers on copy.
2. **Store:** Raw data is saved to local `Isar` DB instantly.
3. **Enrich:** Background isolate scrapes OpenGraph images and parses HTML.
4. **Encrypt:** Payload is locked with a device-wrapped AES-256 key.
5. **Sync:** Encrypted payload + plaintext metadata are pushed to Firestore via a debounced batch queue.

## 🛠 Tech Stack
* **Framework:** Flutter (macOS & Android)
* **Local Storage:** Isar Database
* **Cloud Sync:** Firebase Firestore & Auth
* **Security:** `encrypt` (AES-256) & `flutter_secure_storage`
* **Native Hooks:** `window_manager`, `hotkey_manager`, `clipboard_watcher`
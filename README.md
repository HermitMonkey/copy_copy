# ⌘ copy_copy (Phoenix)

A privacy-first, local-first macOS clipboard manager equipped with on-device AI summarization and a Zero-Knowledge End-to-End Encrypted (E2EE) cloud sync architecture.

## Core Features
* **Zero-Latency Ingestion:** Captures clipboard history instantly with tactile native audio feedback.
* **On-Device NLP Engine:** Pure-Dart extractive summarization generates instant TL;DRs for long articles using zero API calls.
* **Smart Enrichment:** Automatically extracts page titles, hero images, and parses contextual image galleries from URLs.
* **Smart Attachments:** Intercepts PDF URLs and generates clickable Material Document Cards, bypassing memory-heavy HTML scrapers.
* **Mac Polish:** Global Hotkeys (`CMD+Shift+V`), Native System Tray integration, and macOS Launch-at-Login support.

## Security & Sync Architecture (In Progress)
The Phoenix architecture is designed to sync data between macOS and Android without traditional user accounts, while keeping Firebase completely blind to the payload.

1. **Zero-Knowledge Encryption:** Data is encrypted locally using an AES-256-GCM key stored in the macOS Secure Enclave / Android Keystore.
2. **Passwordless Pairing:** The Mac app generates a secure, 5-minute TTL QR Code containing a hashed pairing secret and the AES key. 
3. **Custom Auth Tokens:** The Android app scans the QR code and calls a Firebase Cloud Function, which verifies the secret and mints a Custom Auth Token, unifying both devices under a single Firebase UID.
4. **Offline-First Isar DB:** Bi-directional sync utilizes soft-delete (`isDeleted`) flags to ensure offline devices maintain perfect state consistency when reconnecting.
5. **Data Sovereignty:** Features a 1-click JSON export to local storage and a "Nuclear Wipe" protocol that instantly drops the Isar tables and fires a batch delete to the Firestore cloud.

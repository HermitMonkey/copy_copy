import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clipboard_item.dart';
import 'encryption_service.dart';

class FirestoreSyncService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🛠 THE SYNC QUEUE
  static final List<ClipboardItem> _syncQueue = [];
  static Timer? _debounceTimer;

  static Future<void> authenticate() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
        print("☁️ Authenticated with Firebase: ${_auth.currentUser?.uid}");
      } else {
        print("☁️ Already authenticated: ${_auth.currentUser?.uid}");
      }
    } catch (e) {
      // 🛠 FIX: Catch the error so it doesn't crash the main() function!
      print("⚠️ Firebase Auth Error (App will continue offline): $e");
    }
  }

  /// Adds an item to the queue and resets the countdown timer.
  /// If the user stops copying for 5 seconds, the batch processes.
  static void queueItemForSync(ClipboardItem item) {
    // Replace if already in queue to avoid duplicates
    _syncQueue.removeWhere((existing) => existing.id == item.id);
    _syncQueue.add(item);

    // Cancel the old timer and start a new 5-second countdown
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), _processBatch);

    print("⏳ Item ${item.id} queued. Queue size: ${_syncQueue.length}");
  }

  /// Processes all items in the queue atomically
  static Future<void> _processBatch() async {
    final user = _auth.currentUser;
    if (user == null || _syncQueue.isEmpty) return;

    // Create a Firestore WriteBatch
    final batch = _db.batch();
    final itemsToSync = List<ClipboardItem>.from(_syncQueue); // Copy the list
    _syncQueue.clear(); // Clear the queue immediately

    try {
      for (var item in itemsToSync) {
        // 1. Encrypt Payload
        final encryptedPayload = EncryptionService.encryptData(item.content);

        // 2. Prepare Data
        final docData = {
          'userId': user.uid,
          'contentType': item.contentType,
          'title': item.title,
          'heroImageUrl': item.heroImageUrl,
          'faviconUrl': item.faviconUrl,
          'timestamp': item.timestamp.toIso8601String(),
          'encryptedBody': encryptedPayload['ciphertext'],
          'iv': encryptedPayload['iv'],
        };

        // 3. Add to Batch
        final docRef = _db.collection('clips').doc(item.id.toString());
        batch.set(docRef, docData);
      }

      // 4. Commit the entire batch to the cloud at once
      await batch.commit();
      print(
        "☁️ Successfully batched and synced ${itemsToSync.length} items to Firestore.",
      );
    } catch (e) {
      print("❌ Batch Sync Error: $e");
      // If it fails, put them back in the queue to try again later
      _syncQueue.addAll(itemsToSync);
    }
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clipboard_item.dart';
import 'encryption_service.dart';

class FirestoreSyncService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final List<ClipboardItem> _syncQueue = [];
  static Timer? _debounceTimer;

  // 🛠 NEW: Expose the queue size so the Settings UI can read it
  static int get pendingSyncCount => _syncQueue.length;

  static Future<void> authenticate() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
        print("☁️ Authenticated with Firebase: ${_auth.currentUser?.uid}");
      } else {
        print("☁️ Already authenticated: ${_auth.currentUser?.uid}");
      }
    } catch (e) {
      print("⚠️ Firebase Auth Error (App will continue offline): $e");
    }
  }

  static void queueItemForSync(ClipboardItem item) {
    _syncQueue.removeWhere((existing) => existing.id == item.id);
    _syncQueue.add(item);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), _processBatch);
  }

  static Future<void> _processBatch() async {
    final user = _auth.currentUser;
    if (user == null || _syncQueue.isEmpty) return;

    final batch = _db.batch();
    final itemsToSync = List<ClipboardItem>.from(_syncQueue);
    _syncQueue.clear();

    try {
      for (var item in itemsToSync) {
        final encryptedPayload = EncryptionService.encryptData(item.content);
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
        final docRef = _db.collection('clips').doc(item.id.toString());
        batch.set(docRef, docData);
      }
      await batch.commit();
    } catch (e) {
      print("❌ Batch Sync Error: $e");
      _syncQueue.addAll(itemsToSync);
    }
  }
}

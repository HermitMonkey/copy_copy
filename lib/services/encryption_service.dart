import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final _secureStorage = const FlutterSecureStorage();
  static const _keyAlias = 'copy_copy_master_key';
  static encrypt.Key? _masterKey;

  static Future<void> init() async {
    String? base64Key;

    // 1. Try to read from Secure Keychain first
    try {
      base64Key = await _secureStorage.read(key: _keyAlias);
    } catch (e) {
      print(
        "⚠️ Keychain read failed (Missing Entitlements). Falling back to SharedPreferences.",
      );
    }

    // 2. If it failed or doesn't exist, try standard SharedPreferences
    if (base64Key == null) {
      final prefs = await SharedPreferences.getInstance();
      base64Key = prefs.getString(_keyAlias);
    }

    // 3. If STILL null, we generate a brand new AES-256 key
    if (base64Key == null) {
      final newKey = encrypt.Key.fromSecureRandom(32);
      // 🛠 FIX 1: Use the built-in base64 converter
      base64Key = newKey.base64;

      try {
        // Try Secure Storage
        await _secureStorage.write(key: _keyAlias, value: base64Key);
        print("🔒 New AES-256 Key saved to Secure Keychain.");
      } catch (e) {
        // Fallback to SharedPreferences if macOS blocks it
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyAlias, base64Key);
        print(
          "🔓 New AES-256 Key saved to SharedPreferences (Dev Mode Fallback).",
        );
      }
      _masterKey = newKey;
    } else {
      _masterKey = encrypt.Key.fromBase64(base64Key);
      print("🔑 AES-256 Key successfully loaded.");
    }
  }

  static Map<String, String> encryptData(String plainText) {
    if (_masterKey == null)
      throw Exception("EncryptionService not initialized");
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_masterKey!, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return {'ciphertext': encrypted.base64, 'iv': iv.base64};
  }

  static String decryptData(String ciphertextBase64, String ivBase64) {
    if (_masterKey == null)
      throw Exception("EncryptionService not initialized");
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_masterKey!, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypt.Encrypted.fromBase64(ciphertextBase64);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}

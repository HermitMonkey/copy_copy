import 'package:shared_preferences/shared_preferences.dart';

/// The two tiers available in copy_copy.
enum AppTier { free, pro }

/// Manages the Pro license for free-range (direct) distribution.
///
/// Monetization pathway (no App Store):
///   - Sell license keys via Gumroad / Paddle / LemonSqueezy.
///   - Validate the key format locally; optionally ping a lightweight
///     activation endpoint to enforce seat limits.
///   - Free tier: up to [LicenseService.freeHistoryLimit] clipboard entries stored.
///   - Pro tier: unlimited history, cloud sync, and future premium features.

/// Storefront URL for purchasing a Pro license key.
const _storeUrl = 'copy-copy.gumroad.com';

class LicenseService {
  static const _prefKey = 'license_key';
  static const int freeHistoryLimit = 50;
  static const int proHistoryLimit = 1000;

  // License key format: CCPRO-XXXX-XXXX-XXXX  (base-36 segments)
  static final RegExp _keyFormat = RegExp(
    r'^CCPRO-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$',
  );

  static AppTier _tier = AppTier.free;
  static String? _activeLicenseKey;

  static String get storeUrl => _storeUrl;

  /// Must be called once at app startup (after SharedPreferences is available).
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored != null && _keyFormat.hasMatch(stored)) {
      _tier = AppTier.pro;
      _activeLicenseKey = stored;
    }
  }

  static AppTier get tier => _tier;
  static bool get isPro => _tier == AppTier.pro;
  static String? get activeLicenseKey => _activeLicenseKey;

  /// Number of clipboard items that may be stored at any time.
  static int get historyLimit =>
      isPro ? proHistoryLimit : freeHistoryLimit;

  /// Activate Pro with a valid license key.
  /// Throws [LicenseException] if the key is malformed or already used.
  static Future<void> activate(String rawKey) async {
    final key = rawKey.trim().toUpperCase();
    if (!_keyFormat.hasMatch(key)) {
      throw LicenseException(
        'Invalid license key format.\n'
        'Expected: CCPRO-XXXX-XXXX-XXXX',
      );
    }

    // In production, call your activation server here to enforce seat limits.
    // For now we accept any correctly-formatted key so the UX can be tested.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, key);
    _tier = AppTier.pro;
    _activeLicenseKey = key;
  }

  /// Deactivate Pro and return to the free tier.
  static Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    _tier = AppTier.free;
    _activeLicenseKey = null;
  }
}

class LicenseException implements Exception {
  final String message;
  const LicenseException(this.message);
  @override
  String toString() => message;
}

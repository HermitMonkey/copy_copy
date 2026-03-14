import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _thwackPlayer = AudioPlayer();
  static final AudioPlayer _copiedPlayer = AudioPlayer();

  static bool _isMuted = false;

  static bool get isMuted => _isMuted;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool('soundsMuted') ?? false;

      // 🛠 FIX 1: Forbid macOS from dumping the sounds from RAM when they finish
      await _clickPlayer.setReleaseMode(ReleaseMode.stop);
      await _thwackPlayer.setReleaseMode(ReleaseMode.stop);
      await _copiedPlayer.setReleaseMode(ReleaseMode.stop);

      await _clickPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _thwackPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _copiedPlayer.setPlayerMode(PlayerMode.lowLatency);

      // Pre-cache the assets
      await _clickPlayer.setSource(AssetSource('sounds/click.wav'));
      await _thwackPlayer.setSource(AssetSource('sounds/thwack.wav'));
      await _copiedPlayer.setSource(AssetSource('sounds/copied.wav'));

      print("🎵 Audio Service Initialized. Muted: $_isMuted");
    } catch (e) {
      print("⚠️ Audio Service failed to load assets: $e");
    }
  }

  static Future<void> toggleMute(bool mute) async {
    _isMuted = mute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundsMuted', mute);
  }

  static Future<void> playClick() async {
    if (_isMuted) return;
    try {
      await _clickPlayer.stop();
      // 🛠 FIX 2: Explicitly re-declare the source instead of just resuming
      await _clickPlayer.play(
        AssetSource('sounds/click.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      print("⚠️ Audio Error (click): $e");
    }
  }

  static Future<void> playThwack() async {
    if (_isMuted) return;
    try {
      await _thwackPlayer.stop();
      await _thwackPlayer.play(
        AssetSource('sounds/thwack.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      print("⚠️ Audio Error (thwack): $e");
    }
  }

  static Future<void> playCopied() async {
    if (_isMuted) return;
    try {
      await _copiedPlayer.stop();
      await _copiedPlayer.play(
        AssetSource('sounds/copied.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      print("⚠️ Audio Error (copied): $e");
    }
  }
}

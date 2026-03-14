import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Separate players so one effect doesn't cut off the other.
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _thwackPlayer = AudioPlayer();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      await _clickPlayer.setReleaseMode(ReleaseMode.stop);
      await _clickPlayer.setVolume(1.0);

      await _thwackPlayer.setReleaseMode(ReleaseMode.stop);
      await _thwackPlayer.setVolume(1.0);

      _initialized = true;
      print('🎵 Audio Service initialized.');
    } catch (e) {
      print('⚠️ Audio Service init failed: $e');
    }
  }

  static Future<void> playClick() async {
    if (!_initialized) await init();

    try {
      await _clickPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      print('⚠️ Failed to play click sound: $e');
    }
  }

  static Future<void> playThwack() async {
    if (!_initialized) await init();

    try {
      await _thwackPlayer.play(AssetSource('sounds/thwack.mp3'));
    } catch (e) {
      print('⚠️ Failed to play thwack sound: $e');
    }
  }
}

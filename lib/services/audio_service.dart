import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playClick() async {
    // Native macOS click sound (Zero-latency, no assets required)
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> playThwack() async {
    // Native macOS alert sound for deletions/major actions
    await SystemSound.play(SystemSoundType.alert);

    // NOTE: For true Sutherland Polish, uncomment below once you add 'thwack.mp3' to your assets folder
    // await _player.play(AssetSource('sounds/thwack.mp3'));
  }

  static Future<void> playSuccess() async {
    // await _player.play(AssetSource('sounds/success.mp3'));
  }
}

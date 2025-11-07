import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class HapticService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> celebrateSuccess() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();

      if (hasVibrator) {
        await Vibration.vibrate(
          pattern: [0, 100, 50, 100, 50, 200],
          intensities: [0, 128, 0, 128, 0, 255],
        );
      } else {
        await HapticFeedback.mediumImpact();
      }

      await _playSuccessSound();
    } catch (e) {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> playUndoHaptic() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();

      if (hasVibrator) {
        await Vibration.vibrate(duration: 200, amplitude: 200);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> playLightTap() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> playMediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> playHeavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> playSelectionClick() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      developer.log('Error playing success sound: $e', name: 'HapticService');
    }
  }

  static Future<void> stopAllSounds() async {
    await _audioPlayer.stop();
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}

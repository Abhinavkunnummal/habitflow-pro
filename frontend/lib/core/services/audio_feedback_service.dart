import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Centralized audio and haptic feedback service for HabitFlow Pro
class AudioFeedbackService {
  AudioFeedbackService._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  static void _init() {
    if (_isInitialized) return;
    try {
      _player.setReleaseMode(ReleaseMode.stop);
      _player.setVolume(1.0);
      _isInitialized = true;
    } catch (_) {}
  }

  /// Celebratory chime played when a habit or daily task is completed
  static Future<void> playTaskComplete() async {
    _init();
    try {
      HapticFeedback.mediumImpact();
      await _player.stop();
      await _player.play(AssetSource('sounds/task_complete.wav'));
    } catch (_) {
      // Graceful fallback to system click sound and haptic vibration
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Warm alarm gong played when a focus timer countdown finishes
  static Future<void> playTimerAlarm() async {
    _init();
    try {
      HapticFeedback.heavyImpact();
      await _player.stop();
      await _player.play(AssetSource('sounds/timer_alarm.wav'));
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Pleasant acoustic chime played for upcoming habit reminders
  static Future<void> playReminderChime() async {
    _init();
    try {
      HapticFeedback.lightImpact();
      await _player.stop();
      await _player.play(AssetSource('sounds/reminder.wav'));
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}

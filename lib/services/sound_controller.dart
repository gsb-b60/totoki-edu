import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum SoundEffect { correct, correctAlternate, finish, wrong, streak }

class SoundController extends ChangeNotifier {
  SoundController() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  final AudioPlayer _player = AudioPlayer();
  final Set<SoundEffect> _missingEffects = {};

  bool _soundEnabled = true;
  double _volume = 0.7;
  int _correctCount = 0;

  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    if (_soundEnabled == value) return;
    _soundEnabled = value;
    notifyListeners();
  }

  void setVolume(double value) {
    final nextVolume = value.clamp(0.0, 1.0).toDouble();
    if (_volume == nextVolume) return;
    _volume = nextVolume;
    notifyListeners();
  }

  Future<void> playCorrect() {
    _correctCount++;
    if (_correctCount % 4 == 0) {
      return _playCandidates(
        SoundEffect.correctAlternate,
        fallback: SoundEffect.correct,
      );
    }
    return _play(SoundEffect.correct);
  }

  Future<void> playWrong() => _play(SoundEffect.wrong);

  Future<void> playStreak() => _play(SoundEffect.streak);

  Future<void> playFinish() => _play(SoundEffect.finish);

  bool shouldCelebrateStreak(int streak) {
    return streak == 3 || streak == 5 || (streak > 5 && streak % 5 == 0);
  }

  Future<void> _play(SoundEffect effect) => _playCandidates(effect);

  Future<void> _playCandidates(
    SoundEffect effect, {
    SoundEffect? fallback,
  }) async {
    if (!_soundEnabled) return;

    final candidates = [
      ..._assetCandidates[effect]!,
      if (fallback != null) ..._assetCandidates[fallback]!,
    ];

    for (final assetPath in candidates) {
      if (!await _assetExists(assetPath)) continue;

      try {
        await _player.stop();
        await _player.setVolume(_volume);
        await _player.play(AssetSource(assetPath));
        return;
      } catch (error) {
        debugPrint('Unable to play sound effect $assetPath: $error');
      }
    }

    if (_missingEffects.add(effect)) {
      debugPrint('No sound asset found for $effect in assets/sound/.');
    }
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load('assets/$assetPath');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

const Map<SoundEffect, List<String>> _assetCandidates = {
  SoundEffect.correct: [
    'sound/correct.mp3',
    'sound/correct.wav',
    'sound/correct.ogg',
    'sound/corret.mp3',
    'sound/corret.wav',
    'sound/corret.ogg',
  ],
  SoundEffect.correctAlternate: [
    'sound/correct_ver_2.mp3',
    'sound/correct_ver_2.wav',
    'sound/correct_ver_2.ogg',
    'sound/correct-2.mp3',
    'sound/correct-2.wav',
    'sound/correct-2.ogg',
    'sound/correct_2.mp3',
    'sound/correct_2.wav',
    'sound/correct_2.ogg',
    'sound/correct2.mp3',
    'sound/correct2.wav',
    'sound/correct2.ogg',
  ],
  SoundEffect.finish: [
    'sound/finish.mp3',
    'sound/finish.wav',
    'sound/finish.ogg',
  ],
  SoundEffect.wrong: [
    'sound/wrong.mp3',
    'sound/wrong.wav',
    'sound/wrong.ogg',
  ],
  SoundEffect.streak: [
    'sound/right_in_a_row.mp3',
    'sound/right_in_a_row.wav',
    'sound/right_in_a_row.ogg',
    'sound/in_a_row.mp3',
    'sound/in_a_row.wav',
    'sound/in_a_row.ogg',
    'sound/rightinarow.mp3',
    'sound/rightinarow.wav',
    'sound/rightinarow.ogg',
  ],
};

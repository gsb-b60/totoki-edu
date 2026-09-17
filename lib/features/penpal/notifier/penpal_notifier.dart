import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/penpal_friend.dart';
import '../models/letter_stage.dart';
import '../models/penpal_message.dart';
import '../data/penpal_data.dart';

enum GameStatus { playing, won, lost }

class PenpalNotifier extends ChangeNotifier {
  PenpalFriend? _selectedFriend;
  final List<PenpalMessage> _messages = [];
  int _currentStageIndex = 0;
  int _friendshipLevel = 50;
  int _attempts = 0;
  bool _isTyping = false;
  GameStatus _gameStatus = GameStatus.playing;
  static const int _maxAttempts = 3;

  PenpalFriend? get selectedFriend => _selectedFriend;
  List<PenpalMessage> get messages => List.unmodifiable(_messages);
  int get currentStageIndex => _currentStageIndex;
  int get friendshipLevel => _friendshipLevel;
  int get attemptsRemaining => _maxAttempts - _attempts;
  int get maxAttempts => _maxAttempts;
  bool get isTyping => _isTyping;
  GameStatus get gameStatus => _gameStatus;

  List<LetterStage> get currentStages {
    if (_selectedFriend == null) return [];
    return PenpalData.stages[_selectedFriend!.id] ?? [];
  }

  LetterStage get currentStage {
    final stages = currentStages;
    if (_currentStageIndex >= stages.length) {
      return stages.last;
    }
    return stages[_currentStageIndex];
  }

  void selectFriend(PenpalFriend friend) {
    _selectedFriend = friend;
    _messages.clear();
    _currentStageIndex = 0;
    _friendshipLevel = 50;
    _attempts = 0;
    _gameStatus = GameStatus.playing;
    _isTyping = false;
    notifyListeners();

    _addInitialLetter();
  }

  void goBackToSelection() {
    _selectedFriend = null;
    _messages.clear();
    notifyListeners();
  }

  Future<void> _addInitialLetter() async {
    if (_selectedFriend == null) return;
    _isTyping = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));
    _messages.add(
      PenpalMessage(
        text: _selectedFriend!.initialLetter,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _isTyping = false;
    notifyListeners();
  }

  Future<void> _addSingleMessage(String text, bool isUser) async {
    if (!isUser) {
      _isTyping = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1500));
      _isTyping = false;
    }
    _messages.add(
      PenpalMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void submitReply(String text) async {
    if (_gameStatus != GameStatus.playing || _selectedFriend == null) return;
    if (_attempts >= _maxAttempts) return;

    final trimmedText = text.trim();
    if (trimmedText.length < 150) {
      await _addSingleMessage(
        'That\'s far too brief. I asked for a thoughtful response of at least 150 characters. Please take your time.',
        false,
      );
      return;
    }

    // Add user's reply
    _messages.add(
      PenpalMessage(
        text: trimmedText,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    final regex = RegExp(currentStage.keywordRegex, caseSensitive: false);
    if (!regex.hasMatch(trimmedText)) {
      _attempts++;
      _friendshipLevel = (_friendshipLevel - 10).clamp(0, 100);

      if (_attempts >= _maxAttempts) {
        _gameStatus = GameStatus.lost;
        await _addSingleMessage(
          'It seems we are not finding a common wavelength in our letters, and my time is limited. I think it is best we suspend our correspondence here. I wish you all the best.',
          false,
        );
        notifyListeners();
        return;
      }

      await _addSingleMessage(
        '${currentStage.failHint} (Attempt $_attempts/$_maxAttempts - Friendship: $_friendshipLevel%)',
        false,
      );
      notifyListeners();
      return;
    }

    // Success! Update friendship
    int friendshipReward = 15;
    if (_attempts == 1) {
      friendshipReward = 10;
    } else if (_attempts == 2) {
      friendshipReward = 5;
    }
    _friendshipLevel = (_friendshipLevel + friendshipReward).clamp(0, 100);

    // Reset attempts
    _attempts = 0;

    await _addSingleMessage(currentStage.successReply, false);

    if (_currentStageIndex >= currentStages.length - 1) {
      _gameStatus = GameStatus.won;
      notifyListeners();
      return;
    }

    // Advance stage and show next letter
    _currentStageIndex++;
    _isTyping = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1500));
    _messages.add(
      PenpalMessage(
        text: currentStage.incomingLetter,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _isTyping = false;
    notifyListeners();
  }
}
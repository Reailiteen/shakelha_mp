import 'dart:math';
import 'package:characters/characters.dart';

/// A minimal local-only game engine for pass-and-play mode.
/// This is an isolated module; no sockets.
/// It exposes simple APIs to manage players, rack tiles, turns, and scoring.
class LocalGameEngine {
  final _rng = Random();

  // Arabic letters distribution (placeholder; tune later)
  // Each entry maps a letter to its count and base score.
  static const Map<String, (int count, int score)> distribution = {
    'ا': (8, 1), 'ل': (8, 1), 'م': (6, 2), 'ن': (6, 2), 'ي': (6, 1),
    'ه': (5, 1), 'و': (5, 1), 'ر': (5, 1), 'ت': (5, 1), 'س': (4, 2),
    'ك': (4, 2), 'ب': (4, 3), 'د': (3, 2), 'ج': (2, 4), 'ش': (2, 4),
    'ص': (2, 4), 'ق': (2, 5), 'ف': (2, 4), 'ح': (2, 4), 'ع': (2, 4),
    'غ': (1, 5), 'ط': (1, 5), 'ظ': (1, 8), 'خ': (1, 5), 'ذ': (1, 8),
    'ث': (1, 5), 'ز': (1, 8), 'ض': (1, 8),
  };

  late List<String> _bag;
  final List<_LocalPlayer> _players = [];
  int _turnIndex = 0;

  LocalGameEngine() {
    _bag = _generateBag();
  }

  List<String> get bag => List.unmodifiable(_bag);
  int get currentTurn => _turnIndex;
  List<_LocalPlayer> get players => List.unmodifiable(_players);

  void reset() {
    _bag = _generateBag();
    _players.clear();
    _turnIndex = 0;
  }

  void addPlayer(String nickname) {
    _players.add(_LocalPlayer(nickname));
  }

  void start() {
    for (final p in _players) {
      _drawToRack(p);
    }
  }

  void passTurn() {
    _turnIndex = (_turnIndex + 1) % _players.length;
  }

  int scoreWord(String word) {
    int score = 0;
    for (final ch in word.characters) {
      // ignore diacritics and non-letters later; for now check map
      final e = distribution[ch];
      if (e != null) score += e.$2;
    }
    return score;
  }

  void commitMove({required int playerIndex, required String word, List<String> tilesUsed = const []}) {
    final p = _players[playerIndex];
    p.score += scoreWord(word);
    // remove used tiles from rack
    for (final t in tilesUsed) {
      p.rack.remove(t);
    }
    _drawToRack(p);
    passTurn();
  }

  void _drawToRack(_LocalPlayer p) {
    while (p.rack.length < 7 && _bag.isNotEmpty) {
      final i = _rng.nextInt(_bag.length);
      p.rack.add(_bag.removeAt(i));
    }
  }

  List<String> _generateBag() {
    final list = <String>[];
    distribution.forEach((letter, tuple) {
      for (var i = 0; i < tuple.$1; i++) {
        list.add(letter);
      }
    });
    return list..shuffle(_rng);
  }
}

class _LocalPlayer {
  final String nickname;
  final List<String> rack = [];
  int score = 0;
  _LocalPlayer(this.nickname);
}

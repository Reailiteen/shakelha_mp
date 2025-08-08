import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

/// Singleton Arabic dictionary loader backed by a HashSet for O(1) lookup.
/// Loads words from asset: lib/data/words/validWords.txt (one word per line).
class ArabicDictionary {
  ArabicDictionary._();
  static final ArabicDictionary instance = ArabicDictionary._();

  Set<String>? _words; // normalized words
  Future<void>? _loading;

  bool get isReady => _words != null;

  /// Call once early (e.g., in GameScreen.initState) to ensure dictionary is ready.
  Future<void> preload() {
    _loading ??= _load();
    return _loading!;
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('lib/data/words/validWords.txt');
    final set = <String>{};
    for (final line in raw.split(RegExp(r'\r?\n'))) {
      final w = _normalize(line);
      if (w.isNotEmpty) set.add(w);
    }
    _words = set;
  }

  // Public API
  bool containsWord(String word) {
    final normalized = _normalize(word);
    final ws = _words;
    if (ws == null) return false; // not ready yet
    return ws.contains(normalized);
  }

  List<String> getInvalidWords(List<String> words) {
    final ws = _words;
    if (ws == null) return words; // not ready yet => treat all as invalid so user gets feedback
    final invalid = <String>[];
    for (final w in words) {
      final n = _normalize(w);
      if (n.length < 2) {
        invalid.add(w);
        continue;
      }
      if (!ws.contains(n)) invalid.add(w);
    }
    return invalid;
  }

  List<String> getSuggestions(String partial, {int max = 10}) {
    final ws = _words;
    if (ws == null) return const [];
    final p = _normalize(partial);
    if (p.length < 2) return const [];
    final out = <String>[];
    for (final w in ws) {
      if (w.startsWith(p)) {
        out.add(w);
        if (out.length >= max) break;
      }
    }
    return out;
  }

  // Normalization suitable for Arabic Scrabble dictionary matches.
  String _normalize(String word) {
    var s = word.trim();
    if (s.isEmpty) return s;
    // Remove diacritics
    s = s.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    // Normalize forms
    s = s
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي');
    return s;
  }
}

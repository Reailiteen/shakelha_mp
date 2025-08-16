import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Simple DAWG-like structure for exact contains and prefix suggestions
class _TrieNode {
  final Map<int, _TrieNode> children = {};
  bool isWord = false;
}

class ArabicDictionary {
  ArabicDictionary._();
  static final ArabicDictionary instance = ArabicDictionary._();

  _TrieNode? _root;
  bool get isReady => _root != null;

  Future<void> preload() async {
    if (_root != null) return;
    try {
      await _loadFromJson();
      // Sanity: if empty, fallback to txt
      if (_root == null) {
        await _loadFromTxt();
      }
    } catch (_) {
      await _loadFromTxt();
    }
  }

  Future<void> _loadFromJson() async {
    final raw = await rootBundle.loadString('lib/data/words/validWords.json');
    final List<dynamic> list = jsonDecode(raw);
    final words = <String>[];
    for (final item in list) {
      final w = _normalize(item.toString());
      if (w.isNotEmpty) words.add(w);
    }
    words.sort();
    final root = _TrieNode();
    for (final w in words) {
      _insert(root, w);
    }
    _root = root;
  }

  Future<void> _loadFromTxt() async {
    final raw = await rootBundle.loadString('lib/data/words/validWords.txt');
    final words = <String>[];
    for (final line in raw.split(RegExp(r'\r?\n'))) {
      final w = _normalize(line);
      if (w.isNotEmpty) words.add(w);
    }
    words.sort();
    final root = _TrieNode();
    for (final w in words) {
      _insert(root, w);
    }
    _root = root;
  }

  void _insert(_TrieNode root, String word) {
    var node = root;
    for (final cp in word.runes) {
      node = node.children.putIfAbsent(cp, () => _TrieNode());
    }
    node.isWord = true;
  }

  bool containsWord(String word) {
    final r = _root;
    if (r == null) return false;
    var node = r;
    for (final cp in _normalize(word).runes) {
      final next = node.children[cp];
      if (next == null) return false;
      node = next;
    }
    return node.isWord;
  }

  List<String> getSuggestions(String partial, {int max = 10}) {
    final r = _root;
    if (r == null) return const [];
    final p = _normalize(partial);
    var node = r;
    for (final cp in p.runes) {
      final next = node.children[cp];
      if (next == null) return const [];
      node = next;
    }
    final out = <String>[];
    void dfs(_TrieNode n, List<int> acc) {
      if (out.length >= max) return;
      if (n.isWord) out.add(p + String.fromCharCodes(acc));
      final keys = n.children.keys.toList()..sort();
      for (final k in keys) {
        acc.add(k);
        dfs(n.children[k]!, acc);
        acc.removeLast();
        if (out.length >= max) return;
      }
    }
    dfs(node, <int>[]);
    return out;
  }

  String _normalize(String word) {
    var s = word.trim();
    if (s.isEmpty) return s;
    s = s.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
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



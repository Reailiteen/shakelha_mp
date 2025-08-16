class _DawgNode {
  final Map<int, _DawgNode> edges = {};
  bool isFinal = false;

  // Canonical serialization for structural hashing
  String signature() {
    final buffer = StringBuffer();
    buffer.write(isFinal ? '1' : '0');
    final keys = edges.keys.toList()..sort();
    for (final k in keys) {
      buffer.write('|');
      buffer.write(k);
      buffer.write('>');
      buffer.write(edges[k]!.hashCode);
    }
    return buffer.toString();
  }
}

/// Minimal DAWG (Directed Acyclic Word Graph) for fast exact and prefix lookup.
///
/// Build algorithm adapted from Daciuk et al. (incremental construction with
/// on-the-fly minimization). Words must be inserted in lexicographic order.
class Dawg {
  late final _DawgNode _root;

  Dawg._(this._root);

  bool contains(String word) {
    var node = _root;
    for (final cp in word.runes) {
      final next = node.edges[cp];
      if (next == null) return false;
      node = next;
    }
    return node.isFinal;
  }

  /// Returns all words starting with [prefix], up to [max] results.
  List<String> suggestions(String prefix, {int max = 10}) {
    final out = <String>[];
    var node = _root;
    final prefixRunes = prefix.runes.toList();
    for (final cp in prefixRunes) {
      final next = node.edges[cp];
      if (next == null) return out;
      node = next;
    }
    void dfs(_DawgNode n, List<int> acc) {
      if (out.length >= max) return;
      if (n.isFinal) {
        out.add(prefix + String.fromCharCodes(acc));
      }
      final keys = n.edges.keys.toList()..sort();
      for (final k in keys) {
        acc.add(k);
        dfs(n.edges[k]!, acc);
        acc.removeLast();
        if (out.length >= max) return;
      }
    }
    dfs(node, <int>[]);
    return out;
  }

  /// Builder for DAWG. Call [add] with sorted words, then [build].
  static Dawg buildFromSorted(List<String> sortedWords) {
    final builder = _DawgBuilder();
    for (final w in sortedWords) {
      builder.add(w);
    }
    return Dawg._(builder.finish());
  }
}

class _DawgBuilder {
  final _DawgNode _root = _DawgNode();
  final List<_DawgNode> _previousPath = [];
  String _previousWord = '';
  final Map<String, _DawgNode> _registry = {};

  void add(String word) {
    if (word == _previousWord) return; // skip duplicates
    // Ensure lexicographic order
    if (_previousWord.isNotEmpty && word.compareTo(_previousWord) < 0) {
      throw ArgumentError('Words must be added in lexicographic order');
    }

    int common = 0;
    final minLen = word.length < _previousWord.length ? word.length : _previousWord.length;
    while (common < minLen && word.codeUnitAt(common) == _previousWord.codeUnitAt(common)) {
      common++;
    }
    _minimize(common);

    var node = _previousPath.isEmpty ? _root : _previousPath[common - 1];
    for (int i = common; i < word.length; i++) {
      final newNode = _DawgNode();
      node.edges[word.codeUnitAt(i)] = newNode;
      _previousPath.add(newNode);
      node = newNode;
    }
    node.isFinal = true;
    _previousWord = word;
  }

  _DawgNode finish() {
    _minimize(0);
    _registry.clear();
    _previousPath.clear();
    _previousWord = '';
    return _root;
  }

  void _minimize(int downTo) {
    for (int i = _previousPath.length - 1; i >= downTo; i--) {
      final node = _previousPath[i];
      final signature = node.signature();
      final existing = _registry[signature];
      if (existing != null) {
        // Redirect edge from parent to the existing node
        final parent = i == 0 ? (downTo == 0 ? _root : _previousPath[i - 1]) : _previousPath[i - 1];
        final key = parent.edges.entries.firstWhere((e) => e.value == node).key;
        parent.edges[key] = existing;
        _previousPath.removeAt(i);
      } else {
        _registry[signature] = node;
      }
    }
  }
}


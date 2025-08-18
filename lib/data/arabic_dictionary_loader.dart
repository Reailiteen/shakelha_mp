import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Node in the DAWG structure
class _DawgNode {
  final int id;
  final bool isWord;
  final Map<String, int> edges; // char → node index

  _DawgNode({
    required this.id,
    required this.isWord,
    required this.edges,
  });

  factory _DawgNode.fromJson(Map<String, dynamic> json) {
    return _DawgNode(
      id: json['id'] as int,
      isWord: json['is_word'] as bool,
      edges: Map<String, int>.from(json['edges'] as Map),
    );
  }
}

class ArabicDictionary {
  ArabicDictionary._();
  static final ArabicDictionary instance = ArabicDictionary._();

  List<_DawgNode>? _nodes;
  bool get isReady => _nodes != null && _nodes!.isNotEmpty;

  Future<void> preload() async {
    if (_nodes != null) return;
    try {
      await _loadFromJson();
      if (_nodes == null || _nodes!.isEmpty) {
        await _loadFromTxt();
      }
    } catch (e) {
      print('[Dictionary] Error loading from JSON: $e');
      await _loadFromTxt();
    }
  }

  Future<void> _loadFromJson() async {
    try {
      final raw = await rootBundle.loadString('lib/data/words/validWords.json');
      final List<dynamic> jsonList = jsonDecode(raw);

      _nodes = <_DawgNode>[];
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          _nodes!.add(_DawgNode.fromJson(item));
        }
      }

      // Sort nodes by ID to ensure proper indexing
      _nodes!.sort((a, b) => a.id.compareTo(b.id));

      print('[Dictionary] Loaded ${_nodes!.length} nodes from JSON DAWG');
      if (_nodes!.isNotEmpty) {
        print('[Dictionary] Root node edges: ${_nodes![0].edges.keys.take(10).toList()}');
      }

      debugDawgStructure();
    } catch (e) {
      print('[Dictionary] Failed to load from JSON: $e');
      _nodes = null;
      rethrow;
    }
  }

  Future<void> _loadFromTxt() async {
    try {
      final raw = await rootBundle.loadString('lib/data/words/validWords.txt');
      final words = raw
          .split(RegExp(r'\r?\n'))
          .map(_normalize)
          .where((w) => w.isNotEmpty && w.length > 1)
          .toSet()
          .toList()
        ..sort();

      print('[Dictionary] Building DAWG from ${words.length} words from TXT');

      // Build a simple trie structure first
      final trie = _buildTrie(words);
      
      // Convert trie to node list format
      _nodes = _trieToNodes(trie);

      print('[Dictionary] Built DAWG with ${_nodes!.length} nodes');
    } catch (e) {
      print('[Dictionary] Failed to load from TXT: $e');
      _nodes = [];
    }
  }

  Map<String, dynamic> _buildTrie(List<String> words) {
    final trie = <String, dynamic>{'isWord': false, 'children': <String, dynamic>{}};
    
    for (final word in words) {
      var current = trie;
      for (final char in word.split('')) {
        current['children'] ??= <String, dynamic>{};
        current['children'][char] ??= <String, dynamic>{'isWord': false, 'children': <String, dynamic>{}};
        current = current['children'][char];
      }
      current['isWord'] = true;
    }
    
    return trie;
  }

  List<_DawgNode> _trieToNodes(Map<String, dynamic> trie) {
    final nodes = <_DawgNode>[];
    final nodeMap = <String, int>{};
    
    int nodeId = 0;
    
    void traverse(Map<String, dynamic> node, String path) {
      if (nodeMap.containsKey(path)) return;
      
      final currentId = nodeId++;
      nodeMap[path] = currentId;
      
      final edges = <String, int>{};
      final children = node['children'] as Map<String, dynamic>? ?? {};
      
      for (final entry in children.entries) {
        final char = entry.key;
        final childPath = path + char;
        traverse(entry.value as Map<String, dynamic>, childPath);
        edges[char] = nodeMap[childPath]!;
      }
      
      nodes.add(_DawgNode(
        id: currentId,
        isWord: node['isWord'] as bool,
        edges: edges,
      ));
    }
    
    traverse(trie, '');
    return nodes;
  }

  bool containsWord(String word) {
    if (_nodes == null || _nodes!.isEmpty) return false;

    final normalizedWord = _normalize(word);
    if (normalizedWord.isEmpty) return false;

    print('[Dictionary] Checking word: "$normalizedWord"');

    var currentNodeIndex = 0; // Start at root (first node)
    
    for (final char in normalizedWord.split('')) {
      if (currentNodeIndex >= _nodes!.length) {
        print('[Dictionary] Invalid node index: $currentNodeIndex');
        return false;
      }
      
      final currentNode = _nodes![currentNodeIndex];
      
      if (!currentNode.edges.containsKey(char)) {
        print('[Dictionary] Character "$char" not found in node ${currentNode.id}');
        return false;
      }
      
      currentNodeIndex = currentNode.edges[char]!;
    }

    if (currentNodeIndex >= _nodes!.length) {
      print('[Dictionary] Final node index out of bounds: $currentNodeIndex');
      return false;
    }

    final finalNode = _nodes![currentNodeIndex];
    final result = finalNode.isWord;
    print('[Dictionary] Word "$normalizedWord" ${result ? "found" : "not found"}');
    return result;
  }

  bool search(String word) => containsWord(word);

  List<String> getSuggestions(String partial, {int max = 10}) {
    if (_nodes == null || _nodes!.isEmpty) return const [];

    final normalizedPartial = _normalize(partial);
    if (normalizedPartial.isEmpty) return const [];

    // Navigate to the node representing the partial word
    var currentNodeIndex = 0;
    for (final char in normalizedPartial.split('')) {
      if (currentNodeIndex >= _nodes!.length) return const [];
      
      final currentNode = _nodes![currentNodeIndex];
      if (!currentNode.edges.containsKey(char)) return const [];
      
      currentNodeIndex = currentNode.edges[char]!;
    }

    // Collect suggestions from this point
    final suggestions = <String>[];
    
    void collectWords(int nodeIndex, String currentWord) {
      if (suggestions.length >= max || nodeIndex >= _nodes!.length) return;
      
      final node = _nodes![nodeIndex];
      
      if (node.isWord && currentWord.length > normalizedPartial.length) {
        suggestions.add(currentWord);
      }
      
      for (final entry in node.edges.entries) {
        if (suggestions.length >= max) return;
        collectWords(entry.value, currentWord + entry.key);
      }
    }
    
    collectWords(currentNodeIndex, normalizedPartial);
    return suggestions;
  }

  String _normalize(String word) {
    var s = word.trim();
    if (s.isEmpty) return s;

    // Remove diacritics (tashkeel)
    s = s.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    
    // Normalize Arabic letters
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

  void debugDawgStructure() {
    if (_nodes == null || _nodes!.isEmpty) {
      print('[Dictionary] DAWG is empty!');
      return;
    }

    print('[Dictionary] DAWG has ${_nodes!.length} nodes');
    final rootNode = _nodes![0];
    print('[Dictionary] Root node (${rootNode.id}) edges: ${rootNode.edges.keys.take(20).toList()}');

    // Test some paths
    final testChars = ['ن', 'م', 'ل'];
    for (final char in testChars) {
      if (rootNode.edges.containsKey(char)) {
        final childIndex = rootNode.edges[char]!;
        if (childIndex < _nodes!.length) {
          final childNode = _nodes![childIndex];
          print('[Dictionary] "$char" → node ${childNode.id}, isWord: ${childNode.isWord}, edges: ${childNode.edges.keys.take(10).toList()}');
        }
      }
    }

    // Test some actual words
    final testWords = ['نمل', 'كتاب', 'مدرسة', 'بيت'];
    for (final word in testWords) {
      final found = containsWord(word);
      print('[Dictionary] Test word "$word": $found');
    }
  }

  // Utility method to get statistics
  Map<String, int> getStatistics() {
    if (_nodes == null) return {'nodes': 0, 'words': 0};
    
    int wordCount = 0;
    for (final node in _nodes!) {
      if (node.isWord) wordCount++;
    }
    
    return {
      'nodes': _nodes!.length,
      'words': wordCount,
    };
  }
}
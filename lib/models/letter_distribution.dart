import 'dart:math';
import 'package:collection/collection.dart';

import 'tile.dart';

/// Manages the distribution and drawing of letter tiles
class LetterDistribution {
  /// The list of remaining tiles in the bag
  final List<Tile> _tileBag = [];
  
  /// The standard Arabic letter distribution for Scrabble
  static const Map<String, int> _standardDistribution = {
    'ا': 8, 'ب': 2, 'ت': 4, 'ث': 1, 'ج': 2, 'ح': 2, 'خ': 1, 'د': 3,
    'ذ': 1, 'ر': 6, 'ز': 1, 'س': 3, 'ش': 2, 'ص': 2, 'ض': 1, 'ط': 2,
    'ظ': 1, 'ع': 3, 'غ': 1, 'ف': 2, 'ق': 2, 'ك': 3, 'ل': 5, 'م': 4,
    'ن': 6, 'ه': 3, 'و': 4, 'ي': 6, 'ء': 2, 'ى': 2, 'ة': 3, ' ': 2, // Blank tiles (wildcards)
  };
  
  /// The point values for each Arabic letter in Scrabble
  static const Map<String, int> _letterValues = {
    'ا': 1, 'ب': 3, 'ت': 1, 'ث': 8, 'ج': 3, 'ح': 4, 'خ': 8, 'د': 2,
    'ذ': 8, 'ر': 1, 'ز': 8, 'س': 1, 'ش': 4, 'ص': 3, 'ض': 8, 'ط': 4,
    'ظ': 10, 'ع': 3, 'غ': 8, 'ف': 4, 'ق': 8, 'ك': 3, 'ل': 1, 'م': 3,
    'ن': 1, 'ه': 2, 'و': 2, 'ي': 1, 'ء': 8, 'ى': 4, 'ة': 2, ' ': 0, // Blank tiles are worth 0 points
  };

  /// Creates a new letter distribution with the standard tile set
  LetterDistribution() {
    _initializeTileBag();
  }
  
  /// Creates a letter distribution from a JSON map
  factory LetterDistribution.fromJson(Map<String, dynamic> json) {
    final distribution = LetterDistribution();
    distribution._tileBag.clear();
    
    final List<dynamic> tilesJson = json['tileBag'];
    distribution._tileBag.addAll(
      tilesJson.map((tileJson) => Tile.fromJson(tileJson)).toList(),
    );
    
    return distribution;
  }
  
  /// Converts the letter distribution to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'tileBag': _tileBag.map((tile) => tile.toJson()).toList(),
    };
  }
  
  /// Initializes the tile bag with the standard distribution
  void _initializeTileBag() {
    _tileBag.clear();
    
    _standardDistribution.forEach((letter, count) {
      final value = _letterValues[letter] ?? 0;
      
      for (var i = 0; i < count; i++) {
        _tileBag.add(Tile(
          letter: letter,
          value: value,
          isOnBoard: false,
          isNewlyPlaced: false,
          ownerId: null,
        ));
      }
    });
    
    // Shuffle the tile bag
    _tileBag.shuffle(Random());
  }
  
  /// Draws [count] tiles from the bag
  List<Tile> drawTiles(int count) {
    final drawnTiles = <Tile>[];
    final actualCount = count > _tileBag.length ? _tileBag.length : count;
    
    for (var i = 0; i < actualCount; i++) {
      drawnTiles.add(_tileBag.removeLast());
    }
    
    return drawnTiles;
  }
  
  /// Returns the number of tiles remaining in the bag
  int get tilesRemaining => _tileBag.length;
  
  /// Returns whether the bag is empty
  bool get isEmpty => _tileBag.isEmpty;
  
  /// Returns the point value for a given letter
  static int getLetterValue(String letter) {
    return _letterValues[letter.toUpperCase()] ?? 0;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;
    
    return other is LetterDistribution &&
           listEquals(_tileBag, other._tileBag);
  }
  
  @override
  int get hashCode => Object.hashAll(_tileBag);
}

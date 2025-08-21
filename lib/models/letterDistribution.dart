import 'tile.dart';

/// Manages the distribution and values of tiles in the game.
class LetterDistribution {
  /// The list of all tiles in the game, including their distribution
  final List<Tile> _allTiles;
  
  /// The current bag of available tiles
  List<Tile> _tileBag = [];

  /// Creates a new LetterDistribution with the given tiles
  LetterDistribution({required List<Tile> tiles}) : _allTiles = tiles {
    resetBag();
  }

  /// Creates a standard English Scrabble distribution
  factory LetterDistribution.english() {
    final tiles = <Tile>[];
    
    // Helper function to add multiple tiles of the same letter
    void addTiles(String letter, int count, int value) {
      for (var i = 0; i < count; i++) {
        tiles.add(Tile(letter: letter, value: value));
      }
    }
    
    return LetterDistribution(tiles: tiles..shuffle());
  }
  /// Arabic distribution (aligned with our local engine’s mapping)
  factory LetterDistribution.arabic() {
    final tiles = <Tile>[];
    void addTiles(String letter, int count, int value) {
      for (var i = 0; i < count; i++) {
        tiles.add(Tile(letter: letter, value: value));
      }
    }

    addTiles('ا', 8, 1);
    addTiles('ل', 7, 1);
    addTiles('م', 6, 2);
    addTiles('ن', 6, 2);
    addTiles('ي', 7, 1);
    addTiles('ه', 5, 2);
    addTiles('و', 7, 1);
    addTiles('ر', 5, 2);
    addTiles('ت', 6, 1);
    addTiles('س', 5, 3);
    addTiles('ك', 4, 4);
    addTiles('ب', 6, 2);
    addTiles('د', 4, 3);
    addTiles('ج', 4, 5);
    addTiles('ش', 3, 5);
    addTiles('ص', 3, 5);
    addTiles('ق', 4, 4);
    addTiles('ف', 4, 3);
    addTiles('ح', 4, 4);
    addTiles('ع', 4, 3);
    addTiles('غ', 2, 8);
    addTiles('ط', 3, 6);
    addTiles('ظ', 2, 9);
    addTiles('خ', 3, 6);
    addTiles('ذ', 2, 10);
    addTiles('ث', 2, 7);
    addTiles('ز', 3, 7);
    addTiles('ض', 2, 9);
    addTiles('ء', 4, 6);

    return LetterDistribution(tiles: tiles..shuffle());
  }

  /// Creates a LetterDistribution from a JSON map
  factory LetterDistribution.fromJson(Map<String, dynamic> json) {
    var tilesJson = json['tiles'] as List;
    List<Tile> tiles = tilesJson.map((e) => Tile.fromJson(e)).toList();
    return LetterDistribution(tiles: tiles);
  }

  /// Converts the letter distribution to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'tiles': _allTiles.map((e) => e.toJson()).toList(),
    };
  }
  
  /// Resets the tile bag with all tiles
  void resetBag() {
    _tileBag = List<Tile>.from(_allTiles);
    _tileBag.shuffle();
  }
  
  /// Draws [count] tiles from the bag
  List<Tile> drawTiles(int count, {String? ownerId}) {
    final drawn = <Tile>[];
    final available = count;
    
    for (var i = 0; i < available && _tileBag.isNotEmpty; i++) {
      final tile = _tileBag.removeLast();
      drawn.add(tile.copyWith(ownerId: ownerId));
    }
    
    return drawn;
  }

  /// Returns tiles back to the bag (e.g., after swap)
  void returnTiles(List<Tile> tiles) {
    if (tiles.isEmpty) return;
    _tileBag.addAll(
      tiles.map((t) => t.copyWith(
        isOnBoard: false,
        isNewlyPlaced: false,
        ownerId: null,
        position: null,
      ))
    );
    _tileBag.shuffle();
  }
  
  /// Returns the number of tiles remaining in the bag
  int get tilesRemaining => _tileBag.length;
  
  /// Returns a copy of the current tile bag (for display purposes)
  List<Tile> get tileBag => List.unmodifiable(_tileBag);
  
  /// Returns a copy of all tiles in the distribution (for display purposes)
  List<Tile> get allTiles => List.unmodifiable(_allTiles);
  
  /// Returns the point value for a given letter
  int getLetterValue(String letter) {
    if (letter.isEmpty) return 0;
    
    // Find the first tile with this letter to get its value
    final tile = _allTiles.firstWhere(
      (t) => t.letter == letter.toUpperCase(),
      orElse: () => Tile(letter: letter, value: 0),
    );
    
    return tile.value;
  }
}
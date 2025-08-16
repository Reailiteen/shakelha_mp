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
    
    // Letter distribution based on English Scrabble
    addTiles('A', 9, 1);
    addTiles('B', 2, 3);
    addTiles('C', 2, 3);
    addTiles('D', 4, 2);
    addTiles('E', 12, 1);
    addTiles('F', 2, 4);
    addTiles('G', 3, 2);
    addTiles('H', 2, 4);
    addTiles('I', 9, 1);
    addTiles('J', 1, 8);
    addTiles('K', 1, 5);
    addTiles('L', 4, 1);
    addTiles('M', 2, 3);
    addTiles('N', 6, 1);
    addTiles('O', 8, 1);
    addTiles('P', 2, 3);
    addTiles('Q', 1, 10);
    addTiles('R', 6, 1);
    addTiles('S', 4, 1);
    addTiles('T', 6, 1);
    addTiles('U', 4, 1);
    addTiles('V', 2, 4);
    addTiles('W', 2, 4);
    addTiles('X', 1, 8);
    addTiles('Y', 2, 4);
    addTiles('Z', 1, 10);
    addTiles(' ', 2, 0); // Blank tiles
    
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
    addTiles('ل', 8, 1);
    addTiles('م', 6, 2);
    addTiles('ن', 6, 2);
    addTiles('ي', 6, 1);
    addTiles('ه', 5, 1);
    addTiles('و', 5, 1);
    addTiles('ر', 5, 1);
    addTiles('ت', 5, 1);
    addTiles('س', 4, 2);
    addTiles('ك', 4, 2);
    addTiles('ب', 4, 3);
    addTiles('د', 3, 2);
    addTiles('ج', 2, 4);
    addTiles('ش', 2, 4);
    addTiles('ص', 2, 4);
    addTiles('ق', 2, 5);
    addTiles('ف', 2, 4);
    addTiles('ح', 2, 4);
    addTiles('ع', 2, 4);
    addTiles('غ', 1, 5);
    addTiles('ط', 1, 5);
    addTiles('ظ', 1, 8);
    addTiles('خ', 1, 5);
    addTiles('ذ', 1, 8);
    addTiles('ث', 1, 5);
    addTiles('ز', 1, 8);
    addTiles('ض', 1, 8);

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
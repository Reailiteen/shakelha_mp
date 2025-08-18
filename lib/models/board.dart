import 'tile.dart';
import 'position.dart';
import 'package:mp_tictactoe/data/arabic_dictionary_loader.dart';

/// Represents the game board with a grid of tiles
class Board {
  /// The size of the board (always square)
  final int size;
  
  /// The grid of tiles (null for empty cells)
  final List<List<Tile?>> grid;
  
  /// The positions of special multiplier cells
  final Map<Position, CellMultiplier> cellMultipliers;

  bool isFirstTurn=true;

  /// Creates a new board with the given size and grid
  Board({
    this.size = 15,
    required this.grid,
    Map<Position, CellMultiplier>? cellMultipliers,
  }) : cellMultipliers = cellMultipliers ?? const {};

  /// Creates an empty board of the given size
  factory Board.empty({int size = 15}) {
    return Board(
      size: size,
      grid: List.generate(
        size,
        (_) => List.filled(size, null),
      ),
      cellMultipliers: _createStandardMultipliers(size),
    );
  }
  
  /// Creates a board with standard Scrabble multipliers
  static Map<Position, CellMultiplier> _createStandardMultipliers(int size) {
    final multipliers = <Position, CellMultiplier>{};
    final center = size ~/ 2;
    
    // Helper to add multipliers in all four quadrants
    void addSymmetric(int row, int col, CellMultiplier multiplier) {
      final positions = [
        Position(row: row, col: col),
        Position(row: row, col: size - 1 - col),
        Position(row: size - 1 - row, col: col),
        Position(row: size - 1 - row, col: size - 1 - col),
      ];
      
      for (final pos in positions) {
        multipliers[pos] = multiplier;
      }
    }
    
    // Triple word scores (corners and center)
    addSymmetric(0, 0, CellMultiplier.word(3));
    addSymmetric(center, center, CellMultiplier.word(3));
    
    // Double word scores (diagonal from corners)
    addSymmetric(1, 1, CellMultiplier.word(2));
    
    // Triple letter scores (edges)
    addSymmetric(0, center, CellMultiplier.letter(3));
    
    // Double letter scores (star pattern)
    addSymmetric(2, 2, CellMultiplier.letter(2));
    addSymmetric(1, 4, CellMultiplier.letter(2));
    
    return multipliers;
  }

  /// Creates a Board from a JSON map
  factory Board.fromJson(Map<String, dynamic> json) {
    final gridJson = json['grid'] as List;
    final grid = gridJson.map<List<Tile?>>((row) {
      return (row as List).map<Tile?>((cell) {
        return cell == null ? null : Tile.fromJson(cell);
      }).toList();
    }).toList();
    
    final multipliersJson = json['cellMultipliers'] as Map<String, dynamic>? ?? {};
    final multipliers = multipliersJson.map((key, value) {
      final coords = key.split(',');
      final pos = Position(
        row: int.parse(coords[0]),
        col: int.parse(coords[1]),
      );
      final multiplier = CellMultiplier.fromJson(value);
      return MapEntry(pos, multiplier);
    });

    return Board(
      size: json['size'] ?? 15,
      grid: grid,
      cellMultipliers: multipliers,
    );
  }

  /// Converts the board to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'grid': grid.map((row) => row.map((tile) => tile?.toJson()).toList()).toList(),
      'cellMultipliers': cellMultipliers.map((pos, mult) => MapEntry(
        '${pos.row},${pos.col}',
        mult.toJson(),
      )),
    };
  }
  
  /// Gets the tile at the specified position
  Tile? getTileAt(Position position) {
    if (!_isValidPosition(position)) return null;
    return grid[position.row][position.col];
  }
  
  bool isValidFirstTurn(List<Tile> newlyPlacedTiles){
    if (newlyPlacedTiles.isEmpty ) return false;

  // Step 1: Ensure all tiles are in same row or column
    final positions = newlyPlacedTiles.map((t) => t.position!).toList();
    bool isRow = positions.first.row == positions.last.row;
    bool isCol = positions.first.col == positions.last.col;
    if (!isRow && !isCol) return false;

    // Must cover center cell on first move
    final center = centerPosition;
    final coversCenter = positions.any((p) => p == center);
    if (!coversCenter) return false;

    // Step 3: Collect main word (we ignore points and dictionary here)
    final _ = buildWordFrom(newlyPlacedTiles.first.position!, isRow);

    isFirstTurn = false;

    return true;
  }
  (bool, int) isValidSubmission(List<Tile> newlyPlacedTiles) {

    if (isFirstTurn) {
      return (isValidFirstTurn(newlyPlacedTiles), 0);
    }
  if (newlyPlacedTiles.isEmpty ) return (false, 0);

  // Step 1: Ensure all tiles are in same row or column
  final positions = newlyPlacedTiles.map((t) => t.position!).toList();
  bool isRow = positions.first.row == positions.last.row;
  bool isCol = positions.first.col == positions.last.col;
  if (!isRow && !isCol) return (false, 0);

  // Step 2: Ensure at least one adjacent tile exists (connects to board)
  bool isConnected = false;
  for (final tile in newlyPlacedTiles) {
    for (final neighborPos in getAdjacentPositions(tile.position!)) {
      final neighbor = getTileAt(neighborPos);
      if (neighbor != null && !newlyPlacedTiles.contains(neighbor)) {
        isConnected = true;
        break;
      }
    }
  }
  if (!isConnected) return (false, 0);
  int collectedPoints;
  // Step 3: Collect main word (ignore actual string here)
  collectedPoints = buildWordFrom(newlyPlacedTiles.first.position!, isRow).$2;

  // Step 4: Check perpendicular words from each new tile
  for (final tile in newlyPlacedTiles) {
    final pair = buildWordFrom(tile.position!, !isRow);
    collectedPoints += pair.$2;
  }

  return (true, collectedPoints);
}

  /// Validates a move and the words formed using in-board rules and Arabic dictionary.
  /// Returns (isValid, message, points, wordsFormed)
  (bool, String, int, List<String>) validateAndScoreMove(List<Tile> newlyPlacedTiles) {
    // Rule check
    final (ok, pts) = isValidSubmission(newlyPlacedTiles);
    if (!ok) return (false, 'الحركة غير صالحة', 0, const []);

    // Build words formed by overlaying tiles on a temp board
    final temp = Board.fromJson(toJson());
    for (final t in newlyPlacedTiles) {
      temp.placeTile(t, t.position!);
    }
    final words = temp._collectWordsFormed(newlyPlacedTiles);

    // Dictionary check
    final dict = ArabicDictionary.instance;
    if (!dict.isReady) {
      // Soft-fail to avoid false negatives; ask user to retry
      return (false, 'القاموس غير جاهز', 0, const []);
    }
    for (final w in words) {
      if (w.trim().length < 2) {
        return (false, 'كلمة قصيرة: $w', 0, const []);
      }
      if (!dict.containsWord(w)) {
        return (false, 'كلمة غير موجودة: $w', 0, const []);
      }
    }

    return (true, 'صحيحة', pts, words);
  }

  List<String> _collectWordsFormed(List<Tile> newlyPlacedTiles) {
    // Determine primary direction using first and last tile pos
    final pos = newlyPlacedTiles.map((t) => t.position!).toList();
    final isRow = pos.first.row == pos.last.row;

    final words = <String>[];
    final (main, _) = buildWordFrom(newlyPlacedTiles.first.position!, isRow);
    if (main.length > 1) words.add(main);

    for (final t in newlyPlacedTiles) {
      final (cross, __) = buildWordFrom(t.position!, !isRow);
      if (cross.length > 1) words.add(cross);
    }
    return words;
  }

/// Builds a word starting from a given position in a direction.
  (String, int) buildWordFrom(Position start, bool isRow) {
    // Move backwards to find start of word
    Position p = start;
    int collectedPoints = 0;
    while (true) {
      Position prev = isRow ? Position(row: p.row, col: p.col - 1) : Position(row: p.row - 1, col: p.col);
      if (getTileAt(prev) == null) break;
      p = prev;
    }

    // Move forwards collecting letters
    StringBuffer buffer = StringBuffer();
    while (true) {
      final tile = getTileAt(p);
      if (tile == null) break;
      if(cellMultipliers.containsKey(tile.position)){
        final mult = cellMultipliers[tile.position]!;
        if (mult.isWordMultiplier) {
          // For word multiplier, add base letter value now; word multiplier application
          // is approximated by multiplying here (simple handling). For full accuracy,
          // this would be applied to the total word later.
          collectedPoints += tile.value * mult.value;
        } else {
          collectedPoints += tile.value * mult.value;
        }
      }else{
        collectedPoints += tile.value;
      }
      buffer.write(tile.letter);
      p = isRow ? Position(row: p.row, col: p.col + 1) : Position(row: p.row + 1, col: p.col);
    }

    String word = buffer.toString();
    return (word, collectedPoints);
  }

  /// Returns a new Board with the tile placed
  void placeTile(Tile tile, Position position) {
    if (!_isValidPosition(position)) return;
    grid[position.row][position.col] = tile;
    tile.position = position;
  }
  
  /// Removes a tile from the specified position
  /// Returns a new Board with the tile removed
  void removeTile(Position position) {

    Tile tile = getTileAt(position)!;
    if (!_isValidPosition(position)) {
      return;
    }
    tile.position = null;
    grid[position.row][position.col] = null;
  }
  
  /// Gets all the tiles on the board with their positions
  List<Tile> getAllTiles() {
    final tiles = <Tile>[];
    
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final tile = grid[row][col];
        if (tile != null) {
          tiles.add(tile);
        }
      }
    }
    
    return tiles;
  }
  
  /// Checks if a position is within the bounds of the board
  bool _isValidPosition(Position pos) {
    return pos.row >= 0 &&
           pos.row < size &&
           pos.col >= 0 &&
           pos.col < size;
  }
  
  /// Gets all positions that are adjacent to the given position
  Iterable<Position> getAdjacentPositions(Position pos) sync* {
    final offsets = [
      {'dr': 0, 'dc': -1},  // left
      {'dr': 0, 'dc': 1},   // right
      {'dr': -1, 'dc': 0},  // up
      {'dr': 1, 'dc': 0},   // down
    ];
    
    for (final offset in offsets) {
      final newPos = Position(
        row: pos.row + offset['dr']!,
        col: pos.col + offset['dc']!,
      );
      if (_isValidPosition(newPos)) {
        yield newPos;
      }
    }
  }
  
  /// Gets the center position of the board
  Position get centerPosition => Position(row: size ~/ 2, col: size ~/ 2);
  
  /// Checks if the board is empty (first move)
  bool get isEmpty => getAllTiles().isEmpty;
  
  @override
  String toString() {
    final buffer = StringBuffer();
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final tile = grid[row][col];
        buffer.write(tile?.letter ?? '.');
        buffer.write(' ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}



/// Represents a cell multiplier (letter or word)
class CellMultiplier {
  /// Whether this is a letter or word multiplier
  final bool isWordMultiplier;
  
  /// The multiplier value (e.g., 2 for double, 3 for triple)
  final int value;
  
  /// Whether this multiplier has been used
  bool isUsed;
  
  /// Creates a letter multiplier
  CellMultiplier.letter(this.value, [this.isUsed = false])
      : isWordMultiplier = false;
  
  /// Creates a word multiplier
  CellMultiplier.word(this.value, [this.isUsed = false])
      : isWordMultiplier = true;
  
  /// Creates a CellMultiplier from a JSON map
  factory CellMultiplier.fromJson(Map<String, dynamic> json) {
    final isWordMultiplier = json['isWordMultiplier'] as bool;
    final value = json['value'] as int;
    final isUsed = json['isUsed'] as bool? ?? false;
    
    return isWordMultiplier
        ? CellMultiplier.word(value, isUsed)
        : CellMultiplier.letter(value, isUsed);
  }
  
  /// Converts the multiplier to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'isWordMultiplier': isWordMultiplier,
      'value': value,
      'isUsed': isUsed,
    };
  }
  
  /// Creates a copy of this multiplier with updated fields
  CellMultiplier copyWith({
    bool? isUsed,
  }) {
    return isWordMultiplier
        ? CellMultiplier.word(value, isUsed ?? this.isUsed)
        : CellMultiplier.letter(value, isUsed ?? this.isUsed);
  }
  
  @override
  String toString() => '${isWordMultiplier ? 'Word' : 'Letter'}x$value';
}


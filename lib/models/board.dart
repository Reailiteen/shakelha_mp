import 'tile.dart';
import 'position.dart';

/// Represents the game board with a grid of tiles
class Board {
  /// The size of the board (always square)
  final int size;
  
  /// The grid of tiles (null for empty cells)
  final List<List<Tile?>> grid;
  
  /// The positions of special multiplier cells
  final Map<Position, CellMultiplier> cellMultipliers;

  /// Creates a new board with the given size and grid
  const Board({
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
  
  /// Places a tile at the specified position
  /// Returns a new Board with the tile placed
  Board placeTile(Tile tile, Position position) {
    if (!_isValidPosition(position)) return this;
    
    final newGrid = List<List<Tile?>>.from(
      grid.map((row) => List<Tile?>.from(row)),
    );
    
    newGrid[position.row][position.col] = tile;
    
    return Board(
      size: size,
      grid: newGrid,
      cellMultipliers: cellMultipliers,
    );
  }
  
  /// Removes a tile from the specified position
  /// Returns a new Board with the tile removed
  Board removeTile(Position position) {
    if (!_isValidPosition(position) || getTileAt(position) == null) {
      return this;
    }
    
    final newGrid = List<List<Tile?>>.from(
      grid.map((row) => List<Tile?>.from(row)),
    );
    
    newGrid[position.row][position.col] = null;
    
    return Board(
      size: size,
      grid: newGrid,
      cellMultipliers: cellMultipliers,
    );
  }
  
  /// Gets all the tiles on the board with their positions
  Map<Position, Tile> getAllTiles() {
    final tiles = <Position, Tile>{};
    
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final tile = grid[row][col];
        if (tile != null) {
          tiles[Position(row: row, col: col)] = tile;
        }
      }
    }
    
    return tiles;
  }
  
  /// Gets all empty positions adjacent to existing tiles
  Set<Position> getEmptyAdjacentPositions() {
    final emptyAdjacent = <Position>{};
    final directions = [
      Position(row: -1, col: 0), // up
      Position(row: 1, col: 0),  // down
      Position(row: 0, col: -1), // left
      Position(row: 0, col: 1),  // right
    ];
    
    // First, find all positions with tiles
    final tilePositions = <Position>[];
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (grid[row][col] != null) {
          tilePositions.add(Position(row: row, col: col));
        }
      }
    }
    
    // If no tiles, return center position for first move
    if (tilePositions.isEmpty) {
      final center = size ~/ 2;
      return {Position(row: center, col: center)};
    }
    
    // Find all empty adjacent positions
    for (final pos in tilePositions) {
      for (final dir in directions) {
        final newPos = Position(
          row: pos.row + dir.row,
          col: pos.col + dir.col,
        );
        
        if (_isValidPosition(newPos) && getTileAt(newPos) == null) {
          emptyAdjacent.add(newPos);
        }
      }
    }
    
    return emptyAdjacent;
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
  
  /// Gets all non-empty positions on the board
  Iterable<Position> getOccupiedPositions() sync* {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (grid[row][col] != null) {
          yield Position(row: row, col: col);
        }
      }
    }
  }
  
  /// Gets the center position of the board
  Position get centerPosition => Position(row: size ~/ 2, col: size ~/ 2);
  
  /// Checks if the board is empty (first move)
  bool get isEmpty => !getOccupiedPositions().any((_) => true);
  
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


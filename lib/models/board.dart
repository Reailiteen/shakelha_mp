import 'tile.dart';
import 'position.dart';
import 'package:shakelha_mp/data/arabic_dictionary_loader.dart';
import 'package:flutter/material.dart';

/// Arabic Scrabble Rules Implemented:
/// 1. Starting Word: First word must pass through the center square
/// 2. Connecting Words: Every new word must connect to existing word structure
/// 3. Placement Continuity: Tiles placed in a turn must form continuous word in one direction
/// 4. Multiple Word Formation: Placing tiles may create multiple valid words (crosswords)
/// 5. No Partial Words: Only valid Arabic dictionary words are allowed
/// 6. Word Validation: All words formed must be checked against dictionary before accepting move

/// Word validation status for real-time feedback
enum WordValidationStatus { valid, invalid, pending }

/// Represents a validated word with visual feedback properties
class ValidatedWord {
  final String text;
  final List<Position> positions;
  final bool isHorizontal;
  final WordValidationStatus status;
  final Position startPosition;
  final Position endPosition;

  const ValidatedWord({
    required this.text,
    required this.positions,
    required this.isHorizontal,
    required this.status,
    required this.startPosition,
    required this.endPosition,
  });

  Color get feedbackColor {
    switch (status) {
      case WordValidationStatus.valid:
        return const Color(0xFF4CAF50); // Green
      case WordValidationStatus.invalid:
        return const Color(0xFFF44336); // Red
      case WordValidationStatus.pending:
        return const Color(0xFFFFC107); // Amber
    }
  }

  ValidatedWord copyWith({WordValidationStatus? status}) {
    return ValidatedWord(
      text: text,
      positions: positions,
      isHorizontal: isHorizontal,
      status: status ?? this.status,
      startPosition: startPosition,
      endPosition: endPosition,
    );
  }
}

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
    this.size = 13, // Changed from 15 to 13
    required this.grid,
    Map<Position, CellMultiplier>? cellMultipliers,
  }) : cellMultipliers = cellMultipliers ?? const {};

  /// Creates an empty board of the given size
  factory Board.empty({int size = 13}) { // Changed from 15 to 13
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
    
    // Triple word scores (corners only - no center)
    addSymmetric(0, 0, CellMultiplier.word(3));
    
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

    final board = Board(
      size: json['size'] ?? 13, // Changed from 15 to 13
      grid: grid,
      cellMultipliers: multipliers,
    );
    
    // Preserve the isFirstTurn flag from the original board
    board.isFirstTurn = json['isFirstTurn'] ?? true;
    
    return board;
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
      'isFirstTurn': isFirstTurn,
    };
  }
  
  /// Gets the tile at the specified position
  Tile? getTileAt(Position position) {
    if (!_isValidPosition(position)) return null;
    return grid[position.row][position.col];
  }
  
  bool isValidFirstTurn(List<Tile> newlyPlacedTiles){
    print('[Board] isValidFirstTurn called with ${newlyPlacedTiles.length} tiles');
    for (int i = 0; i < newlyPlacedTiles.length; i++) {
      final tile = newlyPlacedTiles[i];
      print('[Board]   Tile [$i]: "${tile.letter}" at position (${tile.position!.row},${tile.position!.col})');
    }
    if (newlyPlacedTiles.isEmpty ) {
      print('[Board] First turn validation failed: no tiles');
      return false;
    }

    // Step 1: Ensure all tiles are in same row or column (continuity)
    if (!_areTilesContinuous(newlyPlacedTiles)) {
      print('[Board] First turn validation failed: tiles not continuous');
      return false;
    }

    // Step 2: MUST pass through center square
    final centerPos = centerPosition;
    print('[Board] Center position: (${centerPos.row},${centerPos.col})');
    bool passesCenter = false;
    
    // Create temporary board with tiles placed to check the full word
    final tempBoard = Board.fromJson(toJson());
    for (final tile in newlyPlacedTiles) {
      tempBoard.placeTile(tile, tile.position!);
    }
    
    // Check if any word formed passes through center
    final positions = newlyPlacedTiles.map((t) => t.position!).toList();
    final isRow = _isHorizontalPlacement(positions);
    
    // Build the complete word that includes the newly placed tiles
    final (word, _) = tempBoard.buildWordFrom(newlyPlacedTiles.first.position!, isRow);
    print('[Board] Complete word formed: "$word"');
    print('[Board] Placement is ${isRow ? 'horizontal' : 'vertical'}');
    
    // Check if the word passes through center by examining all positions in the word
    Position wordStart = newlyPlacedTiles.first.position!;
    // Find actual start of word by going backwards
    while (true) {
      Position prev = isRow ? 
          Position(row: wordStart.row, col: wordStart.col - 1) : 
          Position(row: wordStart.row - 1, col: wordStart.col);
      if (tempBoard.getTileAt(prev) == null) break;
      wordStart = prev;
    }
    
    print('[Board] Word starts at: (${wordStart.row},${wordStart.col})');
    
    // Check each position in the word
    for (int i = 0; i < word.length; i++) {
      Position wordPos = isRow ? 
          Position(row: wordStart.row, col: wordStart.col + i) : 
          Position(row: wordStart.row + i, col: wordStart.col);
      print('[Board] Word position [$i]: (${wordPos.row},${wordPos.col}) - letter: "${word[i]}"');
      
      if (wordPos.row == centerPos.row && wordPos.col == centerPos.col) {
        passesCenter = true;
        print('[Board] ✓ Word passes through center at position (${wordPos.row},${wordPos.col})');
        break;
      }
    }
    
    if (!passesCenter) {
      print('[Board] ✗ First turn validation failed: word "$word" does not pass through center (${centerPos.row},${centerPos.col})');
      print('[Board]   Word positions: ${[for (int i = 0; i < word.length; i++) isRow ? Position(row: wordStart.row, col: wordStart.col + i) : Position(row: wordStart.row + i, col: wordStart.col)].map((p) => '(${p.row},${p.col})').join(', ')}');
      return false;
    }

    print('[Board] ✓ First turn validation successful: word "$word" passes through center');
    return true;
  }
  (bool, int) isValidSubmission(List<Tile> newlyPlacedTiles) {

    if (isFirstTurn) {
      print('[Board] First turn validation for tiles: ${newlyPlacedTiles.map((t) => '${t.letter}@${t.position}').join(', ')}');
      final isValid = isValidFirstTurn(newlyPlacedTiles);
      print('[Board] First turn validation result: $isValid');
      if (!isValid) return (false, 0);
      
      // For first turn, calculate points normally
      final positions = newlyPlacedTiles.map((t) => t.position!).toList();
      bool isRow = _isHorizontalPlacement(positions);
      
      int collectedPoints = 0;
      // Collect main word points
      final (mainWord, mainPoints) = buildWordFrom(newlyPlacedTiles.first.position!, isRow);
      collectedPoints = mainPoints;
      print('[Board] First turn main word: "$mainWord" = $mainPoints points');

      // Check perpendicular words from each new tile
      for (final tile in newlyPlacedTiles) {
        final (crossWord, crossPoints) = buildWordFrom(tile.position!, !isRow);
        if (crossWord.length > 1) {
          print('[Board] First turn cross word: "$crossWord" = $crossPoints points');
          collectedPoints += crossPoints;
        }
      }
      
      print('[Board] First turn total points: $collectedPoints');
      return (true, collectedPoints);
    }
    
    if (newlyPlacedTiles.isEmpty ) return (false, 0);

    // Step 1: Ensure placement continuity (tiles form continuous word in one direction)
    if (!_areTilesContinuous(newlyPlacedTiles)) {
      print('[Board] Validation failed: tiles not continuous');
      return (false, 0);
    }

    // Step 2: Ensure word connectivity (connects to existing word structure)
    if (!_isProperlyConnected(newlyPlacedTiles)) {
      print('[Board] Validation failed: not properly connected to existing words');
      return (false, 0);
    }
    
    int collectedPoints;
    final positions = newlyPlacedTiles.map((t) => t.position!).toList();
    bool isRow = _isHorizontalPlacement(positions);
    
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
    print('[Board] validateAndScoreMove called with ${newlyPlacedTiles.length} tiles');
    print('[Board] Tiles: ${newlyPlacedTiles.map((t) => '${t.letter}@${t.position}').join(', ')}');
    
    // Rule check (without scoring - we'll do that on the temp board)
    final (ok, _) = isValidSubmission(newlyPlacedTiles);
    if (!ok) {
      print('[Board] Basic rule validation failed');
      return (false, 'الحركة غير صالحة - لا تتبع قواعد اللعبة', 0, const []);
    }

    // Build words formed by overlaying tiles on a temp board
    final temp = Board.fromJson(toJson());
    for (final t in newlyPlacedTiles) {
      temp.placeTile(t, t.position!);
    }
    final words = temp._collectWordsFormed(newlyPlacedTiles);
    
    // Calculate points using the temporary board with tiles placed
    int totalPoints = 0;
    final positions = newlyPlacedTiles.map((t) => t.position!).toList();
    bool isRow = positions.first.row == positions.last.row;
    
    // Main word points
    final (mainWord, mainPoints) = temp.buildWordFrom(newlyPlacedTiles.first.position!, isRow);
    if (mainWord.length > 1) {
      totalPoints += mainPoints;
      print('[Board] Main word: "$mainWord" = $mainPoints points');
    }
    
    // Cross word points
    for (final tile in newlyPlacedTiles) {
      final (crossWord, crossPoints) = temp.buildWordFrom(tile.position!, !isRow);
      if (crossWord.length > 1) {
        totalPoints += crossPoints;
        print('[Board] Cross word: "$crossWord" = $crossPoints points');
      }
    }
    
    // Debug logging for word formation and scoring
    print('[Board] Newly placed tiles: ${newlyPlacedTiles.map((t) => '${t.letter}@${t.position}').join(', ')}');
    print('[Board] Words formed: $words');
    print('[Board] Total points calculated: $totalPoints');

    // Dictionary check - ALL words formed must be valid
    final dict = ArabicDictionary.instance;
    if (!dict.isReady) {
      // Soft-fail to avoid false negatives; ask user to retry
      return (false, 'القاموس غير جاهز', 0, const []);
    }
    
    // Check each word formed
    for (final w in words) {
      final cleanWord = w.trim();
      
      // No single letters allowed (except in very specific cases)
      if (cleanWord.length < 2) {
        return (false, 'كلمة قصيرة جداً: $cleanWord', 0, const []);
      }
      
      // Must be valid Arabic dictionary word
      if (!dict.containsWord(cleanWord)) {
        return (false, 'كلمة غير موجودة في القاموس: $cleanWord', 0, const []);
      }
      
      print('[Board] Valid word found: "$cleanWord"');
    }
    
    // Ensure at least one word was formed (no isolated tiles)
    if (words.isEmpty) {
      return (false, 'لم يتم تكوين كلمات صالحة', 0, const []);
    }

    print('[Board] Final validation result: valid=true, points=$totalPoints, words=$words');
    
    // Note: First turn completion should be handled by the game controller
    // after tiles are actually placed on the board
    
    return (true, 'جميع الكلمات صحيحة', totalPoints, words);
  }

  List<String> _collectWordsFormed(List<Tile> newlyPlacedTiles) {
    // Determine primary direction using first and last tile pos
    final pos = newlyPlacedTiles.map((t) => t.position!).toList();
    final isRow = pos.first.row == pos.last.row;

    final words = <String>[];
    
    // Collect the main word formed by the placement
    if (isRow) {
      // Sort positions by column for horizontal words
      pos.sort((a, b) => a.col.compareTo(b.col));
      // Start from leftmost tile (Arabic is RTL but word detection is LTR)
      final (main, _) = buildWordFrom(pos.first, isRow);
      if (main.length > 1) words.add(main);
    } else {
      // For vertical words, start from the topmost tile
      pos.sort((a, b) => a.row.compareTo(b.row));
      final (main, _) = buildWordFrom(pos.first, isRow);
      if (main.length > 1) words.add(main);
    }

    // Check perpendicular words from each newly placed tile
    // This catches crosswords formed by the new placement
    for (final t in newlyPlacedTiles) {
      final (cross, _) = buildWordFrom(t.position!, !isRow);
      if (cross.length > 1) {
        // Avoid duplicates
        if (!words.contains(cross)) {
          words.add(cross);
        }
      }
    }
    
    print('[Board] Words collected: $words');
    return words;
  }

  /// Builds a word starting from a given position in a direction.
  (String, int) buildWordFrom(Position start, bool isRow) {
    print('[Board] buildWordFrom called: start=${start.row},${start.col}, isRow=$isRow');
    
    // Move backwards to find start of word
    Position p = start;
    int wordMultiplier = 1;
    List<int> letterValues = [];
    
    // First pass: find the actual start of the word by going backwards
    int stepsBack = 0;
    while (true) {
      Position prev = isRow ? Position(row: p.row, col: p.col - 1) : Position(row: p.row - 1, col: p.col);
      if (getTileAt(prev) == null) break;
      p = prev;
      stepsBack++;
    }
    print('[Board] buildWordFrom: went back $stepsBack steps to find start at ${p.row},${p.col}');

    // Second pass: collect letters and calculate scores from start to end
    StringBuffer buffer = StringBuffer();
    int stepsForward = 0;
    while (true) {
      final tile = getTileAt(p);
      if (tile == null) break;
      
      // Get base letter value
      int letterValue = tile.value;
      
      // Apply letter multipliers
      if (cellMultipliers.containsKey(tile.position)) {
        final mult = cellMultipliers[tile.position]!;
        if (mult.isWordMultiplier) {
          wordMultiplier *= mult.value;
        } else {
          letterValue *= mult.value;
        }
      }
      
      letterValues.add(letterValue);
      buffer.write(tile.letter);
      
      // Move forward in the word direction
      p = isRow ? Position(row: p.row, col: p.col + 1) : Position(row: p.row + 1, col: p.col);
      stepsForward++;
    }

    // Calculate total score: sum of letter values × word multiplier
    final collectedPoints = letterValues.fold<int>(0, (sum, value) => sum + value) * wordMultiplier;

    String word = buffer.toString();
    
    // Debug logging for word building
    if (word.length > 1) {
      print('[Board] Built word: "$word" from ${start.row},${start.col} ${isRow ? 'horizontal' : 'vertical'}');
      print('[Board]   Letter values: $letterValues');
      print('[Board]   Word multiplier: $wordMultiplier');
      print('[Board]   Final score: $collectedPoints');
      print('[Board]   Steps: back=$stepsBack, forward=$stepsForward');
    }
    
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
  Position get centerPosition {
    // For a 13x13 board (0-indexed), center is at (6,6)
    final center = Position(row: size ~/ 2, col: size ~/ 2);
    print('[Board] Center position calculated as: (${center.row},${center.col}) for board size $size');
    return center;
  }
  
  /// Checks if a position has a multiplier (special cell)
  bool isSpecialPosition(Position position) {
    return cellMultipliers.containsKey(position);
  }
  
  /// Gets the multiplier at a specific position, or null if none exists
  CellMultiplier? getMultiplierAt(Position position) {
    return cellMultipliers[position];
  }
  
  /// Gets all positions that have multipliers (special cells)
  Set<Position> get specialPositions => cellMultipliers.keys.toSet();
  
  /// Checks if the board is empty (first move)
  bool get isEmpty => getAllTiles().isEmpty;
  
  /// Completes the first turn and updates the board state
  void completeFirstTurn() {
    if (isFirstTurn) {
      isFirstTurn = false;
      print('[Board] First turn completed, subsequent moves will require connectivity');
    }
  }
  
  /// Checks if tiles form a continuous word in one direction (prevents L-shaped placements)
  /// PUBLIC method for external validation
  bool areTilesContinuous(List<Tile> tiles) {
    return _areTilesContinuous(tiles);
  }
  
  /// Checks if tiles form a continuous word in one direction (prevents L-shaped placements)
  bool _areTilesContinuous(List<Tile> tiles) {
    if (tiles.isEmpty) return false;
    if (tiles.length == 1) return true;
    
    final positions = tiles.map((t) => t.position!).toList();
    print('[Board] Checking continuity for tiles at: ${positions.map((p) => '(${p.row},${p.col})').join(', ')}');
    
    // SCRABBLE RULE: All tiles placed in one turn must be in the same row OR same column
    // This prevents L-shaped placements which are invalid in Scrabble
    final isRow = _isHorizontalPlacement(positions);
    final isCol = _isVerticalPlacement(positions);
    
    print('[Board] Placement analysis: isHorizontal=$isRow, isVertical=$isCol');
    
    // Exactly ONE of these must be true (not both, not neither)
    if (!isRow && !isCol) {
      print('[Board] ✗ INVALID: Tiles form L-shape or scattered placement');
      print('[Board]   Scrabble rule: All tiles in one turn must be in same row OR same column');
      print('[Board]   Example INVALID: tiles at (7,5), (7,6), (8,6) - forms L-shape');
      print('[Board]   Example VALID: tiles at (7,5), (7,6), (7,7) - all same row');
      return false;
    }
    
    if (isRow && isCol) {
      // This should only happen with single tile, but let's be explicit
      if (positions.length > 1) {
        print('[Board] ✗ INVALID: Impossible placement detected (both horizontal and vertical)');
        return false;
      }
    }
    
    print('[Board] ✓ Valid straight-line placement detected');
    
    // Now check for gaps in the continuous line
    // Sort positions and check for gaps
    if (isRow) {
      positions.sort((a, b) => a.col.compareTo(b.col));
      // Check for continuity - may have existing tiles filling gaps
      final startCol = positions.first.col;
      final endCol = positions.last.col;
      
      // Check that all positions between start and end have tiles
      // (either newly placed or existing on board)
      for (int col = startCol; col <= endCol; col++) {
        final pos = Position(row: positions.first.row, col: col);
        final existingTile = getTileAt(pos);
        final isNewTile = tiles.any(
          (t) => t.position!.row == pos.row && t.position!.col == pos.col
        );
        
        // Must have either existing tile or newly placed tile at each position
        if (!isNewTile && existingTile == null) {
          print('[Board] ✗ Gap found in horizontal word at column $col - word not continuous');
          print('[Board]   All positions between start and end must have tiles (new or existing)');
          return false;
        }
      }
    } else {
      positions.sort((a, b) => a.row.compareTo(b.row));
      // Check for continuity - may have existing tiles filling gaps
      final startRow = positions.first.row;
      final endRow = positions.last.row;
      
      // Check that all positions between start and end have tiles
      for (int row = startRow; row <= endRow; row++) {
        final pos = Position(row: row, col: positions.first.col);
        final existingTile = getTileAt(pos);
        final isNewTile = tiles.any(
          (t) => t.position!.row == pos.row && t.position!.col == pos.col
        );
        
        // Must have either existing tile or newly placed tile at each position
        if (!isNewTile && existingTile == null) {
          print('[Board] ✗ Gap found in vertical word at row $row - word not continuous');
          print('[Board]   All positions between start and end must have tiles (new or existing)');
          return false;
        }
      }
    }
    
    return true;
  }
  
  /// Determines if placement is horizontal
  bool _isHorizontalPlacement(List<Position> positions) {
    if (positions.length <= 1) return true;
    return positions.every((pos) => pos.row == positions.first.row);
  }
  
  /// Determines if placement is vertical  
  bool _isVerticalPlacement(List<Position> positions) {
    if (positions.length <= 1) return true;
    return positions.every((pos) => pos.col == positions.first.col);
  }
  
  /// Ensures proper connectivity to existing word structure
  bool _isProperlyConnected(List<Tile> newlyPlacedTiles) {
    if (isEmpty) return true; // First move doesn't need connectivity
    
    // The new tiles must connect to the existing word structure in one of these ways:
    // 1. At least one new tile is adjacent to an existing tile
    // 2. The new tiles extend an existing word
    // 3. The new tiles intersect with existing words (crossword style)
    
    bool hasConnection = false;
    
    for (final tile in newlyPlacedTiles) {
      final tilePos = tile.position!;
      
      // Check all four directions for existing tiles
      for (final neighborPos in getAdjacentPositions(tilePos)) {
        final neighbor = getTileAt(neighborPos);
        
        // If we find an existing tile that's not part of the new placement
        if (neighbor != null && !newlyPlacedTiles.any((t) => t.position == neighborPos)) {
          hasConnection = true;
          print('[Board] Connection found: tile at ${tilePos.row},${tilePos.col} connects to existing tile at ${neighborPos.row},${neighborPos.col}');
          break;
        }
      }
      
      if (hasConnection) break;
    }
    
    // Alternative: Check if placement extends existing words
    if (!hasConnection) {
      final positions = newlyPlacedTiles.map((t) => t.position!).toList();
      final isRow = _isHorizontalPlacement(positions);
      
      // Check if we're extending an existing word
      if (isRow) {
        positions.sort((a, b) => a.col.compareTo(b.col));
        final leftmostPos = positions.first;
        final rightmostPos = positions.last;
        
        // Check if there are existing tiles extending this word
        final leftExtension = Position(row: leftmostPos.row, col: leftmostPos.col - 1);
        final rightExtension = Position(row: rightmostPos.row, col: rightmostPos.col + 1);
        
        if (getTileAt(leftExtension) != null || getTileAt(rightExtension) != null) {
          hasConnection = true;
          print('[Board] Connection found: extending existing horizontal word');
        }
      } else {
        positions.sort((a, b) => a.row.compareTo(b.row));
        final topmostPos = positions.first;
        final bottommostPos = positions.last;
        
        // Check if there are existing tiles extending this word
        final topExtension = Position(row: topmostPos.row - 1, col: topmostPos.col);
        final bottomExtension = Position(row: bottommostPos.row + 1, col: bottommostPos.col);
        
        if (getTileAt(topExtension) != null || getTileAt(bottomExtension) != null) {
          hasConnection = true;
          print('[Board] Connection found: extending existing vertical word');
        }
      }
    }
    
    if (!hasConnection) {
      print('[Board] Connection validation failed: no connection to existing word structure');
      print('[Board] New tiles must either:');
      print('[Board]   1. Be adjacent to existing tiles');
      print('[Board]   2. Extend existing words');
      print('[Board]   3. Form crosswords with existing tiles');
    }
    
    return hasConnection;
  }
  
  /// Real-time word validation - detects and validates all words on current board state
  /// Now includes full Scrabble rule validation for comprehensive feedback
  List<ValidatedWord> validateAllWords({String? Function(Position)? getTileAt, List<Tile>? pendingTiles}) {
    final detectedWords = <ValidatedWord>[];
    
    // Use provided getTileAt function or default to board state
    String? tileAt(Position pos) {
      if (getTileAt != null) return getTileAt(pos);
      final tile = this.getTileAt(pos);
      return tile?.letter;
    }
    
    // For comprehensive validation, we need to consider the full game context
    bool hasAnyPendingTiles = pendingTiles?.isNotEmpty ?? false;
    
    // Detect horizontal words
    for (int row = 0; row < size; row++) {
      detectedWords.addAll(_detectWordsInRow(row, tileAt, pendingTiles: pendingTiles));
    }
    
    // Detect vertical words
    for (int col = 0; col < size; col++) {
      detectedWords.addAll(_detectWordsInColumn(col, tileAt, pendingTiles: pendingTiles));
    }
    
    // Handle single tiles with Scrabble rule context
    detectedWords.addAll(_detectSingleTiles(tileAt, pendingTiles: pendingTiles));
    
    // Debug output for word detection
    print('[Board] validateAllWords detected ${detectedWords.length} words:');
    for (final word in detectedWords) {
      print('[Board]   "${word.text}" (${word.status.name}) at positions ${word.positions.map((p) => '(${p.row},${p.col})').join(', ')}');
    }
    
    return detectedWords;
  }
  
  /// Detect single tiles with comprehensive Scrabble rule validation
  List<ValidatedWord> _detectSingleTiles(String? Function(Position) getTileAt, {List<Tile>? pendingTiles}) {
    final singleTiles = <ValidatedWord>[];
    
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final position = Position(row: row, col: col);
        final letter = getTileAt(position);
        
        if (letter != null && letter.isNotEmpty) {
          // Check if this is a single tile (no adjacent tiles in same row or column)
          bool hasHorizontalNeighbor = false;
          bool hasVerticalNeighbor = false;
          
          // Check horizontal neighbors
          if (col > 0) {
            final leftPos = Position(row: row, col: col - 1);
            if (getTileAt(leftPos) != null) hasHorizontalNeighbor = true;
          }
          if (col < size - 1) {
            final rightPos = Position(row: row, col: col + 1);
            if (getTileAt(rightPos) != null) hasHorizontalNeighbor = true;
          }
          
          // Check vertical neighbors
          if (row > 0) {
            final upPos = Position(row: row - 1, col: col);
            if (getTileAt(upPos) != null) hasVerticalNeighbor = true;
          }
          if (row < size - 1) {
            final downPos = Position(row: row + 1, col: col);
            if (getTileAt(downPos) != null) hasVerticalNeighbor = true;
          }
          
          // If no neighbors in either direction, it's a single tile
          if (!hasHorizontalNeighbor && !hasVerticalNeighbor) {
            // For single tiles, determine validity using Scrabble rules
            WordValidationStatus status;
            
            // Check if this is part of a first turn placement
            bool isFirstTurnPlacement = isFirstTurn && pendingTiles != null && pendingTiles.isNotEmpty;
            
            if (isFirstTurnPlacement) {
              // For first turn, single tiles are valid if they're part of center placement
              if (row == size ~/ 2 && col == size ~/ 2) {
                status = WordValidationStatus.valid;
              } else {
                // Check if this single tile will connect to form a word through center
                status = _validateFirstTurnSingleTile(position, pendingTiles!);
              }
            } else {
              // Single letters are generally invalid in Arabic Scrabble
              status = WordValidationStatus.invalid;
            }
            
            singleTiles.add(ValidatedWord(
              text: letter,
              positions: [position],
              isHorizontal: true,
              status: status,
              startPosition: position,
              endPosition: position,
            ));
          }
        }
      }
    }
    
    return singleTiles;
  }
  
  /// Detect words in a specific row (horizontal) with enhanced Scrabble validation
  List<ValidatedWord> _detectWordsInRow(int row, String? Function(Position) getTileAt, {List<Tile>? pendingTiles}) {
    final words = <ValidatedWord>[];
    int startCol = -1;
    String currentWord = '';
    List<Position> currentPositions = [];
    
    for (int col = 0; col <= size; col++) {
      final position = Position(row: row, col: col);
      final letter = col < size ? getTileAt(position) : null;
      
      if (letter != null && letter.isNotEmpty) {
        if (startCol == -1) startCol = col;
        currentWord += letter;
        currentPositions.add(position);
      } else {
        // Word ended or no tile at this position
        if (currentWord.isNotEmpty) {
          final wordLength = currentWord.length;
          if (wordLength >= 2) {
            // Enhanced validation that considers Scrabble rules
            final status = _validateWordWithScrabbleRules(
              currentWord, 
              currentPositions, 
              true, // isHorizontal
              pendingTiles: pendingTiles
            );
            
            words.add(ValidatedWord(
              text: currentWord,
              positions: List.from(currentPositions),
              isHorizontal: true,
              status: status,
              startPosition: Position(row: row, col: startCol),
              endPosition: Position(row: row, col: startCol + wordLength - 1),
            ));
          }
        }
        startCol = -1;
        currentWord = '';
        currentPositions.clear();
      }
    }
    return words;
  }
  
  /// Detect words in a specific column (vertical) with enhanced Scrabble validation
  List<ValidatedWord> _detectWordsInColumn(int col, String? Function(Position) getTileAt, {List<Tile>? pendingTiles}) {
    final words = <ValidatedWord>[];
    int startRow = -1;
    String currentWord = '';
    List<Position> currentPositions = [];
    
    for (int row = 0; row <= size; row++) {
      final position = Position(row: row, col: col);
      final letter = row < size ? getTileAt(position) : null;
      
      if (letter != null && letter.isNotEmpty) {
        if (startRow == -1) startRow = row;
        currentWord += letter;
        currentPositions.add(position);
      } else {
        // Word ended or no tile at this position
        if (currentWord.isNotEmpty) {
          final wordLength = currentWord.length;
          if (wordLength >= 2) {
            // Enhanced validation that considers Scrabble rules
            final status = _validateWordWithScrabbleRules(
              currentWord, 
              currentPositions, 
              false, // isHorizontal
              pendingTiles: pendingTiles
            );
            
            words.add(ValidatedWord(
              text: currentWord,
              positions: List.from(currentPositions),
              isHorizontal: false,
              status: status,
              startPosition: Position(row: startRow, col: col),
              endPosition: Position(row: startRow + wordLength - 1, col: col),
            ));
          }
        }
        startRow = -1;
        currentWord = '';
        currentPositions.clear();
      }
    }
    return words;
  }
  
  /// Validate word text against dictionary with enhanced Scrabble rule consideration
  WordValidationStatus _validateWordWithScrabbleRules(String word, List<Position> positions, bool isHorizontal, {List<Tile>? pendingTiles}) {
    if (word.trim().isEmpty) return WordValidationStatus.invalid;
    
    final cleanWord = word.trim();
    
    // Single letters require special handling
    if (cleanWord.length == 1) {
      // Check if this is a first turn scenario
      if (isFirstTurn && pendingTiles != null && pendingTiles.isNotEmpty) {
        // For first turn, single letters are only valid if part of center placement
        final centerPos = centerPosition;
        bool includesCenter = positions.any((pos) => pos.row == centerPos.row && pos.col == centerPos.col);
        return includesCenter ? WordValidationStatus.valid : WordValidationStatus.invalid;
      }
      // Single letters are generally invalid in Scrabble
      return WordValidationStatus.invalid;
    }
    
    // Multi-letter words: check dictionary + Scrabble rules
    final dict = ArabicDictionary.instance;
    if (!dict.isReady) return WordValidationStatus.pending;
    
    // Dictionary validation
    bool isValidDictWord = dict.containsWord(cleanWord);
    
    // For first turn, also check center square requirement
    if (isFirstTurn && pendingTiles != null && pendingTiles.isNotEmpty) {
      final centerPos = centerPosition;
      bool passesCenter = positions.any((pos) => pos.row == centerPos.row && pos.col == centerPos.col);
      
      // First turn words must pass through center AND be valid dictionary words
      if (!passesCenter) {
        return WordValidationStatus.invalid;
      }
    }
    
    return isValidDictWord ? WordValidationStatus.valid : WordValidationStatus.invalid;
  }
  
  /// Validate single tiles in first turn context
  WordValidationStatus _validateFirstTurnSingleTile(Position position, List<Tile> pendingTiles) {
    // Check if this single tile will become part of a word passing through center
    final centerPos = centerPosition;
    
    // If the single tile is at center, it's valid
    if (position.row == centerPos.row && position.col == centerPos.col) {
      return WordValidationStatus.valid;
    }
    
    // Check if other pending tiles would form a word through center with this tile
    final allPositions = pendingTiles.map((t) => t.position!).toList();
    
    // Check if the word formed by all pending tiles passes through center
    final isRow = _isHorizontalPlacement(allPositions);
    
    if (isRow) {
      // For horizontal placement, check if any position is in same row as center
      final centerRow = centerPos.row;
      bool sameRowAsCenter = allPositions.any((pos) => pos.row == centerRow);
      if (sameRowAsCenter) {
        // Check if the word span includes center column
        allPositions.sort((a, b) => a.col.compareTo(b.col));
        final minCol = allPositions.first.col;
        final maxCol = allPositions.last.col;
        if (minCol <= centerPos.col && centerPos.col <= maxCol) {
          return WordValidationStatus.valid;
        }
      }
    } else {
      // For vertical placement, check if any position is in same column as center
      final centerCol = centerPos.col;
      bool sameColAsCenter = allPositions.any((pos) => pos.col == centerCol);
      if (sameColAsCenter) {
        // Check if the word span includes center row
        allPositions.sort((a, b) => a.row.compareTo(b.row));
        final minRow = allPositions.first.row;
        final maxRow = allPositions.last.row;
        if (minRow <= centerPos.row && centerPos.row <= maxRow) {
          return WordValidationStatus.valid;
        }
      }
    }
    
    return WordValidationStatus.invalid;
  }
  
  /// Legacy word validation method for backward compatibility
  WordValidationStatus _validateWordText(String word) {
    return _validateWordWithScrabbleRules(word, [], true);
  }
  
  /// Debug method to test center square and word validation
  String debugFirstTurnPlacement(List<Position> positions, List<String> letters) {
    final buffer = StringBuffer();
    buffer.writeln('=== DEBUG FIRST TURN PLACEMENT ===');
    buffer.writeln('Board size: $size');
    buffer.writeln('Center position: ${centerPosition}');
    buffer.writeln('Positions provided: ${positions.map((p) => '(${p.row},${p.col})').join(', ')}');
    buffer.writeln('Letters: ${letters.join('')}');
    
    // Check if horizontal or vertical
    final isRow = _isHorizontalPlacement(positions);
    buffer.writeln('Placement direction: ${isRow ? 'horizontal' : 'vertical'}');
    
    // Check continuity
    if (isRow) {
      final sortedPos = List<Position>.from(positions)..sort((a, b) => a.col.compareTo(b.col));
      buffer.writeln('Sorted by column: ${sortedPos.map((p) => '(${p.row},${p.col})').join(', ')}');
      final startCol = sortedPos.first.col;
      final endCol = sortedPos.last.col;
      buffer.writeln('Column range: $startCol to $endCol');
    } else {
      final sortedPos = List<Position>.from(positions)..sort((a, b) => a.row.compareTo(b.row));
      buffer.writeln('Sorted by row: ${sortedPos.map((p) => '(${p.row},${p.col})').join(', ')}');
      final startRow = sortedPos.first.row;
      final endRow = sortedPos.last.row;
      buffer.writeln('Row range: $startRow to $endRow');
    }
    
    // Check center square coverage
    final center = centerPosition;
    bool coversCenter = false;
    
    if (isRow) {
      // Check if all tiles are in center row and span includes center column
      final centerRow = center.row;
      final sameRow = positions.every((p) => p.row == centerRow);
      if (sameRow) {
        final cols = positions.map((p) => p.col).toList()..sort();
        final minCol = cols.first;
        final maxCol = cols.last;
        coversCenter = minCol <= center.col && center.col <= maxCol;
        buffer.writeln('All in center row ($centerRow): $sameRow');
        buffer.writeln('Column span $minCol-$maxCol covers center column ${center.col}: $coversCenter');
      }
    } else {
      // Check if all tiles are in center column and span includes center row
      final centerCol = center.col;
      final sameCol = positions.every((p) => p.col == centerCol);
      if (sameCol) {
        final rows = positions.map((p) => p.row).toList()..sort();
        final minRow = rows.first;
        final maxRow = rows.last;
        coversCenter = minRow <= center.row && center.row <= maxRow;
        buffer.writeln('All in center column ($centerCol): $sameCol');
        buffer.writeln('Row span $minRow-$maxRow covers center row ${center.row}: $coversCenter');
      }
    }
    
    buffer.writeln('Covers center square: $coversCenter');
    buffer.writeln('Word formed: ${letters.join('')}');
    buffer.writeln('================================');
    
    return buffer.toString();
  }
  
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




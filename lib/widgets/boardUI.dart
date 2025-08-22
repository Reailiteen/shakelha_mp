import 'package:flutter/material.dart';
import 'package:shakelha_mp/models/position.dart';
import 'package:shakelha_mp/models/move.dart';
import 'package:shakelha_mp/models/tile.dart';
import 'package:shakelha_mp/provider/pass_play_provider.dart';
import 'package:shakelha_mp/provider/game_provider.dart';
import 'package:provider/provider.dart';

// Import board.dart to access word validation classes
import 'package:shakelha_mp/models/board.dart';
import 'package:shakelha_mp/provider/tile_theme_provider.dart';
import 'package:shakelha_mp/widgets/tileUI.dart';

enum GameMode {
  passAndPlay,
  multiplayer,
}

class BoardUI extends StatefulWidget {
  final int boardSize;
  final GameMode gameMode;
  
  const BoardUI({
    Key? key, 
    this.boardSize = 13, // Default to 13x13
    this.gameMode = GameMode.passAndPlay, // Default to pass & play
  }) : super(key: key);
  
  @override
  State<BoardUI> createState() => _BoardUIState();
}

class _BoardUIState extends State<BoardUI> {
  late double _cellSize;
  
  @override
  Widget build(BuildContext context) {
    // Use the appropriate provider based on game mode
    final passPlay = widget.gameMode == GameMode.passAndPlay 
        ? context.watch<PassPlayProvider>()
        : null;
    final gameProvider = widget.gameMode == GameMode.multiplayer 
        ? context.watch<GameProvider>()
        : null;
    
    // Get the active provider
    final activeProvider = widget.gameMode == GameMode.passAndPlay ? passPlay : gameProvider;
    
    if (activeProvider == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate board size to fit available space - make it square and fit width
    final double availableWidth = screenWidth ; // Use 90% of screen width
    final double availableHeight = screenHeight * 0.55; // Reduced from 0.5 to 0.4 for more compact height
    final double boardSize = availableWidth < availableHeight ? availableWidth : availableHeight;

    // Helper function for decorative dots
    Widget circle([double size = 8]) => Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFECD6), Color(0xFFEDDABE), Color(0xFFD9B91)],
        ),
        shape: BoxShape.circle,
      ),
    );

    // Calculate cell size for the configurable board
    final int gridSize = widget.boardSize;
    final double totalSpacing = (gridSize - 1) * 1.0; // 1px spacing between cells
    final double totalBorder = 8.0; // Border width
    _cellSize = (boardSize - totalBorder - totalSpacing) / gridSize;
    
    // Flag to enable/disable the dotted ribbon design
    const bool showDottedRibbon = false; // Set to true to enable the circle design
    
    return Center(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Stack(
          children: [
            // Bordered board container with grid inside
            Container(
              width: boardSize,
              height: boardSize,
              decoration: BoxDecoration(
                color: const Color(0xE4BD8C).withOpacity(1), // Beige background
                border: Border.all(color: const Color(0xFFDAA864), width: 8, strokeAlign: BorderSide.strokeAlignInside),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(0.0), // No padding
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Get exact grid dimensions for precise positioning
                    final gridWidth = constraints.maxWidth;
                    final int gridSize = widget.boardSize;
                    final actualCellSize = (gridWidth - (gridSize - 1)) / gridSize; // 1px spacing between cells
                    
                    // Update cell size for outline generation
                    _cellSize = actualCellSize;
                    
                    // Create a Stack with positioned cells instead of GridView
                    return Stack(
                      children: [
                        // Generate all board cells as positioned containers
                        ...List.generate(gridSize * gridSize, (index) {
                          final row = index ~/ gridSize;
                          final col = index % gridSize;
                          final pos = Position(row: row, col: col);
                          
                          // Get tile data based on game mode
                          final existingTile = _getExistingTile(activeProvider, pos);
                          final pending = _getPendingTile(activeProvider, pos);
                          final hasPending = pending.tile.letter.isNotEmpty;
                          final displayLetter = existingTile?.letter ?? (hasPending ? pending.tile.letter : '');
                          final displayPoints = existingTile?.value ?? (hasPending ? pending.tile.value : 0);
                          
                          final bool isSpecial = _isSpecialPosition(activeProvider, pos);
                          Color? specialColor;
                          String? multiplierText;
                          
                          if (isSpecial) {
                            // Get the actual multiplier to determine styling
                            final multiplier = _getMultiplier(activeProvider, pos);
                            if (multiplier != null) {
                              if (multiplier.isWordMultiplier) {
                                // Word multipliers get dark blue color
                                specialColor = const Color(0xFF1E3A8A); // Dark blue
                                multiplierText = 'x${multiplier.value}';
                              } else {
                                // Letter multipliers get purple color
                                specialColor = const Color(0xFF9C27B0); // Purple
                                multiplierText = 'x${multiplier.value}';
                              }
                            }
                          }
                          
                          // Check if this position is part of any validated words for visual feedback
                          final wordsAtPosition = _getValidatedWords(activeProvider).where((word) =>
                            word.positions.any((wordPos) => wordPos.row == row && wordPos.col == col) &&
                            // Only show feedback for words involving newly placed tiles
                            word.positions.any((pos) =>
                              _getPendingPlacements(activeProvider).any((placement) => placement.position == pos)
                            )
                          ).toList();
                          
                          final hasValidWord = wordsAtPosition.any((w) => w.status == WordValidationStatus.valid);
                          final hasInvalidWord = wordsAtPosition.any((w) => w.status == WordValidationStatus.invalid);
                          
                          // Calculate position for this cell using the helper method
                          final position = _getTilePosition(row, col, actualCellSize);
                          
                          return Positioned(
                            left: position.dx,
                            top: position.dy,
                            width: actualCellSize,
                            height: actualCellSize,
                            child: DragTarget<Object>(
                              onWillAccept: (data) {
                                final isMyTurn = _isMyTurn(activeProvider);
                                final isEmpty = (existingTile == null) && !hasPending;
                                final canAccept = (data is Tile || data is PlacedTile) && isEmpty;
                                
                                if (!isMyTurn) {
                                  return false;
                                }
                                return canAccept;
                              },
                              onAccept: (data) {
                                if (data is Tile) {
                                  _placeDraggedTile(activeProvider, data, pos);
                                } else if (data is PlacedTile) {
                                  _movePendingTile(activeProvider, data.position, pos);
                                }
                              },
                              builder: (context, candidate, rejected) {
                                final isHovering = candidate.isNotEmpty;
                                final cellContent = Container(
                                  decoration: BoxDecoration(
                                    color: isSpecial 
                                        ? (specialColor ?? const Color(0xFFFFECD6))
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: _getCellBorderColor(hasValidWord, hasInvalidWord, const Color(0xFFAB8756)),
                                      width: _getCellBorderWidth(hasValidWord, hasInvalidWord),
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: isSpecial && multiplierText != null 
                                      ? Center(
                                          child: Text(
                                            multiplierText!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  offset: const Offset(1, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black.withOpacity(0.8),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : null,
                                );

                                Widget tileVisual(String letter, int points, double size) => TileUI(
                                      width: size,
                                      height: size,
                                      letter: letter,
                                      points: points,
                                      left: 0,
                                      top: 0,
                                      tileColors: TileColors.classic, // Use wooden theme for board tiles
                                    );

                                Widget stack = Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    cellContent,
                                    if (displayLetter.isNotEmpty)
                                      Center(child: FractionallySizedBox(widthFactor: 0.9, heightFactor: 0.9, child: tileVisual(displayLetter, displayPoints, 24.4))), // Increased from 22 to 26.4 (1.2x larger)
                                    if (isHovering)
                                      Container(color: Colors.yellow.withOpacity(0.2)),
                                  ],
                                );

                                if (hasPending && _isMyTurn(activeProvider)) {
                                  return Draggable<PlacedTile>(
                                    data: pending,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(width: 28, height: 28, child: tileVisual(displayLetter, displayPoints, 28)),
                                    ),
                                    childWhenDragging: Container(),
                                    onDragEnd: (details) {},
                                    child: GestureDetector(
                                      onDoubleTap: () {
                                        _removePendingPlacement(activeProvider, pos);
                                      },
                                      child: stack,
                                    ),
                                  );
                                }
                                return stack;
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            // Word validation overlay using positioned containers (much more reliable than CustomPaint)
            if (_isWordValidationEnabled(activeProvider))
              ..._generateWordOverlays(_getValidatedWords(activeProvider), _getPendingPlacements(activeProvider), _cellSize),
            
            // Scoring preview and validation feedback for the last placed tile
            if (_getPendingPlacements(activeProvider).isNotEmpty)
              ..._generateScoringAndValidationOverlays(activeProvider, _cellSize),
            
            // Debug grid overlay (disabled)
            if (false) // Set to true to enable debug grid
              IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: DebugGridPainter(
                    cellSize: _cellSize,
                    boardSize: boardSize,
                    gridSize: widget.boardSize,
                  ),
                ),
              ),
            
            // Dotted ribbon above the border
            if (showDottedRibbon)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final h = c.maxHeight;
                    const double inset = 8; // slightly outside to sit over the stroke
                    const double dotSize = 8;
                    final double step = boardSize * 0.04; // Smaller step for more dots
                    final int countH = ((w - inset * 2) / step).ceil(); // Use ceil to ensure coverage
                    final int countV = ((h - inset * 2) / step).ceil(); // Use ceil to ensure coverage
                    final List<Widget> dots = [];
                    
                    // Horizontal dots (top and bottom)
                    for (int i = 0; i <= countH; i++) {
                      final dx = inset + i * step - dotSize / 2;
                      // Ensure we don't go beyond the right edge
                      if (dx + dotSize <= w - inset) {
                        dots.add(Positioned(left: dx, top: inset - dotSize / 2, child: circle(dotSize)));
                        dots.add(Positioned(left: dx, top: h - inset - dotSize / 2, child: circle(dotSize)));
                      }
                    }
                    
                    // Vertical dots (left and right)
                    for (int i = 0; i <= countV; i++) {
                      final dy = inset + i * step - dotSize / 2;
                      // Ensure we don't go beyond the bottom edge
                      if (dy + dotSize <= h - inset) {
                        dots.add(Positioned(left: inset - dotSize / 2, top: dy, child: circle(dotSize)));
                        dots.add(Positioned(left: w - inset - dotSize / 2, top: dy, child: circle(dotSize)));
                      }
                    }
                    
                    // Ensure corner dots are always present
                    dots.add(Positioned(left: inset - dotSize / 2, top: inset - dotSize / 2, child: circle(dotSize))); // Top-left
                    dots.add(Positioned(left: w - inset - dotSize / 2, top: inset - dotSize / 2, child: circle(dotSize))); // Top-right
                    dots.add(Positioned(left: inset - dotSize / 2, top: h - inset - dotSize / 2, child: circle(dotSize))); // Bottom-left
                    dots.add(Positioned(left: w - inset - dotSize / 2, top: h - inset - dotSize / 2, child: circle(dotSize))); // Bottom-right
                    
                    return IgnorePointer(child: Stack(children: dots));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Calculate the position of a tile on the board based on its row and column
  /// This ensures consistent positioning regardless of screen size
  Offset _getTilePosition(int row, int col, double cellSize) {
    const double gridSpacing = 1.0; // Consistent with board layout
    final left = col * (cellSize + gridSpacing);
    final top = row * (cellSize + gridSpacing);
    return Offset(left, top);
  }

  /// Get the position of a tile on the board (public method for external use)
  /// Returns the Offset (left, top) for the given row and column
  Offset getTilePosition(int row, int col) {
    return _getTilePosition(row, col, _cellSize);
  }

  /// Get the current cell size being used by the board
  double get currentCellSize => _cellSize;

  

  /// Generate positioned container overlays for word validation
  List<Widget> _generateWordOverlays(List<ValidatedWord> words, List<PlacedTile> pendingPlacements, double cellSize) {
    // Only show overlays for words that involve newly placed tiles
    final relevantWords = words.where((word) {
      return word.positions.any((pos) =>
        pendingPlacements.any((placement) => placement.position == pos)
      );
    }).toList();
    
    return relevantWords.map((word) {
      // Only show green outlines for valid words - no red outlines for invalid words
      if (word.status != WordValidationStatus.valid) {
        return const SizedBox.shrink();
      }
      
      // Calculate the bounding rectangle for the word
      final positions = word.positions;
      if (positions.isEmpty) return const SizedBox.shrink();
      
      // Sort positions to find bounds
      final sortedByRow = List<Position>.from(positions)..sort((a, b) => a.row.compareTo(b.row));
      final sortedByCol = List<Position>.from(positions)..sort((a, b) => a.col.compareTo(b.col));
      
      final minRow = sortedByRow.first.row;
      final maxRow = sortedByRow.last.row;
      final minCol = sortedByCol.first.col;
      final maxCol = sortedByCol.last.col;
      
      // Use the consistent position calculation method
      final topLeft = _getTilePosition(minRow, minCol, cellSize);
      
      // Calculate dimensions - the overlay should exactly cover the tiles
      // Account for the fact that tiles use 90% of cell size (FractionallySizedBox with 0.9 factor)
      final tileSize = cellSize ; // Tiles are 90% of cell size
      final tileSpacing = 0; // 10% spacing around tiles
      
      // For single tiles, width and height should equal tileSize
      // For multiple tiles, account for the spacing between them
      final width = (maxCol - minCol + 1) * tileSize + (maxCol - minCol) * tileSpacing;
      final height = (maxRow - minRow + 1) * tileSize + (maxRow - minRow) * tileSpacing;
      
      // Center the overlay over the tiles
      final offsetX = 6; // Center horizontally
      final offsetY = 2; // Center vertically
      
      return Positioned(
        left: topLeft.dx + offsetX,
        top: topLeft.dy + offsetY,
        width: width,
        height: height,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: word.feedbackColor,
                width: 2.0,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Generate positioned container overlays for scoring and validation feedback for the last placed tile
  List<Widget> _generateScoringAndValidationOverlays(dynamic provider, double cellSize) {
    final lastPlacedTile = _getPendingPlacements(provider).last;
    final lastPlacedPosition = lastPlacedTile.position;
    
    final List<Widget> overlays = [];
    
    // Check validation status for ALL words involving the current placement
    // This includes the main word and any side words formed
    final allRelevantWords = _getValidatedWords(provider).where((word) =>
      word.positions.any((wordPos) => 
        _getPendingPlacements(provider).any((placement) => placement.position == wordPos)
      )
    ).toList();
    
    final hasValidWord = allRelevantWords.any((w) => w.status == WordValidationStatus.valid);
    final hasInvalidWord = allRelevantWords.any((w) => w.status == WordValidationStatus.invalid);
    final isValidPlacement = hasValidWord && !hasInvalidWord;
    
    // Calculate potential score for current placement
    final potentialScore = _calculatePotentialScore(provider, _getPendingPlacements(provider));
    
    // Get tile position and size
    final position = _getTilePosition(lastPlacedPosition.row, lastPlacedPosition.col, cellSize);
    final double tileSize = cellSize; // 90% of cell size
    final double offsetX = 5; // Center horizontally
    final double offsetY = 5; // Center vertically
    
    // Scoring preview bubble (only show if placement is valid)
    if (isValidPlacement) {
      overlays.add(
        Positioned(
          left: position.dx + offsetX - 25,
          top: position.dy + offsetY - 45,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$potentialScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Show multiplier indicator if on special cell
                  if (_hasMultiplier(provider, lastPlacedPosition))
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getMultiplierText(provider, lastPlacedPosition),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Red overlay for invalid placements - cover the ENTIRE word, not just the last tile
    if (hasInvalidWord) {
      // Find all positions that are part of invalid words
      final invalidWordPositions = <Position>{};
      for (final word in allRelevantWords) {
        if (word.status == WordValidationStatus.invalid) {
          invalidWordPositions.addAll(word.positions);
        }
      }
      
      // Calculate the bounding rectangle for all invalid word positions
      if (invalidWordPositions.isNotEmpty) {
        final sortedByRow = invalidWordPositions.toList()..sort((a, b) => a.row.compareTo(b.row));
        final sortedByCol = invalidWordPositions.toList()..sort((a, b) => a.col.compareTo(b.col));
        
        final minRow = sortedByRow.first.row;
        final maxRow = sortedByRow.last.row;
        final minCol = sortedByCol.first.col;
        final maxCol = sortedByCol.last.col;
        
        // Use the same positioning logic as word overlays
        final topLeft = _getTilePosition(minRow, minCol, cellSize);
        final double tileSize = cellSize;
        final double tileSpacing = 0;
        
        // Calculate dimensions for the entire word
        final width = (maxCol - minCol + 1) * tileSize + (maxCol - minCol) * tileSpacing;
        final height = (maxRow - minRow + 1) * tileSize + (maxRow - minRow) * tileSpacing;
        
        // Center the overlay over the tiles
        final offsetX = 3;
        final offsetY = 2;
        
        overlays.add(
          Positioned(
            left: topLeft.dx + offsetX,
            top: topLeft.dy + offsetY,
            width: width,
            height: height,
            child: IgnorePointer(
              child: GestureDetector(
                onTap: () => _showValidationError(context, allRelevantWords),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 2.0,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return overlays;
  }
  
  /// Calculate potential score for current tile placement
  int _calculatePotentialScore(dynamic provider, List<PlacedTile> pendingPlacements) {
    if (pendingPlacements.isEmpty) return 0;
    
    // Get the board from the provider to check multipliers
    final board = _getBoard(provider);
    
    if (board != null) {
      // Find ALL words that involve the pending placements
      final allRelevantWords = _getValidatedWords(provider).where((word) =>
        word.positions.any((wordPos) => 
          pendingPlacements.any((placement) => placement.position == wordPos)
        )
      ).toList();
      
      int totalScore = 0;
      
      // Calculate score for each word
      for (final word in allRelevantWords) {
        if (word.status == WordValidationStatus.valid) {
          int wordScore = 0;
          int wordMultiplier = 1;
          
          // Sum up points for ALL tiles in the word (new + existing)
          for (final position in word.positions) {
            int tileScore = 0;
            
            // Check if this position has a newly placed tile
            final pendingTile = pendingPlacements.firstWhere(
              (p) => p.position == position,
              orElse: () => PlacedTile(tile: Tile(letter: ''), position: position),
            );
            
            if (pendingTile.tile.letter.isNotEmpty) {
              // This is a newly placed tile - eligible for multipliers
              tileScore = pendingTile.tile.value;
              
              // Apply letter multipliers ONLY to newly placed tiles
              if (board.isSpecialPosition(position)) {
                final multiplier = board.getMultiplierAt(position);
                if (multiplier != null && !multiplier.isWordMultiplier) {
                  tileScore *= multiplier.value;
                }
              }
            } else {
              // This is an existing tile on the board - NO multipliers, just base value
              final existingTile = board.getTileAt(position);
              if (existingTile != null) {
                tileScore = existingTile.value; // Base value only, no multipliers
              }
            }
            
            wordScore += tileScore;
          }
          
          // Apply word multipliers ONLY if newly placed tiles are on multiplier cells
          for (final position in word.positions) {
            // Check if this position has a newly placed tile AND is a special position
            final hasNewTile = pendingPlacements.any((p) => p.position == position);
            if (hasNewTile && board.isSpecialPosition(position)) {
              final multiplier = board.getMultiplierAt(position);
              if (multiplier != null && multiplier.isWordMultiplier) {
                wordMultiplier *= multiplier.value;
                break; // Only apply the first word multiplier to avoid confusion
              }
            }
          }
          
          totalScore += wordScore * wordMultiplier;
        }
      }
      
      return totalScore;
    } else {
      // Fallback: just sum pending tile values if no board available
      int totalScore = 0;
      for (final placement in pendingPlacements) {
        totalScore += placement.tile.value;
      }
      return totalScore;
    }
  }
  
  /// Show validation error details in a snackbar
  void _showValidationError(BuildContext context, List<ValidatedWord> wordsAtPosition) {
    final invalidWords = wordsAtPosition.where((w) => w.status == WordValidationStatus.invalid).toList();
    if (invalidWords.isNotEmpty) {
      // Show all invalid words, not just the first one
      final errorMessages = invalidWords.map((word) => 'Invalid word: "${word.text}"').toList();
      final errorMessage = errorMessages.join('\n');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5), // Increased duration for multiple errors
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
  
  /// Helper to check if a position has a letter multiplier
  bool _hasMultiplier(dynamic provider, Position position) {
    final multiplier = _getMultiplier(provider, position);
    return multiplier != null && !multiplier.isWordMultiplier;
  }
  
  /// Helper to get the multiplier text for a position
  String _getMultiplierText(dynamic provider, Position position) {
    final multiplier = _getMultiplier(provider, position);
    if (multiplier == null) return '';
    return multiplier.isWordMultiplier ? 'x${multiplier.value}' : 'x${multiplier.value}';
  }
  
  /// Get enhanced border color based on word validation status
  Color _getCellBorderColor(bool hasValidWord, bool hasInvalidWord, Color defaultColor) {
    if (hasValidWord) {
      return const Color(0xFF4CAF50).withOpacity(0.2); // Valid - green tint
    }
    // Don't show red borders for invalid words - only show green for valid words
    return defaultColor;
  }
  
  /// Get enhanced border width based on word validation status
  double _getCellBorderWidth(bool hasValidWord, bool hasInvalidWord) {
    if (hasValidWord) {
      return 1.5; // Slightly thicker for validated tiles
    }
    return 1.0; // Default width
  }

  // Helper to get the board from the active provider
  Board? _getBoard(dynamic provider) {
    if (provider is PassPlayProvider) {
      return provider.room?.board;
    } else if (provider is GameProvider) {
      return provider.room?.board;
    }
    return null;
  }
  
  // Helper methods to work with both providers
  Tile? _getExistingTile(dynamic provider, Position pos) {
    if (provider is PassPlayProvider) {
      return provider.room?.board.getTileAt(pos);
    } else if (provider is GameProvider) {
      return provider.room?.board.getTileAt(pos);
    }
    return null;
  }
  
  PlacedTile _getPendingTile(dynamic provider, Position pos) {
    if (provider is PassPlayProvider) {
      return provider.pendingPlacements.firstWhere(
        (p) => p.position == pos,
        orElse: () => PlacedTile(tile: Tile(letter: ''), position: pos),
      );
    } else if (provider is GameProvider) {
      return provider.pendingPlacements.firstWhere(
        (p) => p.position == pos,
        orElse: () => PlacedTile(tile: Tile(letter: ''), position: pos),
      );
    }
    return PlacedTile(tile: Tile(letter: ''), position: pos);
  }
  
  bool _isSpecialPosition(dynamic provider, Position pos) {
    if (provider is PassPlayProvider) {
      return provider.room?.board.isSpecialPosition(pos) ?? false;
    } else if (provider is GameProvider) {
      return provider.room?.board.isSpecialPosition(pos) ?? false;
    }
    return false;
  }
  
  CellMultiplier? _getMultiplier(dynamic provider, Position pos) {
    if (provider is PassPlayProvider) {
      return provider.room?.board.getMultiplierAt(pos);
    } else if (provider is GameProvider) {
      return provider.room?.board.getMultiplierAt(pos);
    }
    return null;
  }
  
  List<ValidatedWord> _getValidatedWords(dynamic provider) {
    if (provider is PassPlayProvider) {
      return provider.validatedWords;
    } else if (provider is GameProvider) {
      // For multiplayer, we might not have word validation yet
      // Return empty list for now, can be enhanced later
      return [];
    }
    return [];
  }
  
  List<PlacedTile> _getPendingPlacements(dynamic provider) {
    if (provider is PassPlayProvider) {
      return provider.pendingPlacements;
    } else if (provider is GameProvider) {
      return provider.pendingPlacements;
    }
    return [];
  }
  
  bool _isWordValidationEnabled(dynamic provider) {
    if (provider is PassPlayProvider) {
      return provider.wordValidationEnabled;
    } else if (provider is GameProvider) {
      // For multiplayer, word validation might be handled differently
      return false;
    }
    return false;
  }
  
  bool _isMyTurn(dynamic provider) {
    if (provider is PassPlayProvider) {
      return provider.isMyTurn;
    } else if (provider is GameProvider) {
      final result = provider.isMyTurn;
      
      if (provider.room != null) {
        final currentIdx = provider.room!.currentPlayerIndex;
        final currentTurnPlayer = currentIdx >= 0 && currentIdx < provider.room!.players.length 
            ? provider.room!.players[currentIdx] 
            : null;
      }
      
      return result;
    }
    return false;
  }
  
  void _placeDraggedTile(dynamic provider, Tile tile, Position position) {
    if (provider is PassPlayProvider) {
      provider.placeDraggedTile(tile, position);
    } else if (provider is GameProvider) {
      provider.placeDraggedTile(tile, position);
    }
  }
  
  void _movePendingTile(dynamic provider, Position fromPosition, Position toPosition) {
    if (provider is PassPlayProvider) {
      provider.movePendingTile(fromPosition, toPosition);
    } else if (provider is GameProvider) {
      provider.movePendingTile(fromPosition, toPosition);
    }
  }
  
  void _removePendingPlacement(dynamic provider, Position position) {
    if (provider is PassPlayProvider) {
      provider.removePendingPlacement(position);
    } else if (provider is GameProvider) {
      provider.removePendingPlacement(position);
    }
  }
}

/// Debug painter to visualize grid alignment
class DebugGridPainter extends CustomPainter {
  final double cellSize;
  final double boardSize;
  final int gridSize; // Added gridSize parameter
  
  const DebugGridPainter({
    required this.cellSize,
    required this.boardSize,
    required this.gridSize, // Initialize gridSize
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Use same offset calculation as outline generation
    const double containerBorder = 8.0; // Changed from 16 to 8
    const double containerVerticalPadding = 0.0; // Changed from 2 to 0
    const double totalOffset = containerBorder + containerVerticalPadding;
    
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw grid lines to verify alignment
    for (int i = 0; i < gridSize; i++) { // Changed from 15 to 13
      final x = totalOffset + i * (cellSize + 1); // +1 for grid spacing
      final y = totalOffset + i * (cellSize + 1);
      
      // Vertical lines
      canvas.drawLine(
        Offset(x, totalOffset),
        Offset(x, totalOffset + gridSize * (cellSize + 1) - 1), // Changed from 15 to 13
        paint,
      );
      
      // Horizontal lines
      canvas.drawLine(
        Offset(totalOffset, y),
        Offset(totalOffset + gridSize * (cellSize + 1) - 1, y), // Changed from 15 to 13
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(DebugGridPainter oldDelegate) {
    return cellSize != oldDelegate.cellSize || boardSize != oldDelegate.boardSize || gridSize != oldDelegate.gridSize; // Added gridSize to comparison
  }
}
import 'package:flutter/material.dart';
import 'package:shakelha_mp/models/position.dart';
import 'package:shakelha_mp/models/move.dart';
import 'package:shakelha_mp/models/tile.dart';
import 'package:shakelha_mp/provider/pass_play_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Import board.dart to access word validation classes
import 'package:shakelha_mp/models/board.dart';
import 'package:shakelha_mp/provider/tile_theme_provider.dart';
import 'package:shakelha_mp/widgets/tileUI.dart';

// Grid cell widget for responsive board tiles
class GridCell extends StatelessWidget {
  final int row;
  final int col;
  final bool isSpecial;
  final Color? specialColor;
  
  const GridCell({
    Key? key,
    required this.row,
    required this.col,
    this.isSpecial = false,
    this.specialColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.2),
      decoration: BoxDecoration(
        color: isSpecial 
            ? (specialColor ?? const Color(0xFFFFECD6))
            : Colors.transparent,
        border: Border.all(
          color: const Color(0xFFAB8756),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: isSpecial
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFECD6),
                      Color(0xFFEDDABE),
                      Color(0xFFD9B991),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class BoardUI extends StatefulWidget {
  final int boardSize; // Add configurable board size
  
  const BoardUI({
    Key? key, 
    this.boardSize = 13, // Default to 13x13
  }) : super(key: key);
  
  @override
  State<BoardUI> createState() => _BoardUIState();
}

class _BoardUIState extends State<BoardUI> {
  late double _cellSize;
  
  @override
  Widget build(BuildContext context) {
    final passPlay = context.watch<PassPlayProvider>();
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
                    final gridHeight = constraints.maxHeight;
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
                          final positionKey = '$row-$col';
                          final pos = Position(row: row, col: col);
                          final existingTile = passPlay.room?.board.getTileAt(pos);
                          final pending = passPlay.pendingPlacements.firstWhere(
                            (p) => p.position == pos,
                            orElse: () => PlacedTile(tile: Tile(letter: ''), position: pos),
                          );
                          final hasPending = pending.tile.letter.isNotEmpty;
                          final displayLetter = existingTile?.letter ?? (hasPending ? pending.tile.letter : '');
                          final displayPoints = existingTile?.value ?? (hasPending ? pending.tile.value : 0);
                          
                          final bool isSpecial = passPlay.room?.board.isSpecialPosition(pos) ?? false;
                          Color? specialColor;
                          String? multiplierText;
                          
                          if (isSpecial) {
                            // Get the actual multiplier to determine styling
                            final multiplier = passPlay.room?.board.getMultiplierAt(pos);
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
                          final wordsAtPosition = passPlay.validatedWords.where((word) =>
                            word.positions.any((wordPos) => wordPos.row == row && wordPos.col == col) &&
                            // Only show feedback for words involving newly placed tiles
                            word.positions.any((pos) =>
                              passPlay.pendingPlacements.any((placement) => placement.position == pos)
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
                                if (!passPlay.isMyTurn) return false;
                                final isEmpty = (existingTile == null) && !hasPending;
                                return (data is Tile || data is PlacedTile) && isEmpty;
                              },
                              onAccept: (data) {
                                if (data is Tile) {
                                  passPlay.placeDraggedTile(data, pos);
                                } else if (data is PlacedTile) {
                                  passPlay.movePendingTile(data.position, pos);
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

                                if (hasPending && passPlay.isMyTurn) {
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
                                        passPlay.removePendingPlacement(pos);
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
            if (passPlay.wordValidationEnabled)
              ..._generateWordOverlays(passPlay.validatedWords, passPlay.pendingPlacements, _cellSize),
            
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

  /// Debug method to print tile positions for troubleshooting
  void debugTilePositions() {
    print('=== Board Debug Info ===');
    print('Current cell size: $_cellSize');
    print('Board size: ${widget.boardSize}');
    
    // Print a few sample positions
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final pos = _getTilePosition(row, col, _cellSize);
        print('Tile at ($row, $col): left=${pos.dx.toStringAsFixed(2)}, top=${pos.dy.toStringAsFixed(2)}');
      }
    }
    print('========================');
  }

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
      final offsetX = 5; // Center horizontally
      final offsetY = 5; // Center vertically
      
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
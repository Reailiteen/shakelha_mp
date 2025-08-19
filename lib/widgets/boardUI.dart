import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/models/move.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/provider/pass_play_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Import board.dart to access word validation classes
import 'package:mp_tictactoe/models/board.dart';

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
  const BoardUI({Key? key}) : super(key: key);
  
  @override
  State<BoardUI> createState() => _BoardUIState();
}

class _BoardUIState extends State<BoardUI> {
  late double _cellSize;
  
  @override
  Widget build(BuildContext context) {
    final passPlay = context.watch<PassPlayProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate board size to fit available space
    final double availableHeight = screenHeight * 0.6;
    final double boardSize = availableHeight;

    // Helper function for decorative dots
    Widget circle([double size = 8]) => Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFECD6), Color(0xFFEDDABE), Color(0xFFD9B991)],
        ),
        shape: BoxShape.circle,
      ),
    );

    // Calculate cell size for outline generation
    // Use simpler calculation that matches GridView layout
    // GridView has 13 cells with 1px spacing between them
    // Total grid width = 13 * cellSize + 12 * 1px spacing
    // So: 13 * cellSize + 12 = boardSize - 16 (border only, no horizontal padding)
    // Solving: 13 * cellSize = boardSize - 28
    // cellSize = (boardSize - 28) / 13
    _cellSize = (boardSize - 28) / 13;
    
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
                border: Border.all(color: const Color(0xFFDAA864), width: 8,strokeAlign: BorderSide.strokeAlignInside), // Reduced from 16 to 8
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
                padding: const EdgeInsets.symmetric(vertical: 0.0), // Only vertical padding, no horizontal
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Get exact grid dimensions for precise outline positioning
                    final gridWidth = constraints.maxWidth;
                    final gridHeight = constraints.maxHeight;
                    final actualCellSize = (gridWidth - 12) / 13; // 12px total spacing between 13 cells (no horizontal padding)
                    
                    // Update cell size for outline generation
                    _cellSize = actualCellSize;
                    
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true, // Prevent GridView from expanding beyond container
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 13, // Changed from 15 to 13
                        mainAxisExtent: actualCellSize, // Force exact cell height
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      itemCount: 169, // Changed from 225 (15*15) to 169 (13*13)
                      itemBuilder: (context, index) {
                        final row = index ~/ 13; // Changed from 15 to 13
                        final col = index % 13; // Changed from 15 to 13
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
                        } else if (row == 6 && col == 6) { // Changed from 7,7 to 6,6 for 13x13 board
                          // Center square gets green color
                          specialColor = const Color(0xFF4CAF50); // Green
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
                        
                        return DragTarget<Object>(
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

                            Widget tileVisual(String letter, int points, double size) => Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3), // Reduced from 8 to 3 for less rounded tiles
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                  child: Stack(children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEBD5C),
                                        borderRadius: BorderRadius.circular(2), // Reduced from 5 to 2
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Color(0xFFF7D286), Color(0xFF664C18)],
                                          stops: [0.8, 1.0],
                                        ),
                                        borderRadius: BorderRadius.circular(3), // Reduced from 7 to 3
                                      ),
                                    ),
                                    Container(
                                      height: size * 0.3,
                                      margin: const EdgeInsets.all(1),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Color(0xFFFFF1D5), Color(0xFFF7D286)],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(3), // Reduced from 7 to 3
                                          topRight: Radius.circular(3), // Reduced from 7 to 3
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(1, 3, 1, 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7D286),
                                        borderRadius: BorderRadius.circular(3), // Reduced from 7 to 3
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        letter,
                                        style: GoogleFonts.jomhuria(
                                          textStyle: TextStyle(
                                            color: const Color(0xFF50271A),
                                            fontSize: size * 1.1,
                                            fontWeight: FontWeight.w400, // Reduced from 800 to 600
                                            height: 0.4,
                                          ),
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    Positioned(
                                      right: size * 0.06,
                                      bottom: size * 0.035,
                                      child: Text(
                                        points.toString(),
                                        style: GoogleFonts.jomhuria(
                                          textStyle: TextStyle(
                                            color: const Color(0xFF50271A),
                                            fontSize: size * 0.5,
                                            fontWeight: FontWeight.w500, // Reduced from 800 to 600
                                            height: 0.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
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
                        );
                      },
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
            
            // Center tile star indicator (only show when center is empty)
            if (passPlay.room?.board.getTileAt(Position(row: 6, col: 6)) == null && // Changed from 7,7 to 6,6 for 13x13
                !passPlay.pendingPlacements.any((p) => p.position == Position(row: 6, col: 6))) // Changed from 7,7 to 6,6 for 13x13
              Positioned(
                left: 6 * (_cellSize + 1) + (_cellSize - 24) / 2, // Center the star on the 6,6 position
                top: 6 * (_cellSize + 1) + (_cellSize - 24) / 2,
                child: IgnorePointer(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), // Green color
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
      
      // Use the old approach that worked correctly
      // Calculate positions based on cell size and spacing
      const double gridSpacing = 1.0;
      
      final top = minRow * (cellSize + gridSpacing);
      final height = (maxRow - minRow + 1) * cellSize + (maxRow - minRow) * gridSpacing;
      final width = (maxCol - minCol + 1) * cellSize + (maxCol - minCol) * gridSpacing;
      final left = minCol * (cellSize + gridSpacing);
      
      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: word.feedbackColor,
                width: 2.0, // Reduced from 3.0 to 2.0
                strokeAlign: BorderSide.strokeAlignCenter, // Center the outline between tiles
              ),
              borderRadius: BorderRadius.circular(2.0), // Reduced from 6.0 to 2.0 for less rounded corners
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
  
  const DebugGridPainter({
    required this.cellSize,
    required this.boardSize,
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
    for (int i = 0; i <= 13; i++) { // Changed from 15 to 13
      final x = totalOffset + i * (cellSize + 1); // +1 for grid spacing
      final y = totalOffset + i * (cellSize + 1);
      
      // Vertical lines
      canvas.drawLine(
        Offset(x, totalOffset),
        Offset(x, totalOffset + 13 * (cellSize + 1) - 1), // Changed from 15 to 13
        paint,
      );
      
      // Horizontal lines
      canvas.drawLine(
        Offset(totalOffset, y),
        Offset(totalOffset + 13 * (cellSize + 1) - 1, y), // Changed from 15 to 13
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(DebugGridPainter oldDelegate) {
    return cellSize != oldDelegate.cellSize || boardSize != oldDelegate.boardSize;
  }
}
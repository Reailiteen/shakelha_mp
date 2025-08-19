import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/models/move.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/provider/pass_play_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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

class BoardUI extends StatelessWidget {
  const BoardUI({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final passPlay = context.watch<PassPlayProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate board size to fit available space
    final double availableHeight = screenHeight * 0.48;
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

    return Center(

      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Stack(
          children: [
            // Bordered board container with grid inside
            Container(
              decoration: BoxDecoration(
                color: const Color(0xE4BD8C).withOpacity(1), // Beige background
                border: Border.all(color: const Color(0xFFDAA864), width: 16,strokeAlign: BorderSide.strokeAlignInside),
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
                padding: const EdgeInsets.all(2.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 15,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: 225,
                  itemBuilder: (context, index) {
                    final row = index ~/ 15;
                    final col = index % 15;
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
                          // Letter multipliers get neon yellow color
                          specialColor = const Color(0xFFFFD700); // Neon yellow
                          multiplierText = 'x${multiplier.value}';
                        }
                      }
                    } else if (row == 7 && col == 7) {
                      // Center square gets green color
                      specialColor = const Color(0xFF4CAF50); // Green
                    }
                    
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
                              color: const Color(0xFFAB8756),
                              width: 1,
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
                                borderRadius: BorderRadius.circular(8),
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
                                    borderRadius: BorderRadius.circular(5),
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
                                    borderRadius: BorderRadius.circular(7),
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
                                      topLeft: Radius.circular(7),
                                      topRight: Radius.circular(7),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(1, 3, 1, 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7D286),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    letter,
                                    style: GoogleFonts.jomhuria(
                                      textStyle: TextStyle(
                                        color: const Color(0xFF50271A),
                                        fontSize: size * 1.2,
                                        fontWeight: FontWeight.w800,
                                        height: 0.4,
                                      ),
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                Positioned(
                                  right: size * 0.07,
                                  bottom: size * 0.03,
                                  child: Text(
                                    points.toString(),
                                    style: GoogleFonts.jomhuria(
                                      textStyle: TextStyle(
                                        color: const Color(0xFF50271A),
                                        fontSize: size * 0.5,
                                        fontWeight: FontWeight.w800,
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
                              Center(child: FractionallySizedBox(widthFactor: 0.9, heightFactor: 0.9, child: tileVisual(displayLetter, displayPoints, 20))),
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
                ),
              ),
            ),
            // Dotted ribbon above the border
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
}
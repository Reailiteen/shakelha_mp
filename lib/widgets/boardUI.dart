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
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    
    // Define special positions (like triple word score, double letter, etc.)
    final Set<String> specialPositions = {
      '0-0', '0-3', '0-7', '0-11', '0-14', // Top row special positions
      '3-0', '3-14', 
      '7-0', '7-3', '7-7', '7-11', '7-14', // Middle row
      '11-0', '11-14',
      '14-0', '14-3', '14-7', '14-11', '14-14', // Bottom row
      // Add more special positions as needed
    };
    
    // Calculate board size to fit available space
    final double availableWidth = screenWidth * 0.95;
    final double boardSize = availableWidth;
    
    return Center(
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          color: const Color(0xFF512103),
          border: Border.all(
            color: const Color(0xFF2D462D),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(8),
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
          padding: const EdgeInsets.all(4.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 15,
              childAspectRatio: 1.0,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: 225, // 15x15 = 225 cells
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
              
              final bool isSpecial = specialPositions.contains(positionKey);
              Color? specialColor;
              
              // Assign different colors based on position
              if (row == 7 && col == 7) {
                // Center star
                specialColor = const Color(0xFF9E7649);
              } else if (isSpecial) {
                // Other special positions
                if (row == 0 || row == 14 || col == 0 || col == 14) {
                  specialColor = const Color(0xFFFFECD6);
                } else {
                  specialColor = const Color(0xFFEDDABE);
                }
              }
              
              return DragTarget<Object>(
                onWillAccept: (data) {
                  if (!passPlay.isMyTurn) return false;
                  // Accept if cell empty (no committed or pending)
                  final isEmpty = (existingTile == null) && !hasPending;
                  return (data is Tile || data is PlacedTile) && isEmpty;
                },
                onAccept: (data) {
                  if (data is Tile) {
                    passPlay.placeDraggedTile(data, pos);
                  } else if (data is PlacedTile) {
                    // Move pending tile from old position to new
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

                  // Tile visual: use same tile face as rack, scaled down
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
                          // base
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEBD5C),
                              borderRadius: BorderRadius.circular(8),
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
                          // Letter (thicker and centered)
                          Center(
                            child: Text(
                              letter,
                              style: GoogleFonts.jomhuria(
                                textStyle: TextStyle(
                                  color: const Color(0xFF50271A),
                                  fontSize: size * 2.2,
                                  fontWeight: FontWeight.w800,
                                  height: 1.0,
                                ),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          // Points (always visible)
                          Positioned(
                            right: size * 0.1,
                            bottom: size * 0.05,
                            child: Text(
                              points.toString(),
                              style: GoogleFonts.jomhuria(
                                textStyle: TextStyle(
                                  color: const Color(0xFF50271A),
                                  fontSize: size * 1.5,
                                  fontWeight: FontWeight.w700,
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
                    // Allow dragging pending tile to another empty cell (immediate drag)
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
                          // double tap to return pending tile back to rack
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
    );
  }
}
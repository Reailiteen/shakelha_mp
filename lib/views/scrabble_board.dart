import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:mp_tictactoe/provider/room_data_provider.dart';
import 'package:provider/provider.dart';

/// A 15×15 Scrabble board grid supporting Arabic letters and pending placements.
class ScrabbleBoard extends StatelessWidget {
  const ScrabbleBoard({Key? key}) : super(key: key);

  static const int boardSize = 15;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Each cell size from available width; board is square elsewhere
        final cellSize = constraints.maxWidth / boardSize;
        final letterFont = cellSize * 0.66;
        final hoverFont = cellSize * 0.66;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFD54F), // ornate gold
              width: 3,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFF7F7F7), // pearl white
                Color(0xFFE7D8C5), // desert sand-like
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardSize,
                ),
                itemCount: boardSize * boardSize,
                itemBuilder: (context, index) {
              final row = index ~/ boardSize;
              final col = index % boardSize;
              final pos = Position(row: row, col: col);
              final tile = game.getTileAt(pos);
              final isPending = game.hasPendingPlacements() && game.pendingPlacements.any((p) => p.position == pos);
              final pendingTile = isPending
                  ? game.pendingPlacements.firstWhere((p) => p.position == pos).tile
                  : null;
              final remoteHover = context.watch<RoomDataProvider>().getHoverAtPosition(pos);

              return DragTarget<Tile>(
                onWillAccept: (data) => game.isMyTurn && tile == null,
                onAccept: (draggedTile) {
                  game.placeDraggedTile(draggedTile, pos);
                },
                onMove: (_) {
                  game.sendHover(pos);
                },
                onLeave: (_) {
                  game.clearHover();
                },
                builder: (context, candidateData, rejectedData) {
                  final isHover = candidateData.isNotEmpty;
                  return MouseRegion(
                    onHover: (_) => game.sendHover(pos),
                    onExit: (_) => game.clearHover(),
                    child: GestureDetector(
                      onTap: () {
                        if (game.isMyTurn) {
                          if (isPending) {
                            game.removePendingPlacement(pos);
                          } else {
                            game.placeTileOnBoard(pos);
                          }
                        }
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                              color: isHover ? Colors.yellow.shade100 : _cellColor(row, col, isPending),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              (tile?.letter ?? pendingTile?.letter) ?? '',
                              style: TextStyle(
                                fontSize: letterFont,
                                fontWeight: FontWeight.w700,
                                color: Colors.brown.shade700,
                                shadows: const [
                                  Shadow(offset: Offset(0.5, 0.5), blurRadius: 0.5, color: Colors.black26),
                                ],
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          if (remoteHover != null && tile == null && pendingTile == null)
                            Align(
                              alignment: Alignment.center,
                              child: Opacity(
                                opacity: 0.35,
                                child: Text(
                                  remoteHover.letter,
                                  style: TextStyle(
                                    fontSize: hoverFont,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.blueGrey.shade600,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ),
                          if (!game.isMyTurn)
                            Container(
                              color: Colors.black.withOpacity(0.04),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
  );
}
  Color _cellColor(int row, int col, bool isPending) {
    if (isPending) return Colors.yellow.shade200;
    // Center star cell
    if (row == 7 && col == 7) return const Color(0xFFFFF3E0);
    // Standard board alternating color, subtle
    return (row + col) % 2 == 0 ? const Color(0xFFF3F6FA) : Colors.white;
  }
}

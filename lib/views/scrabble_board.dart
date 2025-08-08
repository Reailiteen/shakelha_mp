import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:provider/provider.dart';

/// A 15×15 Scrabble board grid supporting Arabic letters and pending placements.
class ScrabbleBoard extends StatelessWidget {
  const ScrabbleBoard({Key? key}) : super(key: key);

  static const int boardSize = 15;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return AspectRatio(
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
          final isPending = game.hasPendingPlacement(pos);

          return GestureDetector(
            onTap: () {
              if (game.isMyTurn) {
                if (isPending) {
                  game.removePendingPlacement(pos);
                } else {
                  game.placeTileOnBoard(pos);
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: _cellColor(row, col, isPending),
              ),
              alignment: Alignment.center,
              child: Text(
                tile?.letter ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _cellColor(int row, int col, bool isPending) {
    if (isPending) return Colors.yellow.shade200;
    // Center star cell
    if (row == 7 && col == 7) return Colors.orange.shade100;
    // Standard board alternating color
    return (row + col) % 2 == 0 ? Colors.blueGrey.shade50 : Colors.white;
  }
}

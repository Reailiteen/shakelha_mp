import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:provider/provider.dart';

/// Widget displaying the player's tile rack with Arabic letters
class PlayerRack extends StatelessWidget {
  const PlayerRack({Key? key}) : super(key: key);

  /// Calculates the average size between rack tile and board tile for better drag feedback
  static double _getDragFeedbackSize(double rackTileSize) {
    const double boardCellSize = 28.0; // Standard board cell size (15x15 grid)
    return (rackTileSize + boardCellSize) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final currentPlayer = game.getCurrentPlayer();
    
    if (currentPlayer == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        // Compute size to fit 7 tiles + spacing without scroll
        final spacing = 6.0;
        final tileSize = ((maxW - spacing * 12) / 7).clamp(28.0, 48.0);
        final rackHeight = tileSize + 12; // padding
        return Container(
          constraints: BoxConstraints(minHeight: rackHeight),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.brown.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.brown.shade300, width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                ...currentPlayer.rack.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tile = entry.value;
                  final isSelected = game.selectedRackIndex == index;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                    child: SizedBox(
                      width: tileSize,
                      height: tileSize,
                      child: Draggable<Tile>(
                        data: tile,
                        feedback: SizedBox(
                          // Use average size between rack tile and board tile for better visual consistency
                          width: _getDragFeedbackSize(tileSize),
                          height: _getDragFeedbackSize(tileSize),
                          child: _RackTileVisual(tile: tile, highlighted: true, size: _getDragFeedbackSize(tileSize)),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _RackTileVisual(tile: tile, selected: isSelected, size: tileSize),
                        ),
                        onDragStarted: () => game.startPlacingTiles(),
                        child: GestureDetector(
                          onTap: () {
                            if (!game.isPlacingTiles) {
                              game.startPlacingTiles();
                            }
                            game.selectRackTile(index);
                          },
                          child: _RackTileVisual(tile: tile, selected: isSelected, size: tileSize),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                // Fill empty slots visually (non-interactive)
                ...List.generate(
                  7 - currentPlayer.rack.length,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                    child: Container(
                      width: tileSize,
                      height: tileSize,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade400, width: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RackTileVisual extends StatelessWidget {
  final Tile tile;
  final bool selected;
  final bool highlighted;
  final double? size;
  const _RackTileVisual({Key? key, required this.tile, this.selected = false, this.highlighted = false, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = size ?? 50;
    return Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  color: highlighted
                      ? Colors.yellow.shade300
                      : (selected ? Colors.yellow.shade200 : Colors.brown.shade50),
                  border: Border.all(
                    color: selected ? Colors.orange : Colors.brown.shade400,
                    width: selected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tile.letter,
                      style: TextStyle(
                        fontSize: (s * 0.4).clamp(14.0, 24.0),
                        fontWeight: FontWeight.w800,
                        color: Colors.amber.shade800,
                        shadows: const [
                          Shadow(offset: Offset(0.5, 0.5), blurRadius: 0.5, color: Colors.black26),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      tile.value.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
  }
}

import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:provider/provider.dart';

/// Widget displaying the player's tile rack with Arabic letters
class PlayerRack extends StatelessWidget {
  const PlayerRack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final currentPlayer = game.getCurrentPlayer();
    
    if (currentPlayer == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...currentPlayer.rack.asMap().entries.map((entry) {
            final index = entry.key;
            final tile = entry.value;
            final isSelected = game.selectedRackIndex == index;
            
            return Draggable<Tile>(
              data: tile,
              feedback: _RackTileVisual(tile: tile, highlighted: true),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _RackTileVisual(tile: tile, selected: isSelected),
              ),
              onDragStarted: () => game.startPlacingTiles(),
              child: GestureDetector(
                onTap: () {
                  if (!game.isPlacingTiles) {
                    game.startPlacingTiles();
                  }
                  game.selectRackTile(index);
                },
                child: _RackTileVisual(tile: tile, selected: isSelected),
              ),
            );
          }).toList(),
          // Fill empty slots
          ...List.generate(
            7 - currentPlayer.rack.length,
            (index) => Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RackTileVisual extends StatelessWidget {
  final Tile tile;
  final bool selected;
  final bool highlighted;
  const _RackTileVisual({Key? key, required this.tile, this.selected = false, this.highlighted = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
                width: 50,
                height: 50,
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
                        fontSize: 20,
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

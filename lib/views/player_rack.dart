import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
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
            
            return GestureDetector(
              onTap: () => game.selectRackTile(index),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.yellow.shade200 : Colors.brown.shade50,
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.brown.shade400,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tile.letter,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:provider/provider.dart';

/// Game control buttons for Scrabble actions
class GameControls extends StatelessWidget {
  const GameControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: game.canSubmitMove() ? () => game.submitMove() : null,
            icon: const Icon(Icons.check),
            label: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: game.hasPendingPlacements() ? () => game.cancelMove() : null,
            icon: const Icon(Icons.undo),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: game.isMyTurn ? () => game.passTurn() : null,
            icon: const Icon(Icons.skip_next),
            label: const Text('Pass'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: game.canExchangeTiles() ? () => _showExchangeDialog(context, game) : null,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Exchange'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showExchangeDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exchange Tiles'),
        content: const Text('Select tiles from your rack to exchange, then tap Exchange.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              game.exchangeSelectedTiles();
              Navigator.pop(context);
            },
            child: const Text('Exchange'),
          ),
        ],
      ),
    );
  }
}

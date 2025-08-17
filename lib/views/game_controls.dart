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
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 6,
            children: [
                _GlowingButton(
                  onPressed: game.isMyTurn
                      ? () {
                          if (game.isPlacingTiles) {
                            game.cancelPlacingTiles();
                          } else {
                            game.startPlacingTiles();
                          }
                        }
                      : null,
                  icon: Icon(game.isPlacingTiles ? Icons.close : Icons.play_arrow, size: 18),
                  label: Text(game.isPlacingTiles ? 'Finish' : 'Place'),
                  backgroundColor: Colors.teal,
                  glowColor: Colors.teal,
                ),
                _GlowingButton(
                  onPressed: game.canSubmitMove()
                      ? () {
                          final ok = game.submitMove();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? 'Move submitted' : (game.errorMessage ?? 'Failed to submit')),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Submit'),
                  backgroundColor: Colors.green,
                  glowColor: Colors.green,
                ),
                _GlowingButton(
                  onPressed: game.hasPendingPlacements() ? () => game.cancelMove() : null,
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Cancel'),
                  backgroundColor: Colors.orange,
                  glowColor: Colors.orange,
                ),
                _GlowingButton(
                  onPressed: game.isMyTurn
                      ? () {
                          game.passTurn();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Turn passed'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: const Text('Pass'),
                  backgroundColor: Colors.blue,
                  glowColor: Colors.blue,
                ),
                _GlowingButton(
                  onPressed: game.canExchangeTiles() ? () => _showExchangeDialog(context, game) : null,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Swap'),
                  backgroundColor: Colors.purple,
                  glowColor: Colors.purple,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExchangeDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B4E6E),
        title: const Text('Exchange Tiles', style: TextStyle(color: Colors.white)),
        content: const Text('Select tiles from your rack to exchange, then tap Exchange.', 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF19B6A6).withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                game.exchangeSelectedTiles();
                Navigator.pop(context);
              },
              child: const Text('Exchange', style: TextStyle(color: Color(0xFF19B6A6))),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final Color backgroundColor;
  final Color glowColor;

  const _GlowingButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(0, 34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          elevation: 0,
          side: BorderSide(
            color: glowColor.withOpacity(0.6),
            width: 1,
          ),
        ),
      ),
    );
  }
}

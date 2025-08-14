import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/move.dart';

class MoveHistory extends StatelessWidget {
  const MoveHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final Room? room = game.room;

    final List<_Entry> entries = <_Entry>[];

    // Prefer server-provided move history if available
    if (room != null && room.moveHistory.isNotEmpty) {
      for (final m in room.moveHistory) {
        final Move move = m;
        if (move.type == MoveType.place) {
          final player = room.players.firstWhere(
            (p) => p.id == move.playerId,
            orElse: () => room.players.first,
          );
          final words = move.wordsFormed.isNotEmpty
              ? move.wordsFormed.join(', ')
              : '';
          entries.add(_Entry(playerName: player.nickname, points: move.points, words: words));
        } else if (move.type == MoveType.pass) {
          final player = room.players.firstWhere(
            (p) => p.id == move.playerId,
            orElse: () => room.players.first,
          );
          entries.add(_Entry(playerName: player.nickname, points: 0, words: 'Pass'));
        }
      }
    } else {
      // Fallback: show latest local submission words if any
      if (game.lastSubmittedWords.isNotEmpty) {
        entries.add(_Entry(playerName: 'You', points: 0, words: game.lastSubmittedWords.join(', ')));
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF26A69A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.history),
        label: const Text('سجل الحركات'),
        onPressed: entries.isEmpty
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.6,
                      minChildSize: 0.4,
                      maxChildSize: 0.9,
                      builder: (context, controller) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E2235).withOpacity(0.98),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.6), width: 1),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.history, color: Colors.white),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'سجل الحركات',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white70),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                                Expanded(
                                  child: ListView.separated(
                                    controller: controller,
                                    padding: const EdgeInsets.all(12),
                                    itemCount: entries.length,
                                    separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.06), height: 12),
                                    itemBuilder: (context, index) {
                                      final e = entries[index];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.03),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                e.playerName,
                                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                              ),
                                            ),
                                            if (e.words.isNotEmpty)
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  e.words,
                                                  textAlign: TextAlign.right,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(color: Colors.white70),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFD54F),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '+${e.points}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
      ),
    );
  }
}

class _Entry {
  final String playerName;
  final int points;
  final String words;
  _Entry({required this.playerName, required this.points, required this.words});
}

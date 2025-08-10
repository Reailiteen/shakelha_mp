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
        icon: const Icon(Icons.history),
        label: const Text('Move History'),
        onPressed: entries.isEmpty
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (ctx) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.6,
                      minChildSize: 0.4,
                      maxChildSize: 0.9,
                      builder: (context, controller) {
                        return SafeArea(
                          top: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.history),
                                    const SizedBox(width: 8),
                                    const Text('Move History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: ListView.separated(
                                  controller: controller,
                                  padding: const EdgeInsets.all(12),
                                  itemCount: entries.length,
                                  separatorBuilder: (_, __) => const Divider(height: 12),
                                  itemBuilder: (context, index) {
                                    final e = entries[index];
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            e.playerName,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        if (e.words.isNotEmpty)
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              e.words,
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        Text('+${e.points}')
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
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

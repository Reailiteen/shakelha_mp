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

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Move History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Text('No moves yet', style: TextStyle(color: Colors.black54))
            else
              SizedBox(
                height: 140,
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
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

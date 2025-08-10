import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:provider/provider.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final players = game.room?.players ?? [];

    if (players.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: players
            .map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: 
                    Text(
                      p.nickname + ' : ' + p.score.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
      
                
                
              ),
            )
            .toList(),
      ),
    );
  }
}

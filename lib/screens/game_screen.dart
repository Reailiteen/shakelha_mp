import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/room_data_provider.dart';
import 'package:mp_tictactoe/resources/socket_methods.dart';
import 'package:mp_tictactoe/views/scoreboard.dart';
import 'package:mp_tictactoe/views/scrabble_board.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:mp_tictactoe/views/waiting_lobby.dart';
import 'package:mp_tictactoe/views/player_rack.dart';
import 'package:mp_tictactoe/views/game_controls.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  static String routeName = '/game';
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.updateRoomListener(context);
    _socketMethods.tilesPlacedListener(context);
    _socketMethods.moveSubmittedListener(context);
    _socketMethods.turnPassedListener(context);
    _socketMethods.tilesExchangedListener(context);
    _socketMethods.errorOccurredListener(context);
    // _socketMethods.updatePlayersStateListener(context);
    // _socketMethods.pointIncreaseListener(context);
    // _socketMethods.endGameListener(context);
  }

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);

    final room = roomDataProvider.room;
    final waiting = room == null || (room.players.length < 2);

    return Scaffold(
      appBar: waiting
          ? null
          : AppBar(
              title: Text('Room: ${room!.id}'),
              centerTitle: true,
            ),
      body: waiting
          ? const WaitingLobby()
          : ChangeNotifierProvider<GameProvider>(
              create: (_) => GameProvider(),
              builder: (context, child) {
                // Seed GameProvider with current Room and my player id
                final game = context.read<GameProvider>();
                final room = roomDataProvider.room!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  game.updateRoom(room);
                  // Map my socket id to the corresponding Player.id
                  final mySocketId = _socketMethods.socketClient.id;
                  final me = mySocketId == null
                      ? null
                      : room.players.firstWhere(
                          (p) => p.socketId == mySocketId,
                          orElse: () => room.players.first,
                        );
                  game.setCurrentPlayerId((me ?? room.players.first).id);
                });
                return SafeArea(
                  child: Column(
                    children: [
                      const Scoreboard(),
                      const Expanded(child: ScrabbleBoard()),
                      Builder(builder: (context) {
                        final g = context.watch<GameProvider>();
                        final r = g.room;
                        String turnLabel = 'Waiting...';
                        if (r != null && r.players.isNotEmpty) {
                          final idx = r.currentPlayerIndex;
                          final name = r.players[idx].nickname;
                          turnLabel = "$name's turn";
                        }
                        return Text(
                          turnLabel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        );
                      }),
                      const PlayerRack(),
                      const GameControls(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/room_data_provider.dart';
import 'package:mp_tictactoe/resources/socket_methods.dart';
import 'package:mp_tictactoe/views/scoreboard.dart';
import 'package:mp_tictactoe/views/scrabble_board.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:mp_tictactoe/views/waiting_lobby.dart';
import 'package:mp_tictactoe/views/player_rack.dart';
import 'package:mp_tictactoe/views/game_controls.dart';
import 'package:mp_tictactoe/views/move_history.dart';
import 'package:provider/provider.dart';
import 'package:mp_tictactoe/data/arabic_dictionary_loader.dart';
import 'package:mp_tictactoe/models/room.dart';

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
    // Preload dictionary for fast word validation
    ArabicDictionary.instance.preload();
    _socketMethods.updateRoomListener(context);
    _socketMethods.hoverUpdateListener(context);
    _socketMethods.tilesPlacedListener(context);
    _socketMethods.moveSubmittedListener(context);
    _socketMethods.turnPassedListener(context);
    _socketMethods.tilesExchangedListener(context);
    _socketMethods.errorOccurredListener(context);
    _socketMethods.turnChangedListener(context);
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
              title: Text('Room: ${room.id}'),
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

                // Keep GameProvider synced with RoomDataProvider on every socket update
                // This prevents turn desync between clients
                // The selector triggers when RoomDataProvider.room changes
                final sync = Selector<RoomDataProvider, Room?>(
                  selector: (_, prov) => prov.room,
                  builder: (ctx, latestRoom, __) {
                    if (latestRoom != null) {
                      // Update GameProvider's room state; it recomputes isMyTurn
                      ctx.read<GameProvider>().updateRoom(latestRoom);
                    }
                    return const SizedBox.shrink();
                  },
                );
                return SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 800;
                      // final board = const Expanded(child: ScrabbleBoard());
                      final controls = Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(builder: (context) {
                            final g = context.watch<GameProvider>();
                            final r = g.room;
                            String turnLabel = 'Waiting...';
                            bool myTurn = g.isMyTurn;
                            if (r != null && r.players.isNotEmpty) {
                              final idx = r.currentPlayerIndex;
                              final name = r.players[idx].nickname;
                              turnLabel = "$name's turn" + (myTurn ? ' (You)' : '');
                            }
                            return Container(
                              width: double.infinity,
                              color: myTurn ? Colors.green.shade100 : Colors.red.shade100,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              alignment: Alignment.center,
                              child: Text(
                                turnLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: myTurn ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                            );
                          }),
                          const MoveHistory(),
                          const PlayerRack(),
                          const GameControls(),
                        ],
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  sync,
                                  const Scoreboard(),
                                  const MoveHistory(),
                                  const Expanded(child: ScrabbleBoard()),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: controls,
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          sync,
                          const Scoreboard(),
                          const MoveHistory(),
                          // Board takes ~3/5 of height
                          const Expanded(flex: 3, child: ScrabbleBoard()),
                          // Lower panel takes ~2/5 of height
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Builder(builder: (context) {
                                  final g = context.watch<GameProvider>();
                                  final r = g.room;
                                  String turnLabel = 'Waiting...';
                                  bool myTurn = g.isMyTurn;
                                  if (r != null && r.players.isNotEmpty) {
                                    final idx = r.currentPlayerIndex;
                                    final name = r.players[idx].nickname;
                                    turnLabel = "$name's turn" + (myTurn ? ' (You)' : '');
                                  }
                                  return Container(
                                    width: double.infinity,
                                    color: myTurn ? Colors.green.shade100 : Colors.red.shade100,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    alignment: Alignment.center,
                                    child: Text(
                                      turnLabel,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: myTurn ? Colors.green.shade900 : Colors.red.shade900,
                                      ),
                                    ),
                                  );
                                }),
                                const PlayerRack(),
                                const GameControls(),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

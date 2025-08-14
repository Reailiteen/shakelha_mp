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
import 'package:mp_tictactoe/views/abilities_bar.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      appBar: waiting
          ? null
          : AppBar(
              title: Text('Room: ${room.id}'),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'Room sidebar',
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ],
            ),
      endDrawer: waiting ? null : Builder(
        builder: (context) {
          final mySocketId = _socketMethods.socketClient.id;
          final isHost = room.hostSocketId != null && room.hostSocketId == mySocketId;
          final seats = '${room.players.length}/${room.maxPlayers}';
          return Drawer(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.meeting_room),
                        const SizedBox(width: 8),
                        Text('Room Sidebar', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const Divider(),
                    SelectableText('Room ID: ${room.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: '),
                        Chip(label: Text(room.status)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Seats: '),
                        Chip(label: Text(seats)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Publicly Listed'),
                        Switch(
                          value: room.isPublic,
                          onChanged: isHost ? (v) {
                            _socketMethods.setRoomVisibility(roomId: room.id, isPublic: v);
                          } : null,
                        ),
                      ],
                    ),
                    if (!isHost)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text('Only the host can change visibility', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF101828),
              Color(0xFF16304A),
            ],
          ),
        ),
        child: waiting
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
                            String turnLabel = 'بانتظار اللاعبين...';
                            bool myTurn = g.isMyTurn;
                            if (r != null && r.players.isNotEmpty) {
                              final idx = r.currentPlayerIndex;
                              final name = r.players[idx].nickname;
                              turnLabel = myTurn ? 'دورك يا $name' : 'دور $name';
                            }
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: (myTurn ? const Color(0xFF26A69A) : const Color(0xFFE57373))
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: myTurn ? const Color(0xFF26A69A) : const Color(0xFFE57373),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    myTurn ? Icons.person : Icons.arrow_right_alt,
                                    size: 18,
                                    color: myTurn ? const Color(0xFF26A69A) : const Color(0xFFE57373),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    turnLabel,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const AbilitiesBar(),
                          const SizedBox(height: 8),
                          const PlayerRack(),
                          const GameControls(),
                        ],
                      );

                      if (isWide) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final boardW = constraints.maxWidth * 0.6;
                            final sideW = constraints.maxWidth - boardW;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: boardW,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: ScrabbleBoard(),
                                  ),
                                ),
                                SizedBox(
                                  width: sideW,
                                  child: Column(
                                    children: [
                                      sync,
                                      const Scoreboard(),
                                      const MoveHistory(),
                                      Expanded(child: controls),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }

                      return Column(
                         children: [
                          // Header that can wrap instead of scrolling
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Scoreboard(),
                                MoveHistory(),
                              ],
                            ),
                          ),
                          // Board takes ~60% height
                          const Expanded(flex: 7, child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ScrabbleBoard(),
                          )),
                          // Lower panel takes ~40% height
                          Expanded(
                            flex: 3,
                            child: LayoutBuilder(
                              builder: (context, c) {
                                // Scale UI down for narrow widths; keep board size unchanged
                                final scale = (c.maxWidth / 900).clamp(0.75, 1.0);
                                final baseText = 16.0 * scale;
                                return Transform.scale(
                                  scale: scale,
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        sync,
                                        Builder(builder: (context) {
                                          final g = context.watch<GameProvider>();
                                          final r = g.room;
                                          String turnLabel = 'بانتظار اللاعبين...';
                                          bool myTurn = g.isMyTurn;
                                          if (r != null && r.players.isNotEmpty) {
                                            final idx = r.currentPlayerIndex;
                                            final name = r.players[idx].nickname;
                                            turnLabel = myTurn ? 'دورك يا $name' : 'دور $name';
                                          }
                                          return Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: (myTurn ? const Color(0xFF26A69A) : const Color(0xFFE57373))
                                                  .withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: myTurn ? const Color(0xFF26A69A) : const Color(0xFFE57373),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  myTurn ? Icons.person : Icons.arrow_right_alt,
                                                  size: 16 * scale,
                                                  color: myTurn ? const Color(0xFF26A69A) : const Color(0xFFE57373),
                                                ),
                                                SizedBox(width: 6 * scale),
                                                Text(
                                                  turnLabel,
                                                  style: TextStyle(
                                                    fontSize: baseText,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        const AbilitiesBar(),
                                        const PlayerRack(),
                                        const GameControls(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/room_data_provider.dart';
import 'package:mp_tictactoe/resources/socket_methods.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:mp_tictactoe/views/waiting_lobby.dart';
import 'package:provider/provider.dart';
import 'package:mp_tictactoe/data/arabic_dictionary_loader.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/widgets/topbar.dart';
import 'package:mp_tictactoe/widgets/multiplayer_enemyUI.dart';
import 'package:mp_tictactoe/widgets/multiplayer_boardUI.dart';
import 'package:mp_tictactoe/widgets/multiplayer_playerUI.dart';
import 'package:mp_tictactoe/widgets/gameBG.dart';


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
    _socketMethods.boardResetListener(context);
    // _socketMethods.updatePlayersStateListener(context);
    // _socketMethods.pointIncreaseListener(context);
    // _socketMethods.endGameListener(context);
  }

  @override
  void dispose() {
    // Clean up socket listeners to prevent memory leaks and context errors
    _socketMethods.removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);

    final room = roomDataProvider.room;
    final waiting = room == null || (room.players.length < 2);

    return Scaffold(
      key: _scaffoldKey,
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
                        Chip(label: Text(room.status.toString())),
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
                    const SizedBox(height: 8),
                    if (isHost)
                      TextButton.icon(
                        onPressed: () {
                          _socketMethods.resetBoard(room.id);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Board'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                        ),
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
      body: waiting
          ? const WaitingLobby()
          : _buildGameScreen(roomDataProvider),
    );
  }

  Widget _buildGameScreen(RoomDataProvider roomDataProvider) {
    return ChangeNotifierProvider<GameProvider>(
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
        final sync = Selector<RoomDataProvider, Room?>(
          selector: (_, prov) => prov.room,
          builder: (ctx, latestRoom, __) {
            if (latestRoom != null) {
              ctx.read<GameProvider>().updateRoom(latestRoom);
            }
            return const SizedBox.shrink();
          },
        );

        return Scaffold(
          body: Stack(
            children: [
              // Background
              GameUi(child: _buildGameScreenContent(roomDataProvider)),
              // Sync widget
              sync,
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameScreenContent(RoomDataProvider roomDataProvider) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final room = roomDataProvider.room!;
          final mySocketId = _socketMethods.socketClient.id;
          final currentPlayer = room.players[room.currentPlayerIndex];
          final isMyTurn = currentPlayer.socketId == mySocketId;
          
          // Get my player and opponent player
          final me = mySocketId == null ? null : room.players.firstWhere(
            (p) => p.socketId == mySocketId,
            orElse: () => room.players.first,
          );
          final opponent = room.players.firstWhere(
            (p) => p.socketId != mySocketId,
            orElse: () => room.players.last,
          );
          
          return Column(
            children: [
              // Top Bar - 7% of screen height
              SizedBox(
                height: constraints.maxHeight * 0.07,
                child: Builder(builder: (context) {
                  final g = context.watch<GameProvider>();
                  final r = g.room;
                  String turnLabel = 'بانتظار اللاعبين...';
                  bool myTurn = g.isMyTurn;
                  if (r != null && r.players.isNotEmpty) {
                    final idx = r.currentPlayerIndex;
                    final name = r.players[idx].nickname;
                    turnLabel = myTurn ? 'دورك يا $name' : 'دور $name';
                  }
                  return Topbar(
                    currentText: turnLabel,
                    showMenuBars: false,
                    actionButton: IconButton(
                      tooltip: 'Room sidebar',
                      icon: const Icon(Icons.info_outline, color: Color(0xFFFAE3C5)),
                      onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  );
                }),
              ),
              
              // Enemy UI - 17% of screen height
              SizedBox(
                height: constraints.maxHeight * 0.17,
                child: MultiplayerEnemyUi(
                  name: opponent.nickname,
                  points: opponent.score,
                  image: "https://placehold.co/100x100",
                  tiles: opponent.rack,
                  socketMethods: _socketMethods,
                ),
              ),
              
              // Game Board - Expanded main content
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: MultiplayerBoardUI(socketMethods: _socketMethods),
                ),
              ),
              
              // Player UI - 21% of screen height
              SizedBox(
                height: constraints.maxHeight * 0.21,
                child: Builder(builder: (context) {
                  // Debug: Print player and tile information
                  debugPrint('[GameScreen] Player UI Debug:');
                  debugPrint('[GameScreen]   me: ${me?.nickname ?? 'null'}');
                  debugPrint('[GameScreen]   me?.rack: ${me?.rack.length ?? 0} tiles');
                  if (me?.rack.isNotEmpty == true) {
                    debugPrint('[GameScreen]   First tile: ${me!.rack.first.letter} (${me.rack.first.value} points)');
                  }
                  
                  return MultiplayerPlayerUi(
                    name: me?.nickname ?? 'Player',
                    points: me?.score ?? 0,
                    image: "https://placehold.co/100x100",
                    tiles: me?.rack ?? [],
                    socketMethods: _socketMethods,
                  );
                }),
              ),
              SizedBox(height: constraints.maxHeight * 0.005),
            ],
          );
        },
      ),
    );
  }
}

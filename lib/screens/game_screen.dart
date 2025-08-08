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

    return Scaffold(
      body: roomDataProvider.room == null
          ? const WaitingLobby()
          : ChangeNotifierProvider<GameProvider>(
              create: (_) => GameProvider(),
              child: SafeArea(
                child: Column(
                  children: [
                    const Scoreboard(),
                    const Expanded(child: ScrabbleBoard()),
                    Text(
                        '${roomDataProvider.room!.currentPlayerId ?? 'Player 1'}\'s turn',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const PlayerRack(),
                    const GameControls(),
                  ],
                ),
              ),
            ),
    );
  }
}

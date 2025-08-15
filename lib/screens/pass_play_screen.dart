import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/pass_play_provider.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';
import 'package:mp_tictactoe/data/arabic_dictionary_loader.dart';
import 'package:mp_tictactoe/widgets/playerUI.dart';
import 'package:provider/provider.dart';

import 'package:mp_tictactoe/widgets/topbar.dart';
import 'package:mp_tictactoe/widgets/enemyUI.dart';
import 'package:mp_tictactoe/widgets/gameBG.dart';
import 'package:mp_tictactoe/widgets/board.dart';
import 'package:mp_tictactoe/models/tile.dart';

class PassPlayScreen extends StatefulWidget {
  static const routeName = '/new-pass-play';
  const PassPlayScreen({super.key});

  @override
  State<PassPlayScreen> createState() => _PassPlayScreenState();
}

class _PassPlayScreenState extends State<PassPlayScreen> {
  final _p1Controller = TextEditingController(text: '');
  final _p2Controller = TextEditingController(text: '');
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    // Preload dictionary for fast word validation
    ArabicDictionary.instance.preload();
  }

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  void _startGame(PassPlayProvider provider) {
    final p1Name = _p1Controller.text.trim().isEmpty ? 'Player 1' : _p1Controller.text.trim();
    final p2Name = _p2Controller.text.trim().isEmpty ? 'Player 2' : _p2Controller.text.trim();

    provider.initializeGame(p1Name, p2Name);
    setState(() => _gameStarted = true);
  }

  void _resetGame(PassPlayProvider provider) {
    provider.resetGame();
    setState(() => _gameStarted = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PassPlayProvider>(
      create: (_) => PassPlayProvider(),
      child: Consumer<PassPlayProvider>(
        builder: (context, passPlayProvider, child) {
          if (!_gameStarted || passPlayProvider.room == null) {
            return _buildSetupScreen(passPlayProvider);
          }

          return _buildGameScreen(passPlayProvider);
        },
      ),
    );
  }

  Widget _buildSetupScreen(PassPlayProvider provider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تمرير واللعب (محلي)'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'إعداد اللعبة المحلية',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _p1Controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'اسم اللاعب الأول',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF26A69A)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _p2Controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'اسم اللاعب الثاني',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF26A69A)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _startGame(provider),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('ابدأ اللعبة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen(PassPlayProvider passPlayProvider) {
    return ChangeNotifierProvider<GameProvider>(
      create: (_) => GameProvider(),
      builder: (context, child) {
        // Seed GameProvider with current Room and player id
        final game = context.read<GameProvider>();
        final room = passPlayProvider.room!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          game.updateRoom(room);
          game.setCurrentPlayerId(passPlayProvider.currentPlayerId ?? room.players.first.id);

          // Surface latest pass&play message as a SnackBar (non-blocking)
          final p = passPlayProvider;
          final msg = p.errorMessage ?? p.successMessage;
          if (msg != null && mounted) {
            final isError = p.errorMessage != null;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(msg, textAlign: TextAlign.center),
                  backgroundColor: isError ? const Color(0xFFE57373) : const Color(0xFF26A69A),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
          }
        });

        // Keep GameProvider synced with PassPlayProvider
        final sync = Selector<PassPlayProvider, String?>(
          selector: (_, prov) => prov.room?.id,
          builder: (ctx, roomId, __) {
            if (passPlayProvider.room != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final gp = ctx.read<GameProvider>();
                gp.updateRoom(passPlayProvider.room!);
                gp.setCurrentPlayerId(
                  passPlayProvider.currentPlayerId ?? passPlayProvider.room!.players.first.id
                );
              });
            }
            return const SizedBox.shrink();
          },
        );

        return Scaffold(
          body: Stack(
            children: [
              // Background
              GameUi(),
              
              // Main content - Mobile optimized layout
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isPortrait = constraints.maxHeight > constraints.maxWidth;
                    
                    return Column(
                      children: [
                        // Sync widget
                        sync,
                        
                        // Top Bar - 10% of screen height
                        SizedBox(
                          height: constraints.maxHeight * 0.09,
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
                            return Topbar(currentText: turnLabel);
                          }),
                        ),
                        
                        // Enemy UI - 12% of screen height (reduced from 15%)
                        SizedBox(
                          height: constraints.maxHeight * 0.17,
                          child: Builder(builder: (context) {
                            final room = passPlayProvider.room!;
                            final currentPlayerId = passPlayProvider.currentPlayerId ?? room.players.first.id;
                            final otherPlayer = room.players.firstWhere(
                              (p) => p.id != currentPlayerId,
                              orElse: () => room.players.last,
                            );
                            
                            // Create sample tiles for enemy with actual letters
                            final sampleLetters = ['ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ'];
                            final enemyTiles = List.generate(7, (index) => 
                              Tile(letter: sampleLetters[index], value: index + 1)
                            );
                            
                            return EnemyUi(
                              name: otherPlayer.nickname,
                              points: otherPlayer.score,
                              image: "https://placehold.co/100x100",
                              tiles: enemyTiles,
                            );
                          }),
                        ),
                        
                        // Game Board - 50% of screen height (main content)
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Board(),
                          ),
                        ),
                        
                        // Player UI - 18% of screen height (reduced from 20%)
                        SizedBox(
                          height: constraints.maxHeight * 0.21,
                          child: Builder(builder: (context) {
                            final room = passPlayProvider.room!;
                            final currentPlayerId = passPlayProvider.currentPlayerId ?? room.players.first.id;
                            final currentPlayer = room.players.firstWhere(
                              (p) => p.id == currentPlayerId,
                              orElse: () => room.players.first,
                            );
                            
                            // Get player's tiles from the room
                            final playerTiles = currentPlayer.rack.isNotEmpty 
                              ? currentPlayer.rack 
                              : List.generate(7, (index) => 
                                  Tile(letter: 'أ', value: 1)
                                );
                            
                            return PlayerUi(
                              name: currentPlayer.nickname,
                              points: currentPlayer.score,
                              image: "https://placehold.co/100x100",
                              tiles: playerTiles,
                            );
                          }),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.005),
                        
                        // Bottom padding for safe area
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
  }
}
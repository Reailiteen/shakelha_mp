import 'package:flutter/material.dart';
import 'package:shakelha_mp/provider/pass_play_provider.dart';
import 'package:shakelha_mp/provider/game_provider.dart';
import 'package:shakelha_mp/data/arabic_dictionary_loader.dart';
import 'package:shakelha_mp/widgets/playerUI.dart';
import 'package:provider/provider.dart';
// Import board.dart to access word validation classes
import 'package:shakelha_mp/models/board.dart';

import 'package:shakelha_mp/widgets/topbar.dart';
import 'package:shakelha_mp/widgets/enemyUI.dart';
import 'package:shakelha_mp/widgets/gameBG.dart';
import 'package:shakelha_mp/widgets/boardUI.dart';
import 'package:shakelha_mp/models/tile.dart';
import 'package:shakelha_mp/widgets/letter_distribution_view.dart';

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
  int _selectedBoardSize = 13; // Default to 13x13

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

    provider.initializeGame(p1Name, p2Name, boardSize: _selectedBoardSize);
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
                      // Board size selector
                      Text(
                        'حجم اللوحة',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBoardSizeOption(11, '11 × 11'),
                          _buildBoardSizeOption(13, '13 × 13'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _p1Controller,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'اللاعب 1',
                          labelStyle: const TextStyle(color: Color.fromARGB(179, 60, 193, 255)),
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
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'اللاعب 2',
                          labelStyle: const TextStyle(color: Color.fromARGB(179, 60, 193, 255)),
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
        return Scaffold(
          body: _buildGameScreenContent(passPlayProvider),
        );
      },
    );
  }

  Widget _buildGameScreenContent(PassPlayProvider passPlayProvider) {
    return SafeArea(
      
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Detect swipe to the right (positive velocity)
          if (details.primaryVelocity! > 300) {
            _showLetterDistribution(context, passPlayProvider);
          }
        },
        child: LayoutBuilder(

          builder: (context, constraints) {
            return Column(
              children: [
                // Top Bar with word validation status - 10% of screen height
                SizedBox(
                  height: constraints.maxHeight * 0.07,
                  child: Consumer<PassPlayProvider>(
                    builder: (context, passPlay, child) {
                      final room = passPlay.room!;
                      String turnLabel = 'بانتظار اللاعبين...';
                      bool myTurn = passPlay.isMyTurn;
                      if (room.players.isNotEmpty) {
                        final idx = room.currentPlayerIndex;
                        final name = room.players[idx].nickname;
                        turnLabel = myTurn ? 'دورك يا $name' : 'دور $name';
                      }
                      
                      return Row(
                        children: [
                          Expanded(child: Topbar(currentText: turnLabel)),
                          // Word validation toggle and status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Validation status indicator
                                if (passPlay.wordValidationEnabled && passPlay.validatedWords.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getValidationStatusColor(passPlay.validatedWords),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${passPlay.validatedWords.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                
                                const SizedBox(width: 4),
                                
                                // Toggle button
                                GestureDetector(
                                  onTap: () {
                                    passPlay.toggleWordValidation();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          passPlay.wordValidationEnabled
                                            ? 'تم تفعيل التحقق من الكلمات'
                                            : 'تم إلغاء التحقق من الكلمات',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: passPlay.wordValidationEnabled
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey[600],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      passPlay.wordValidationEnabled
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.005),
                
                // Enemy UI - 12% of screen height
                SizedBox(
                  height: constraints.maxHeight * 0.14,
                  child: Consumer<PassPlayProvider>(
                    builder: (context, passPlay, child) {
                      final room = passPlay.room!;
                      final currentPlayerId = passPlay.currentPlayerId ?? room.players.first.id;
                      final otherPlayer = room.players.firstWhere(
                        (p) => p.id != currentPlayerId,
                        orElse: () => room.players.last,
                      );
                      
                      // Show opponent's actual rack tiles from room
                      final opponentRack = otherPlayer.rack;
                      
                      return EnemyUi(
                        name: otherPlayer.nickname,
                        points: otherPlayer.score,
                        image: "https://placehold.co/100x100",
                        tiles: opponentRack,
                      );
                    },
                  ),
                ),
                
                // Game Board - 50% of screen height (main content)
                Expanded(
                  flex: 7,
                  child: BoardUI(boardSize: passPlayProvider.room?.board.size ?? 13),
                ),
                SizedBox(height: constraints.maxHeight * 0.01),
                
                // Player UI - 18% of screen height
                SizedBox(
                  height: constraints.maxHeight * 0.17,
                  child: Consumer<PassPlayProvider>(
                    builder: (context, passPlay, child) {
                      final room = passPlay.room!;
                      final currentPlayerId = passPlay.currentPlayerId ?? room.players.first.id;
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
                    },
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.005),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Shows the letter distribution as a modal bottom sheet
  void _showLetterDistribution(BuildContext context, PassPlayProvider passPlayProvider) {
    // Get the letter distribution from the room if available
    final letterDistribution = passPlayProvider.room?.letterDistribution;
    showDialog(context: context, builder: (context) => LetterDistributionBottomSheet(
        letterDistribution: letterDistribution,
      ));
  }
  
  /// Get validation status color based on word states
  Color _getValidationStatusColor(List<ValidatedWord> words) {
    final hasInvalid = words.any((w) => w.status == WordValidationStatus.invalid);
    final hasPending = words.any((w) => w.status == WordValidationStatus.pending);
    
    if (hasInvalid) {
      return const Color(0xFFF44336); // Red
    } else if (hasPending) {
      return const Color(0xFFFFC107); // Amber
    } else {
      return const Color(0xFF4CAF50); // Green
    }
  }

  /// Build board size option button
  Widget _buildBoardSizeOption(int size, String label) {
    final isSelected = _selectedBoardSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBoardSize = size;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26A69A) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF26A69A) : Colors.white24,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shakelha_mp/models/tile.dart';
import 'package:shakelha_mp/models/move.dart';
import 'package:shakelha_mp/widgets/tileUI.dart';
import 'package:shakelha_mp/provider/pass_play_provider.dart';
import 'package:provider/provider.dart';
import 'package:shakelha_mp/widgets/letter_distribution_view.dart';

class PlayerUi extends StatelessWidget {
  const PlayerUi({Key? key, required this.name, required this.points, required this.image, required this.tiles}) : super(key: key);
  final String name;
  final int points;
  final String image;
  final List<Tile> tiles;
  
  /// Calculates the average size between rack tile and board tile for better drag feedback
  static double _getDragFeedbackSize(double rackTileSize) {
    const double boardCellSize = 28.0; // Standard board cell size (15x15 grid)
    return (rackTileSize + boardCellSize) / 2;
  }
  
  @override
  Widget build(BuildContext context) {
    // Use Provider.of to ensure we get a non-null provider when this widget is used under the PassPlay provider
    final prov = Provider.of<PassPlayProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          // Tiles rack - now a DragTarget for tiles being returned from the board
          Expanded(
            flex: 12,
            child: DragTarget<PlacedTile>(
              onWillAccept: (data) {
                // Only accept if it's the player's turn and the tile is from the board
                return prov.isMyTurn == true && data != null;
              },
              onAccept: (placedTile) {
                // Return the tile to the rack by removing it from the board
                prov.removePendingPlacement(placedTile.position);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA46D41),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    // Add visual feedback when dragging tiles over the rack
                    border: candidateData.isNotEmpty 
                        ? Border.all(color: Colors.green.withOpacity(0.7), width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: tiles.asMap().entries.map((entry) {
                      final tile = entry.value;
                      final double tileSize = (screenWidth - 50) / 7; // 7 tiles with padding
                      
                      return Container(
                        width: tileSize,
                        height: tileSize,
                        child: Draggable<Tile>(
                          data: tile,
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: _getDragFeedbackSize(tileSize),
                              height: _getDragFeedbackSize(tileSize),
                              child: TileUI(
                                width: _getDragFeedbackSize(tileSize),
                                height: _getDragFeedbackSize(tileSize),
                                letter: tile.letter,
                                points: tile.value,
                                left: 0,
                                top: 0,
                              ),
                            ),
                          ),
                          childWhenDragging: const SizedBox.shrink(),
                          onDragStarted: () {
                            // Initialize placing mode if available
                            prov.startPlacingTiles();
                          },
                          child: TileUI(
                            width: tileSize,
                            height: tileSize,
                            letter: tile.letter,
                            points: tile.value,
                            left: 0,
                            top: 0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Controls row only (player info removed; now lives in EnemyUi header row)
          Expanded(
            flex: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Pass turn icon button
                IconButton(
                  onPressed: () {
                    prov.passTurn();
                  },
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF137F83),
                    shape: const CircleBorder(),
                  ),
                ),
                
                // Move history icon button (moved to be next to Pass)
                IconButton(
                  onPressed: () {
                    if (prov.room == null) return;
                    final moves = prov.room!.moveHistory;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) {
                        return SafeArea(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('تاريخ الحركات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: moves.length,
                                    itemBuilder: (c, i) {
                                      final move = moves[i];
                                      // Show formed words when available, otherwise show the letters placed or move type
                                      final wordsText = move.wordsFormed.isNotEmpty
                                          ? move.wordsFormed.join(', ')
                                          : (move.placedTiles.isNotEmpty
                                              ? move.placedTiles.map((p) => p.tile.letter).join('')
                                              : move.type.toString().split('.').last);
                                      
                                      return ListTile(
                                        title: Text(
                                          wordsText,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (move.placedTiles.isNotEmpty)
                                              Text('Tiles: ' + move.placedTiles.map((p) => '${p.tile.letter}@${p.position.row},${p.position.col}').join('; ')),
                                            Text('${move.playerId} • ${move.timestamp.toLocal().toString().split('.').first}'),
                                          ],
                                        ),
                                        trailing: Text(
                                          '+${move.totalPoints}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.history, color: Colors.white, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A2),
                    shape: const CircleBorder(),
                  ),
                ),
                
                // Submit button as a proper ElevatedButton (fixed to reliably call provider.submitMove)
                ElevatedButton(
                  onPressed: () {
                    // Ensure provider call is executed; provider should exist because widget is used under the PassPlay provider
                    prov.submitMove();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                  ),
                  child: const Text(
                    'إرسال',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Swap all tiles icon button
                IconButton(
                  onPressed: () {
                    final player = prov.currentPlayer;
                    if (player == null) return;
                    if (player.rack.isEmpty) return;
                    // Swap out all tiles and pass the turn
                    prov.swapTiles(List<Tile>.from(player.rack));
                  },
                  icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF9F6538),
                    shape: const CircleBorder(),
                  ),
                ),
                
                // More menu (replaces hint). Contains Hint and Letter Distribution
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.blue),
                  color: const Color.fromARGB(255, 75, 126, 220),
                  onSelected: (value) async {
                    if (value == 'hint') {
                      // For now show a placeholder hint sheet. Real hint logic can be added in the provider later.
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (ctx) {
                          return SafeArea(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('تلميح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 12),
                                  const Text('سيظهر التلميح هنا. تفعيل منطق التلميحات في المزود (provider) لاحقًا.'),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('إغلاق'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (value == 'distribution') {
                      // Show the letter distribution bottom sheet (moved here from the top bar)
                      final letterDistribution = prov.room?.letterDistribution;
                      showDialog(
                        context: context,
                        builder: (dCtx) => LetterDistributionBottomSheet(
                          letterDistribution: letterDistribution,
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'hint', child: Text('تلميح')),
                    const PopupMenuItem(value: 'distribution', child: Text('توزيع الحروف')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
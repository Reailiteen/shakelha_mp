import 'package:flutter/material.dart';
import 'package:shakelha_mp/models/tile.dart';
import 'package:shakelha_mp/models/move.dart';
import 'package:shakelha_mp/widgets/tileUI.dart';
import 'package:shakelha_mp/provider/pass_play_provider.dart';
import 'package:provider/provider.dart';

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
    final passPlay = context.read<PassPlayProvider?>();
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
                return passPlay?.isMyTurn == true && data != null;
              },
              onAccept: (placedTile) {
                // Return the tile to the rack by removing it from the board
                if (passPlay != null) {
                  passPlay.removePendingPlacement(placedTile.position);
                }
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
                            if (passPlay != null) passPlay.startPlacingTiles();
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
                    final prov = context.read<PassPlayProvider?>();
                    prov?.passTurn();
                  },
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF137F83),
                    shape: const CircleBorder(),
                  ),
                ),
                
                // Word suggestion icon button
                IconButton(
                  onPressed: () {
                    // No-op hint UI. Logic to be added later.
                  },
                  icon: const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 127, 141, 25),
                    shape: const CircleBorder(),
                  ),
                ),
                
                // Submit button as small container (centered)
                GestureDetector(
                  onTap: () {
                    final prov = context.read<PassPlayProvider?>();
                    if (prov != null) {
                      prov.submitMove();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                ),
                
                // Swap all tiles icon button
                IconButton(
                  onPressed: () {
                    final prov = context.read<PassPlayProvider?>();
                    if (prov == null) return;
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
                
                // Move history icon button
                IconButton(
                  onPressed: () {
                    final prov = context.read<PassPlayProvider?>();
                    if (prov?.room == null) return;
                    final moves = prov!.room!.moveHistory;
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
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 12),
                                Center(
                                  child: Container(
                                    width: 120,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'الكلمات السابقة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: moves.length,
                                    itemBuilder: (c, i) {
                                      final m = moves[i];
                                      final player = prov.room!.players.firstWhere((p) => p.id == m.playerId, orElse: () => prov.room!.players.first);
                                      final words = m.wordsFormed.isNotEmpty ? m.wordsFormed.join('، ') : '—';
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          title: Text(player.nickname, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                                          subtitle: Text('الكلمات: $words', textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 28)),
                                          trailing: Text('+${m.points}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
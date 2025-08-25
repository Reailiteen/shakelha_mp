import 'package:flutter/material.dart';
import 'package:shakelha_mp/models/tile.dart';
import 'tileUI.dart';
import 'package:shakelha_mp/provider/room_data_provider.dart';
import 'package:shakelha_mp/provider/game_provider.dart';
import 'package:shakelha_mp/resources/socket_methods.dart';
import 'package:provider/provider.dart';

class MultiplayerPlayerUi extends StatelessWidget {
  const MultiplayerPlayerUi({
    Key? key,
    required this.name,
    required this.points,
    required this.image,
    required this.tiles,
    required this.socketMethods,
  }) : super(key: key);

  final String name;
  final int points;
  final String image;
  final List<Tile> tiles;
  final SocketMethods socketMethods;
  
  /// Calculates the average size between rack tile and board tile for better drag feedback
  static double _getDragFeedbackSize(double rackTileSize) {
    const double boardCellSize = 28.0; // Standard board cell size (15x15 grid)
    return (rackTileSize + boardCellSize) / 2;
  }
  
  @override
  Widget build(BuildContext context) {
    final roomDataProvider = context.watch<RoomDataProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final room = roomDataProvider.room;
    // Watch GameProvider to know if it's our turn (used to enable/disable actions)
    final gameProv = context.watch<GameProvider?>();
    final bool isMyTurn = gameProv?.isMyTurn ?? false;
    // If the provided tiles list is empty (e.g. first player), try to use the current player's rack from the room
    final mySocketId = socketMethods.socketClient?.id;
    final me = (room != null && mySocketId != null)
        ? room.players.firstWhere((p) => p.socketId == mySocketId, orElse: () => room.players.first)
        : null;
    final List<Tile> displayTiles = tiles.isNotEmpty
        ? tiles
        : (me != null ? List<Tile>.from(me.rack) : tiles);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          // Tiles rack
          Expanded(
            flex: 12,
            child: Container(
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: displayTiles.isEmpty 
                  ? [
                      // Show empty rack message
                      Expanded(
                        child: Center(
                          child: Text(
                            'Rack is empty (${displayTiles.length} tiles)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ]
                  : displayTiles.asMap().entries.map((entry) {
                      final tile = entry.value;
                      final double tileSize = (screenWidth - 50) / 7; // 7 tiles with padding
                      
                      return Container(
                        child: Draggable<Tile>(
                          data: tile,
                          feedback:TileUI(
                            // Use average size between rack tile and board tile for better visual consistency
                            width: _getDragFeedbackSize(tileSize),
                            height: _getDragFeedbackSize(tileSize),
                            letter: tile.letter,
                            points: tile.value,
                            left: 0,
                            top: 0,
                          ),
                          childWhenDragging: const SizedBox.shrink(),
                          onDragStarted: () {
                            // Multiplayer: could emit socket event for drag preview
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
            ),
          ),
          const SizedBox(height: 10),
          // Controls row
          Expanded(
            flex: 10,
            child: Row(
              children: [
                // Action buttons
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (room != null && isMyTurn) ? () {
                              // Route pass through GameProvider so turn checks are enforced
                              final gp = Provider.of<GameProvider>(context, listen: false);
                              gp.passTurn();
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF137F83),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'تمرير الدور',
                              style: TextStyle(
                                fontSize: screenWidth * 0.034,
                                fontFamily: 'Jomhuria',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (room != null && isMyTurn) ? () {
                              // Submit via GameProvider so validation and turn checks run locally
                              final gameProvider = Provider.of<GameProvider>(context, listen: false);
                              gameProvider.submitMove();
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 127, 141, 25),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'تأكيد الحركة',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Jomhuria',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // Exchange and history buttons
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: room != null ? () {
                              // Exchange all tiles - create a unique identifier for each tile
                              final mySocketId = socketMethods.socketClient.id;
                              final me = mySocketId == null ? null : room.players.firstWhere(
                                (p) => p.socketId == mySocketId,
                                orElse: () => room.players.first,
                              );
                              if (me != null && me.rack.isNotEmpty) {
                                // Create unique identifiers for tiles based on their properties and position
                                final tileIds = me.rack.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final tile = entry.value;
                                  // Create a unique ID combining letter, value, and position in rack
                                  return '${tile.letter}_${tile.value}_$index';
                                }).toList();
                                
                                if (tileIds.isNotEmpty) {
                                  socketMethods.exchangeTiles(room.id, tileIds);
                                }
                              }
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9F6538),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'تبديل الكل',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Jomhuria',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (room?.moveHistory == null) return;
                              final moves = room!.moveHistory;
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
                                                final player = room!.players.firstWhere(
                                                  (p) => p.id == m.playerId, 
                                                  orElse: () => room!.players.first
                                                );
                                                final words = m.wordsFormed.isNotEmpty 
                                                  ? m.wordsFormed.join('، ') 
                                                  : '—';
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: ListTile(
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 16, 
                                                      vertical: 12
                                                    ),
                                                    title: Text(
                                                      player.nickname, 
                                                      textDirection: TextDirection.rtl, 
                                                      style: const TextStyle(
                                                        fontSize: 36, 
                                                        fontWeight: FontWeight.w800
                                                      )
                                                    ),
                                                    subtitle: Text(
                                                      'الكلمات: $words', 
                                                      textDirection: TextDirection.rtl, 
                                                      style: const TextStyle(fontSize: 28)
                                                    ),
                                                    trailing: Text(
                                                      '+${m.points}', 
                                                      style: const TextStyle(
                                                        fontSize: 32, 
                                                        fontWeight: FontWeight.bold
                                                      )
                                                    ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6750A2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'الكلمات السابقة',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Jomhuria',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
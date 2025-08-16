
// import 'package:flutter/material.dart';
// import 'package:mp_tictactoe/models/tile.dart';
// import 'package:mp_tictactoe/widgets/tileUI.dart';

// class PlayerUi extends StatelessWidget {
//   const PlayerUi({Key? key, required this.name, required this.points, required this.image, required this.tiles}) : super(key: key);
//   final String name;
//   final int points;
//   final String image;
//   final List<Tile> tiles;
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Column(
//       children: [
//         Container(
//           width: screenWidth * 0.6,
//           height: screenHeight * 0.2,
//           clipBehavior: Clip.antiAlias,
//           decoration: BoxDecoration(),
//           child: Stack(
//             children: [
//               Positioned(
//                 left: 141,
//                 top: 95,
//                 child: Container(
//                   width: screenWidth * 0.2,
//                   height: screenHeight * 0.1,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: BoxDecoration(),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         left: 0,
//                         top: 0,
//                         child: Container(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFF9F6538),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             shadows: [
//                               BoxShadow(
//                                 color: Color(0x84000000),
//                                 blurRadius: 4.50,
//                                 offset: Offset(0, 5),
//                                 spreadRadius: 2,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 6,
//                         top: 3,
//                         child: Container(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFAC7244),
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(width: 1),
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 31,
//                         top: 27,
//                         child: SizedBox(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           child: Text(
//                             name,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 56,
//                               fontFamily: 'Jomhuria',
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 0,
//                 top: 157,
//                 child: Container(
//                   width: screenWidth * 0.2,
//                   height: screenHeight * 0.1,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: BoxDecoration(),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         left: 0,
//                         top: 0,
//                         child: Container(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFF6750A2),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             shadows: [
//                               BoxShadow(
//                                 color: Color(0x84000000),
//                                 blurRadius: 4.50,
//                                 offset: Offset(0, 5),
//                                 spreadRadius: 2,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 3,
//                         top: 1,
//                         child: Container(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFF5A4B82),
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(width: 1),
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 14,
//                         top: 8,
//                         child: SizedBox(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           child: Text(
//                             'الكلمات السابقة',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontFamily: 'Jomhuria',
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 0,
//                 top: 100,
//                 child: Container(
//                   width: screenWidth * 0.2,
//                   height: screenHeight * 0.1,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: BoxDecoration(),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         left: 0,
//                         top: 0,
//                         child: Container(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFF137F83),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             shadows: [
//                               BoxShadow(
//                                 color: Color(0x84000000),
//                                 blurRadius: 4.50,
//                                 offset: Offset(0, 5),
//                                 spreadRadius: 2,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 4,
//                         top: 2,
//                         child: Container(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFF076B5C),
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(width: 1),
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 19,
//                         top: 11,
//                         child: SizedBox(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           child: Text(
//                             'تمرير الدور',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontFamily: 'Jomhuria',
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: screenWidth * 0.6,
//                 top: screenHeight * 0.2,
//                 child: Container(
//                   transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
//                   width:  screenWidth * 0.2,
//                   height: screenHeight * 0.1,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: BoxDecoration(),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         left: 0,
//                         top: 0,
//                         child: Container(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(
//                                 width: 3,
//                                 color: const Color(0xFFC9954E),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: screenWidth * 0.1,
//                         top: 0,
//                         child: Container(
//                           width: screenWidth * 0.1,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             image: DecorationImage(
//                               image: NetworkImage(image),
//                               fit: BoxFit.cover,
//                             ),
//                             shape: OvalBorder(
//                               side: BorderSide(
//                                 width: 5,
//                                 color: const Color(0xFFC9954E),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: screenWidth * 0.1,
//                         top: screenHeight * 0.1,
//                         child: SizedBox(
//                           width: screenWidth * 0.1,
//                           height: screenHeight * 0.1,
//                           child: Transform(
//                             transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
//                             child: Text(
//                               name,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 48,
//                                 fontFamily: 'Jomhuria',
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: screenWidth * 0.1,
//                         top: screenHeight * 0.1,
//                         child: SizedBox(
//                           width: screenWidth * 0.1,
//                           height: screenHeight * 0.1,
//                           child: Transform(
//                             transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
//                             child: Text(
//                               'نقاط : $points ',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 40,
//                                 fontFamily: 'Jomhuria',
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: screenWidth * 0.1,
//                 top: screenHeight * 0.1,
//                 child: Container(
//                   width: screenWidth * 0.8,
//                   height: screenHeight * 0.1,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: ShapeDecoration(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     shadows: [
//                       BoxShadow(
//                         color: Color(0x7A000000),
//                         blurRadius: 4,
//                         offset: Offset(0, 4),
//                         spreadRadius: 0,
//                       )
//                     ],
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         left: 0,
//                         top: 0,
//                         child: Container(
//                           width: screenWidth * 0.8,
//                           height: screenHeight * 0.1,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFA46D41),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                         ),
//                       ),
//                       for (int i = 0; i < tiles.length; i++)
//                         TileUI(
//                           width:  screenWidth * 0.1,
//                           height: screenHeight * 0.1,
//                           letter: tiles[i].letter,
//                           points: tiles[i].value,
//                           left: screenWidth * 0.1 + i * screenWidth * 0.1,
//                           top: screenHeight * 0.1,
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/widgets/tileUI.dart';
import 'package:mp_tictactoe/provider/pass_play_provider.dart';
import 'package:provider/provider.dart';

class PlayerUi extends StatelessWidget {
  const PlayerUi({Key? key, required this.name, required this.points, required this.image, required this.tiles}) : super(key: key);
  final String name;
  final int points;
  final String image;
  final List<Tile> tiles;
  @override
  Widget build(BuildContext context) {
    final passPlay = context.read<PassPlayProvider?>();
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          // Tiles rack
          Expanded(
            flex:10,
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
                children: tiles.asMap().entries.map((entry) {
                  final tile = entry.value;
                  final double tileSize = (screenWidth - 50) / 7; // 7 tiles with padding
                  
                  return Container(
                    width: tileSize,
                    height: tileSize,
                    child: Draggable<Tile>(
                      data: tile,
                      feedback: SizedBox(
                        width: tileSize,
                        height: tileSize,
                        child: TileUI(
                          width: tileSize,
                          height: tileSize,
                          letter: tile.letter,
                          points: tile.value,
                          left: 0,
                          top: 0,
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
            ),
          ),
          const SizedBox(height: 10),
          // Player info and controls row
          Expanded(
            flex: 9,
            child: Row(
              children: [
                // Player avatar and info
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFC9954E),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: screenWidth * 0.06,
                          backgroundColor: const Color(0xFFC9954E),
                          child: CircleAvatar(
                            radius: screenWidth * 0.055,
                            backgroundImage: NetworkImage(image),
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Name and points
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                  fontFamily: 'Jomhuria',
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'نقاط: $points',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.03,
                                  fontFamily: 'Jomhuria',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 4),
                
                // Action buttons
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final prov = context.read<PassPlayProvider?>();
                              prov?.passTurn();
                            },
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
                                fontSize: screenWidth * 0.028,
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
                              // No-op hint UI. Logic to be added later.
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF137F83),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'اقتراح كلمة',
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
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

                // Swap and history buttons
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final prov = context.read<PassPlayProvider?>();
                              if (prov == null) return;
                              final player = prov.currentPlayer;
                              if (player == null) return;
                              if (player.rack.isEmpty) return;
                              // Swap out all tiles and pass the turn
                              prov.swapTiles(List<Tile>.from(player.rack));
                            },
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
                                fontSize: screenWidth * 0.025,
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
                                        maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(height: 4),
                                          Center(
                                            child: Container(
                                              width: 40,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'الكلمات السابقة',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: moves.length,
                                              itemBuilder: (c, i) {
                                                final m = moves[i];
                                                final player = prov.room!.players.firstWhere((p) => p.id == m.playerId, orElse: () => prov.room!.players.first);
                                                final words = m.wordsFormed.isNotEmpty ? m.wordsFormed.join('، ') : '—';
                                                return ListTile(
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  title: Text(player.nickname, textDirection: TextDirection.rtl),
                                                  subtitle: Text('الكلمات: $words', textDirection: TextDirection.rtl),
                                                  trailing: Text('+${m.points}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                fontSize: screenWidth * 0.025,
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
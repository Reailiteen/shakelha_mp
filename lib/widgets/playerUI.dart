
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

class PlayerUi extends StatelessWidget {
  const PlayerUi({Key? key, required this.name, required this.points, required this.image, required this.tiles}) : super(key: key);
  final String name;
  final int points;
  final String image;
  final List<Tile> tiles;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
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
                              // Handle pass turn
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
                              // Handle view previous words
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
          
          const SizedBox(height: 8),
          
          // Tiles rack
          Expanded(
            flex:11,
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
                  final int index = entry.key;
                  final tile = entry.value;
                  final double tileSize = (screenWidth - 80) / 7; // 7 tiles with padding
                  
                  return Container(
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
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
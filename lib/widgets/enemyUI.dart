import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/widgets/tileUI.dart';

class EnemyUi extends StatelessWidget {
  const EnemyUi({Key? key, required this.name, required this.points, required this.image, required this.tiles}) : super(key: key);
  final String name;
  final int points;
  final String image;
  final List<Tile> tiles;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          // Player info
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
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
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'نقاط : $points',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Jomhuria',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Enemy tiles (show same UI as player tiles)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4.0),
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
                  final double tileSize = (screenWidth - 80) / 7;
                  
                  return SizedBox(
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

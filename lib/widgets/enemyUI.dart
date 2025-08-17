import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/widgets/tileUI.dart';
import 'package:mp_tictactoe/provider/pass_play_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
          // Scrabble-style top row: Opponent info (left) + My info (right)
          Expanded(
            flex: 4,
            child: Builder(builder: (context) {
              final prov = context.read<PassPlayProvider?>();
              final my = prov?.currentPlayer;
              final myName = my?.nickname ?? '—';
              final myPoints = my?.score ?? 0;

              Widget buildHeaderCard({
                required bool avatarOnLeft,
                required String displayName,
                required int displayPoints,
                required String avatar,
              }) {
                return LayoutBuilder(
                  builder: (context, c) {
                    final h = c.maxHeight;
                    final nameSize = (h * 0.42).clamp(10.0, 22.0);
                    final pointsSize = (h * 0.32).clamp(8.0, 18.0);

                    Widget avatarWidget (double height)=>CircleAvatar(
                      radius: height * 0.5,
                      backgroundColor: const Color(0xFFC9954E).withOpacity(0.9),
                      child: CircleAvatar(
                        radius: height * 0.45,
                        backgroundImage: NetworkImage(avatar),
                        backgroundColor: Colors.grey[300],
                      ),
                    );

                    Widget textBlock(bool flipx) => Transform.flip(flipX: !flipx, child: Stack(
                      children: [
                        Positioned(top: 0, left: 0, right: 0, bottom: 20, child: Text(
                          displayName,

                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: nameSize*1.2,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.jomhuria().fontFamily,
                            letterSpacing: screenWidth * 0.001,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )),
                        Positioned(top: 26, left: !flipx ? 0 : 40 , right: !flipx ? 40 : 0, bottom: 0, child: Text(
                          'نقاط : $displayPoints',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: pointsSize,
                            fontWeight: FontWeight.w400,
                            fontFamily: GoogleFonts.jomhuria().fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )),
                      ],
                    ));

                    return Transform.flip(flipX: !avatarOnLeft, child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                            border: Border.all(color: const Color(0xFFC9954E), width: 3),
                          ),
                          child: Padding(padding: EdgeInsets.only(left: screenWidth * 0.02,bottom: h * 0.05), child: Center(child: textBlock(avatarOnLeft))),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: avatarWidget(h),
                        ),
                        ]
                      )
                    );
                  },
                );
              }

              return Row(
                children: [
                  Expanded(child: buildHeaderCard(avatarOnLeft: false, displayName: name, displayPoints: points, avatar: image)),
                  const SizedBox(width: 10),
                  Expanded(child: buildHeaderCard(avatarOnLeft: true, displayName: myName, displayPoints: myPoints, avatar: 'https://placehold.co/100x100')),
                ],
              );
            }),
          ),
          
          const SizedBox(height: 4),
          
          // Enemy tiles (show same UI as player tiles)
          Expanded(
            flex: 4,
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

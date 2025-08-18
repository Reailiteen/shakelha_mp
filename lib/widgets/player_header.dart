import 'package:flutter/material.dart';

class PlayerHeader extends StatelessWidget {
  const PlayerHeader({super.key, required this.name, required this.points, required this.imageUrl});

  final String name;
  final int points;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width > 430 ? 430 : MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1B0F).withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC9954E), width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundColor: const Color(0xFFC9954E),
            child: CircleAvatar(
              radius: screenWidth * 0.055,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    fontFamily: 'Jomhuria',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'نقاط : $points',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.032,
                    fontFamily: 'Jomhuria',
                    fontWeight: FontWeight.w700,
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



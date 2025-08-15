import 'package:flutter/material.dart';

// Grid cell widget for responsive board tiles
class GridCell extends StatelessWidget {
  final int row;
  final int col;
  final bool isSpecial;
  final Color? specialColor;
  
  const GridCell({
    Key? key,
    required this.row,
    required this.col,
    this.isSpecial = false,
    this.specialColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.2),
      decoration: BoxDecoration(
        color: isSpecial 
            ? (specialColor ?? const Color(0xFFFFECD6))
            : Colors.transparent,
        border: Border.all(
          color: const Color(0xFFAB8756),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: isSpecial
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFECD6),
                      Color(0xFFEDDABE),
                      Color(0xFFD9B991),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class BoardUI extends StatelessWidget {
  const BoardUI({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define special positions (like triple word score, double letter, etc.)
    final Set<String> specialPositions = {
      '0-0', '0-3', '0-7', '0-11', '0-14', // Top row special positions
      '3-0', '3-14', 
      '7-0', '7-3', '7-7', '7-11', '7-14', // Middle row
      '11-0', '11-14',
      '14-0', '14-3', '14-7', '14-11', '14-14', // Bottom row
      // Add more special positions as needed
    };
    
    // Calculate board size to fit available space
    final double availableWidth = screenWidth * 0.95;
    final double availableHeight = double.infinity;
    final double boardSize = availableWidth;
    final double cellSize = boardSize / 15; // 15x15 grid
    
    return Center(
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          color: const Color(0xFF512103),
          border: Border.all(
            color: const Color(0xFF2D462D),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 15,
              childAspectRatio: 1.0,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: 225, // 15x15 = 225 cells
            itemBuilder: (context, index) {
              final row = index ~/ 15;
              final col = index % 15;
              final positionKey = '$row-$col';
              
              final bool isSpecial = specialPositions.contains(positionKey);
              Color? specialColor;
              
              // Assign different colors based on position
              if (row == 7 && col == 7) {
                // Center star
                specialColor = const Color(0xFF9E7649);
              } else if (isSpecial) {
                // Other special positions
                if (row == 0 || row == 14 || col == 0 || col == 14) {
                  specialColor = const Color(0xFFFFECD6);
                } else {
                  specialColor = const Color(0xFFEDDABE);
                }
              }
              
              return GestureDetector(
                onTap: () {
                  // Handle cell tap - for placing tiles
                  print('Tapped cell: $row, $col');
                },
                child: GridCell(
                  row: row,
                  col: col,
                  isSpecial: isSpecial,
                  specialColor: specialColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
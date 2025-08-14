// import 'package:flutter/material.dart';

// class GameUi extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Column(
//       children: [
//         Container(
//           width: screenWidth,
//           height: screenHeight,
//           clipBehavior: Clip.antiAlias,
//           decoration: BoxDecoration(),
//           child: Stack(
//             children: [
//               Positioned(
//                 left: 0,
//                 top: 0,
//                 child: Container(
//                   width: screenWidth,
//                   height: screenHeight,
//                   decoration: BoxDecoration(color: const Color(0x33A70000)),
//                 ),
//               ),
//               Positioned(
//                 left: screenWidth * 0.1,
//                 top: screenHeight * 0.1,
//                 child: Container(
//                   width: screenWidth * 0.8,
//                   height: screenHeight * 0.8,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFF512103),
//                     shape: RoundedRectangleBorder(
//                       side: BorderSide(
//                         width: 16,
//                         strokeAlign: BorderSide.strokeAlignOutside,
//                         color: const Color(0xFF2D462D),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: screenWidth * 0.1,
//                 top: screenHeight * 0.9,
//                 child: Container(
//                   width: screenWidth * 0.8,
//                   height: screenHeight * 0.1,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: NetworkImage("https://placehold.co/682x74"),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: screenWidth * 0.1,
//                 top: screenHeight * 0.9,
//                 child: Container(
//                   width: screenWidth * 0.8,
//                   height: screenHeight * 0.05,
//                   decoration: BoxDecoration(color: const Color(0xFFB46C28)),
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

class GameUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2D462D), // Dark green at top
            Color(0xFF512103), // Brown in middle
            Color(0xFF301A0F), // Darker brown at bottom
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1), // Subtle overlay
        ),
      ),
    );
  }
}
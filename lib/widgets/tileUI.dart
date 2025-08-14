// import 'package:flutter/material.dart';

// class TileUI extends StatelessWidget {
//   const TileUI({Key? key, required this.width, required this.height, required this.letter, required this.points,required this.top,required this.left}) : super(key: key);
//   final double width;
//   final double height;
//   final String letter;
//   final int points;
//   final double top;
//   final double left;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: width,
//           height: height,
//           clipBehavior: Clip.antiAlias,
//           decoration: ShapeDecoration(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             shadows: [
//               BoxShadow(
//                 color: Color(0xAA000000),
//                 blurRadius: 7.90,
//                 offset: Offset(0, 5),
//                 spreadRadius: 0,
//               )
//             ],
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 left: left,
//                 top: top,
//                 child: Container(
//                   width: width,
//                   height: height,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFFEEBD5C),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: left + 1,
//                 top: top + 1,
//                 child: Container(
//                   width: width - 2,
//                   height: height - 2,
//                   decoration: ShapeDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment(0.50, 0.82),
//                       end: Alignment(0.50, 1.11),
//                       colors: [const Color(0xFFF7D286), const Color(0xFF664C18)],
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: left + 1,
//                 top: top + 1,
//                 child: Container(
//                   width: width - 2,
//                   height: height - 2,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: ShapeDecoration(
//                     color: Colors.white.withValues(alpha: 0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         left: left + 1,
//                         top: top + 1,
//                         child: Container(
//                           width: width - 4,
//                           height: height - 4,
//                           decoration: ShapeDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment(0.50, -0.00),
//                               end: Alignment(0.50, 0.13),
//                               colors: [const Color(0xFFFFF1D5), const Color(0xFFF7D286)],
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(11),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: left + 1,
//                         top: top + 4,
//                         child: Container(
//                           width: width - 6,
//                           height: height - 6,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFF7D286),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(11),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: left + 51,
//                         top: top + 47,
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: Text(
//                             points.toString(),
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: const Color(0xFF50271A),
//                               fontSize: 32,
//                               fontFamily: 'Jomhuria',
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: left + 1,
//                         top: top - 3,
//                         child: SizedBox(
//                           width: width - 6,
//                           height: height - 6,
//                           child: Text(
//                             letter,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: const Color(0xFF50271A),
//                               fontSize: 64,
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
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';

class TileUI extends StatelessWidget {
  const TileUI({Key? key, required this.width, required this.height, required this.letter, required this.points,required this.top,required this.left}) : super(key: key);
  final double width;
  final double height;
  final String letter;
  final int points;
  final double top;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Base tile background
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFEEBD5C),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Gradient overlay
          Container(
            width: width,
            height: height,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF7D286),
                  Color(0xFF664C18),
                ],
                stops: [0.8, 1.0],
              ),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          
          // Top highlight
          Container(
            width: width,
            height: height * 0.3,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF1D5),
                  Color(0xFFF7D286),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
          ),
          
          // Main face
          Container(
            width: width,
            height: height,
            margin: const EdgeInsets.fromLTRB(1, 3, 1, 1),
            decoration: BoxDecoration(
              color: const Color(0xFFF7D286),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          
          // Letter
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                letter,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF50271A),
                  fontSize: width * 0.5, // Responsive font size
                  fontFamily: 'Jomhuria',
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
          ),
          
          // Points (bottom right)
          if (points > 0)
            Positioned(
              right: width * 0.1,
              bottom: width * 0.05,
              child: Text(
                points.toString(),
                style: TextStyle(
                  color: const Color(0xFF50271A),
                  fontSize: width * 0.2, // Responsive font size
                  fontFamily: 'Jomhuria',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
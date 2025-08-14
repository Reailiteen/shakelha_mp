// import 'package:flutter/material.dart';

// class Topbar extends StatelessWidget {
//   const Topbar({Key? key, required this.currentText}) : super(key: key);
//   final String currentText;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 666,
//           height: 158,
//           clipBehavior: Clip.antiAlias,
//           decoration: ShapeDecoration(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//             shadows: [
//               BoxShadow(
//                 color: Color(0x7F000000),
//                 blurRadius: 5,
//                 offset: Offset(0, 14),
//                 spreadRadius: 0,
//               )
//             ],
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 left: 0,
//                 top: -135,
//                 child: Container(
//                   width: 674,
//                   height: 393,
//                   decoration: ShapeDecoration(
//                     image: DecorationImage(
//                       image: NetworkImage("https://placehold.co/674x393"),
//                       fit: BoxFit.cover,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 0,
//                 top: 0,
//                 child: Container(
//                   width: 666,
//                   height: 158,
//                   decoration: ShapeDecoration(
//                     shape: RoundedRectangleBorder(
//                       side: BorderSide(
//                         width: 5,
//                         color: const Color(0xFFB16F15),
//                       ),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 122,
//                 top: 18,
//                 child: Container(
//                   width: 422,
//                   height: 125,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFF6E2B0F),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(19),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 14,
//                 top: 46,
//                 child: Container(
//                   width: 80,
//                   height: 72,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: BoxDecoration(),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         left: 0,
//                         top: 0,
//                         child: Container(
//                           width: 80,
//                           height: 17,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFFAE3C5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             shadows: [
//                               BoxShadow(
//                                 color: Color(0x63000000),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 3),
//                                 spreadRadius: 0,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 0,
//                         top: 25,
//                         child: Container(
//                           width: 80,
//                           height: 17,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFFAE3C5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             shadows: [
//                               BoxShadow(
//                                 color: Color(0x63000000),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 3),
//                                 spreadRadius: 0,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 0,
//                         top: 50,
//                         child: Container(
//                           width: 80,
//                           height: 17,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFFAE3C5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             shadows: [
//                               BoxShadow(
//                                 color: Color(0x63000000),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 3),
//                                 spreadRadius: 0,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 139,
//                 top: 43,
//                 child: SizedBox(
//                   width: 388,
//                   height: 72,
//                   child: Text(
//                     currentText,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 96,
//                       fontFamily: 'Jomhuria',
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 559,
//                 top: 43,
//                 child: Container(
//                   width: 81,
//                   height: 70,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: BoxDecoration(),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         left: 61.63,
//                         top: 2,
//                         child: Container(
//                           transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.79),
//                           width: 27.45,
//                           height: 32,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFFAE3C5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 39,
//                         top: 47.41,
//                         child: Container(
//                           transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
//                           width: 27.45,
//                           height: 32,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFFAE3C5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         left: 0,
//                         top: 27,
//                         child: Container(
//                           width: 78,
//                           height: 17,
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFFAE3C5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
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

class Topbar extends StatelessWidget {
  const Topbar({Key? key, required this.currentText}) : super(key: key);
  final String currentText;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: Container(
        width: screenWidth * 0.95,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6E2B0F),
              Color(0xFF512103),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFB16F15),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Menu button (left)
            Container(
              width: screenWidth * 0.15,
              height: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    Container(
                      width: double.infinity,
                      height: 3,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAE3C5),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Center text area
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    currentText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.055, // Responsive font size
                      fontFamily: 'Jomhuria',
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ),
            
            // Arrow button (right)
            Container(
              width: screenWidth * 0.15,
              height: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFFFAE3C5),
                  size: screenWidth * 0.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
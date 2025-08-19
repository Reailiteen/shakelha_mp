import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Topbar extends StatelessWidget {
  const Topbar({
    Key? key, 
    required this.currentText,
    this.actionButton,
    this.showMenuBars = true,
  }) : super(key: key);
  
  final String currentText;
  final Widget? actionButton;
  final bool showMenuBars;
  
  /// Returns true if the back button should be hidden
  bool _shouldHideBackButton(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == null) return false;
    
    // Hide back button for screens where going back leads to nowhere
    final noBackScreens = [
      '/home',           // HomeShell (main menu/shop)
      '/main-menu',      // MainMenuScreen
      '/splash',         // SplashScreen
    ];
    
    return noBackScreens.contains(currentRoute);
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hideBackButton = _shouldHideBackButton(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
      child: Container(
        width: screenWidth * 0.95,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage('lib/data/ui/topbar_bg.jpeg'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: const Color(0xFFB16F15).withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            // Menu button or action button (left)
            SizedBox(
              width: screenWidth * 0.15,
              height: double.infinity,
              child: showMenuBars
                ? LayoutBuilder(
                    builder: (context, c) {
                      final double h = c.maxHeight;
                      final double barThickness = h / 8; // 3 bars + spacing
                      final double spacing = h / 12;
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) => Container(
                            width: screenWidth * 0.1,
                            height: barThickness.clamp(2, 6),
                            margin: EdgeInsets.symmetric(vertical: spacing / 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAE3C5),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                                BoxShadow(
                                  color: const Color(0xFFFAE3C5).withOpacity(0.6),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          )),
                        ),
                      );
                    },
                  )
                : actionButton ?? const SizedBox.shrink(),
            ),
            
            // Center text area
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final maxH = c.maxHeight;
                  final fontSize = (screenWidth * 0.07).clamp(10.0, maxH * 0.85);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Center(
                      child: Container(
                        height: maxH * 0.92,
                        width: screenWidth * 0.7,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                          color: const Color(0xFF512103).withOpacity(0.9),
                          border: Border.all(
                            color: const Color(0xFFB16F15),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jomhuria(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: fontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Arrow button (right) - conditionally shown
            if (!hideBackButton)
              SizedBox(
                width: screenWidth * 0.15,
                height: double.infinity,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFAE3C5).withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 0.2,
                        ),
                      ],
                    ),
                    child: FittedBox(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Color(0xFFFAE3C5)),
                        onPressed: () => Navigator.pop(context),
                        iconSize: 65,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Empty space when back button is hidden to maintain layout
            if (hideBackButton)
              SizedBox(width: screenWidth * 0.15),
          ],
        ),
      ),
    );
  }
}
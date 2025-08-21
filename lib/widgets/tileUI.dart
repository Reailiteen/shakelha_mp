import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shakelha_mp/provider/tile_theme_provider.dart';

class TileUI extends StatelessWidget {
  const TileUI({
    Key? key, 
    required this.width, 
    required this.height, 
    required this.letter, 
    required this.points,
    required this.top,
    required this.left,
    this.tileColors, // Optional: if not provided, will use provider's current theme
  }) : super(key: key);
  
  final double width;
  final double height;
  final String letter;
  final int points;
  final double top;
  final double left;
  final TileColors? tileColors; // Made optional

  @override
  Widget build(BuildContext context) {
    // Get colors from provider if no specific theme is provided
    final colors = tileColors != null 
        ? context.read<TileThemeProvider>().getColorsForTheme(tileColors!)
        : context.watch<TileThemeProvider>().getCurrentColors();
    
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
              color: colors['base'],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Gradient overlay
          Container(
            width: width,
            height: height,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors['gradientStart']!,
                  colors['gradientEnd']!,
                ],
                stops: const [0.8, 1.0],
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors['highlightStart']!,
                  colors['highlightEnd']!,
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
              color: colors['mainFace'],
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          
          // Letter (center)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                letter,
                textAlign: TextAlign.center,
                style: GoogleFonts.jomhuria(
                  textStyle: TextStyle(
                    color: colors['text'],
                    fontSize: width * 0.7, // Slightly bigger
                    fontWeight: FontWeight.w800, // thicker font
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),

          // Points (always visible, bottom right)
          Positioned(
            right: width * 0.07,
            bottom: width * 0.03,
            child: Text(
              points.toString(),
              style: GoogleFonts.jomhuria(
                textStyle: TextStyle(
                  color: colors['text'],
                  fontSize: width * 0.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class TileColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color pointsColor;

  const TileColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.pointsColor,
  });

  static const classic = TileColors(
    backgroundColor: Color(0xFFF6E5D1),
    borderColor: Color(0xFFAB8756),
    textColor: Color(0xFF4A4A4A),
    pointsColor: Color(0xFF7C5C3B),
  );
}

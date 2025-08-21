import 'package:flutter/material.dart';

/// Provider class to manage tile themes across the app
/// Allows dynamic switching between different tile color schemes
class TileThemeProvider extends ChangeNotifier {
  TileColors _currentTheme = TileColors.wooden;
  
  // Getter for current theme
  TileColors get currentTheme => _currentTheme;
  
  // Setter for current theme
  set currentTheme(TileColors theme) {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();
    }
  }
  
  // Get colors based on current theme
  Map<String, Color> getCurrentColors() {
    return _getColorsForTheme(_currentTheme);
  }
  
  // Get colors for a specific theme
  Map<String, Color> getColorsForTheme(TileColors theme) {
    return _getColorsForTheme(theme);
  }
  
  // Private method to get colors for a specific theme
  Map<String, Color> _getColorsForTheme(TileColors theme) {
    switch (theme) {
      case TileColors.wooden:
        return {
          'base': const Color(0xFFEEBD5C),
          'gradientStart': const Color(0xFFF7D286),
          'gradientEnd': const Color(0xFF664C18),
          'highlightStart': const Color(0xFFFFF1D5),
          'highlightEnd': const Color(0xFFF7D286),
          'mainFace': const Color(0xFFF7D286),
          'text': const Color(0xFF50271A),
        };
      case TileColors.classic:
        return {
          'base': const Color(0xFFE6D7C3),
          'gradientStart': const Color(0xFFF0E6D2),
          'gradientEnd': const Color(0xFFD4C4A8),
          'highlightStart': const Color(0xFFFFF8E1),
          'highlightEnd': const Color(0xFFE6D7C3),
          'mainFace': const Color(0xFFE6D7C3),
          'text': const Color(0xFF8D6E63),
        };
      case TileColors.modern:
        return {
          'base': const Color(0xFF64B5F6),
          'gradientStart': const Color(0xFF81C784),
          'gradientEnd': const Color(0xFF4FC3F7),
          'highlightStart': const Color(0xFFE3F2FD),
          'highlightEnd': const Color(0xFF81C784),
          'mainFace': const Color(0xFF81C784),
          'text': const Color(0xFF1565C0),
        };
      case TileColors.dark:
        return {
          'base': const Color(0xFF424242),
          'gradientStart': const Color(0xFF616161),
          'gradientEnd': const Color(0xFF212121),
          'highlightStart': const Color(0xFF757575),
          'highlightEnd': const Color(0xFF616161),
          'mainFace': const Color(0xFF616161),
          'text': const Color(0xFFE0E0E0),
        };
      case TileColors.colorful:
        return {
          'base': const Color(0xFFFF9800),
          'gradientStart': const Color(0xFFFF5722),
          'gradientEnd': const Color(0xFFE91E63),
          'highlightStart': const Color(0xFFFFEB3B),
          'highlightEnd': const Color(0xFFFF9800),
          'mainFace': const Color(0xFFFF9800),
          'text': const Color(0xFFD32F2F),
        };
    }
  }
  
  // Get available themes
  List<TileColors> get availableThemes => TileColors.values;
  
  // Get theme name for display
  String getThemeName(TileColors theme) {
    switch (theme) {
      case TileColors.wooden:
        return 'Wooden';
      case TileColors.classic:
        return 'Classic';
      case TileColors.modern:
        return 'Modern';
      case TileColors.dark:
        return 'Dark';
      case TileColors.colorful:
        return 'Colorful';
    }
  }
  
  // Get theme description
  String getThemeDescription(TileColors theme) {
    switch (theme) {
      case TileColors.wooden:
        return 'Traditional wooden Scrabble tiles';
      case TileColors.classic:
        return 'Classic beige Scrabble colors';
      case TileColors.modern:
        return 'Modern flat design with blue-green';
      case TileColors.dark:
        return 'Dark theme for low-light environments';
      case TileColors.colorful:
        return 'Bright and vibrant colors';
    }
  }
}

// Enum for different tile color themes
enum TileColors {
  wooden,    // Original wooden theme
  classic,   // Classic Scrabble colors
  modern,    // Modern flat design
  dark,      // Dark theme
  colorful   // Bright colorful theme
}

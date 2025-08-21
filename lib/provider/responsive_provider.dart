import 'package:flutter/material.dart';

/// Provider class to manage responsive design across the app
/// Calculates content width and height based on device type and screen size
class ResponsiveProvider extends ChangeNotifier {
  double _contentWidth = 1200;  
  double _contentHeight = 800;
  double _scale = 1.0;
  double _horizontalPadding = 0;
  double _verticalPadding = 0;
  Size _screenSize = const Size(0, 0);

  // Getters for content dimensions
  double get contentWidth => _contentWidth;
  double get contentHeight => _contentHeight;
  double get scale => _scale;
  double get horizontalPadding => _horizontalPadding;
  double get verticalPadding => _verticalPadding;
  Size get screenSize => _screenSize;

  /// Update responsive values based on screen constraints
  void updateConstraints(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    _screenSize = Size(screenWidth, screenHeight);

    // Define base sizes per device group
    double baseWidth;
    double baseHeight;

    final ratio = screenWidth / screenHeight;

    if (ratio > 0.48 && ratio <= 0.62) {
      // 9:16 phones
      baseWidth = 560;
      baseHeight = 992; // maintain 9:16 ratio
    } else if (ratio >= 0.41 && ratio <= 0.48) {
      // 9:19 new gen phones
      baseWidth = 560;
      baseHeight = 1180; // maintain 9:19 ratio
    } else if (ratio >= 0.7 && ratio <= 0.75) {
      // 3:4 tablets / iPads
      baseWidth = 900;
      baseHeight = 1200; // maintain 3:4 ratio
    } else if (ratio >= 1.4 && ratio <= 1.8) {
      // 3:2 laptops / ultrabooks
      baseWidth = 1400; // Increased from 1200
      baseHeight = 900;  // Increased from 800
    } else if (ratio >= 1.8) {
      // Wide desktop screens
      baseWidth = 1600; // New category for wide screens
      baseHeight = 900;
    } else {
      // Fallback - use larger default for desktop
      baseWidth = 1400; // Increased from 1000
      baseHeight = 900;  // Increased from 1000
    }

    // Calculate scale to fit screen, but don't scale down too much on large screens
    final scaleX = screenWidth / baseWidth;
    final scaleY = screenHeight / baseHeight;
    
    // For desktop, use a minimum scale to prevent everything from being too small
    if (screenWidth > 1200) {
      _scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.8, 1.5);
    } else {
      _scale = scaleX < scaleY ? scaleX : scaleY;
    }

    _contentWidth = baseWidth * _scale;
    _contentHeight = baseHeight * _scale;

    // Calculate padding to center content
    _horizontalPadding = (screenWidth - _contentWidth) / 2;
    _verticalPadding = (screenHeight - _contentHeight) / 2;

    notifyListeners();
  }

  /// Get responsive value based on scale
  double responsiveValue(double baseValue) {
    return baseValue * _scale;
  }

  /// Get responsive font size
  double responsiveFontSize(double baseFontSize) {
    return baseFontSize * _scale;
  }

  /// Check if device is phone
  bool get isPhone => _screenSize.width < 600;

  /// Check if device is tablet
  bool get isTablet => _screenSize.width >= 600 && _screenSize.width < 1200;

  /// Check if device is desktop
  bool get isDesktop => _screenSize.width >= 1200;

  /// Get responsive width percentage
  double getWidthPercent(double percent) {
    return _contentWidth * (percent / 100);
  }

  /// Get responsive height percentage
  double getHeightPercent(double percent) {
    return _contentHeight * (percent / 100);
  }
}
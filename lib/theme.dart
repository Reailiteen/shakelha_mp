import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Single mid-tone theme for the game's Arabic/Gulf aesthetic (no light/dark split)
// Balanced contrast, ornate gold accents, turquoise highlights, deep blue surfaces.

class AppColors {
  // Brand
  static const primary = Color(0xFF19B6A6); // Sea turquoise
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFFFFD54F); // Ornate gold
  static const onSecondary = Color(0xFF1A1A1A);
  static const tertiary = Color(0xFF8D6E63); // Majlis brown
  static const onTertiary = Colors.white;

  // Surfaces
  static const background = Color(0xFF0E2235); // Deep night-blue
  static const surface = Color(0xFF12283A); // Panel
  static const onSurface = Color(0xFFF2F4F7);

  // Decorative
  static const ornateGold = Color(0xFFFFD54F);
  static const desertSand = Color(0xFFE7D8C5);
  static const pearl = Color(0xFFF7F7F7);

  // Status
  static const error = Color(0xFFD32F2F);
  static const onError = Colors.white;
}

class FontSizes {
  static const double displayLarge = 40;
  static const double displayMedium = 34;
  static const double displaySmall = 28;
  static const double headlineLarge = 24;
  static const double headlineMedium = 20;
  static const double headlineSmall = 18;
  static const double titleLarge = 18;
  static const double titleMedium = 16;
  static const double titleSmall = 14;
  static const double labelLarge = 14;
  static const double labelMedium = 12;
  static const double labelSmall = 11;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark, // mid-tone leaning dark for contrast
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    error: AppColors.error,
    onError: AppColors.onError,
    background: AppColors.background,
    onBackground: AppColors.onSurface,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    centerTitle: true,
  ),
  cardColor: AppColors.surface,
  dialogBackgroundColor: AppColors.surface,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: FontSizes.displayLarge, fontWeight: FontWeight.w800, color: AppColors.onSurface),
    displayMedium: TextStyle(fontSize: FontSizes.displayMedium, fontWeight: FontWeight.w700, color: AppColors.onSurface),
    displaySmall: TextStyle(fontSize: FontSizes.displaySmall, fontWeight: FontWeight.w700, color: AppColors.onSurface),
    headlineLarge: TextStyle(fontSize: FontSizes.headlineLarge, fontWeight: FontWeight.w700, color: AppColors.onSurface),
    headlineMedium: TextStyle(fontSize: FontSizes.headlineMedium, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    headlineSmall: TextStyle(fontSize: FontSizes.headlineSmall, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    titleLarge: TextStyle(fontSize: FontSizes.titleLarge, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    titleMedium: TextStyle(fontSize: FontSizes.titleMedium, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    titleSmall: TextStyle(fontSize: FontSizes.titleSmall, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    bodyLarge: TextStyle(fontSize: FontSizes.bodyLarge, color: AppColors.onSurface),
    bodyMedium: TextStyle(fontSize: FontSizes.bodyMedium, color: AppColors.onSurface),
    bodySmall: TextStyle(fontSize: FontSizes.bodySmall, color: AppColors.onSurface),
    labelLarge: TextStyle(fontSize: FontSizes.labelLarge, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    labelMedium: TextStyle(fontSize: FontSizes.labelMedium, color: AppColors.onSurface),
    labelSmall: TextStyle(fontSize: FontSizes.labelSmall, color: AppColors.onSurface),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  dividerColor: Colors.white12,
);

// Compatibility aliases to avoid breaking existing references to LightModeColors
class LightModeColors {
  static const lightPrimary = AppColors.primary;
  static const lightOnPrimary = AppColors.onPrimary;
  static const lightPrimaryContainer = AppColors.surface;
  static const lightOnPrimaryContainer = AppColors.onSurface;
  static const lightSecondary = AppColors.secondary;
  static const lightOnSecondary = AppColors.onSecondary;
  static const lightTertiary = AppColors.tertiary;
  static const lightOnTertiary = AppColors.onTertiary;
  static const lightError = AppColors.error;
  static const lightOnError = AppColors.onError;
  static const lightInversePrimary = AppColors.secondary;
  static const lightShadow = Colors.black;
  static const lightSurface = AppColors.surface;
  static const lightOnSurface = AppColors.onSurface;
  static const lightAppBarBackground = AppColors.surface;
  static const lightAccent = AppColors.secondary;
  static const lightBackground = AppColors.background;
  static const ornateGold = AppColors.ornateGold;
  static const desertSand = AppColors.desertSand;
  static const pearl = AppColors.pearl;
}

// A single mid-tone theme suited for the game's Gulf/Arabic aesthetic.
// No separate light/dark variants; balanced colors with good contrast.
const double displayLarge = 40;
const double displayMedium = 34;
const double displaySmall = 28;
const double headlineLarge = 24;
const double headlineMedium = 20;
const double headlineSmall = 18;
const double titleLarge = 18;
const double titleMedium = 16;
const double titleSmall = 14;
const double labelLarge = 14;
const double labelMedium = 12;
const double labelSmall = 11;
const double bodyLarge = 16;
const double bodyMedium = 14;
const double bodySmall = 12;
const Color lightOnPrimaryContainer = AppColors.onSurface;
const Color lightSecondary = AppColors.secondary;
const Color lightOnSecondary = AppColors.onSecondary;
const Color lightTertiary = AppColors.tertiary;
const Color lightOnTertiary = AppColors.onTertiary;
const Color lightError = AppColors.error;
const Color lightOnError = AppColors.onError;
const Color lightInversePrimary = AppColors.secondary;
const Color lightShadow = Colors.black;
const Color lightSurface = AppColors.surface;
const Color lightOnSurface = AppColors.onSurface;
const Color lightAppBarBackground = AppColors.surface;
const Color lightAccent = AppColors.secondary;
const Color lightBackground = AppColors.background;

// Extended names used in UI
const Color ornateGold = AppColors.ornateGold;
const Color majlisBrown = AppColors.tertiary;
const Color seaTurquoise = AppColors.primary;
const Color desertSand = AppColors.secondary;

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.surface,
    onPrimaryContainer: AppColors.onSurface,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    error: AppColors.error,
    onError: AppColors.onError,
    inversePrimary: LightModeColors.lightInversePrimary,
    shadow: LightModeColors.lightShadow,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
  ),
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: LightModeColors.lightAppBarBackground,
    foregroundColor: LightModeColors.lightOnPrimaryContainer,
    elevation: 0,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.surface,
    onPrimaryContainer: AppColors.onSurface,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.error,
    onErrorContainer: AppColors.onError,
    inversePrimary: AppColors.secondary,
    shadow: Colors.black,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  ),
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  ),
);

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light, vibrant theme with beige, light blue palette
// Dark blue as secondary color, maintaining vibrant feel

class AppColors {
  // === PRIMARY COLORS ===
  static const Color primary = Color(0xFF87CEEB); // Sky blue (light blue)
  static const Color onPrimary = Color(0xFF1E3A8A); // Dark blue text on primary
  static const Color primaryLight = Color(0xFFB0E0E6); // Powder blue
  static const Color primaryDark = Color(0xFF4682B4); // Steel blue
  static const Color primaryContainer = Color(0xFFE0F6FF); // Very light blue container
  static const Color onPrimaryContainer = Color(0xFF003354); // Dark blue on container
  
  // === SECONDARY COLORS ===
  static const Color secondary = Color(0xFF1E3A8A); // Dark blue (as requested)
  static const Color onSecondary = Color(0xFFFFFFFF); // White text on secondary
  static const Color secondaryLight = Color(0xFF3B82F6); // Bright blue
  static const Color secondaryDark = Color(0xFF1E40AF); // Deeper blue
  static const Color secondaryContainer = Color(0xFFDBE7FF); // Light blue container
  static const Color onSecondaryContainer = Color(0xFF001A41); // Very dark blue on container
  
  // === TERTIARY COLORS ===
  static const Color tertiary = Color(0xFFF5DEB3); // Beige (wheat)
  static const Color onTertiary = Color(0xFF2C1810); // Dark brown text on tertiary
  static const Color tertiaryLight = Color(0xFFFFF8DC); // Cornsilk (light beige)
  static const Color tertiaryDark = Color(0xFFD2B48C); // Tan (darker beige)
  static const Color tertiaryContainer = Color(0xFFFFEFD5); // Very light beige container
  static const Color onTertiaryContainer = Color(0xFF3E2723); // Dark brown on container
  
  // === BACKGROUND COLORS ===
  static const Color background = Color(0xFFFFFDF5); // Ivory white (main background)
  static const Color onBackground = Color(0xFF1A1B1E); // Dark text on background
  static const Color backgroundExtra = Color(0xFFF5F5DC); // Beige for extra space
  static const Color backgroundSecondary = Color(0xFFEEF7FF); // Very light blue background
  static const Color backgroundTertiary = Color(0xFFFAF8F5); // Warm off-white
  
  // === SURFACE COLORS ===
  static const Color surface = Color(0xFFFFFFFF); // Pure white surface
  static const Color onSurface = Color(0xFF1A1B1E); // Dark text on surface
  static const Color surfaceVariant = Color(0xFFF7F7F7); // Light gray surface
  static const Color onSurfaceVariant = Color(0xFF424242); // Medium dark text
  static const Color surfaceTint = Color(0xFF87CEEB); // Sky blue tint
  static const Color inverseSurface = Color(0xFF2F3136); // Dark surface for contrast
  static const Color inverseOnSurface = Color(0xFFE3E3E3); // Light text on dark surface
  
  // === OUTLINE COLORS ===
  static const Color outline = Color(0xFFBDBDBD); // Light gray outline
  static const Color outlineVariant = Color(0xFFE0E0E0); // Lighter outline
  static const Color outlinePrimary = Color(0xFF87CEEB); // Sky blue outline
  static const Color outlineSecondary = Color(0xFF1E3A8A); // Dark blue outline
  
  // === ACCENT COLORS ===
  static const Color accent = Color(0xFFFFD700); // Gold accent
  static const Color accentLight = Color(0xFFFFF59D); // Light gold
  static const Color accentDark = Color(0xFFFFA000); // Orange gold
  static const Color accentComplementary = Color(0xFFFF6B6B); // Coral pink
  
  // === SUCCESS COLORS ===
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color onSuccess = Color(0xFFFFFFFF); // White text on success
  static const Color successLight = Color(0xFF81C784); // Light green
  static const Color successDark = Color(0xFF388E3C); // Dark green
  static const Color successContainer = Color(0xFFE8F5E8); // Very light green
  
  // === WARNING COLORS ===
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color onWarning = Color(0xFFFFFFFF); // White text on warning
  static const Color warningLight = Color(0xFFFFB74D); // Light orange
  static const Color warningDark = Color(0xFFF57C00); // Dark orange
  static const Color warningContainer = Color(0xFFFFF3E0); // Very light orange
  
  // === ERROR COLORS ===
  static const Color error = Color(0xFFF44336); // Red
  static const Color onError = Color(0xFFFFFFFF); // White text on error
  static const Color errorLight = Color(0xFFEF5350); // Light red
  static const Color errorDark = Color(0xFFD32F2F); // Dark red
  static const Color errorContainer = Color(0xFFFFEBEE); // Very light red
  
  // === SHADOW COLORS ===
  static const Color shadow = Color(0xFF000000); // Black shadow
  static const Color shadowLight = Color(0x1F000000); // Light shadow (12% opacity)
  static const Color shadowMedium = Color(0x3D000000); // Medium shadow (24% opacity)
  static const Color shadowDark = Color(0x5C000000); // Dark shadow (36% opacity)
  static const Color shadowPrimary = Color(0x3D87CEEB); // Sky blue shadow
  
  // === GAME SPECIFIC COLORS ===
  static const Color gameBoard = Color(0xFFFFF8DC); // Cornsilk for game board
  static const Color gameBoardAccent = Color(0xFFD2B48C); // Tan accent
  static const Color gameTile = Color(0xFFFFFFFF); // White tiles
  static const Color gameTileSelected = Color(0xFFB0E0E6); // Light blue for selected
  static const Color gameText = Color(0xFF1A1B1E); // Dark text on game elements
  static const Color gameScore = Color(0xFF1E3A8A); // Dark blue for scores
  
  // === BUTTON COLORS ===
  static const Color buttonPrimary = Color(0xFF87CEEB); // Sky blue button
  static const Color buttonSecondary = Color(0xFF1E3A8A); // Dark blue button
  static const Color buttonTertiary = Color(0xFFF5DEB3); // Beige button
  static const Color buttonDisabled = Color(0xFFE0E0E0); // Light gray disabled
  static const Color buttonHover = Color(0xFFB0E0E6); // Light blue hover
  
  // === TEXT COLORS ===
  static const Color textPrimary = Color(0xFF1A1B1E); // Main dark text
  static const Color textSecondary = Color(0xFF424242); // Secondary text
  static const Color textTertiary = Color(0xFF757575); // Tertiary text
  static const Color textLight = Color(0xFFFFFFFF); // White text
  static const Color textAccent = Color(0xFF1E3A8A); // Dark blue accent text
  
  // === SPECIAL COLORS ===
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color cream = Color(0xFFFFFDD0); // Cream color
  static const Color pearl = Color(0xFFEAE0C8); // Pearl beige
  static const Color champagne = Color(0xFFFAD5A5); // Light champagne
}

// === FONT SIZES ===
class AppFontSizes {
  // Display sizes
  static const double displayLarge = 44.0;
  static const double displayMedium = 38.0;
  static const double displaySmall = 32.0;
  
  // Headline sizes
  static const double headlineLarge = 28.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 20.0;
  
  // Title sizes
  static const double titleLarge = 20.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  
  // Body sizes
  static const double bodyLarge = 18.0;
  static const double bodyMedium = 16.0;
  static const double bodySmall = 14.0;
  
  // Label sizes
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  
  // Game specific sizes
  static const double gameTitle = 32.0;
  static const double gameScore = 24.0;
  static const double gameTile = 16.0;
  static const double gameHint = 12.0;
}

// === SPACING ===
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// === BORDER RADIUS ===
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 100.0;
}

// === MAIN THEME DATA ===
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: GoogleFonts.poppins().fontFamily, // Modern, clean font
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.textPrimary,
    background: AppColors.background,
    onBackground: AppColors.onBackground,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    shadow: AppColors.shadow,
    surfaceTint: AppColors.surfaceTint,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: AppFontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
  cardColor: AppColors.surface,
  dialogBackgroundColor: AppColors.surface,
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: AppColors.onSurface,
    displayColor: AppColors.onSurface,
  ).copyWith(
    displayLarge: GoogleFonts.poppins(
      fontSize: AppFontSizes.displayLarge,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: AppFontSizes.displayMedium,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: AppFontSizes.displaySmall,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: AppFontSizes.headlineLarge,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: AppFontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: AppFontSizes.headlineSmall,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: AppFontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: AppFontSizes.titleMedium,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: AppFontSizes.titleSmall,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: AppFontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: AppFontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: AppFontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: AppFontSizes.labelLarge,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: AppFontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: AppFontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonPrimary,
      foregroundColor: AppColors.onPrimary,
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: GoogleFonts.poppins(
        fontSize: AppFontSizes.labelLarge,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.secondary,
      side: const BorderSide(color: AppColors.outlineSecondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: GoogleFonts.poppins(
        fontSize: AppFontSizes.labelLarge,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.secondary,
      textStyle: GoogleFonts.poppins(
        fontSize: AppFontSizes.labelLarge,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    hintStyle: GoogleFonts.poppins(
      color: AppColors.textTertiary,
      fontSize: AppFontSizes.bodyMedium,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 2,
    shadowColor: AppColors.shadowLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  ),
  dividerColor: AppColors.outlineVariant,
  dividerTheme: const DividerThemeData(
    color: AppColors.outlineVariant,
    thickness: 1,
  ),
);

// === LEGACY COMPATIBILITY ===
// Keeping some old references to avoid breaking existing code
class LightModeColors {
  static const lightPrimary = AppColors.primary;
  static const lightOnPrimary = AppColors.onPrimary;
  static const lightPrimaryContainer = AppColors.primaryContainer;
  static const lightOnPrimaryContainer = AppColors.onPrimaryContainer;
  static const lightSecondary = AppColors.secondary;
  static const lightOnSecondary = AppColors.onSecondary;
  static const lightTertiary = AppColors.tertiary;
  static const lightOnTertiary = AppColors.onTertiary;
  static const lightError = AppColors.error;
  static const lightOnError = AppColors.onError;
  static const lightInversePrimary = AppColors.secondary;
  static const lightShadow = AppColors.shadow;
  static const lightSurface = AppColors.surface;
  static const lightOnSurface = AppColors.onSurface;
  static const lightAppBarBackground = AppColors.surface;
  static const lightAccent = AppColors.accent;
  static const lightBackground = AppColors.background;
  static const ornateGold = AppColors.accent;
  static const desertSand = AppColors.tertiary;
  static const pearl = AppColors.pearl;
}

// Font size constants for backward compatibility
const double displayLarge = AppFontSizes.displayLarge;
const double displayMedium = AppFontSizes.displayMedium;
const double displaySmall = AppFontSizes.displaySmall;
const double headlineLarge = AppFontSizes.headlineLarge;
const double headlineMedium = AppFontSizes.headlineMedium;
const double headlineSmall = AppFontSizes.headlineSmall;
const double titleLarge = AppFontSizes.titleLarge;
const double titleMedium = AppFontSizes.titleMedium;
const double titleSmall = AppFontSizes.titleSmall;
const double labelLarge = AppFontSizes.labelLarge;
const double labelMedium = AppFontSizes.labelMedium;
const double labelSmall = AppFontSizes.labelSmall;
const double bodyLarge = AppFontSizes.bodyLarge;
const double bodyMedium = AppFontSizes.bodyMedium;
const double bodySmall = AppFontSizes.bodySmall;

// Color constants for backward compatibility
const Color lightOnPrimaryContainer = AppColors.onPrimaryContainer;
const Color lightSecondary = AppColors.secondary;
const Color lightOnSecondary = AppColors.onSecondary;
const Color lightTertiary = AppColors.tertiary;
const Color lightOnTertiary = AppColors.onTertiary;
const Color lightError = AppColors.error;
const Color lightOnError = AppColors.onError;
const Color lightInversePrimary = AppColors.secondary;
const Color lightShadow = AppColors.shadow;
const Color lightSurface = AppColors.surface;
const Color lightOnSurface = AppColors.onSurface;
const Color lightAppBarBackground = AppColors.surface;
const Color lightAccent = AppColors.accent;
const Color lightBackground = AppColors.background;
const Color ornateGold = AppColors.accent;
const Color majlisBrown = AppColors.tertiaryDark;
const Color seaTurquoise = AppColors.primary;
const Color desertSand = AppColors.tertiary;

String mainFontFamily = GoogleFonts.poppins().fontFamily!;
// Theme getters
ThemeData get lightTheme => appTheme;
ThemeData get darkTheme => appTheme; // Using same light theme for now
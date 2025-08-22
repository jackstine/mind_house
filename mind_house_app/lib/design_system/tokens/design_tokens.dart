// Design Token System for Mind House App
// Material Design 3 compliant design tokens for information management

import 'package:flutter/material.dart';

/// Comprehensive design token system providing consistent styling
/// across the Mind House application
class MindHouseDesignTokens {
  MindHouseDesignTokens._();

  // ==========================================================================
  // COLOR SYSTEM
  // ==========================================================================

  /// Primary color palette for brand identity and key actions
  static const ColorScheme lightColorScheme = ColorScheme.light(
    // Brand colors
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF21005D),

    // Secondary colors for complementary elements
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1D192B),

    // Tertiary colors for accent and highlighting
    tertiary: Color(0xFF7D5260),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF31111D),

    // Error colors for validation and warnings
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    // Surface colors for backgrounds and containers
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F2FA),
    surfaceContainer: Color(0xFFF3EDF7),
    surfaceContainerHigh: Color(0xFFECE6F0),
    surfaceContainerHighest: Color(0xFFE6E0E9),

    // Outline colors for borders and dividers
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    // Brand colors
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFEADDFF),

    // Secondary colors
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF8),

    // Tertiary colors
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
    tertiaryContainer: Color(0xFF633B48),
    onTertiaryContainer: Color(0xFFFFD8E4),

    // Error colors
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),

    // Surface colors
    surface: Color(0xFF10080C),
    onSurface: Color(0xFFE6E0E9),
    surfaceContainerLowest: Color(0xFF0B0307),
    surfaceContainerLow: Color(0xFF1D1B20),
    surfaceContainer: Color(0xFF211F26),
    surfaceContainerHigh: Color(0xFF2B2930),
    surfaceContainerHighest: Color(0xFF36343B),

    // Outline colors
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
  );

  /// Semantic color mappings for information management
  static const Color informationPrimary = Color(0xFF0066CC);
  static const Color informationSecondary = Color(0xFF4285F4);
  static const Color successColor = Color(0xFF0D7377);
  static const Color warningColor = Color(0xFFFF8C00);
  static const Color criticalColor = Color(0xFFDC3545);

  // ==========================================================================
  // TYPOGRAPHY SYSTEM
  // ==========================================================================

  /// Information hierarchy typography scale
  static const TextTheme textTheme = TextTheme(
    // Display styles for major headings and hero content
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),

    // Headline styles for section headers and important content
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
    ),

    // Title styles for card headers and prominent labels
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),

    // Label styles for buttons, tabs, and form elements
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),

    // Body styles for main content and descriptions
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
  );

  // ==========================================================================
  // SPACING SYSTEM
  // ==========================================================================

  /// Consistent spacing scale for layouts and components
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  static const double spaceXXXL = 64.0;

  /// Content spacing for information density
  static const double contentSpacingTight = 8.0;
  static const double contentSpacingNormal = 16.0;
  static const double contentSpacingLoose = 24.0;

  /// Component internal spacing
  static const EdgeInsets componentPaddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets componentPaddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets componentPaddingLarge = EdgeInsets.all(24.0);

  // ==========================================================================
  // COMPONENT SIZING
  // ==========================================================================

  /// Standard component heights
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;

  static const double inputHeightSmall = 36.0;
  static const double inputHeightMedium = 48.0;
  static const double inputHeightLarge = 56.0;

  static const double cardMinHeight = 80.0;
  static const double cardMaxHeight = 400.0;

  /// Icon sizes for different contexts
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // ==========================================================================
  // BORDER RADIUS SYSTEM
  // ==========================================================================

  /// Border radius values for consistent rounded corners
  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  /// Component-specific border radius
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(radiusLG),
  );
  static const BorderRadius inputBorderRadius = BorderRadius.all(
    Radius.circular(radiusMD),
  );
  static const BorderRadius buttonBorderRadius = BorderRadius.all(
    Radius.circular(radiusLG),
  );

  // ==========================================================================
  // ELEVATION SYSTEM
  // ==========================================================================

  /// Elevation levels for layering components
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 3.0;
  static const double elevation3 = 6.0;
  static const double elevation4 = 8.0;
  static const double elevation5 = 12.0;

  // ==========================================================================
  // ANIMATION SYSTEM
  // ==========================================================================

  /// Duration values for consistent animations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Easing curves for different animation types
  static const Curve easeStandard = Curves.easeInOut;
  static const Curve easeEmphasized = Curves.easeInOutCubic;
  static const Curve easeEnter = Curves.easeOut;
  static const Curve easeExit = Curves.easeIn;

  // ==========================================================================
  // ACCESSIBILITY
  // ==========================================================================

  /// Minimum touch target sizes for accessibility
  static const double minTouchTarget = 48.0;
  static const double minIconTouchTarget = 40.0;

  /// Semantic sizes for screen readers
  static const String semanticSmall = 'small';
  static const String semanticMedium = 'medium';
  static const String semanticLarge = 'large';

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Get appropriate text color based on background
  static Color getTextColor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  /// Get spacing value by name
  static double getSpacing(String size) {
    switch (size) {
      case 'xxs':
        return spaceXXS;
      case 'xs':
        return spaceXS;
      case 'sm':
        return spaceSM;
      case 'md':
        return spaceMD;
      case 'lg':
        return spaceLG;
      case 'xl':
        return spaceXL;
      case 'xxl':
        return spaceXXL;
      case 'xxxl':
        return spaceXXXL;
      default:
        return spaceMD;
    }
  }

  /// Get border radius by name
  static double getRadius(String size) {
    switch (size) {
      case 'xs':
        return radiusXS;
      case 'sm':
        return radiusSM;
      case 'md':
        return radiusMD;
      case 'lg':
        return radiusLG;
      case 'xl':
        return radiusXL;
      case 'xxl':
        return radiusXXL;
      default:
        return radiusMD;
    }
  }
}

/// Extension methods for easier token access
extension MindHouseThemeExtension on ThemeData {
  /// Quick access to design tokens
  static MindHouseDesignTokens get tokens => MindHouseDesignTokens();
}
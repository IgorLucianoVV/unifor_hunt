import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the treasure hunt gaming application.
class AppTheme {
  AppTheme._();

  // Gaming-focused color palette optimized for outdoor mobile usage
  static const Color primaryLight =
      Color(0xFF034AF6); // Deep purple for primary actions
  static const Color primaryVariantLight =
      Color.fromARGB(255, 71, 126, 255);// Lighter purple for secondary elements
  static const Color secondaryLight =
      Color(0xFF00B894); // Teal green for success states
  static const Color secondaryVariantLight =
      Color.fromARGB(255, 249, 181, 56); // Warm yellow for warnings
  static const Color backgroundLight =
      Color(0xFF1A1A2E); // Deep navy background
  static const Color surfaceLight = Color(0xFF16213E); // Elevated surface color
  static const Color errorLight = Color(0xFFE84393); // Vibrant pink for errors
  static const Color onPrimaryLight = Color(0xFFFFFFFF); // Pure white text
  static const Color onSecondaryLight = Color(0xFFFFFFFF); // Pure white text
  static const Color onBackgroundLight = Color(0xFFFFFFFF); // Pure white text
  static const Color onSurfaceLight = Color(0xFFFFFFFF); // Pure white text
  static const Color onErrorLight = Color(0xFFFFFFFF); // Pure white text

  // Dark theme uses same colors as this is primarily a dark gaming theme
  static const Color primaryDark = Color(0xFF034AF6);
  static const Color primaryVariantDark = Color.fromARGB(255, 71, 126, 255);
  static const Color secondaryDark = Color.fromARGB(255, 0, 206, 165);
  static const Color secondaryVariantDark = Color(0xFFFDCB6E);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color errorDark = Color(0xFFE84393);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFFFFFFFF);

  // Gaming-specific colors
  static const Color accentGlow =
      Color.fromARGB(255, 71, 126, 255); // Reserved for glow effects
  static const Color textSecondary =
      Color(0xFFB8BCC8); // Light gray for secondary text
  static const Color cardDark = Color(0xFF16213E); // Card background
  static const Color dialogDark = Color(0xFF16213E); // Dialog background

  // Shadow and divider colors optimized for dark theme
  static const Color shadowDark = Color(0x33000000); // 20% opacity black
  static const Color dividerDark = Color(0x33FFFFFF); // 20% opacity white

  // Text emphasis colors for gaming interface
  static const Color textHighEmphasis = Color(0xFFFFFFFF); // Pure white
  static const Color textMediumEmphasis = Color(0xFFB8BCC8); // Light gray
  static const Color textDisabled = Color(0x61FFFFFF); // 38% opacity white

  /// Light theme (primarily used for testing - app is designed for dark mode)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryVariantLight,
      onPrimaryContainer: onPrimaryLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryVariantLight,
      onSecondaryContainer: onSecondaryLight,
      tertiary: accentGlow,
      onTertiary: onPrimaryLight,
      tertiaryContainer: accentGlow.withValues(alpha: 0.2),
      onTertiaryContainer: onPrimaryLight,
      error: errorLight,
      onError: onErrorLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textSecondary,
      outline: dividerDark,
      outlineVariant: dividerDark.withValues(alpha: 0.5),
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: backgroundLight,
      onInverseSurface: onBackgroundLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardDark,
    dividerColor: dividerDark,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: onSurfaceLight,
      elevation: 4.0,
      shadowColor: shadowDark,
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurfaceLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textMediumEmphasis,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: onPrimaryLight,
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 4.0,
        shadowColor: shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryLight, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: dividerDark.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: dividerDark.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorLight, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorLight, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textMediumEmphasis,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabled,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return textMediumEmphasis;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight.withValues(alpha: 0.5);
        }
        return textDisabled;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(onPrimaryLight),
      side: const BorderSide(color: textMediumEmphasis, width: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return textMediumEmphasis;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: textDisabled,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      thumbColor: primaryLight,
      overlayColor: primaryLight.withValues(alpha: 0.2),
      inactiveTrackColor: textDisabled,
      trackHeight: 4.0,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textMediumEmphasis,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: shadowDark,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: GoogleFonts.inter(
        color: onSurfaceLight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceLight,
      contentTextStyle: GoogleFonts.inter(
        color: onSurfaceLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 6.0,
    ),
    dialogTheme: DialogThemeData(backgroundColor: dialogDark),
  );

  /// Dark theme (primary gaming theme)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryVariantDark,
      onPrimaryContainer: onPrimaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryVariantDark,
      onSecondaryContainer: onSecondaryDark,
      tertiary: accentGlow,
      onTertiary: onPrimaryDark,
      tertiaryContainer: accentGlow.withValues(alpha: 0.2),
      onTertiaryContainer: onPrimaryDark,
      error: errorDark,
      onError: onErrorDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: textSecondary,
      outline: dividerDark,
      outlineVariant: dividerDark.withValues(alpha: 0.5),
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: backgroundLight,
      onInverseSurface: onBackgroundLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    dividerColor: dividerDark,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: onSurfaceDark,
      elevation: 4.0,
      shadowColor: shadowDark,
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurfaceDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textMediumEmphasis,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: onPrimaryDark,
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryDark,
        backgroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 4.0,
        shadowColor: shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryDark, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: false),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceDark,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: dividerDark.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: dividerDark.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryDark, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorDark, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorDark, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textMediumEmphasis,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabled,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryDark;
        }
        return textMediumEmphasis;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryDark.withValues(alpha: 0.5);
        }
        return textDisabled;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(onPrimaryDark),
      side: const BorderSide(color: textMediumEmphasis, width: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryDark;
        }
        return textMediumEmphasis;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearTrackColor: textDisabled,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryDark,
      thumbColor: primaryDark,
      overlayColor: primaryDark.withValues(alpha: 0.2),
      inactiveTrackColor: textDisabled,
      trackHeight: 4.0,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: textMediumEmphasis,
      indicatorColor: primaryDark,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: shadowDark,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: GoogleFonts.inter(
        color: onSurfaceDark,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceDark,
      contentTextStyle: GoogleFonts.inter(
        color: onSurfaceDark,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 6.0,
    ),
    dialogTheme: DialogThemeData(backgroundColor: dialogDark),
  );

  /// Helper method to build text theme based on brightness
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHigh = isLight ? textHighEmphasis : textHighEmphasis;
    final Color textMedium = isLight ? textMediumEmphasis : textMediumEmphasis;
    final Color textLow = isLight ? textDisabled : textDisabled;

    return TextTheme(
      // Display styles using Orbitron for gaming aesthetic
      displayLarge: GoogleFonts.orbitron(
        fontSize: 57,
        fontWeight: FontWeight.w900,
        color: textHigh,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textHigh,
      ),
      displaySmall: GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textHigh,
      ),

      // Headline styles using Orbitron for gaming headers
      headlineLarge: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textHigh,
      ),
      headlineMedium: GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textHigh,
      ),
      headlineSmall: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: textHigh,
      ),

      // Title styles using Inter for readability
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textHigh,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHigh,
        letterSpacing: 0.1,
      ),

      // Body styles using Inter for extended reading
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHigh,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHigh,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMedium,
        letterSpacing: 0.4,
      ),

      // Label styles using Roboto for UI elements
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHigh,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMedium,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textLow,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Gaming-specific text styles for data display
  static TextStyle dataStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textHighEmphasis,
      letterSpacing: 0.5,
    );
  }

  /// Glow effect for gaming elements
  static BoxShadow glowEffect({
    Color? color,
    double blurRadius = 8.0,
    double spreadRadius = 0.0,
  }) {
    return BoxShadow(
      color: (color ?? accentGlow).withValues(alpha: 0.5),
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      offset: Offset.zero,
    );
  }

  /// Gaming button decoration with subtle glow
  static BoxDecoration gamingButtonDecoration({
    required Color backgroundColor,
    bool isPressed = false,
    bool hasGlow = false,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        if (hasGlow) glowEffect(color: backgroundColor),
        BoxShadow(
          color: shadowDark,
          blurRadius: isPressed ? 2.0 : 4.0,
          offset: Offset(0, isPressed ? 1.0 : 2.0),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'design_tokens.dart';

ThemeData buildAequusTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseColorScheme = ColorScheme.fromSeed(
    seedColor: AequusDesignTokens.primaryBlue,
    brightness: brightness,
  );

  final scaffoldBackgroundColor =
      isDark ? AequusDesignTokens.canvasDark : AequusDesignTokens.canvasLight;

  return ThemeData(
    brightness: brightness,
    colorScheme: baseColorScheme,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    textTheme: _buildTextTheme(baseColorScheme.onSurface),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: scaffoldBackgroundColor,
  foregroundColor: baseColorScheme.onSurface,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AequusDesignTokens.typography.title,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: AequusDesignTokens.radii.s13,
        borderSide: BorderSide(
          color: baseColorScheme.primary.withValues(alpha: 0.34),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AequusDesignTokens.radii.s13,
        borderSide: BorderSide(color: baseColorScheme.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AequusDesignTokens.spacing.s21,
        vertical: AequusDesignTokens.spacing.s13,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: AequusDesignTokens.primaryBlue,
        padding: EdgeInsets.symmetric(
          horizontal: AequusDesignTokens.spacing.s34,
          vertical: AequusDesignTokens.spacing.s13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AequusDesignTokens.radii.s21,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: baseColorScheme.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AequusDesignTokens.spacing.s13,
          vertical: AequusDesignTokens.spacing.s8,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AequusDesignTokens.radii.s21,
      ),
      color: isDark
          ? AequusDesignTokens.canvasDark.withValues(alpha: 0.89)
          : Colors.white,
    ),
  );
}

TextTheme _buildTextTheme(Color onSurface) {
  return TextTheme(
    displayLarge: TextStyle(
      fontSize: AequusDesignTokens.typography.display,
      fontWeight: FontWeight.w600,
      color: onSurface,
    ),
    headlineMedium: TextStyle(
      fontSize: AequusDesignTokens.typography.headline,
      fontWeight: FontWeight.w500,
      color: onSurface.withValues(alpha: 0.89),
    ),
    titleLarge: TextStyle(
      fontSize: AequusDesignTokens.typography.title,
      fontWeight: FontWeight.w600,
      color: onSurface,
    ),
    bodyLarge: TextStyle(
      fontSize: AequusDesignTokens.typography.body,
      fontWeight: FontWeight.w400,
      color: onSurface.withValues(alpha: 0.89),
    ),
    bodyMedium: TextStyle(
      fontSize: AequusDesignTokens.typography.body,
      fontWeight: FontWeight.w400,
      color: onSurface.withValues(alpha: 0.55),
    ),
    labelLarge: TextStyle(
      fontSize: AequusDesignTokens.typography.caption,
      letterSpacing: 0.34,
      fontWeight: FontWeight.w500,
      color: onSurface.withValues(alpha: 0.55),
    ),
  );
}

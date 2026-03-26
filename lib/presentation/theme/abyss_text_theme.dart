import 'package:flutter/material.dart';
import 'abyss_colors.dart';

abstract final class AbyssTextTheme {
  static const _fontFamily = 'Rajdhani';

  static TextTheme create() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AbyssColors.biolumCyan,
        letterSpacing: 1.5,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AbyssColors.biolumCyan,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AbyssColors.biolumTeal,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AbyssColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AbyssColors.onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AbyssColors.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AbyssColors.biolumCyan,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AbyssColors.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AbyssColors.onSurfaceDim,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AbyssColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AbyssColors.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AbyssColors.onSurfaceDim,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AbyssColors.abyssBlack,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AbyssColors.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        color: AbyssColors.onSurfaceDim,
      ),
    );
  }
}

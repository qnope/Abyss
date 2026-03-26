import 'package:flutter/material.dart';
import 'abyss_colors.dart';

abstract final class AbyssInputTheme {
  static InputDecorationTheme inputDecoration() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AbyssColors.surfaceDim,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AbyssColors.biolumCyan.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AbyssColors.biolumCyan,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AbyssColors.error),
      ),
      hintStyle: TextStyle(
        color: AbyssColors.onSurfaceDim.withValues(alpha: 0.6),
      ),
      labelStyle: const TextStyle(color: AbyssColors.onSurfaceDim),
      prefixIconColor: AbyssColors.biolumCyan,
    );
  }

  static SliderThemeData slider() {
    return SliderThemeData(
      activeTrackColor: AbyssColors.biolumCyan,
      inactiveTrackColor: AbyssColors.surfaceBright,
      thumbColor: AbyssColors.biolumCyan,
      overlayColor: AbyssColors.biolumCyan.withValues(alpha: 0.15),
      valueIndicatorColor: AbyssColors.biolumCyan,
      valueIndicatorTextStyle: const TextStyle(
        color: AbyssColors.abyssBlack,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static ProgressIndicatorThemeData progressIndicator() {
    return const ProgressIndicatorThemeData(
      color: AbyssColors.biolumCyan,
      linearTrackColor: AbyssColors.surfaceBright,
      circularTrackColor: AbyssColors.surfaceBright,
    );
  }
}

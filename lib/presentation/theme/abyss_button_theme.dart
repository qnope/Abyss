import 'package:flutter/material.dart';
import 'abyss_colors.dart';

abstract final class AbyssButtonTheme {
  static ElevatedButtonThemeData elevatedButton() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AbyssColors.biolumCyan,
        foregroundColor: AbyssColors.abyssBlack,
        disabledBackgroundColor: AbyssColors.disabled,
        disabledForegroundColor: AbyssColors.onSurfaceDim,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        shadowColor: AbyssColors.biolumCyan.withValues(alpha: 0.4),
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButton() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AbyssColors.biolumCyan,
        side: const BorderSide(color: AbyssColors.biolumCyan, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static TextButtonThemeData textButton() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AbyssColors.biolumTeal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static IconButtonThemeData iconButton() {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AbyssColors.biolumCyan,
        highlightColor: AbyssColors.biolumCyan.withValues(alpha: 0.1),
      ),
    );
  }

  /// An outlined button lying over the map, on deep water so it reads
  /// over any cell.
  static ButtonStyle overMap() => OutlinedButton.styleFrom(
        foregroundColor: AbyssColors.biolumCyan,
        backgroundColor: AbyssColors.deepNavy.withValues(alpha: 0.85),
        side: const BorderSide(color: AbyssColors.biolumCyan, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}

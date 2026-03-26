import 'package:flutter/material.dart';
import 'abyss_colors.dart';

abstract final class AbyssCardTheme {
  static CardThemeData card() {
    return CardThemeData(
      color: AbyssColors.surfaceLight,
      shadowColor: AbyssColors.biolumCyan.withValues(alpha: 0.15),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AbyssColors.biolumCyan.withValues(alpha: 0.15),
        ),
      ),
      margin: const EdgeInsets.all(8),
    );
  }

  static DialogThemeData dialog() {
    return DialogThemeData(
      backgroundColor: AbyssColors.deepNavy,
      surfaceTintColor: AbyssColors.biolumCyan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AbyssColors.biolumCyan.withValues(alpha: 0.2),
        ),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AbyssColors.biolumCyan,
      ),
    );
  }

  static BottomSheetThemeData bottomSheet() {
    return BottomSheetThemeData(
      backgroundColor: AbyssColors.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      dragHandleColor: AbyssColors.biolumCyan.withValues(alpha: 0.5),
      showDragHandle: true,
    );
  }

  static AppBarTheme appBar() {
    return AppBarTheme(
      backgroundColor: AbyssColors.abyssBlack.withValues(alpha: 0.9),
      foregroundColor: AbyssColors.biolumCyan,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: 'Rajdhani',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AbyssColors.biolumCyan,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: AbyssColors.biolumCyan),
    );
  }
}

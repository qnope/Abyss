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

  static PopupMenuThemeData popupMenu() {
    return PopupMenuThemeData(
      color: AbyssColors.deepNavy,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AbyssColors.biolumCyan.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  static const double savePanelRadius = 16;
  static const _panelShape = BorderRadius.all(
    Radius.circular(savePanelRadius),
  );
  static final _panelColor = AbyssColors.surfaceLight.withValues(alpha: 0.78);

  /// Panel of a save card, lighter when [faded]. A [highlighted] panel
  /// glows cyan: the game a player most likely resumes.
  static BoxDecoration savePanel({
    required bool highlighted,
    bool faded = false,
  }) {
    if (highlighted) {
      return BoxDecoration(
        color: _panelColor,
        borderRadius: _panelShape,
        border: Border.all(
          color: AbyssColors.biolumCyan.withValues(alpha: 0.75),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AbyssColors.biolumCyan.withValues(alpha: 0.22),
            blurRadius: 18,
          ),
        ],
      );
    }
    return BoxDecoration(
      color: faded ? AbyssColors.dimmed(_panelColor) : _panelColor,
      borderRadius: _panelShape,
      border: Border.all(
        color: AbyssColors.biolumCyan.withValues(alpha: faded ? 0.08 : 0.18),
      ),
    );
  }
}

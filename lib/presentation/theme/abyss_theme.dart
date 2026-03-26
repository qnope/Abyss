import 'package:flutter/material.dart';
import 'abyss_button_theme.dart';
import 'abyss_card_theme.dart';
import 'abyss_colors.dart';
import 'abyss_input_theme.dart';
import 'abyss_text_theme.dart';

abstract final class AbyssTheme {
  static ThemeData create() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AbyssColors.abyssBlack,
      colorScheme: _colorScheme,
      textTheme: AbyssTextTheme.create(),
      appBarTheme: AbyssCardTheme.appBar(),
      cardTheme: AbyssCardTheme.card(),
      dialogTheme: AbyssCardTheme.dialog(),
      bottomSheetTheme: AbyssCardTheme.bottomSheet(),
      elevatedButtonTheme: AbyssButtonTheme.elevatedButton(),
      outlinedButtonTheme: AbyssButtonTheme.outlinedButton(),
      textButtonTheme: AbyssButtonTheme.textButton(),
      iconButtonTheme: AbyssButtonTheme.iconButton(),
      inputDecorationTheme: AbyssInputTheme.inputDecoration(),
      sliderTheme: AbyssInputTheme.slider(),
      progressIndicatorTheme: AbyssInputTheme.progressIndicator(),
      dividerColor: AbyssColors.biolumCyan.withValues(alpha: 0.1),
      splashColor: AbyssColors.biolumCyan.withValues(alpha: 0.1),
      highlightColor: AbyssColors.biolumCyan.withValues(alpha: 0.05),
      tooltipTheme: _tooltipTheme,
      snackBarTheme: _snackBarTheme,
      navigationBarTheme: _navigationBarTheme,
      iconTheme: const IconThemeData(color: AbyssColors.biolumCyan),
    );
  }

  static const _colorScheme = ColorScheme.dark(
    primary: AbyssColors.biolumCyan,
    onPrimary: AbyssColors.abyssBlack,
    secondary: AbyssColors.biolumTeal,
    onSecondary: AbyssColors.abyssBlack,
    tertiary: AbyssColors.biolumPurple,
    onTertiary: AbyssColors.abyssBlack,
    surface: AbyssColors.deepNavy,
    onSurface: AbyssColors.onSurface,
    error: AbyssColors.error,
    onError: AbyssColors.abyssBlack,
    outline: AbyssColors.trench,
  );

  static final _tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: AbyssColors.surfaceBright,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AbyssColors.biolumCyan.withValues(alpha: 0.3),
      ),
    ),
    textStyle: const TextStyle(
      color: AbyssColors.onSurface,
      fontSize: 12,
    ),
  );

  static const _snackBarTheme = SnackBarThemeData(
    backgroundColor: AbyssColors.surfaceBright,
    contentTextStyle: TextStyle(color: AbyssColors.onSurface),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static final _navigationBarTheme = NavigationBarThemeData(
    backgroundColor: AbyssColors.abyssBlack.withValues(alpha: 0.95),
    indicatorColor: AbyssColors.biolumCyan.withValues(alpha: 0.15),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AbyssColors.biolumCyan);
      }
      return const IconThemeData(color: AbyssColors.onSurfaceDim);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: AbyssColors.biolumCyan,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );
      }
      return const TextStyle(
        color: AbyssColors.onSurfaceDim,
        fontSize: 12,
      );
    }),
  );
}

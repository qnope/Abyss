import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';

void main() {
  group('AbyssTheme', () {
    test('creates a valid ThemeData', () {
      final theme = AbyssTheme.create();

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AbyssColors.biolumCyan);
      expect(theme.scaffoldBackgroundColor, AbyssColors.abyssBlack);
    });

    test('uses Material 3', () {
      final theme = AbyssTheme.create();

      expect(theme.useMaterial3, isTrue);
    });
    test('the selected navigation tab glows cyan, the others stay dim', () {
      final nav = AbyssTheme.create().navigationBarTheme;
      const selected = {WidgetState.selected};
      const idle = <WidgetState>{};

      expect(nav.iconTheme!.resolve(selected)!.color, AbyssColors.biolumCyan);
      expect(nav.iconTheme!.resolve(idle)!.color, AbyssColors.onSurfaceDim);
      final label = nav.labelTextStyle!;
      expect(label.resolve(selected)!.color, AbyssColors.biolumCyan);
      expect(label.resolve(selected)!.fontWeight, FontWeight.w600);
      expect(label.resolve(idle)!.color, AbyssColors.onSurfaceDim);
    });
  });
}

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
  });
}

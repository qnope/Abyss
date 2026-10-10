import 'dart:convert';
import 'dart:io';

import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _family = 'Rajdhani';

/// The Rajdhani family as Flutter bundles it: weight -> asset path.
Future<Map<int, String>> _bundledRajdhani() async {
  final manifest = jsonDecode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  final family = manifest.cast<Map<String, dynamic>>().firstWhere(
        (entry) => entry['family'] == _family,
        orElse: () => const {'fonts': <dynamic>[]},
      );
  return {
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>())
      (font['weight'] as int?) ?? 400: font['asset'] as String,
  };
}

/// Every weight the theme draws with the Rajdhani family.
Set<int> _themeRajdhaniWeights() {
  final theme = AbyssTheme.create();
  final text = theme.textTheme;
  final styles = <TextStyle?>[
    text.displayLarge, text.displayMedium, text.displaySmall,
    text.headlineLarge, text.headlineMedium, text.headlineSmall,
    text.titleLarge, text.titleMedium, text.titleSmall,
    text.labelLarge, text.labelMedium, text.labelSmall,
    theme.appBarTheme.titleTextStyle,
    // Widgets often bold a theme title with copyWith.
    text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  ];
  return {
    for (final style in styles)
      if (style?.fontFamily == _family)
        (style!.fontWeight ?? FontWeight.normal).value,
  };
}

void main() {
  testWidgets('bundles the four Rajdhani weights', (tester) async {
    final fonts = await tester.runAsync(_bundledRajdhani);

    expect(fonts!.keys.toSet(), {400, 500, 600, 700});
  });

  testWidgets('covers every Rajdhani weight the theme uses', (tester) async {
    final fonts = await tester.runAsync(_bundledRajdhani);

    expect(fonts!.keys.toSet(), containsAll(_themeRajdhaniWeights()));
  });

  testWidgets('loads every bundled Rajdhani file', (tester) async {
    await tester.runAsync(() async {
      final fonts = await _bundledRajdhani();
      expect(fonts, isNotEmpty);
      final loader = FontLoader(_family);
      for (final asset in fonts.values) {
        final bytes = await rootBundle.load(asset);
        expect(bytes.lengthInBytes, greaterThan(10000), reason: asset);
        loader.addFont(Future.value(bytes));
      }
      await loader.load();
    });
  });

  test('ships the font licence next to the files', () {
    expect(File('assets/fonts/rajdhani/OFL.txt').existsSync(), isTrue);
  });
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Features flutter_svg ignores or renders differently from a browser.
/// Clip paths are allowed: illustrations are rasterized once, so their
/// cost is paid a single time.
const _forbidden = [
  '<filter',
  '<mask',
  '<image',
  '<text',
  '<style',
  '<use',
  '<pattern',
  '<!DOCTYPE',
  'mix-blend-mode',
];

/// Expected viewBox of every illustration.
const _viewBoxes = {
  'assets/illustrations/menu/abyss_backdrop.svg': '0 0 1600 2200',
  'assets/illustrations/saves/depth_surface.svg': '0 0 160 160',
  'assets/illustrations/saves/depth_deep.svg': '0 0 160 160',
  'assets/illustrations/saves/depth_core.svg': '0 0 160 160',
  'assets/illustrations/saves/empty_sonar.svg': '0 0 240 240',
};

void main() {
  final files =
      Directory('assets/illustrations')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.svg'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final gradientId = RegExp(r'<(?:linear|radial)Gradient[^>]*\bid="([^"]+)"');
  final clipId = RegExp(r'<clipPath[^>]*\bid="([^"]+)"');
  final urlUse = RegExp(r'url\(#([^)]+)\)');

  test('every illustration is listed', () {
    expect(files.map((f) => f.path).toSet(), _viewBoxes.keys.toSet());
  });

  for (final file in files) {
    group(file.path, () {
      final content = file.readAsStringSync();

      test('folder is declared in pubspec', () {
        expect(pubspec, contains('    - ${file.parent.path}/'));
      });

      test('has its expected viewBox', () {
        expect(content, contains('viewBox="${_viewBoxes[file.path]}"'));
      });

      test('avoids features flutter_svg ignores', () {
        for (final token in _forbidden) {
          expect(content, isNot(contains(token)), reason: token);
        }
      });

      test('declares every reference it uses, once', () {
        final ids = [
          ...gradientId.allMatches(content).map((m) => m[1]!),
          ...clipId.allMatches(content).map((m) => m[1]!),
        ];
        expect(ids.toSet().length, ids.length, reason: 'duplicate id');
        for (final use in urlUse.allMatches(content)) {
          expect(ids, contains(use[1]), reason: 'url(#${use[1]}) undefined');
        }
      });

      testWidgets('loads through flutter_svg', (tester) async {
        await tester.pumpWidget(MaterialApp(home: SvgPicture.string(content)));
        expect(tester.takeException(), isNull);
      });
    });
  }
}

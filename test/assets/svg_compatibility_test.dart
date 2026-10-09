import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps every game SVG compatible with flutter_svg and cheap to rasterize
/// once at startup (see SvgRasterCache). Detail is unlimited: only the
/// features that create layers or that flutter_svg ignores are banned.
const _forbidden = [
  ' opacity=',
  '<filter',
  '<mask',
  '<clipPath',
  '<image',
  '<text',
  '<style',
  '<use',
  '<!DOCTYPE',
  '<metadata',
];

void main() {
  final svgFiles =
      Directory('assets/icons')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.svg'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final gradientId = RegExp(r'<(?:linear|radial)Gradient[^>]*\bid="([^"]+)"');
  final gradientUse = RegExp(r'url\(#([^)]+)\)');

  for (final file in svgFiles) {
    group(file.path, () {
      final content = file.readAsStringSync();

      test('uses a 64x64 viewBox', () {
        expect(content, contains('viewBox="0 0 64 64"'));
      });

      test('avoids layer-creating features', () {
        for (final token in _forbidden) {
          expect(content, isNot(contains(token)), reason: token);
        }
      });

      test('declares every gradient it uses, once', () {
        final declared = gradientId.allMatches(content).map((m) => m[1]!);
        final ids = declared.toList();
        expect(ids.toSet().length, ids.length, reason: 'duplicate gradient');
        for (final use in gradientUse.allMatches(content)) {
          expect(ids, contains(use[1]), reason: 'url(#${use[1]}) undefined');
        }
      });
    });
  }
}

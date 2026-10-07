import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps detailed SVG icons compatible with flutter_svg and quick to
/// rasterize. Icons are drawn from cached bitmaps (see SvgRasterCache).
const _maxShapes = 300;
const _maxGradients = 16;
const _maxBytes = 24000;
const _forbidden = [
  ' opacity=',
  '<filter',
  '<mask',
  '<clipPath',
  '<image',
  '<text',
  '<style',
  '<use',
];

void main() {
  final svgFiles = Directory('assets/icons')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.svg'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final shapePattern = RegExp(r'<(path|rect|circle|ellipse|line|polygon)\b');
  final gradientPattern = RegExp(r'<(linear|radial)Gradient\b');

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

      test('stays within the shape budget', () {
        final shapes = shapePattern.allMatches(content).length;
        expect(shapes, lessThanOrEqualTo(_maxShapes));
      });

      test('stays within the size budget', () {
        expect(content.length, lessThanOrEqualTo(_maxBytes));
      });

      test('stays within the gradient budget', () {
        final gradients = gradientPattern.allMatches(content).length;
        expect(gradients, lessThanOrEqualTo(_maxGradients));
      });
    });
  }
}

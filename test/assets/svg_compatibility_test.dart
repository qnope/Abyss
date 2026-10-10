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

/// Features allowed in some files only, by the prefix of their path under
/// assets/icons. The guide's portrait keeps the clip of its medallion: it
/// is rasterized once like every icon, then drawn as a bitmap.
const _allowed = {
  'guide/': ['<clipPath'],
};

void main() {
  final svgFiles =
      Directory('assets/icons')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.svg'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final declaredId = RegExp(
    r'<(?:linearGradient|radialGradient|clipPath)[^>]*\bid="([^"]+)"',
  );
  final urlUse = RegExp(r'url\(#([^)]+)\)');

  for (final file in svgFiles) {
    group(file.path, () {
      final content = file.readAsStringSync();

      test('uses a 64x64 viewBox', () {
        expect(content, contains('viewBox="0 0 64 64"'));
      });

      test('avoids layer-creating features', () {
        for (final token in _forbidden.where((t) => !_allows(file, t))) {
          expect(content, isNot(contains(token)), reason: token);
        }
      });

      test('declares every gradient or clip it uses, once', () {
        final declared = declaredId.allMatches(content).map((m) => m[1]!);
        final ids = declared.toList();
        expect(ids.toSet().length, ids.length, reason: 'duplicate gradient');
        for (final use in urlUse.allMatches(content)) {
          expect(ids, contains(use[1]), reason: 'url(#${use[1]}) undefined');
        }
      });
    });
  }
}

bool _allows(File file, String token) {
  final relative = file.path.replaceFirst('assets/icons/', '');
  return _allowed.entries.any(
    (e) => relative.startsWith(e.key) && e.value.contains(token),
  );
}

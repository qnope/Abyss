import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final svgFiles = Directory('assets/icons')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.svg'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('asset directory contains SVG files', () {
    expect(svgFiles.length, greaterThanOrEqualTo(30));
  });

  group('pubspec declares all SVG directories', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final dirs = svgFiles
        .map((f) => f.parent.path.endsWith('/')
            ? f.parent.path
            : '${f.parent.path}/')
        .toSet();

    for (final dir in dirs) {
      test('$dir is declared', () {
        expect(pubspec, contains(dir));
      });
    }
  });

  group('SVG files are valid and renderable', () {
    for (final file in svgFiles) {
      testWidgets('${file.path} loads', (tester) async {
        final content = file.readAsStringSync();
        await tester.pumpWidget(
          MaterialApp(home: SvgPicture.string(content)),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}

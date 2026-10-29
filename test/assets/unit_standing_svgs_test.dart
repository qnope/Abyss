import 'dart:io';

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/unit_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Features flutter_svg ignores: a standing unit must not rely on them.
const _ignored = ['<pattern', '<filter', '<mask'];

/// Every unit is drawn standing, full body, for the isometric army: feet
/// at the bottom of a 120x150 canvas, centred.
void main() {
  test('pubspec declares the standing units folder', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('    - assets/icons/units/standing/'),
    );
  });

  test('each unit has its own standing drawing', () {
    final paths = UnitType.values.map((t) => t.standingPath).toSet();
    expect(paths, hasLength(UnitType.values.length));
    expect(paths, everyElement(startsWith('assets/icons/units/standing/')));
    expect(UnitType.domeBreaker.standingPath, endsWith('/dome_breaker.svg'));
  });

  for (final type in UnitType.values) {
    group(type.standingPath, () {
      final file = File(type.standingPath);
      String content() => file.readAsStringSync();

      test('exists', () => expect(file.existsSync(), isTrue));

      test('is an SVG on a 120x150 canvas', () {
        expect(content().trimLeft(), startsWith('<svg'));
        expect(content(), contains('viewBox="0 0 120 150"'));
        expect(content().trimRight(), endsWith('</svg>'));
      });

      test('avoids features flutter_svg ignores', () {
        for (final token in _ignored) {
          expect(content(), isNot(contains(token)), reason: token);
        }
      });

      testWidgets('loads through flutter_svg', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: SvgPicture.string(content())),
        );
        expect(tester.takeException(), isNull);
      });
    });
  }
}

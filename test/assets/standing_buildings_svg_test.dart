import 'dart:io';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/extensions/building_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sections of a building card that are scenery, not building: the water,
/// its light and particles, the sand floor and its pebbles, the frame.
const _dropped = [
  'eau',
  'rayons de lumiere',
  'rayons captes',
  'lueur',
  'particules en suspension',
  'particules proches',
  'plancher de sable',
  'galets',
  'coquillages',
  'petites algues et anemones',
  'bulles',
  'cadre',
  'banc de petits poissons',
  'suspended particles',
  'basalt gravel',
  'halo',
  'faisceaux',
];

final _comment = RegExp(r'<!--\s*(.*?)\s*-->');

void main() {
  for (final type in BuildingType.values) {
    group('${type.name} standing', () {
      final standing = File(type.standingPath);
      final source = File(type.iconPath);

      test('sits in the standing folder under its card file name', () {
        final name = type.iconPath.split('/').last;
        expect(type.standingPath, 'assets/icons/buildings/standing/$name');
        expect(standing.existsSync(), isTrue);
      });

      testWidgets('is bundled and renders', (tester) async {
        final content = await tester.runAsync(
          () => rootBundle.loadString(type.standingPath),
        );
        await tester.pumpWidget(MaterialApp(home: SvgPicture.string(content!)));
        expect(tester.takeException(), isNull);
      });

      test('keeps the defs and every section of the building', () {
        final content = standing.readAsStringSync();
        final card = source.readAsStringSync();
        expect(content, startsWith(card.split('</defs>').first));
        final kept = _sections(card).where((s) => !_isDropped(s)).toList();
        expect(kept, isNotEmpty);
        expect(_sections(content), kept);
      });

      test('drops the water, the floor and the frame', () {
        final content = standing.readAsStringSync();
        expect(_sections(content).where(_isDropped), isEmpty);
        final body = content.split('</defs>').last.trimLeft();
        expect(body, startsWith('<!--'), reason: 'unnamed background kept');
      });
    });
  }
}

List<String> _sections(String svg) =>
    _comment.allMatches(svg).map((m) => m[1]!).toList();

bool _isDropped(String section) =>
    _dropped.any(_plain(section.toLowerCase()).startsWith);

/// [text] without the French accents of the section names.
String _plain(String text) => text
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[àâ]'), 'a')
    .replaceAll(RegExp('[îï]'), 'i')
    .replaceAll('ô', 'o')
    .replaceAll('ç', 'c');

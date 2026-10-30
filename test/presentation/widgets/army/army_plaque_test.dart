import 'dart:ui';

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_army_colors.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_plaque.dart';
import 'package:abyss/presentation/widgets/army/army_plaque_drawer.dart';
import 'package:abyss/presentation/widgets/army/army_roster.dart';
import 'package:abyss/presentation/widgets/army/army_squad_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';

void main() {
  const harpoonist = UnitType.harpoonist, guardian = UnitType.guardian;
  const roster = ArmyRoster(
    barracksLevel: 2,
    counts: {harpoonist: 22, UnitType.abyssAdmiral: 1, guardian: 7},
    recruitable: {harpoonist, guardian},
  );

  group('ArmyPlaque', () {
    test('counts the squad in its colour, its name in the plural', () {
      final plaque = ArmyPlaque.of(harpoonist, roster, fr);
      expect(plaque.count, '22');
      expect(plaque.name, 'Harponneurs');
      expect(plaque.colour, AbyssArmyColors.of(harpoonist));
      expect(plaque.lock, isNull);
      expect(plaque.recruitable, isTrue);
    });

    test('names a single unit in the singular', () {
      final plaque = ArmyPlaque.of(UnitType.abyssAdmiral, roster, fr);
      expect(plaque.count, '1');
      expect(plaque.name, 'Amiral des Abysses');
      expect(plaque.recruitable, isFalse);
    });

    test('an empty squad counts zero', () {
      final plaque = ArmyPlaque.of(UnitType.scout, roster, fr);
      expect(plaque.count, '0');
      expect(plaque.name, 'Éclaireurs');
    });

    test('a locked squad shows the barracks level it waits for', () {
      final plaque = ArmyPlaque.of(guardian, roster, fr);
      expect(plaque.lock, 'Caserne niv. 3');
      expect(plaque.count, isNull);
      expect(plaque.name, 'Gardien');
      expect(plaque.recruitable, isFalse);
    });
  });

  group('placing a plaque', () {
    const drawer = ArmyPlaqueDrawer();

    test('stays at the front of its pad when it fits the view', () {
      final at = ArmySquadGeometry.plaqueAt(harpoonist);
      final plaque = ArmyPlaque.of(harpoonist, roster, fr);
      expect(drawer.placed(at, plaque, left: -1e4, right: 1e4), at);
    });

    test('every plaque, its badge included, lies inside a narrow view', () {
      const view = Size(320, 520);
      final fit = ArmyFit.of(view);
      final left = fit.toProjection(Offset.zero).dx;
      final right = fit.toProjection(Offset(view.width, 0)).dx;
      final all = ArmyRoster(
        barracksLevel: 9,
        counts: {for (final type in UnitType.values) type: 1500},
        recruitable: UnitType.values.toSet(),
      );
      for (final type in UnitType.values) {
        final plaque = ArmyPlaque.of(type, all, fr);
        final at = drawer.placed(
          ArmySquadGeometry.plaqueAt(type),
          plaque,
          left: left,
          right: right,
        );
        final (before, after) = drawer.reach(plaque);
        expect(at.dx - before, greaterThanOrEqualTo(left), reason: '$type');
        expect(at.dx + after, lessThanOrEqualTo(right), reason: '$type');
        expect(at.dy, ArmySquadGeometry.plaqueAt(type).dy);
      }
    });

    test('the recruit badge stands right of the count, within reach', () {
      final plaque = ArmyPlaque.of(harpoonist, roster, fr);
      const at = Offset(100, 50);
      final badge = drawer.badgeAt(at, plaque);
      final (_, right) = drawer.reach(plaque);
      expect(badge.dy, at.dy);
      expect(badge.dx, greaterThan(at.dx));
      expect(
        badge.dx + ArmyPlaqueDrawer.badgeRadius,
        lessThanOrEqualTo(at.dx + right),
      );
    });
  });
}

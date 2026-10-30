import 'dart:ui';

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_marks_painter.dart';
import 'package:abyss/presentation/widgets/army/army_roster.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';

void main() {
  const view = Size(390, 635);
  final fit = ArmyFit.of(view);
  const roster = ArmyRoster(
    barracksLevel: 2,
    counts: {UnitType.scout: 14, UnitType.harpoonist: 1},
    recruitable: {UnitType.scout},
  );

  ArmyMarksPainter marks(ArmyRoster army, {bool locked = false}) =>
      ArmyMarksPainter(
        fit: fit,
        roster: army,
        l10n: fr,
        barracksLocked: locked,
      );

  void paint(ArmyMarksPainter painter) {
    final recorder = PictureRecorder();
    painter.paint(Canvas(recorder), view);
    recorder.endRecording().dispose();
  }

  test('paints the barracks plaque, every count, lock and badge', () {
    paint(marks(roster));
    paint(marks(const ArmyRoster(barracksLevel: 0), locked: true));
  });

  test('the same army is not repainted', () {
    expect(marks(roster).shouldRepaint(marks(roster)), isFalse);
  });

  test('a count, a badge, the barracks or the language repaints the marks', () {
    final before = marks(roster);
    expect(
      marks(
        const ArmyRoster(barracksLevel: 2, counts: {UnitType.scout: 15}),
      ).shouldRepaint(before),
      isTrue,
    );
    expect(
      marks(
        const ArmyRoster(barracksLevel: 3),
      ).shouldRepaint(marks(const ArmyRoster(barracksLevel: 2))),
      isTrue,
    );
    expect(marks(roster, locked: true).shouldRepaint(before), isTrue);
    expect(
      ArmyMarksPainter(
        fit: fit,
        roster: roster,
        l10n: en,
      ).shouldRepaint(before),
      isTrue,
    );
  });

  test('the marks take no touch', () {
    expect(marks(roster).hitTest(Offset.zero), isFalse);
  });
}

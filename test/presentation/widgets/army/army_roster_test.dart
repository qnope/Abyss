import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_roster.dart';
import 'package:abyss/presentation/widgets/army/squad_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scout = UnitType.scout, guardian = UnitType.guardian;

  group('figuresOf', () {
    test('a squad shows as many figures as its size tier', () {
      for (final (count, figures) in [
        (0, 0),
        (1, 1),
        (2, 2),
        (5, 2),
        (6, 3),
        (15, 3),
        (16, 4),
        (30, 4),
        (31, 5),
        (60, 5),
        (61, 6),
        (500, 6),
      ]) {
        final roster = ArmyRoster(barracksLevel: 1, counts: {scout: count});
        expect(roster.figuresOf(scout), figures, reason: '$count units');
        expect(figures, SquadSize.of(count));
      }
    });

    test('a locked unit shows one ghost, whatever its count', () {
      const roster = ArmyRoster(barracksLevel: 2, counts: {guardian: 40});
      expect(roster.isLocked(guardian), isTrue);
      expect(roster.figuresOf(guardian), 1);
      expect(roster.isLocked(scout), isFalse);
    });
  });

  test('the barracks level unlocks the units of the rules', () {
    const roster = ArmyRoster(barracksLevel: 2);
    expect(roster.unlocked, {
      scout,
      UnitType.harpoonist,
      UnitType.abyssAdmiral,
    });
    expect(roster.unlockLevelOf(guardian), 3);
  });

  test('only an unlocked unit is shown recruitable', () {
    const roster = ArmyRoster(barracksLevel: 1, recruitable: {scout, guardian});
    expect(roster.canRecruit(scout), isTrue);
    expect(roster.canRecruit(guardian), isFalse);
    expect(roster.canRecruit(UnitType.harpoonist), isFalse);
  });

  test('two rosters of the same army are equal', () {
    expect(
      ArmyRoster(barracksLevel: 1, counts: {scout: 3}, recruitable: {scout}),
      ArmyRoster(barracksLevel: 1, counts: {scout: 3}, recruitable: {scout}),
    );
    expect(
      ArmyRoster(barracksLevel: 1, counts: {scout: 3}),
      isNot(ArmyRoster(barracksLevel: 1, counts: {scout: 4})),
    );
  });
}

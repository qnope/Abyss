import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = ArmyPlanner();
  List<Combatant> wave() => CombatantBuilder.monsterCombatantsFrom(
      const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 10));

  test('a crushing army always wins, an empty one never does', () {
    expect(planner.winRate({UnitType.harpoonist: 60}, wave), 1);
    expect(planner.winRate(const {}, wave), 0);
  });

  test('a win without a surviving admiral does not count when one is needed',
      () {
    final army = {UnitType.harpoonist: 60};
    expect(planner.wins(army, GuardianFactory.forFaille), isTrue);
    expect(
      planner.wins(army, GuardianFactory.forFaille, needsAdmiral: true),
      isFalse,
    );
  });

  test('smallestWinning finds the smallest army that wins', () {
    Map<UnitType, int> harpoons(int k) => {UnitType.harpoonist: k};
    final k = planner.smallestWinning(60, harpoons, wave)!;

    expect(planner.wins(harpoons(k), wave), isTrue);
    expect(planner.wins(harpoons(k - 1), wave), isFalse);
  });

  test('smallestWinning gives up when even the largest army loses', () {
    final k = planner.smallestWinning(
      3,
      (k) => {UnitType.scout: k},
      GuardianFactory.forVolcanicKernel,
    );
    expect(k, isNull);
  });

  test('planning never touches the game dice: same answer every time', () {
    final army = {UnitType.harpoonist: 8};
    expect(
      planner.winRate(army, wave),
      planner.winRate(army, wave),
    );
  });
}

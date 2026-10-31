import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

/// An enemy that counts its rehearsals: it is asked for once per fight.
class _Counted {
  final List<Combatant> Function() _enemy;
  int calls = 0;

  _Counted(this._enemy);

  List<Combatant> call() {
    calls++;
    return _enemy();
  }
}

List<Combatant> _wave() => CombatantBuilder.monsterCombatantsFrom(
  const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 10),
);

/// Rehearsals [planner] plays to judge [army] against [_wave].
int _rehearsalsOf(
  ArmyPlanner planner,
  Map<UnitType, int> army, {
  bool winRate = false,
}) {
  final _Counted enemy = _Counted(_wave);
  winRate ? planner.winRate(army, enemy.call) : planner.wins(army, enemy.call);
  return enemy.calls;
}

void main() {
  const planner = ArmyPlanner();
  // Never wins, yet strong enough to be rehearsed.
  const doomed = {UnitType.harpoonist: 5};
  const crushing = {UnitType.harpoonist: 10};

  test('the armies used below are rehearsed in full by winRate', () {
    expect(planner.winRate(doomed, _wave), 0);
    expect(planner.winRate(crushing, _wave), 1);
    expect(_rehearsalsOf(planner, doomed, winRate: true), 8);
    expect(_rehearsalsOf(planner, crushing, winRate: true), 8);
  });

  test('wins stops once two losses out of 8 settle a no at 85%', () {
    expect(planner.wins(doomed, _wave), isFalse);
    expect(_rehearsalsOf(planner, doomed), 2);
  });

  test('wins stops once seven wins out of 8 settle a yes at 85%', () {
    expect(planner.wins(crushing, _wave), isTrue);
    expect(_rehearsalsOf(planner, crushing), 7);
  });

  test('the thresholds follow rehearsals and confidence', () {
    const lenient = ArmyPlanner(rehearsals: 10, confidence: 0.7);
    expect(_rehearsalsOf(lenient, doomed), 4);
    expect(_rehearsalsOf(lenient, crushing), 7);
    const strict = ArmyPlanner(rehearsals: 20, confidence: 0.95);
    expect(_rehearsalsOf(strict, doomed), 2);
    expect(_rehearsalsOf(strict, crushing), 19);
  });

  test('wins always agrees with winRate against confidence', () {
    const planners = <ArmyPlanner>[
      ArmyPlanner(),
      ArmyPlanner(rehearsals: 10, confidence: 0.7),
      ArmyPlanner(rehearsals: 20, confidence: 0.95),
      ArmyPlanner(rehearsals: 5, confidence: 1),
      ArmyPlanner(rehearsals: 6, confidence: 0.5),
      ArmyPlanner(rehearsals: 3, confidence: 0.1),
      ArmyPlanner(rehearsals: 4, confidence: 0),
      ArmyPlanner(rehearsals: 4, confidence: 1.5),
    ];
    final enemies = <List<Combatant> Function()>[
      _wave,
      GuardianFactory.forFaille,
      GuardianFactory.forVolcanicKernel,
    ];
    final armies = <Map<UnitType, int>>[
      for (int k = 0; k <= 12; k++) {UnitType.harpoonist: k},
      for (int k = 0; k <= 60; k += 15)
        {UnitType.harpoonist: k, UnitType.abyssAdmiral: 1},
    ];
    for (final ArmyPlanner p in planners) {
      for (final enemy in enemies) {
        for (final army in armies) {
          for (final bool admiral in <bool>[false, true]) {
            expect(
              p.wins(army, enemy, needsAdmiral: admiral),
              p.winRate(army, enemy, needsAdmiral: admiral) >= p.confidence,
              reason: '${p.rehearsals}@${p.confidence} $army $admiral',
            );
          }
        }
      }
    }
  });
}

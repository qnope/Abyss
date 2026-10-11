import 'package:abyss/domain/fight/assault/assault_plan.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'assault_test_helper.dart';

const _admiral = UnitType.abyssAdmiral;
const _guardian = UnitType.guardian;
const _harpoonist = UnitType.harpoonist;

AssaultPlan _plan(Map<UnitType, int> army,
        {AssaultTarget target = AssaultTarget.faille,
        int maxAdded = AssaultPlan.defaultMaxHarpoonists}) =>
    AssaultPlan.of(
      player: assaultPlayer(),
      level: 1,
      target: target,
      army: army,
      maxHarpoonists: maxAdded,
    );

int _wins(Map<UnitType, int> army) => _plan(army).chance.wins;

void main() {
  test('the fewest harpoonists that win 19 rehearsals of 20', () {
    final plan = _plan({_admiral: 1, _guardian: 2, _harpoonist: 3});
    final int needed = plan.suggestedHarpoonists!;
    Map<UnitType, int> army(int k) =>
        {_admiral: 1, _guardian: 2, _harpoonist: k};

    expect(plan.suggestedArmy, army(needed));
    expect(_wins(army(needed)), greaterThanOrEqualTo(19));
    expect(_wins(army(needed - 1)), lessThan(19));
  });

  test('ignores the harpoonists and others already selected', () {
    final int bare = _plan({_admiral: 1}).suggestedHarpoonists!;

    expect(
      _plan({_admiral: 1, _harpoonist: 7, UnitType.scout: 3})
          .suggestedHarpoonists,
      bare,
    );
  });

  test('guardians lower the count', () {
    expect(_plan({_admiral: 1, _guardian: 6}).suggestedHarpoonists,
        lessThan(_plan({_admiral: 1}).suggestedHarpoonists!));
  });

  test('assumes one admiral when none is selected', () {
    final plan = _plan({_guardian: 1});

    expect(plan.suggestedArmy![_admiral], 1);
    expect(plan.suggestedHarpoonists,
        _plan({_admiral: 1, _guardian: 1}).suggestedHarpoonists);
  });

  test('the kernel needs more than a Faille', () {
    expect(_plan({_admiral: 1}, target: AssaultTarget.kernel)
            .suggestedHarpoonists,
        greaterThan(_plan({_admiral: 1}).suggestedHarpoonists!));
  });

  test('counts the Military research of an attacker', () {
    final player = assaultPlayer()
      ..techBranches[TechBranch.military] = TechBranchState(
        branch: TechBranch.military,
        unlocked: true,
        researchLevel: 1,
      );
    final researched = AssaultPlan.of(
      player: player,
      level: 1,
      target: AssaultTarget.cheminee,
      army: {_admiral: 1},
    );

    expect(researched.suggestedHarpoonists,
        lessThan(_plan({_admiral: 1}, target: AssaultTarget.cheminee)
            .suggestedHarpoonists!));
  });

  test('none when out of reach within the cap', () {
    final plan =
        _plan({_admiral: 1}, target: AssaultTarget.kernel, maxAdded: 5);

    expect(plan.suggestedHarpoonists, isNull);
    expect(plan.suggestedArmy, isNull);
  });

  test('is the same for the same input', () {
    expect(_plan({_admiral: 1, _guardian: 1}).suggestedHarpoonists,
        _plan({_admiral: 1, _guardian: 1}).suggestedHarpoonists);
  });

  test('a plan for a 30-unit army recomputes well under 50 ms', () {
    final watch = Stopwatch()..start();
    for (int k = 0; k < 10; k++) {
      _plan({_admiral: 1, _guardian: 4, _harpoonist: 25 + k}).chance;
    }
    final perPlan = watch.elapsedMicroseconds / 10 / 1000;
    // ignore: avoid_print
    print('assault plan: ${perPlan.toStringAsFixed(1)} ms per chance');

    expect(perPlan, lessThan(50));
  });
}

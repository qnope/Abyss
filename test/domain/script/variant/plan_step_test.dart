import 'package:abyss/domain/script/variant/plan_step.dart';
import 'package:abyss/domain/script/variant/replay_variant.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PlanStep step(Map<String, Object?> json) =>
      PlanStep(turn: 1, rank: 0, json: json);

  const Map<UnitType, int> none = <UnitType, int>{};

  test('scales the recruits of fighters, not scouts nor admirals', () {
    const variant = ReplayVariant(army: 0.8);
    Object? countOf(String unit) => step(<String, Object?>{
          'do': 'recruit',
          'unit': unit,
          'count': 10,
        }).adapt(variant, none)!['count'];

    expect(countOf('harpoonist'), 8);
    expect(countOf('scout'), 10);
    expect(countOf('abyssAdmiral'), 10);
  });

  test('cuts a selection of units to what is there', () {
    final adapted = step(<String, Object?>{
      'do': 'descend',
      'x': 1,
      'y': 2,
      'units': <String, Object?>{'harpoonist': 70, 'scout': 4},
    }).adapt(const ReplayVariant(), <UnitType, int>{UnitType.harpoonist: 50});

    expect(adapted!['units'], <String, int>{'harpoonist': 50});
  });

  test('gives up a selection when none of its units is there', () {
    final adapted = step(<String, Object?>{
      'do': 'attackKernel',
      'x': 1,
      'y': 2,
      'units': <String, Object?>{'harpoonist': 70},
    }).adapt(const ReplayVariant(), none);

    expect(adapted, isNull);
  });

  test('drops the dice of the replay unless the variant keeps them', () {
    final fight = step(<String, Object?>{'do': 'collect', 'seed': 7});
    final descent = step(<String, Object?>{
      'do': 'descend',
      'seed': 7,
      'units': <String, Object?>{'scout': 1},
    });
    const scouts = <UnitType, int>{UnitType.scout: 1};

    expect(fight.adapt(const ReplayVariant(), none)!['seed'], 7);
    expect(
      fight.adapt(const ReplayVariant(sameDice: false), none),
      isNot(contains('seed')),
    );
    expect(
      descent.adapt(const ReplayVariant(sameDice: false), scouts)!['seed'],
      7,
    );
    expect(
      descent.adapt(const ReplayVariant(sameMap: false), scouts),
      isNot(contains('seed')),
    );
  });

  test('keeps to the steps on the road to the volcano', () {
    expect(step(<String, Object?>{'do': 'attackBase'}).persistent, isTrue);
    expect(step(<String, Object?>{'do': 'descend'}).persistent, isTrue);
    expect(step(<String, Object?>{'do': 'upgrade'}).persistent, isFalse);
  });

  test('labels a variant by what it changes', () {
    const variant = ReplayVariant(sameMap: false, army: 0.8, defends: true);

    expect(variant.isExact, isFalse);
    expect(const ReplayVariant().isExact, isTrue);
    expect(variant.label, contains('autre carte'));
    expect(variant.label, contains('armée ×0.8'));
    expect(variant.label, contains('défense prudente'));
  });
}

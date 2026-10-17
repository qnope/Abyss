import 'package:abyss/domain/action/attack_base_defence.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_brain.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/script/strategies/conquest_moves.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/kernel_descent_helper.dart';

const _harpoonist = UnitType.harpoonist;

/// The owner holds the kernel at [level] behind a garrison the guardians'
/// sizing would never match; the attacker has [onKernel] harpoonists, an
/// admiral and two scouts on the volcano level (enough for the guardians)
/// and [home] harpoonists and an admiral at home.
KernelDescent _scene(int level, {int home = 600, int onKernel = 300}) {
  final d = KernelDescent(kernelLevel: level);
  d.war.garrison(const {UnitType.guardian: 200, _harpoonist: 200});
  d.put(3, {
    _harpoonist: onKernel,
    UnitType.abyssAdmiral: 1,
    UnitType.scout: 2,
  });
  d.put(1, {_harpoonist: home, UnitType.abyssAdmiral: 1});
  return d;
}

void _advance(KernelDescent d, {bool besieges = true}) =>
    d.turn().advanceConquest(const ArmyPlanner(), besiegesHeldKernel: besieges);

bool _beatsHolder(KernelDescent d) => const ArmyPlanner().wins({
  _harpoonist: d.count(3, _harpoonist),
}, () => BaseDefence.kernel(d.war.owner).side);

void main() {
  group('against a kernel held at level 7', () {
    test('brings the home army down to the volcano in the same turn', () {
      final d = _scene(7);
      expect(_beatsHolder(d), isFalse);

      _advance(d);

      expect(d.count(3, _harpoonist), greaterThan(300));
      expect(d.count(2, _harpoonist), 0, reason: 'nobody waits on level 2');
      expect(d.count(1, _harpoonist), greaterThan(0), reason: 'only a share');
      expect(_beatsHolder(d), isTrue);
    });

    test('takes down what waits on level 2 with the newcomers', () {
      final d = _scene(7);
      d.put(2, {_harpoonist: 20});

      _advance(d);

      expect(d.count(2, _harpoonist), 0);
      expect(d.count(3, _harpoonist), greaterThan(320));
    });

    test('recruits toward the holder while the army is too small', () {
      final d = _scene(7, home: 50);
      d.war.attacker.buildings[BuildingType.barracks] = Building(
        type: BuildingType.barracks,
        level: 5,
      );
      for (final r in d.war.attacker.resources.values) {
        r.amount = 200000;
      }

      _advance(d);

      final recruited = [
        UnitType.guardian,
        UnitType.domeBreaker,
        _harpoonist,
      ].map((t) => d.count(1, t)).reduce((a, b) => a + b);
      expect(recruited, greaterThan(50));
      expect(d.count(3, _harpoonist), 300);
    });

    test('a reference script still sizes against the guardians', () {
      final d = _scene(7);

      _advance(d, besieges: false);

      expect(d.count(3, _harpoonist), 300);
      expect(d.count(1, _harpoonist), 600);
    });

    test('a faction brain brings its army down', () {
      final d = _scene(7);

      FactionBrain(FactionPersonality.pearlOrder).playTurn(d.turn());

      expect(d.count(3, _harpoonist), greaterThan(300));
    });
  });

  test('nothing goes down to a kernel held at level 6', () {
    final d = _scene(6);

    _advance(d);

    expect(d.count(3, _harpoonist), 300);
    expect(d.count(1, _harpoonist), 600);
  });

  test('nothing goes down to a kernel held at level 7 but never seen', () {
    final d = _scene(7);
    d.war.attacker.revealedCellsPerLevel[3] = [];

    _advance(d);

    expect(d.count(1, _harpoonist), 600);
  });
}

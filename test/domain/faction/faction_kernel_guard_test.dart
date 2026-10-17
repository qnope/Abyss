import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_kernel_guard.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_descent_helper.dart';

/// The attacker of a [KernelDescent] holding the kernel at level 8 with
/// [garrison], [home] Harponneurs on its base and [noise] made so far, no
/// raid announced.
KernelDescent _holder({
  required int home,
  required int noise,
  Map<UnitType, int> garrison = const {UnitType.harpoonist: 28},
}) {
  final d = KernelDescent(kernelLevel: 8);
  final GameMap map = d.war.game.levels[KernelGarrison.volcanoLevel]!;
  map.setCell(
    d.war.at.x,
    d.war.at.y,
    map.cellAt(d.war.at.x, d.war.at.y).copyWith(collectedBy: d.war.attacker.id),
  );
  d.war.attacker.buildings[BuildingType.volcanicKernel] = Building(
    type: BuildingType.volcanicKernel,
    level: 8,
  );
  d.war.put(d.war.attacker, KernelGarrison.stockKey, garrison);
  d.put(1, {UnitType.harpoonist: home});
  d.war.attacker.raidState
    ..totalNoise = noise
    ..incoming = null
    ..arrivalTurn = null;
  return d;
}

void main() {
  test('a quiet base sends its share of fighters down to a weak kernel', () {
    final d = _holder(home: 550, noise: 0);

    FactionKernelGuard.play(d.turn(), 0.7);

    expect(d.count(1, UnitType.harpoonist), 550 - 385);
    expect(d.count(3, UnitType.harpoonist), 385);
  });

  test('a loud base keeps what holds the raid its noise brings next', () {
    // Seed 2 of the Nomads' race, turn 120: 70 % of the home army went
    // down while no raid was announced, and the 167 left lost the next
    // three raids, so the faction fell with 391 fighters on its kernel.
    final d = _holder(home: 550, noise: 2600);

    FactionKernelGuard.play(d.turn(), 0.7);

    expect(d.count(1, UnitType.harpoonist), greaterThan(550 - 385));
  });

  test('a strong garrison keeps the home army home', () {
    final d = _holder(
      home: 550,
      noise: 2600,
      garrison: const {UnitType.domeBreaker: 40, UnitType.guardian: 20},
    );

    FactionKernelGuard.play(d.turn(), 0.7);

    expect(d.count(1, UnitType.harpoonist), 550);
  });
}

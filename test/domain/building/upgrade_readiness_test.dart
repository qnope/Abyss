import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/building/upgrade_readiness.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hq = BuildingType.headquarters, farm = BuildingType.algaeFarm;

  /// A player whose headquarters stands at level 2, rich enough to pay.
  Player player() => Player(name: 'Nemo')
    ..buildings[hq]!.level = 2
    ..buildings[farm]!.level = 1
    ..resources[ResourceType.coral]!.amount = 5000
    ..resources[ResourceType.ore]!.amount = 5000
    ..resources[ResourceType.algae]!.amount = 5000
    ..resources[ResourceType.energy]!.amount = 5000;

  UpgradeReadiness readinessOf(
    Player nemo,
    BuildingType type, {
    Set<TransitionBaseType> captured = const {},
  }) =>
      UpgradeReadiness.of(
        type,
        buildings: nemo.buildings,
        resources: nemo.resources,
        worksite: nemo.worksite,
        capturedBaseTypes: captured,
      );

  test('a free worksite, the costs paid and the prerequisites met: ready',
      () {
    final readiness = readinessOf(player(), farm);
    expect(readiness.siteFree, isTrue);
    expect(readiness.isReady, isTrue);
    expect(readiness.isLocked, isFalse);
  });

  test('no worksite left this turn: not ready, though not locked', () {
    final nemo = player()..worksite.upgrades = 1;
    final readiness = readinessOf(nemo, farm);
    expect(readiness.siteFree, isFalse);
    expect(readiness.check.canUpgrade, isTrue);
    expect(readiness.isReady, isFalse);
    expect(readiness.isLocked, isFalse);
  });

  test('too poor to pay: not ready, though not locked', () {
    final nemo = player()..resources[ResourceType.coral]!.amount = 0;
    final readiness = readinessOf(nemo, farm);
    expect(readiness.isReady, isFalse);
    expect(readiness.isLocked, isFalse);
  });

  test('a prerequisite missing: not ready and locked', () {
    final nemo = player()..buildings[farm]!.level = 2;
    final readiness = readinessOf(nemo, farm);
    expect(readiness.check.missingPrerequisites, {hq: 4});
    expect(readiness.isReady, isFalse);
    expect(readiness.isLocked, isTrue);
  });

  test('a base to capture first locks the building', () {
    final nemo = player()..buildings[hq]!.level = 5;
    final module = BuildingType.descentModule;
    expect(readinessOf(nemo, module).isLocked, isTrue);
    final captured = readinessOf(nemo, module,
        captured: {TransitionBaseType.faille});
    expect(captured.isLocked, isFalse);
    expect(captured.isReady, isTrue);
  });

  test('the volcanic core to capture first locks the kernel', () {
    final nemo = player()..buildings[hq]!.level = 10;
    final kernel = readinessOf(nemo, BuildingType.volcanicKernel);
    expect(kernel.check.missingPrerequisites, isEmpty);
    expect(kernel.isLocked, isTrue);
  });

  test('at its maximum level: neither ready nor locked', () {
    final nemo = player()..buildings[farm]!.level = 5;
    final readiness = readinessOf(nemo, farm);
    expect(readiness.check.isMaxLevel, isTrue);
    expect(readiness.isReady, isFalse);
    expect(readiness.isLocked, isFalse);
  });

  test('a discount lowers the costs it checks', () {
    final nemo = player()
      ..buildings[hq]!.level = 0
      ..resources[ResourceType.coral]!.amount = 50
      ..resources[ResourceType.ore]!.amount = 40;
    UpgradeReadiness withDiscount(int percent) => UpgradeReadiness.of(
          hq,
          buildings: nemo.buildings,
          resources: nemo.resources,
          worksite: nemo.worksite,
          discountPercent: percent,
        );
    expect(withDiscount(0).isReady, isFalse);
    expect(withDiscount(20).isReady, isTrue);
  });
}

import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/garrison_kernel_action.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import 'volcano_test_helper.dart';

void main() {
  test('moves units of the volcano level into the garrison', () {
    final player = volcanoPlayer(onVolcano: {UnitType.harpoonist: 10});
    final game = volcanoGame(player);
    final result = GarrisonKernelAction(
      selectedUnits: {UnitType.harpoonist: 6},
    ).execute(game, player);
    expect(result.isSuccess, isTrue);
    expect(KernelGarrison.of(player), {UnitType.harpoonist: 6});
    expect(player.unitsOnLevel(3)[UnitType.harpoonist]!.count, 4);
  });

  test('withdraws units back to the volcano level', () {
    final player = volcanoPlayer(garrison: {UnitType.guardian: 5});
    final game = volcanoGame(player);
    GarrisonKernelAction(
      selectedUnits: {UnitType.guardian: 2},
      withdraw: true,
    ).execute(game, player);
    expect(KernelGarrison.sizeOf(player), 3);
    expect(player.unitsOnLevel(3)[UnitType.guardian]!.count, 2);
  });

  test('refuses more units than there are', () {
    final player = volcanoPlayer(onVolcano: {UnitType.harpoonist: 1});
    final result = GarrisonKernelAction(
      selectedUnits: {UnitType.harpoonist: 2},
    ).validate(volcanoGame(player), player);
    expect(result.isSuccess, isFalse);
  });

  test('refuses while the kernel is not captured', () {
    final player = volcanoPlayer(onVolcano: {UnitType.harpoonist: 4});
    final result = GarrisonKernelAction(
      selectedUnits: {UnitType.harpoonist: 2},
    ).validate(volcanoGame(player, captured: false), player);
    expect(result.reason, ActionFailure.kernelNotCaptured);
  });
}

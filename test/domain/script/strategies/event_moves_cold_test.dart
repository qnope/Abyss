import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/army_planner.dart';
import 'package:abyss/domain/script/strategies/event_moves.dart';
import 'package:abyss/domain/script/strategies/growth_moves.dart';
import 'package:abyss/domain/script/strategies/recruit_moves.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../event/event_test_helper.dart';
import 'event_moves_test_helper.dart';

/// Turn of a cold current for a base whose farms make about 230 algae,
/// fed to [guardians], with [algae] in stock and Solar Panels at [solar].
ScriptTurn _cold({int guardians = 0, int algae = 0, int solar = 15}) {
  final player = producingPlayer();
  player.buildings[BuildingType.solarPanel]!.level = solar;
  player.unitsOnLevel(1)[UnitType.guardian]!.count = guardians;
  player.resources[ResourceType.algae]!.amount = algae;
  return choiceTurn(player, RandomEventType.coldCurrent);
}

bool? _choice(ScriptTurn turn) {
  turn.chooseEvent(const ArmyPlanner());
  return choiceOf(turn.player);
}

void main() {
  const int heating = EventRules.heatingEnergyPerTurn;

  test('the farms are heated when the cut would starve the units', () {
    final turn = _cold(guardians: 70, algae: 100);
    expect(turn.algaeMargin, greaterThan(0));
    expect(turn.energyMargin, greaterThanOrEqualTo(heating));
    expect(_choice(turn), isTrue);
    expect(turn.player.eventState.heating, isTrue);
  });

  test('endured when the margin stays fine under the cut, whatever the '
      'energy', () {
    final turn = _cold(solar: 25);
    expect(turn.energyMargin, greaterThan(10 * heating));
    expect(_choice(turn), isFalse);
    expect(turn.player.eventState.heating, isFalse);
  });

  test('endured when the stock feeds the units through the three turns', () {
    expect(_choice(_cold(guardians: 70, algae: 400)), isFalse);
  });

  test('endured when the energy margin cannot pay the heating', () {
    final turn = _cold(guardians: 70, algae: 100, solar: 1);
    expect(turn.energyMargin, lessThan(heating));
    expect(_choice(turn), isFalse);
  });
}

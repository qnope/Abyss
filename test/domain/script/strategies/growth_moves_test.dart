import 'dart:math';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/growth_moves.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:flutter_test/flutter_test.dart';

ScriptTurn _turn() => ScriptTurn(
  game: GameFactory.newSinglePlayer(playerName: 'p', mapSeed: 5),
  random: Random(1),
  log: <ScriptLogEntry>[],
);

void main() {
  test('the energy margin counts the heating of the farms', () {
    final ScriptTurn calm = _turn();
    final ScriptTurn heated = _turn();
    heated.player.eventState
      ..activate(RandomEventType.coldCurrent, untilTurn: heated.game.turn)
      ..heating = true;
    expect(
      heated.energyMargin,
      calm.energyMargin - EventRules.heatingEnergyPerTurn,
    );
  });

  group('research with a plan of its own', () {
    ScriptTurn labTurn() {
      final ScriptTurn turn = _turn();
      turn.player.buildings[BuildingType.laboratory]!.level = 2;
      for (final r in turn.player.resources.values) {
        r.amount = 0;
      }
      return turn;
    }

    const plan = <TechBranch>[TechBranch.explorer, TechBranch.resources];

    test('skips an Explorer node it cannot pay and goes on', () {
      final ScriptTurn turn = labTurn();
      turn.player.resources[ResourceType.coral]!.amount = 1000;
      turn.player.resources[ResourceType.algae]!.amount = 1000;

      turn.research(plan: plan);

      expect(turn.player.techBranches[TechBranch.explorer]!.unlocked, isFalse);
      expect(
          turn.player.techBranches[TechBranch.resources]!.researchLevel, 1);
    });

    test('a lab too low still stops the plan', () {
      final ScriptTurn turn = labTurn();
      turn.player.buildings[BuildingType.laboratory]!.level = 1;
      for (final r in turn.player.resources.values) {
        r.amount = 1000;
      }
      turn.player.techBranches[TechBranch.explorer]!
        ..unlocked = true
        ..researchLevel = 1;

      turn.research(plan: const [
        TechBranch.explorer,
        TechBranch.explorer,
        TechBranch.resources,
      ]);

      expect(turn.player.techBranches[TechBranch.explorer]!.researchLevel, 1);
      expect(turn.player.techBranches[TechBranch.resources]!.unlocked, isFalse);
    });

    test('the default plan still waits for what it cannot pay', () {
      final ScriptTurn turn = labTurn();
      turn.player.resources[ResourceType.ore]!.amount = 1000;
      turn.player.resources[ResourceType.energy]!.amount = 1000;

      turn.research();

      expect(
          turn.player.techBranches[TechBranch.resources]!.unlocked, isFalse);
      expect(turn.player.techBranches[TechBranch.military]!.unlocked, isFalse);
    });
  });
}

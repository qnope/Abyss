import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_brain.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_scouting.dart';
import 'package:abyss/domain/faction/faction_traits.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/strategies/scout_moves.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/base_attack_helper.dart';
import '../../helpers/faction_war_helper.dart';

/// A war slot of the first faction with no scout left and rich stocks.
War _richAndBlind() {
  final war = warGame();
  station(war.attacker, horde);
  setLevel(war.attacker, BuildingType.barracks, 1);
  for (final r in war.attacker.resources.values) {
    r.amount = 5000;
  }
  return war;
}

FactionTurn _turnOf(War war) => FactionTurn(
  game: war.game,
  player: war.attacker,
  executor: ActionExecutor(),
  seeds: Random(2),
);

void main() {
  test('an expedition keeps 6 scouts deep, the Nomads 8', () {
    for (final p in FactionPersonality.values) {
      expect(
        FactionScouting.deepScoutsOf(p),
        p == FactionPersonality.currentNomads ? 8 : 6,
        reason: p.name,
      );
    }
    expect(FactionScouting.deepExplorers, 3);
  });

  test('the spy slot recruits the whole need of scouts at once', () {
    final war = _richAndBlind();
    final p = war.game.factions[0].personality;
    final wanted = _turnOf(war).scoutsWanted(
      explorers: FactionTraits.of(p).explorers,
      deepScouts: FactionScouting.deepScoutsOf(p),
      scoutsAhead: true,
    );

    war.play();

    expect(standing(war.attacker, UnitType.scout), wanted + 1,
        reason: 'the need, plus the spy of the slot');
  });

  test('a slot does not cost the exploration of the turn', () {
    final war = _richAndBlind();
    final p = war.game.factions[0].personality;

    FactionBrain(p).playTurn(_turnOf(war));

    final level1 = war.attacker.pendingExplorations
        .where((o) => o.level == 1)
        .length;
    expect(level1, FactionTraits.of(p).explorers);
  });

  test('a poor faction still keeps one scout for the spy', () {
    final war = warGame();
    station(war.attacker, horde);
    setLevel(war.attacker, BuildingType.barracks, 1);
    for (final r in war.attacker.resources.values) {
      r.amount = 0;
    }
    war.attacker.resources[ResourceType.algae]!.amount = 10;
    war.attacker.resources[ResourceType.coral]!.amount = 5;

    war.play();

    expect(standing(war.attacker, UnitType.scout), 1);
  });
}

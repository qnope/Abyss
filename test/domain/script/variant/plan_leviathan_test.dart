import 'dart:convert';

import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/variant/plan_script.dart';
import 'package:abyss/domain/script/variant/replay_variant.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../leviathan/leviathan_scene.dart';

void main() {
  final String idle = jsonEncode(<String, Object?>{
    'name': 'plan',
    'player': 'Test',
    'turns': <String, Object?>{},
  });

  AttackOutcome strike(ReplayVariant variant) {
    final war = leviathanScene();
    war.put(war.human, 1, const {
      UnitType.guardian: 60,
      UnitType.domeBreaker: 60,
    });
    war.playUntil(war.strikeTurn);
    PlanScript.fromReplay(
      idle,
      variant,
    ).playTurn(ScriptTurn(game: war.game, random: SeededRandom(5), log: []));
    return war.endTurn().report!.outcome;
  }

  test('a plan that defends holds the Faille it is warned about', () {
    expect(
      strike(const ReplayVariant(sameDice: false, defends: true)),
      AttackOutcome.repelled,
    );
  });

  test('a plan that does not defend leaves it to the guardians', () {
    expect(
      strike(const ReplayVariant(sameDice: false)),
      AttackOutcome.postTaken,
    );
  });
}

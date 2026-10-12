import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/end_turn_action_result.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/leviathan/leviathan_force.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';
import 'leviathan_scene.dart';

TurnResult _end(PostWar war) {
  final result = ActionExecutor().execute(
    EndTurnAction(random: SeededRandom(5), playFactions: false),
    war.game,
    war.human,
  );
  return (result as EndTurnActionResult).turnResult!;
}

void main() {
  test('the end of turn announces the guardians, then fights them', () {
    final war = leviathanScene();
    TurnResult result = _end(war);
    expect(result.announcedLeviathan, isNull);
    expect(result.leviathan, isNull);
    while (war.game.turn < war.strikeTurn - 1) {
      _end(war);
    }

    result = _end(war);
    expect(result.announcedLeviathan!.turn, war.strikeTurn);
    expect(result.announcedLeviathan!.postName, war.post.name);
    expect(result.leviathan, isNull);

    result = _end(war);
    final report = result.leviathan!;
    expect(report.attackerName, LeviathanForce.attackerName);
    expect(report.outcome, AttackOutcome.postTaken);
    expect(result.attacks, contains(report));
    expect(war.human.buildings[BuildingType.descentModule]!.level, 0);
    expect(war.post.capturedBy, isNull);
  });
}

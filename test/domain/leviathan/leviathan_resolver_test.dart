import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/leviathan/leviathan_force.dart';
import 'package:abyss/domain/leviathan/leviathan_resolver.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reinforcement_order.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';
import 'leviathan_scene.dart';

void main() {
  test('nothing is announced before the turn it strikes', () {
    final war = leviathanScene();
    expect(war.strikeTurn, war.game.turn + 3);
    expect(war.endTurn().announced, isNull);
    expect(LeviathanResolver.announcedNow(war.game), isNull);
    expect(war.endTurn().announced, isNull);
  });

  test('the end of the turn before announces it for the next one', () {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn - 1);
    final announced = war.endTurn().announced!;

    expect(war.game.turn, war.strikeTurn);
    expect(announced.turn, war.strikeTurn);
    expect(announced.postName, war.post.name);
    expect(announced.level, war.level);
    expect(announced.at, war.at);
    expect(announced.defendingLevel, war.below);
    expect(announced.force, {
      LeviathanForce.leviathanKey: 1,
      LeviathanForce.sentinelKey: LeviathanForce.sentinels,
    });
    final now = LeviathanResolver.announcedNow(war.game)!;
    expect(now.at, war.at);
    expect(now.turn, war.game.turn);
  });

  test('a strong level 2 holds the Faille', () {
    final war = leviathanScene();
    war.put(war.human, 2, wall);
    war.playUntil(war.strikeTurn);
    final report = war.endTurn().report!;

    expect(report.outcome, AttackOutcome.repelled);
    expect(report.target, AttackTarget.post);
    expect(report.attackerName, LeviathanForce.attackerName);
    expect(report.passageLost, isNull);
    expect(war.post.capturedBy, war.human.id);
    expect(war.human.buildings[BuildingType.descentModule]!.level, 2);
    final BaseAssaultEntry entry = report.entry;
    expect(entry.defending, isTrue);
    expect(entry.postName, war.post.name);
    expect(entry.turn, war.strikeTurn);
    expect(entry.units, wall);
    expect(war.human.historyEntries.last, same(entry));
    final dead = entry.dead.values.fold(0, (a, b) => a + b);
    expect(
      war.count(war.human, 2, UnitType.guardian) +
          war.count(war.human, 2, UnitType.harpoonist),
      160 - dead,
    );
    expect(LeviathanResolver.announcedNow(war.game), isNull);
    expect(war.leviathan.isScheduled, isFalse);
  });

  test('an empty level 2 loses the Faille and the Module', () {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn);
    final report = war.endTurn().report!;

    expect(report.outcome, AttackOutcome.postTaken);
    expect(report.passageLost, BuildingType.descentModule);
    expect(war.human.buildings[BuildingType.descentModule]!.level, 0);
    expect(war.post.capturedBy, isNull);
  });

  test('a weak level 2 is lost with the Faille, and so are the '
      'reinforcements on their way', () {
    final war = leviathanScene();
    war.put(war.human, 2, garrison);
    war.human.pendingReinforcements.addAll([
      ReinforcementOrder(
        fromLevel: 1,
        toLevel: 2,
        units: const {UnitType.guardian: 5},
        departTurn: 11,
        arrivalPoint: GridPosition(x: 0, y: 0),
      ),
      ReinforcementOrder(
        fromLevel: 2,
        toLevel: 3,
        units: const {UnitType.guardian: 5},
        departTurn: 11,
        arrivalPoint: GridPosition(x: 0, y: 0),
      ),
    ]);
    war.playUntil(war.strikeTurn);
    final report = war.endTurn().report!;

    expect(report.outcome, AttackOutcome.postTaken);
    expect(war.count(war.human, 2, UnitType.harpoonist), 0);
    expect(war.human.pendingReinforcements.single.toLevel, 3);
    expect(report.unitsLost, 3);
  });
}

import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/leviathan/leviathan_resolver.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';
import 'leviathan_scene.dart';

/// The scene, the Faille taken at turn 12 with no Module de descente.
PostWar _noModule() {
  final war = PostWar(TransitionBaseType.faille, humanHolds: true);
  war.human.buildings[BuildingType.descentModule] = Building(
    type: BuildingType.descentModule,
    level: 0,
  );
  LeviathanResolver.onCapture(
    war.game,
    war.human,
    base: war.post,
    level: war.level,
    at: war.at,
  );
  return war;
}

void _buildModule(PostWar war) =>
    war.human.buildings[BuildingType.descentModule]!.level = 1;

void main() {
  test('a working Module at the capture strikes 3 turns later', () {
    final war = leviathanScene();
    expect(war.leviathan.dueTurn, 15);
  });

  test('without a working Module, the strike is postponed', () {
    final war = _noModule();
    expect(war.leviathan.isScheduled, isTrue);
    expect(war.leviathan.dueTurn, isNull);
    for (var i = 0; i < 8; i++) {
      final outcome = war.endTurn();
      expect(outcome.announced, isNull);
      expect(outcome.report, isNull);
      expect(LeviathanResolver.announcedNow(war.game), isNull);
    }
    expect(war.leviathan.isScheduled, isTrue);
  });

  test('a Module built later strikes 3 turns after it', () {
    final war = _noModule();
    war.playUntil(16);
    _buildModule(war);
    expect(war.endTurn().announced, isNull);
    expect(war.leviathan.dueTurn, 19);
    war.playUntil(18);
    expect(war.endTurn().announced!.turn, 19);
    expect(war.endTurn().report, isNotNull);
    expect(war.leviathan.isScheduled, isFalse);
  });

  test('a Module built soon after the capture keeps capture + 3', () {
    final war = _noModule();
    _buildModule(war);
    war.endTurn();
    expect(war.leviathan.dueTurn, 15);
  });

  test('a degraded Module does not count as working', () {
    final war = _noModule();
    _buildModule(war);
    war.human.buildings[BuildingType.headquarters]!.level = 1;
    expect(war.human.isDegraded(BuildingType.descentModule), isTrue);
    war.endTurn();
    expect(war.leviathan.dueTurn, isNull);
  });

  test('a Module working while the Faille is lost does not count', () {
    final war = _noModule();
    war.post.capturedBy = war.attacker.id;
    _buildModule(war);
    war.endTurn();
    expect(war.leviathan.dueTurn, isNull);
  });
}

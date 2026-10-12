import 'dart:math';

import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/leviathan/leviathan_resolver.dart';
import 'package:abyss/domain/leviathan/leviathan_return.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';
import '../action/attack_transition_base_helper.dart';

const Map<UnitType, int> _army = {
  UnitType.abyssAdmiral: 1,
  UnitType.guardian: 30,
  UnitType.harpoonist: 30,
};

bool _capture(Game game, Player player) =>
    AttackTransitionBaseAction(
      targetX: 1,
      targetY: 1,
      level: 1,
      selectedUnits: _army,
      random: Random(42),
    ).execute(game, player).isSuccess &&
    game.levels[1]!.cellAt(1, 1).transitionBase!.capturedBy == player.id;

void main() {
  test('a new game can still get the counter-attack', () {
    final scene = createAttackScenario();
    expect(scene.game.leviathanReturn!.isAvailable, isTrue);
    expect(scene.game.leviathanReturn!.isScheduled, isFalse);
  });

  test('the first Faille taken by the human strikes back 3 turns later', () {
    final scene = createAttackScenario(stock: _army);
    scene.game.turn = 9;
    expect(_capture(scene.game, scene.player), isTrue);

    final LeviathanReturn state = scene.game.leviathanReturn!;
    expect(LeviathanReturn.delay, 3);
    expect(state.isScheduled, isTrue);
    expect(state.isAvailable, isFalse);
    expect(state.strikeTurn, 12);
    expect(state.postName, 'Faille');
    expect(state.level, 1);
    expect(state.at, GridPosition(x: 1, y: 1));
  });

  test('a Cheminée taken does not bring the guardians back', () {
    final scene = createAttackScenario(
      baseType: TransitionBaseType.cheminee,
      stock: const {
        UnitType.abyssAdmiral: 1,
        UnitType.guardian: 60,
        UnitType.domeBreaker: 60,
      },
    );
    AttackTransitionBaseAction(
      targetX: 1,
      targetY: 1,
      level: 1,
      selectedUnits: const {
        UnitType.abyssAdmiral: 1,
        UnitType.guardian: 60,
        UnitType.domeBreaker: 60,
      },
      random: Random(42),
    ).execute(scene.game, scene.player);
    final base = scene.game.levels[1]!.cellAt(1, 1).transitionBase!;
    expect(base.capturedBy, scene.player.id);
    expect(scene.game.leviathanReturn!.isAvailable, isTrue);
  });

  test('only the first capture schedules it, once per game', () {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    final state = war.game.leviathanReturn!;
    LeviathanResolver.onCapture(
      war.game,
      war.human,
      base: war.post,
      level: war.level,
      at: war.at,
    );
    final int strike = state.strikeTurn!;
    state.end();
    war.game.turn += 10;
    LeviathanResolver.onCapture(
      war.game,
      war.human,
      base: war.post,
      level: war.level,
      at: war.at,
    );
    expect(state.strikeTurn, strike);
    expect(state.isScheduled, isFalse);
  });

  test('a faction taking a Faille never gets it', () {
    final war = PostWar(TransitionBaseType.faille);
    LeviathanResolver.onCapture(
      war.game,
      war.owner,
      base: war.post,
      level: war.level,
      at: war.at,
    );
    expect(war.game.leviathanReturn!.isAvailable, isTrue);
  });

  test('a game saved before the counter-attack never gets it', () {
    final scene = createAttackScenario(stock: _army);
    scene.game.leviathanReturn = null;
    expect(_capture(scene.game, scene.player), isTrue);
    expect(scene.game.leviathanReturn, isNull);
    expect(LeviathanResolver.announcedNow(scene.game), isNull);
    final outcome = LeviathanResolver.resolve(scene.game);
    expect(outcome.report, isNull);
    expect(outcome.announced, isNull);
  });
}

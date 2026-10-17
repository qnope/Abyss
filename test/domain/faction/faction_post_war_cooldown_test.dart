import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/faction/faction_post_war.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';

/// The human holds the Faille, the faction stands ready; it last attacked
/// the human's posts [ago] turns before (never when `null`).
PostWar _scene({int? ago}) {
  final war = PostWar(TransitionBaseType.faille, humanHolds: true)
    ..game.turn = 40;
  war.arm(war.attacker);
  if (ago != null) {
    war.attacker.raidState.postAttackTurns[war.human.id] = 40 - ago;
  }
  return war;
}

bool _play(PostWar war) => FactionPostWar.play(
  FactionTurn(
    game: war.game,
    player: war.attacker,
    executor: ActionExecutor(),
    seeds: Random(2),
  ),
  const ArmyPlanner(),
);

/// Another Faille of level 1, given to the second faction and shown to
/// the attacker.
TransitionBase _secondPost(PostWar war) {
  final map = war.game.levels[war.level]!;
  final rival = war.game.players[war.game.factions[1].id]!;
  for (var y = 0; y < map.height; y++) {
    for (var x = 0; x < map.width; x++) {
      final base = map.cellAt(x, y).transitionBase;
      if (base == null || base == war.post) continue;
      if (base.type != TransitionBaseType.faille) continue;
      base.capturedBy = rival.id;
      rival.buildings[war.passage] = war.human.buildings[war.passage]!;
      war.attacker.addRevealedCell(war.level, GridPosition(x: x, y: y));
      return base;
    }
  }
  throw StateError('a single Faille');
}

void main() {
  test('it leaves alone a post of the human on cooldown', () {
    final war = _scene(ago: 3);

    expect(_play(war), isFalse);
    expect(war.post.capturedBy, war.human.id);
    expect(war.attacker.historyEntries.whereType<BaseAssaultEntry>(), isEmpty);
  });

  test('it turns to another target instead of wasting the turn', () {
    final war = _scene(ago: 1);
    final other = _secondPost(war);

    expect(_play(war), isTrue);
    expect(war.post.capturedBy, war.human.id);
    expect(other.capturedBy, war.attacker.id);
  });

  test('it takes the post of the human again once the cooldown is over', () {
    final war = _scene(ago: 4);

    expect(_play(war), isTrue);
    expect(war.post.capturedBy, war.attacker.id);
    expect(war.attacker.raidState.postAttackTurns, {war.human.id: 40});
  });
}

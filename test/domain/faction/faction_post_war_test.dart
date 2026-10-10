import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/faction/faction_war.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';

PostWar _scene(TransitionBaseType kind) {
  final war = PostWar(kind);
  while (!FactionWar.isDue(war.game.turn, war.game.factions[0].personality)) {
    war.game.turn++;
  }
  return war;
}

void _play(PostWar war) => FactionWar.play(
  FactionTurn(
    game: war.game,
    player: war.attacker,
    executor: ActionExecutor(),
    seeds: Random(2),
  ),
  war.game.factions[0].personality,
);

void main() {
  for (final kind in TransitionBaseType.values) {
    test('a faction takes a weakly held ${kind.name} it has seen', () {
      final war = _scene(kind);
      war.arm(war.attacker);
      war.put(war.owner, war.below, garrison);

      _play(war);

      expect(war.post.capturedBy, war.attacker.id);
      expect(war.owner.buildings[war.passage]!.level, 0);
      expect(
        war.owner.historyEntries.whereType<BaseAssaultEntry>(),
        hasLength(1),
      );
    });
  }

  test('it leaves a post whose defence it would not beat', () {
    final war = _scene(TransitionBaseType.faille);
    war.arm(war.attacker, {UnitType.harpoonist: 6});
    war.put(war.owner, 2, wall);

    _play(war);

    expect(war.post.capturedBy, war.owner.id);
    expect(war.attacker.historyEntries.whereType<BaseAssaultEntry>(), isEmpty);
  });

  test('it ignores a post its fog has not shown', () {
    final war = _scene(TransitionBaseType.faille);
    war.arm(war.attacker);
    war.attacker.revealedCellsPerLevel[1] = [];

    _play(war);

    expect(war.post.capturedBy, war.owner.id);
  });

  test('it does not attack its own post', () {
    final war = _scene(TransitionBaseType.faille);
    war.arm(war.attacker);
    war.post.capturedBy = war.attacker.id;

    _play(war);

    expect(war.attacker.historyEntries.whereType<BaseAssaultEntry>(), isEmpty);
  });

  test('a post of the human falls at once, without announcement', () {
    final war = _scene(TransitionBaseType.faille);
    war.arm(war.attacker);
    war.post.capturedBy = war.human.id;
    war.human.buildings[war.passage] = war.owner.buildings[war.passage]!;
    final Player human = war.human;

    _play(war);

    expect(war.post.capturedBy, war.attacker.id);
    expect(human.raidState.attacks, isEmpty);
    final entry = human.historyEntries.whereType<BaseAssaultEntry>().single;
    expect(entry.defending, isTrue);
    expect(entry.postName, war.post.name);
  });
}

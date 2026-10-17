import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/faction/faction_post_war.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';

/// Counts the posts the faction weighs before it attacks.
class _Counting extends ArmyPlanner {
  int weighed = 0;

  @override
  bool wins(
    Map<UnitType, int> army,
    List<Combatant> Function() enemy, {
    UnitBoost boost = UnitBoost.none,
    List<Combatant> Function()? allies,
    bool needsAdmiral = false,
  }) {
    weighed++;
    return super.wins(
      army,
      enemy,
      boost: boost,
      allies: allies,
      needsAdmiral: needsAdmiral,
    );
  }
}

/// The human holds the Faille, the faction stands ready; the human lost a
/// post [ago] turns before.
PostWar _scene(int Function(PostWar) ago) {
  final war = PostWar(TransitionBaseType.faille)..game.turn = 40;
  war.arm(war.attacker);
  war.post.capturedBy = war.human.id;
  war.human.buildings[war.passage] = war.owner.buildings[war.passage]!;
  war.human.raidState.postLostTurn = war.game.turn - ago(war);
  return war;
}

bool _play(PostWar war, ArmyPlanner planner) => FactionPostWar.play(
  FactionTurn(
    game: war.game,
    player: war.attacker,
    executor: ActionExecutor(),
    seeds: Random(2),
  ),
  planner,
);

void main() {
  test('it does not even weigh a spaced post of the human', () {
    final war = _scene((w) => w.game.difficulty.postGap - 1);
    final planner = _Counting();

    expect(_play(war, planner), isFalse);
    expect(planner.weighed, 0);
    expect(war.post.capturedBy, war.human.id);
    expect(war.attacker.historyEntries.whereType<BaseAssaultEntry>(), isEmpty);
  });

  test('it takes the post of the human again once the gap is over', () {
    final war = _scene((w) => w.game.difficulty.postGap);

    expect(_play(war, _Counting()), isTrue);
    expect(war.post.capturedBy, war.attacker.id);
    expect(war.human.raidState.postLostTurn, 40);
  });
}

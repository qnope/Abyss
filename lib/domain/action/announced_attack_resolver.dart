import 'dart:math';

import '../game/game.dart';
import '../game/player.dart';
import '../raid/announced_attack.dart';
import '../raid/raid_battle.dart';
import '../replay/seeded_random.dart';
import '../unit/unit_type.dart';
import 'attack_base_action.dart';
import 'attack_base_result.dart';

/// End-of-turn step that fights the attacks announced for the turn that
/// ends, with the units the human holds on the base level right now.
///
/// It is not an action of the journal: the announcement already is, and
/// the fight follows from the state and the announced seed, so a replay
/// that never asks a brain fights the very same battles. Each fight is an
/// [AttackBaseAction], so the rules, the history of both sides, the
/// pillage and the damage to the base are those of any attack on a base.
abstract final class AnnouncedAttackResolver {
  /// The results of the attacks fought, in the order they were announced.
  static List<AttackBaseResult> resolve(Game game) {
    final Player human = game.humanPlayer;
    final List<AnnouncedAttack> due = <AnnouncedAttack>[
      for (final AnnouncedAttack a in human.raidState.attacks)
        if (a.arrivalTurn <= game.turn) a,
    ];
    human.raidState.attacks.removeWhere(due.contains);
    final List<AttackBaseResult> results = <AttackBaseResult>[];
    for (final AnnouncedAttack a in due) {
      final AttackBaseResult? result = _fight(game, human, a);
      if (result != null) results.add(result);
    }
    return results;
  }

  static AttackBaseResult? _fight(
    Game game,
    Player human,
    AnnouncedAttack attack,
  ) {
    final Player? attacker = game.players[attack.attackerId];
    if (attacker == null || attacker.hasFallen) return null;
    final AttackBaseAction action = AttackBaseAction(
      targetPlayerId: human.id,
      selectedUnits: _stillThere(attacker, attack.units),
      random: SeededRandom(attack.seed),
    );
    final result = action.execute(game, attacker);
    if (result is! AttackBaseResult || !result.isSuccess) return null;
    attacker.addHistoryEntry(
      action.makeHistoryEntry(game, attacker, result, game.turn)!,
    );
    attacker.raidState.addNoise(action.noiseMade(attacker));
    return result;
  }

  /// The announced army, less the units the attacker lost since.
  static Map<UnitType, int> _stillThere(
    Player attacker,
    Map<UnitType, int> announced,
  ) => <UnitType, int>{
    for (final MapEntry<UnitType, int> e in announced.entries)
      e.key: min(
        e.value,
        attacker.unitsOnLevel(RaidBattle.baseLevel)[e.key]!.count,
      ),
  };
}

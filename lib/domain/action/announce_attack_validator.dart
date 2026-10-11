import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../raid/announced_attack.dart';
import '../raid/raid_state.dart';
import '../unit/unit_type.dart';
import 'action_failure.dart';
import 'attack_base_validator.dart';

/// The rules that say whether a faction may announce an attack on the
/// human for the end of turn [arrivalTurn].
abstract final class AnnounceAttackValidator {
  static ActionFailure? check(
    Game game,
    Player player,
    Map<UnitType, int> army, {
    required int arrivalTurn,
  }) {
    final Player human = game.humanPlayer;
    final ActionFailure? failure = AttackBaseValidator.check(
      game,
      player,
      human.id,
      army,
    );
    if (failure != null) return failure;
    final RaidState state = human.raidState;
    if (state.hasAttackFrom(player.id)) {
      return ActionFailure.attackAlreadyAnnounced;
    }
    if (arrivalTurn - _lastAttack(human) < game.difficulty.attackGap) {
      return ActionFailure.attackTooSoon;
    }
    // A monster raid already fixed for that turn keeps the human busy.
    if (state.isIncoming && state.arrivalTurn == arrivalTurn) {
      return ActionFailure.raidSameTurn;
    }
    return null;
  }

  /// The turn of the latest attack on the base, announced or fought;
  /// minus infinity-ish when there was none.
  static int _lastAttack(Player human) {
    int last = -1000;
    for (final AnnouncedAttack a in human.raidState.attacks) {
      if (a.arrivalTurn > last) last = a.arrivalTurn;
    }
    for (final HistoryEntry e in human.historyEntries) {
      if (e is BaseAssaultEntry &&
          e.defending &&
          e.postName == null &&
          e.turn > last) {
        last = e.turn;
      }
    }
    return last;
  }
}

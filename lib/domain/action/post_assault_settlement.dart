import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/transition_base.dart';
import 'attack_base_entries.dart';
import 'attack_base_result.dart';
import 'post_takeover.dart';

/// The end of an attack on a post: the takeover ([PostTakeover]) when the
/// attacker won, then the report its [owner] keeps of the fight.
abstract final class PostAssaultSettlement {
  /// Settles [result] of [attackerName]'s attack on [post], held by
  /// [owner], during [turn]: [attacker] takes it on a win (`null` for the
  /// guardians, who guard it again). Returns the owner's entry, already
  /// in its history.
  static BaseAssaultEntry settle({
    required int turn,
    required TransitionBase post,
    required Player? attacker,
    required String attackerName,
    required Player owner,
    required AttackBaseResult result,
  }) {
    final PostLoss lost =
        result.victory
            ? PostTakeover.apply(post: post, attacker: attacker, owner: owner)
            : PostLoss.none;
    if (result.victory) owner.raidState.postLostTurn = turn;
    final BaseAssaultEntry entry = AttackBaseEntries.forDefender(
      turn,
      attackerName,
      result,
      postName: post.name,
      lostWithPost: lost.units,
      passageDestroyed: lost.passage,
    );
    owner.addHistoryEntry(entry);
    return entry;
  }
}

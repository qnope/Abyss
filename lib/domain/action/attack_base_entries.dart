import '../history/history_entry.dart';
import '../unit/unit_type.dart';
import 'attack_base_result.dart';

/// The two history entries of an attack on a base, or on a post when
/// [postName] is given: one for each side.
abstract final class AttackBaseEntries {
  /// The entry of the attacker, who sent [AttackBaseResult.sent].
  static BaseAssaultEntry forAttacker(
    int turn,
    String defenderName,
    AttackBaseResult r, {
    String? postName,
  }) => _entry(turn, defenderName, r, defending: false, postName: postName);

  /// The entry of the defender, who fielded the base's units and lost
  /// [lostWithPost] with the post or the kernel taken, and the passage
  /// building of the post when [passageDestroyed].
  static BaseAssaultEntry forDefender(
    int turn,
    String attackerName,
    AttackBaseResult r, {
    String? postName,
    Map<UnitType, int> lostWithPost = const {},
    bool passageDestroyed = true,
  }) => _entry(
    turn,
    attackerName,
    r,
    defending: true,
    postName: postName,
    lostWithPost: lostWithPost,
    passageDestroyed: passageDestroyed,
  );

  static BaseAssaultEntry _entry(
    int turn,
    String opponentName,
    AttackBaseResult r, {
    required bool defending,
    String? postName,
    Map<UnitType, int> lostWithPost = const {},
    bool passageDestroyed = true,
  }) => BaseAssaultEntry(
    turn: turn,
    victory: r.victory,
    defending: defending,
    opponentName: opponentName,
    fightResult: r.fight!,
    units: defending ? r.defence.engaged : r.sent,
    survivorsIntact: defending ? r.defence.survivorsIntact : r.survivorsIntact,
    wounded: defending ? r.defence.wounded : r.wounded,
    dead: defending ? r.defence.dead : r.dead,
    rampartBefore: r.damage.rampartBefore,
    rampartAfter: r.damage.rampartAfter,
    headquartersBefore: r.damage.headquartersBefore,
    headquartersAfter: r.damage.headquartersAfter,
    pillaged: r.damage.pillaged,
    loot: r.damage.loot,
    postName: postName,
    lostWithPost: lostWithPost,
    passageDestroyed: passageDestroyed,
  );
}

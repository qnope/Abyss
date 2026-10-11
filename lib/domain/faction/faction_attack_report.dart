import '../action/attack_held_kernel_action.dart';
import '../action/post_takeover.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/transition_base_name.dart';
import 'faction.dart';
import 'faction_personality.dart';

/// What a faction attacked: the human base, one of its posts (a Faille or
/// a Cheminée), or the volcanic kernel it holds.
enum AttackTarget { base, post, kernel }

/// How an attack on the human ended, from the human's side: the base
/// razed, losing part of its stocks or not, the post taken, the kernel
/// down one level or taken.
enum AttackOutcome {
  repelled,
  damaged,
  pillaged,
  postTaken,
  kernelDamaged,
  kernelTaken,
}

/// An attack of a player on the human, reported at the end of a turn:
/// who attacked and the human's own report of the fight.
class FactionAttackReport {
  final String attackerId;
  final String attackerName;

  /// `null` when the attacker is not one of the game's factions.
  final FactionPersonality? personality;

  /// The report of the defender, readable on the assault screen.
  final BaseAssaultEntry entry;

  const FactionAttackReport({
    required this.attackerId,
    required this.attackerName,
    required this.personality,
    required this.entry,
  });

  /// The report of [attacker]'s attack in the human's [entry].
  factory FactionAttackReport.of(
    Game game,
    Player attacker,
    BaseAssaultEntry entry,
  ) => FactionAttackReport(
    attackerId: attacker.id,
    attackerName: attacker.name,
    personality:
        <FactionPersonality>[
          for (final Faction f in game.factions)
            if (f.id == attacker.id) f.personality,
        ].firstOrNull,
    entry: entry,
  );

  AttackTarget get target => switch (entry.postName) {
    null => AttackTarget.base,
    AttackHeldKernelAction.kernelCode => AttackTarget.kernel,
    _ => AttackTarget.post,
  };

  AttackOutcome get outcome {
    if (!entry.victory) return AttackOutcome.repelled;
    return switch (target) {
      AttackTarget.post => AttackOutcome.postTaken,
      AttackTarget.kernel =>
        entry.rampartAfter == 0
            ? AttackOutcome.kernelTaken
            : AttackOutcome.kernelDamaged,
      AttackTarget.base =>
        entry.pillaged.values.any((int n) => n > 0)
            ? AttackOutcome.pillaged
            : AttackOutcome.damaged,
    };
  }

  /// The post attacked; `null` for the base, the kernel or a post whose
  /// name no map generates.
  TransitionBaseName? get post =>
      target == AttackTarget.post
          ? TransitionBaseName.parse(entry.postName!)
          : null;

  /// The passage building destroyed with the post taken, if any.
  BuildingType? get passageLost {
    final TransitionBaseName? post = this.post;
    if (post == null || !entry.victory) return null;
    return PostTakeover.passageOf(post.type);
  }

  /// The level whose units are lost with the post, if it is one.
  int? get levelBelow => post?.targetLevel;

  /// How many units the human lost with the post or the kernel taken:
  /// those killed defending it and those lost with it; 0 when it held.
  int get unitsLost => switch (outcome) {
    AttackOutcome.postTaken ||
    AttackOutcome.kernelTaken => _sum(entry.dead) + _sum(entry.lostWithPost),
    _ => 0,
  };

  static int _sum(Map<Object, int> units) =>
      units.values.fold<int>(0, (int a, int b) => a + b);
}

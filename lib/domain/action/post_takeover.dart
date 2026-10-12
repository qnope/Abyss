import '../building/building_type.dart';
import '../game/player.dart';
import '../map/transition_base.dart';
import '../map/transition_base_type.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'post_loss.dart';

export 'post_loss.dart';

/// What a won attack does to a post: its passage building is destroyed,
/// the units its owner kept on the level below are lost with it, and the
/// attacker holds the post, empty until it builds a passage of its own.
/// Without attacker (the guardians coming back), the monsters guard it
/// again.
abstract final class PostTakeover {
  /// The building that opens [type]: the Module de descente for a Faille,
  /// the Capsule pressurisée for a Cheminée.
  static BuildingType passageOf(TransitionBaseType type) =>
      type == TransitionBaseType.faille
          ? BuildingType.descentModule
          : BuildingType.pressureCapsule;

  /// Whether [player] built the passage of [type]: below level 1, nobody
  /// can go down through the post yet.
  static bool passageBuilt(Player player, TransitionBaseType type) =>
      (player.buildings[passageOf(type)]?.level ?? 0) > 0;

  /// Whether units of [player] can go down through a post of [type]: its
  /// passage built and not degraded.
  static bool passageWorks(Player player, TransitionBaseType type) =>
      passageBuilt(player, type) && !player.isDegraded(passageOf(type));

  /// Applies the takeover; returns what the owner lost with the post.
  static PostLoss apply({
    required TransitionBase post,
    required Player? attacker,
    required Player owner,
  }) {
    final bool passage = passageBuilt(owner, post.type);
    owner.buildings[passageOf(post.type)]?.level = 0;
    final Map<UnitType, Unit> below =
        owner.unitsPerLevel[post.targetLevel] ?? const <UnitType, Unit>{};
    final Map<UnitType, int> lost = <UnitType, int>{
      for (final MapEntry<UnitType, Unit> e in below.entries)
        if (e.value.count > 0) e.key: e.value.count,
    };
    for (final Unit unit in below.values) {
      unit.count = 0;
    }
    owner.pendingReinforcements.removeWhere(
      (o) => o.toLevel == post.targetLevel,
    );
    post.capturedBy = attacker?.id;
    return PostLoss(units: lost, passage: passage);
  }
}

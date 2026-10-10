import '../building/building_type.dart';
import '../game/player.dart';
import '../map/transition_base.dart';
import '../map/transition_base_type.dart';
import '../unit/unit.dart';

/// What a won attack does to a post: its passage building is destroyed,
/// the units its owner kept on the level below are lost with it, and the
/// attacker holds the post, empty until it builds a passage of its own.
abstract final class PostTakeover {
  /// The building that opens [type]: the Module de descente for a Faille,
  /// the Capsule pressurisée for a Cheminée.
  static BuildingType passageOf(TransitionBaseType type) =>
      type == TransitionBaseType.faille
          ? BuildingType.descentModule
          : BuildingType.pressureCapsule;

  static void apply({
    required TransitionBase post,
    required Player attacker,
    required Player owner,
  }) {
    owner.buildings[passageOf(post.type)]?.level = 0;
    final Iterable<Unit>? lost = owner.unitsPerLevel[post.targetLevel]?.values;
    for (final Unit unit in lost ?? const <Unit>[]) {
      unit.count = 0;
    }
    owner.pendingReinforcements.removeWhere(
      (o) => o.toLevel == post.targetLevel,
    );
    post.capturedBy = attacker.id;
  }
}

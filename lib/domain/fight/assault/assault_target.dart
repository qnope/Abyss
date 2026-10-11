import '../../action/post_takeover.dart';
import '../../building/building_type.dart';
import '../../game/game.dart';
import '../../map/cell_content_type.dart';
import '../../map/transition_base_type.dart';
import '../../map/volcano_footprint.dart';
import '../combatant.dart';
import '../guardian_factory.dart';

/// What an assault led by an Abyss Admiral can capture.
enum AssaultTarget {
  faille,
  cheminee,
  kernel;

  /// The guardians the assault fights, fresh at each call.
  List<Combatant> guardians() => switch (this) {
        faille => GuardianFactory.forType(TransitionBaseType.faille),
        cheminee => GuardianFactory.forType(TransitionBaseType.cheminee),
        kernel => GuardianFactory.forVolcanicKernel(),
      };

  /// The building that opens the way down once captured; `null` for the
  /// kernel, which opens nothing.
  BuildingType? get passage => switch (this) {
        faille => PostTakeover.passageOf(TransitionBaseType.faille),
        cheminee => PostTakeover.passageOf(TransitionBaseType.cheminee),
        kernel => null,
      };

  /// The target still to capture at ([x], [y]) on [level] of [game], any
  /// cell of the volcano meaning the kernel; `null` when there is none.
  static AssaultTarget? at(Game game, int level, int x, int y) {
    final map = game.levels[level];
    if (map == null) return null;
    final anchor = VolcanoFootprint.anchorOf(map, x, y);
    if (anchor != null) {
      final kernel = map.cellAt(anchor.x, anchor.y);
      return kernel.isCollected ? null : AssaultTarget.kernel;
    }
    final cell = map.cellAt(x, y);
    final base = cell.transitionBase;
    if (cell.content != CellContentType.transitionBase || base == null) {
      return null;
    }
    if (base.isCaptured) return null;
    return base.type == TransitionBaseType.faille ? faille : cheminee;
  }
}

import '../../../../../domain/unit/unit_type.dart';
import '../../../../extensions/unit_type_extensions.dart';
import '../map_effect.dart';
import 'fog_lift_run.dart';

/// The fog lifting from the [cells] seen at the end of a turn, each with
/// its floor tile, while the scouts waiting on [scouts], their
/// exploration over, fade away with it.
///
/// The map below already shows those cells seen: the lift covers them
/// as the fog does, their contents hidden, then fades as they fade in.
/// The [beacons], wrecks seen through the fog, stay drawn above it
/// meanwhile.
class MapFogLift extends MapEffect {
  /// The cells seen, with their floor tile (as `floorTileOf` scatters
  /// them).
  final Map<(int, int), String> cells;

  /// Cells where a scout waited for its exploration.
  final Set<(int, int)> scouts;

  /// Cells of [cells] whose content shows through the fog: a wreck not
  /// searched yet.
  final Set<(int, int)> beacons;

  @override
  final (int, int) focus;

  const MapFogLift({
    required this.cells,
    required this.focus,
    this.scouts = const {},
    this.beacons = const {},
  });

  @override
  Set<String> get imagePaths => {...cells.values, UnitType.scout.iconPath};

  @override
  MapEffectRun stage(MapStage stage) => FogLiftRun(this, stage: stage);
}

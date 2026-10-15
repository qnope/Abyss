import '../../../../../domain/unit/unit_type.dart';
import '../../../../extensions/unit_type_extensions.dart';
import '../map_effect.dart';
import 'fog_lift_run.dart';

/// The fog lifting from the [cells] seen at the end of a turn, each with
/// the sprite of its terrain, while the scouts waiting on [scouts], their
/// exploration over, fade away with it.
///
/// The still map below already shows those cells seen: the lift covers
/// them as the fog does, then fades.
class MapFogLift extends MapEffect {
  /// The cells seen, with the sprite of their terrain.
  final Map<(int, int), String> cells;

  /// Cells where a scout waited for its exploration.
  final Set<(int, int)> scouts;

  @override
  final (int, int) focus;

  const MapFogLift({
    required this.cells,
    required this.focus,
    this.scouts = const {},
  });

  @override
  Set<String> get imagePaths => {...cells.values, UnitType.scout.iconPath};

  @override
  MapEffectRun stage(MapStage stage) => FogLiftRun(this, stage: stage);
}

import '../map_effect.dart';
import 'map_siege_run.dart';
import 'siege_geometry.dart';

/// Attackers drawn with [attackerSprite] besieging the place covering
/// [span] cells across from [place] (a base, a volcano): an alert rings,
/// they close in, then a shield pushes them back on a [victory], or they
/// break in with a red flash.
class MapSiege extends MapEffect {
  final (int, int) place;
  final int span;
  final bool victory;
  final String attackerSprite;

  const MapSiege({
    required this.place,
    required this.victory,
    required this.attackerSprite,
    this.span = 1,
  });

  @override
  (int, int) get focus => place;

  @override
  Set<String> get imagePaths => {attackerSprite};

  @override
  MapEffectRun stage(MapStage stage) => MapSiegeRun(this,
      stage: stage, geometry: SiegeGeometry(place: place, span: span));
}

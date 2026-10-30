import '../map/map_projection.dart';

/// One unit of the pads' drawing, in projection units: the mockup drew
/// them for cells 48 of its pixels wide.
const basePadUnit = MapProjection.tileWidth / 48;

/// The ground a building stands on, which grows with its level.
enum BasePadTier {
  /// A surveyed plot, for a building still to build: a dashed outline
  /// and four marker stakes.
  plot,

  /// A gravel slab, levels 1 to 3.
  gravel,

  /// A riveted metal deck, its rim lit in the building's colour, levels
  /// 4 to 7.
  deck,

  /// A lit deck with corner beacons, levels 8 and up.
  litDeck;

  /// The pad of a building at [level].
  static BasePadTier ofLevel(int level) =>
      level <= 0
          ? plot
          : level <= 3
          ? gravel
          : level <= 7
          ? deck
          : litDeck;

  /// How far the pad lifts its building above the ground: its thickness,
  /// none for a plot.
  double get lift => this == plot ? 0 : (2.5 + index * 1.5) * basePadUnit;
}

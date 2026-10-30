/// A kind of decor standing on the seabed between the cells of an
/// isometric map: its sprite, how often it is drawn and how large.
///
/// Every decor sprite has a 64 × 64 frame and stands on its foot at
/// (32, 56): see [MapDecor.footRatio].
class DecorKind {
  final String svgPath;

  /// How often it is drawn, against the other kinds' weights.
  final int weight;

  /// Side of its square box, as a share of a tile's width.
  final double sizeRatio;

  const DecorKind(this.svgPath, {required this.weight, required this.sizeRatio});
}

const _folder = 'assets/icons/decor';

/// The decor of the seabed: algae and rocks often, corals and sponges
/// now and then; algae small, corals tall.
abstract final class SeabedDecor {
  static const rock =
      DecorKind('$_folder/rock.svg', weight: 4, sizeRatio: 0.5);
  static const algae =
      DecorKind('$_folder/algae.svg', weight: 5, sizeRatio: 0.4);
  static const coralPink =
      DecorKind('$_folder/coral_pink.svg', weight: 1, sizeRatio: 0.55);
  static const coralTeal =
      DecorKind('$_folder/coral_teal.svg', weight: 1, sizeRatio: 0.55);
  static const coralPurple =
      DecorKind('$_folder/coral_purple.svg', weight: 1, sizeRatio: 0.55);
  static const spongePurple =
      DecorKind('$_folder/sponge_purple.svg', weight: 1, sizeRatio: 0.48);
  static const spongeOrange =
      DecorKind('$_folder/sponge_orange.svg', weight: 1, sizeRatio: 0.48);

  /// Every kind, as [scatterDecor] draws them by default.
  static const all = [
    rock,
    algae,
    coralPink,
    coralTeal,
    coralPurple,
    spongePurple,
    spongeOrange,
  ];
}

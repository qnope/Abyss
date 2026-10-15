import '../../theme/abyss_motion.dart';
import 'sprite_motion.dart';

/// A sprite rising into place, e.g. a building whose level went up: it
/// starts a little low and small, pops up past its size and settles,
/// while a glow above it fades away.
abstract final class RiseMotion {
  static const _startScale = 0.8;
  static const _startDrop = 0.12;
  static const _startGlow = 0.7;

  /// The pose at [t], from 0 (the start) to 1 (back at rest).
  static SpriteMotion at(double t) {
    final rise = AbyssMotion.pop.transform(t.clamp(0, 1));
    return SpriteMotion(
      scale: _startScale + (1 - _startScale) * rise,
      dy: _startDrop * (1 - rise),
      glow: _startGlow * (1 - t.clamp(0, 1)),
      pivot: SpritePivot.bottom,
    );
  }
}

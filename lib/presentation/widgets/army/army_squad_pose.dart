import '../../../domain/unit/unit_type.dart';
import '../ambience/ambient_motion.dart';
import '../ambience/sprite_motion.dart';

/// How the squads of the parade ground live on the shared ambience clock,
/// as pure functions of its [seconds]: each soldier breathes and bobs a
/// little on its feet, each banner sways on the foot of its pole. Every
/// soldier and every banner has a phase of its own, so that no squad
/// moves in step.
abstract final class ArmySquadPose {
  /// Share of the ambient bob a soldier keeps: barely off the deck.
  static const _bob = .4;

  /// Share of the ambient sway a banner keeps: a gentle lean.
  static const _sway = .5;

  /// The pose of the soldier standing on slot [figure] of the squad of
  /// [type], around its feet.
  static SpriteMotion soldier(UnitType type, int figure, double seconds) {
    final phase = AmbientMotion.phaseOf(type.index, figure + 1);
    final breath = AmbientMotion.breathe.at(seconds, phase: phase);
    final bob = AmbientMotion.bob.at(seconds, phase: phase + .25);
    return SpriteMotion(
      scale: breath.scale,
      dy: _bob * bob.dy,
      pivot: SpritePivot.bottom,
    );
  }

  /// The pose of the banner of [type], around the foot of its pole.
  static SpriteMotion banner(UnitType type, double seconds) {
    final phase = AmbientMotion.phaseOf(type.index, 7);
    final sway = AmbientMotion.sway.at(seconds, phase: phase);
    return SpriteMotion(
      rotation: _sway * sway.rotation,
      pivot: SpritePivot.bottom,
    );
  }
}

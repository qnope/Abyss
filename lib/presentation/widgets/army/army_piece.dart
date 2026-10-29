import '../../../domain/unit/unit_type.dart';
import 'army_layout.dart';

/// Something standing on the parade ground, drawn over the ground in the
/// order of its [depth].
sealed class ArmyPiece {
  const ArmyPiece();

  /// Depth of the point the piece stands on, as [ArmyLayout.depthOf] gives.
  double get depth;
}

/// The barracks, standing in the back block.
final class BarracksPiece extends ArmyPiece {
  const BarracksPiece();

  /// The building fills most of its block, so it stands nearer than its
  /// centre.
  @override
  double get depth => ArmyLayout.depthOf(ArmyLayout.barracks) + 1;
}

/// The supplies stacked in the front block.
final class DepotPiece extends ArmyPiece {
  const DepotPiece();

  @override
  double get depth => ArmyLayout.depthOf(ArmyLayout.depot);
}

/// A piece that belongs to the squad of one unit type.
sealed class UnitPiece extends ArmyPiece {
  const UnitPiece(this.type);

  final UnitType type;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is UnitPiece &&
      other.type == type;

  @override
  int get hashCode => Object.hash(runtimeType, type);
}

/// The banner of a squad, at a corner of its drill pad.
final class BannerPiece extends UnitPiece {
  const BannerPiece(super.type);

  @override
  double get depth => ArmyLayout.depthOf(ArmyLayout.bannerAt(type));
}

/// The standing figures of a squad, just over its pad centre so that a
/// banner planted level with the centre stays behind them.
final class SquadPiece extends UnitPiece {
  const SquadPiece(super.type);

  @override
  double get depth => ArmyLayout.depthOf(ArmyLayout.padCentre(type)) + .01;
}

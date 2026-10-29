import '../../../domain/unit/unit_type.dart';
import '../common/back_to_front.dart' as order;
import 'army_piece.dart';

/// The order in which the standing pieces of the parade ground are drawn.
abstract final class ArmyDrawOrder {
  /// Barracks, depot, and the banner and squad of every unit type, from the
  /// back to the front. The layout is fixed, so is the order.
  static final List<ArmyPiece> backToFront = List.unmodifiable(
    order.backToFront<ArmyPiece>([
      const BarracksPiece(),
      const DepotPiece(),
      for (final type in UnitType.values) ...[
        BannerPiece(type),
        SquadPiece(type),
      ],
    ], (piece) => piece.depth),
  );
}

import 'dart:math';

import '../map/grid_position.dart';
import '../script/script_turn.dart';

/// Where a faction's scouts look first: towards the centre of the map,
/// where the posts and the human wait, and along the diagonals of its own
/// base rather than straight to the borders.
///
/// A diagonal step reveals a fresh corner of the fog, while a border is a
/// dead end that shows nothing of the others.
abstract final class FactionExploration {
  /// Worth of one cell nearer the centre than the base.
  static const double towardCentre = 0.5;

  /// Cost of one cell off the diagonal of the base.
  static const double offDiagonal = 0.3;

  /// Added to the number of fresh cells a target reveals.
  static double bias({
    required GridPosition base,
    required int width,
    required int height,
    required GridPosition target,
  }) {
    final double cx = (width - 1) / 2;
    final double cy = (height - 1) / 2;
    double fromCentre(GridPosition p) =>
        max((p.x - cx).abs(), (p.y - cy).abs());
    final double nearer = fromCentre(base) - fromCentre(target);
    final int gap =
        ((target.x - base.x).abs() - (target.y - base.y).abs()).abs();
    return towardCentre * nearer - offDiagonal * gap;
  }

  /// The bias of the faction playing [turn], for the base level.
  static double forTurn(ScriptTurn turn, GridPosition target) => bias(
    base: GridPosition(x: turn.player.baseX, y: turn.player.baseY),
    width: turn.game.levels[1]!.width,
    height: turn.game.levels[1]!.height,
    target: target,
  );
}

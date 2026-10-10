import 'dart:math';

import '../../game/game.dart';
import '../../game/player.dart';
import '../../unit/unit_type.dart';
import '../../volcano/kernel_garrison.dart';
import '../event_rules.dart';
import 'event_effect.dart';

/// Survivors who may join the base as free harpoonists: no cost, no
/// noise, and they leave the turn's recruitment open. They eat algae
/// like any unit.
class SurvivorsEffect extends EventEffect {
  const SurvivorsEffect();

  /// Survivors met at the end of [endedTurn]: [EventRules.survivorsMin],
  /// one more every [EventRules.survivorsTurnsPerExtra] turns, up to
  /// [EventRules.survivorsMax].
  static int countAt(int endedTurn) => min(
    EventRules.survivorsMax,
    EventRules.survivorsMin + endedTurn ~/ EventRules.survivorsTurnsPerExtra,
  );

  @override
  void onDraw(
    Game game,
    Player player, {
    required int turn,
    required Random random,
  }) => player.eventState.survivors = countAt(turn);

  /// Welcomed, the survivors met at the draw join the units of level 1.
  @override
  void apply(
    Game game,
    Player player, {
    required bool accept,
    required int turn,
    Random? random,
  }) {
    final int count = player.eventState.survivors ?? 0;
    if (!accept || count <= 0) return;
    KernelGarrison.stockAt(player, 1)[UnitType.harpoonist]!.count += count;
  }
}

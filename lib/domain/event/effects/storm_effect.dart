import 'dart:math';

import '../../game/game.dart';
import '../../game/player.dart';
import '../event_rules.dart';
import '../random_event_type.dart';
import 'event_effect.dart';

/// Storm, which forbids exploring for [EventRules.stormTurns] turns but
/// covers the noise: the gauge loses [EventRules.stormNoiseRelief] points
/// at once. Explorations ordered before it still resolve.
class StormEffect extends EventEffect {
  const StormEffect();

  @override
  void apply(
    Game game,
    Player player, {
    required bool accept,
    required int turn,
    Random? random,
  }) {
    player.eventState.activate(
      RandomEventType.storm,
      untilTurn: turn + EventRules.stormTurns - 1,
    );
    player.raidState.quiet(EventRules.stormNoiseRelief);
  }
}

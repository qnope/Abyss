import 'dart:math';

import '../../game/game.dart';
import '../../game/player.dart';
import '../event_rules.dart';
import '../random_event_type.dart';
import 'event_effect.dart';

/// Warm and cold currents, which change the production of
/// [EventRules.effectTurns] turns (see `EventProduction`).
///
/// Exploiting a warm current lifts the production but makes noise every
/// turn; letting it pass changes nothing. A cold current always lasts:
/// heating the farms keeps the algae for energy, enduring it costs algae.
class CurrentEffect extends EventEffect {
  /// [RandomEventType.warmCurrent] or [RandomEventType.coldCurrent].
  final RandomEventType type;

  const CurrentEffect(this.type);

  bool get _warm => type == RandomEventType.warmCurrent;

  @override
  void apply(
    Game game,
    Player player, {
    required bool accept,
    required int turn,
    Random? random,
  }) {
    if (_warm && !accept) return;
    player.eventState
      ..activate(type, untilTurn: turn + EventRules.effectTurns - 1)
      ..heating = !_warm && accept;
  }

  @override
  void onTurnEnd(Game game, Player player, {required int turn}) {
    if (_warm) player.raidState.addNoise(EventRules.warmNoisePerTurn);
  }
}

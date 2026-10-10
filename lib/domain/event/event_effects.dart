import 'dart:math';

import '../game/game.dart';
import '../game/player.dart';
import 'effects/caravan_effect.dart';
import 'effects/current_effect.dart';
import 'effects/event_effect.dart';
import 'effects/predators_effect.dart';
import 'effects/storm_effect.dart';
import 'effects/survivors_effect.dart';
import 'effects/wreck_effect.dart';
import 'random_event_type.dart';

/// Hands each step of a random event to the [EventEffect] of its type.
abstract final class EventEffects {
  /// Events that may not be drawn at the end of [endedTurn].
  static Set<RandomEventType> excludedAt(
    Game game,
    Player player,
    int endedTurn,
  ) => {
    for (final type in RandomEventType.values)
      if (!of(type).allowedAt(game, player, endedTurn)) type,
  };

  /// Prepares [type] the moment it is drawn at the end of [turn].
  static void onDraw(
    Game game,
    Player player,
    RandomEventType type, {
    required int turn,
    required Random random,
  }) => of(type).onDraw(game, player, turn: turn, random: random);

  /// Plays [type] out from [turn] (see [EventEffect.apply]).
  static void apply(
    Game game,
    Player player,
    RandomEventType type, {
    required bool accept,
    required int turn,
    Random? random,
  }) =>
      of(type).apply(game, player, accept: accept, turn: turn, random: random);

  /// Runs [EventEffect.onAnyTurnEnd] of every event at the end of [turn].
  static void endTurn(Game game, Player player, {required int turn}) {
    for (final RandomEventType type in RandomEventType.values) {
      of(type).onAnyTurnEnd(game, player, turn: turn);
    }
  }

  /// The effect of [type].
  static EventEffect of(RandomEventType type) => switch (type) {
    RandomEventType.warmCurrent => const CurrentEffect(
      RandomEventType.warmCurrent,
    ),
    RandomEventType.coldCurrent => const CurrentEffect(
      RandomEventType.coldCurrent,
    ),
    RandomEventType.wreck => const WreckEffect(),
    RandomEventType.predators => const PredatorsEffect(),
    RandomEventType.storm => const StormEffect(),
    RandomEventType.survivors => const SurvivorsEffect(),
    RandomEventType.caravan => const CaravanEffect(),
  };
}

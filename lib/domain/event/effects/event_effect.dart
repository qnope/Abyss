import 'dart:math';

import '../../game/game.dart';
import '../../game/player.dart';

/// What one random event does to a player. Every hook does nothing until
/// the event overrides it.
abstract class EventEffect {
  const EventEffect();

  /// Whether the event may be drawn at the end of [endedTurn].
  bool allowedAt(Game game, Player player, int endedTurn) => true;

  /// Prepares the event the moment it is drawn at the end of [turn], with
  /// the dice of that end of turn.
  void onDraw(
    Game game,
    Player player, {
    required int turn,
    required Random random,
  }) {}

  /// Plays the event out during [turn]. [accept] is the player's choice,
  /// `false` for the prudent option applied when the turn ended without
  /// one, and `true` for an event drawn without a choice.
  void apply(
    Game game,
    Player player, {
    required bool accept,
    required int turn,
    Random? random,
  }) {}
}

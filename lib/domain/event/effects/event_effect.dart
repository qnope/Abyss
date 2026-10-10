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

  /// Why the player may not take the first option now, or `null` when
  /// they may. The prudent option is always open.
  String? refusal(Game game, Player player) => null;

  /// Plays the event out from [turn], the first turn whose end it can
  /// still change: the turn of the choice when the player chooses, the
  /// next one when it is applied while a turn ends (that turn's
  /// production is already made). So an effect lasting n turns from
  /// [turn] always covers n productions. [accept] is the player's choice,
  /// `false` for the prudent option applied when the turn ended without
  /// one, and `true` for an event drawn without a choice.
  void apply(
    Game game,
    Player player, {
    required bool accept,
    required int turn,
    Random? random,
  }) {}

  /// Upkeep of the event's lasting effect at the end of [turn], one of
  /// the turns it covers.
  void onTurnEnd(Game game, Player player, {required int turn}) {}
}

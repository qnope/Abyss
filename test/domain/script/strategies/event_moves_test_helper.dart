import 'dart:math';

import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';

/// Script turn of the single-player [game] of its human player.
ScriptTurn scriptTurnOf(Game game) =>
    ScriptTurn(game: game, random: Random(1), log: <ScriptLogEntry>[]);

/// Script turn 12 of [player], who waits for a choice on [type] drawn
/// at the end of turn 11. No other draw is scheduled.
ScriptTurn choiceTurn(Player player, RandomEventType type) {
  player.eventState
    ..schedule(100)
    ..setPending(type, 12);
  return scriptTurnOf(Game.singlePlayer(player)..turn = 12);
}

/// The choice [player] made on the turn's event: `true` for the first
/// option, `false` for the prudent one, `null` when none was made yet.
bool? choiceOf(Player player) {
  final entries = player.historyEntries.whereType<EventEntry>().toList();
  if (entries.isEmpty) return null;
  final EventEntry entry = entries.single;
  return entry.defaulted ? null : entry.accepted;
}

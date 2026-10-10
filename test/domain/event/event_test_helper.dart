import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';

/// Player with no event scheduled, pending or active yet.
Player eventPlayer() => Player(id: 'p1', name: 'Test');

/// Single-player game of [player] during [turn].
Game eventGame(Player player, {int turn = 1}) =>
    Game.singlePlayer(player)..turn = turn;

/// Event entries of [player]'s history, oldest first.
List<EventEntry> eventEntriesOf(Player player) =>
    player.historyEntries.whereType<EventEntry>().toList();

/// Every event that waits for a choice.
List<RandomEventType> get choiceEvents => [
  for (final type in RandomEventType.values)
    if (type != RandomEventType.storm) type,
];

import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/player_defaults.dart';
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
    if (type != RandomEventType.storm && type != RandomEventType.wreck) type,
];

/// Player of [id] whose farms, mines and panels all produce, with room
/// in every store.
Player producingPlayer({String id = 'p1'}) {
  final buildings = PlayerDefaults.buildings();
  for (final type in [
    BuildingType.headquarters,
    BuildingType.algaeFarm,
    BuildingType.coralMine,
    BuildingType.oreExtractor,
  ]) {
    buildings[type] = Building(type: type, level: 3);
  }
  // The QG stands high enough for the others: none of them is degraded.
  buildings[BuildingType.headquarters]!.level = 10;
  buildings[BuildingType.solarPanel] =
      Building(type: BuildingType.solarPanel, level: 6);
  return Player(id: id, name: 'Test', buildings: buildings);
}

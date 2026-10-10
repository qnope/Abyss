import '../../building/building_type.dart';
import '../../event/random_event_type.dart';
import '../../game/defeat_checker.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../../map/cell_content_type.dart';
import '../../map/map_cell.dart';
import '../../raid/noise_rules.dart';
import '../../worksite/worksite_rules.dart';
import 'tip.dart';

/// The situations the tip cards explain, read from the state of a game.
/// Each check is cheap: a few fields, or one pass over the cells the
/// player revealed.
abstract final class TipTriggers {
  /// A quarter of the gauge: noisy enough to be worth explaining, late
  /// enough not to crowd the first lessons of the tutorial.
  static bool noise(Game game, Player player) =>
      player.raidState.noise >= NoiseRules.threshold ~/ 4;

  /// The headquarters opened a second building site.
  static bool worksites(Game game, Player player) =>
      player.buildings[BuildingType.headquarters]!.level >=
      WorksiteRules.extraSiteAtHq.first;

  /// A branch offers its first choice: its node 1 is researched.
  static bool techChoice(Game game, Player player) => player.techBranches.values
      .any((branch) => branch.unlocked && branch.researchLevel >= 1);

  static bool raidAnnounced(Game game, Player player) =>
      player.raidState.isIncoming;

  /// A raid was fought on the base, won or lost.
  static bool raidFought(Game game, Player player) =>
      player.raidState.raidsRepelled + player.raidState.raidsLost > 0;

  /// Losing one more raid in a row makes the base fall.
  static bool lastChance(Game game, Player player) =>
      player.raidState.lostInARow >= DefeatChecker.lostRaidsLimit - 1;

  static bool lair(Game game, Player player) => _revealed(
    game,
    player,
    (cell) => cell.content == CellContentType.monsterLair,
  );

  /// A lair of a monster family revealed, not the generic monsters.
  static bool monsterFamily(Game game, Player player) => _revealed(
    game,
    player,
    (cell) =>
        cell.content == CellContentType.monsterLair &&
        cell.lair?.family != null,
  );

  static bool volcanoWave(Game game, Player player) =>
      player.volcanoState.isIncoming;

  static bool chestOrRuins(Game game, Player player) => _revealed(
    game,
    player,
    (cell) =>
        cell.content == CellContentType.resourceBonus ||
        cell.content == CellContentType.ruins,
  );

  static bool transitionBase(Game game, Player player) => _revealed(
    game,
    player,
    (cell) => cell.content == CellContentType.transitionBase,
  );

  static bool descent(Game game, Player player) =>
      player.buildings[BuildingType.descentModule]!.level >= 1;

  /// A first random event was drawn.
  static bool event(Game game, Player player) =>
      player.eventState.eventsSeen > 0;

  /// The trigger of the event [type]: it is the last one drawn.
  static TipTrigger drawn(RandomEventType type) =>
      (game, player) => player.eventState.lastDrawn == type;

  /// Whether a cell revealed to [player], on any level, matches [test].
  static bool _revealed(
    Game game,
    Player player,
    bool Function(MapCell cell) test,
  ) {
    for (final entry in player.revealedCellsPerLevel.entries) {
      final map = game.levels[entry.key];
      if (map == null) continue;
      for (final position in entry.value) {
        if (test(map.cellAt(position.x, position.y))) return true;
      }
    }
    return false;
  }
}

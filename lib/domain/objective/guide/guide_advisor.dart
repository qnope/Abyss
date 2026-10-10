import '../../building/building_type.dart';
import '../../event/random_event_type.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../../unit/unit_type.dart';
import '../current_objective.dart';
import '../objective.dart';
import '../objective_chapter.dart';
import '../objective_id.dart';
import '../objective_migration.dart';
import 'guide_advice.dart';
import 'guide_raid.dart';
import 'guide_target.dart';
import 'guide_targets.dart';
import 'guide_texts.dart';

/// The guide of the tutorial: what it says to a player and what its halo
/// surrounds, read from the state of the game alone, without playing any
/// move.
abstract final class GuideAdvisor {
  static const _endTurn = GuideTarget.endTurn();

  /// The advice for [player] in [game], `null` when the tutorial is off or
  /// its chapter is over.
  static GuideAdvice? of(Game game, Player player) {
    if (!ObjectiveMigration.stateOf(game, player).tutorialEnabled) return null;
    final Objective? objective = CurrentObjective.of(game, player);
    if (objective == null) return null;
    if (objective.chapter != ObjectiveChapter.installation) return null;
    final GuideTarget target = GuideTargets.of(player, objective.id)!;
    if (objective.isDone(game, player)) {
      return const GuideAdvice(GuideTexts.goalMet, _endTurn);
    }
    final GuideAdvice? busy = _busy(player, target);
    final GuideTarget reachable = busy?.target ?? target;
    return _raid(game, player, objective.id, reachable) ??
        _exploration(game, player, objective.id) ??
        _wreck(player, reachable) ??
        busy ??
        GuideAdvice(GuideTexts.lessonOf(objective.id)!, target);
  }

  /// The first raid announced, while the tutorial asks to push it back
  /// with the harpoonists of [target].
  static GuideAdvice? _raid(
    Game game,
    Player player,
    ObjectiveId id,
    GuideTarget target,
  ) {
    if (id != ObjectiveId.firstRaid || !player.raidState.isIncoming) {
      return null;
    }
    return GuideRaid.of(game, player, target);
  }

  /// A scout on its way, or a storm that keeps them at home.
  static GuideAdvice? _exploration(Game game, Player player, ObjectiveId id) {
    if (id != ObjectiveId.explore) return null;
    if (player.pendingExplorations.isNotEmpty) {
      return const GuideAdvice(GuideTexts.exploring, _endTurn);
    }
    final events = player.eventState;
    if (!events.isActive(RandomEventType.storm, game.turn)) return null;
    return GuideAdvice(GuideTexts.storm(events.activeUntilTurn!), _endTurn);
  }

  /// A wreck on the map that no scout can reach yet: the halo points at
  /// the scouts once the barracks stand, at [target] until then.
  /// [target] is what the objective can use this turn.
  static GuideAdvice? _wreck(Player player, GuideTarget target) {
    final events = player.eventState;
    final int? until = events.wreckUntilTurn;
    if (events.wreckPosition == null || until == null) return null;
    if (_owned(player, UnitType.scout) > 0) return null;
    if (_level(player, BuildingType.barracks) == 0) {
      return GuideAdvice(GuideTexts.wreckWithoutBarracks(until), target);
    }
    return GuideAdvice(
      GuideTexts.wreckWithoutScout(until),
      const GuideTarget.unit(UnitType.scout),
    );
  }

  /// The worksite or the recruitment [target] asks for, already used this
  /// turn.
  static GuideAdvice? _busy(Player player, GuideTarget target) {
    final int hq = _level(player, BuildingType.headquarters);
    if (target.building != null && player.worksite.freeBuildSites(hq) <= 0) {
      return const GuideAdvice(GuideTexts.worksiteTaken, _endTurn);
    }
    if (player.recruitedUnitTypes.contains(target.unit)) {
      return const GuideAdvice(GuideTexts.alreadyRecruited, _endTurn);
    }
    return null;
  }

  static int _level(Player player, BuildingType type) =>
      player.buildings[type]?.level ?? 0;

  static int _owned(Player player, UnitType type) => player.unitsPerLevel.values
      .fold(0, (sum, units) => sum + (units[type]?.count ?? 0));
}

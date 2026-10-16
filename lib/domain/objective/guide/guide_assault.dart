import '../../building/building_type.dart';
import '../../fight/assault/assault_plan.dart';
import '../../fight/assault/assault_target.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../../history/history_entry.dart';
import '../../map/transition_base_name.dart';
import '../../map/transition_base_type.dart';
import '../../unit/unit_cost_calculator.dart';
import '../../unit/unit_type.dart';
import 'guide_advice.dart';
import 'guide_map.dart';
import 'guide_message.dart';
import 'guide_target.dart';

/// What the guide says towards the capture of a Faille, a Cheminée or the
/// kernel: an Abyss Admiral first, brought down to the level of the
/// assault, then the target and the army [AssaultPlan] advises.
abstract final class GuideAssault {
  /// The advice for [player] towards the capture of [target].
  static GuideAdvice of(Game game, Player player, AssaultTarget target) {
    final int level = levelOf(target);
    final int? admiralLevel = _deepestAdmiral(player, level);
    if (admiralLevel == null) return _recruit(player, target);
    if (admiralLevel < level) {
      return GuideAdvice(
        GuideAdmiralToSend(target, level, from: admiralLevel),
        GuideMap.heldPostOn(game, player, admiralLevel) ??
            const GuideTarget.map(),
      );
    }
    final GuideTarget? cell = GuideMap.nearest(game, player, target, level);
    if (cell == null) {
      return GuideAdvice(GuidePostToFind(target), const GuideTarget.map());
    }
    return GuideAdvice(
      GuidePostAssault(target, harpoonists: _advised(player, target, level)),
      cell,
    );
  }

  /// Level of the map [target] stands on.
  static int levelOf(AssaultTarget target) => switch (target) {
    AssaultTarget.faille => 1,
    AssaultTarget.cheminee => 2,
    AssaultTarget.kernel => 3,
  };

  /// Whether an assault on [target] was won this turn of [game] while
  /// every admiral fell.
  static bool admiralFell(Game game, Player player, AssaultTarget target) {
    for (final HistoryEntry entry in player.historyEntries.reversed) {
      if (entry.turn < game.turn) return false;
      if (entry is CaptureEntry &&
          entry.turn == game.turn &&
          !entry.captured &&
          _targetOf(entry) == target) {
        return true;
      }
    }
    return false;
  }

  /// The barracks the admiral needs, then the admiral.
  static GuideAdvice _recruit(Player player, AssaultTarget target) {
    final int needed = UnitCostCalculator().unlockLevel(UnitType.abyssAdmiral);
    if ((player.buildings[BuildingType.barracks]?.level ?? 0) < needed) {
      return GuideAdvice(
        GuideAdmiralNeedsBarracks(target, needed),
        const GuideTarget.building(BuildingType.barracks),
      );
    }
    return GuideAdvice(
      GuideAdmiralToRecruit(target),
      const GuideTarget.unit(UnitType.abyssAdmiral),
    );
  }

  /// The deepest level from 1 to [level] where [player] has an admiral.
  static int? _deepestAdmiral(Player player, int level) {
    for (var l = level; l >= 1; l--) {
      if (_count(player, l, UnitType.abyssAdmiral) > 0) return l;
    }
    return null;
  }

  /// Harpoonists to send with the admirals and Guardians of [level].
  static int? _advised(Player player, AssaultTarget target, int level) =>
      AssaultPlan.of(
        player: player,
        level: level,
        target: target,
        army: {
          UnitType.abyssAdmiral: _count(player, level, UnitType.abyssAdmiral),
          UnitType.guardian: _count(player, level, UnitType.guardian),
        },
      ).suggestedHarpoonists;

  static int _count(Player player, int level, UnitType type) =>
      player.unitsOnLevel(level)[type]?.count ?? 0;

  static AssaultTarget? _targetOf(CaptureEntry entry) {
    if (entry.isVolcanicKernel) return AssaultTarget.kernel;
    return switch (TransitionBaseName.parse(entry.transitionBaseName)?.type) {
      TransitionBaseType.faille => AssaultTarget.faille,
      TransitionBaseType.cheminee => AssaultTarget.cheminee,
      null => null,
    };
  }
}

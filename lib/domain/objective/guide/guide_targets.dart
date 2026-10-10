import '../../building/building_type.dart';
import '../../game/player.dart';
import '../../tech/tech_branch.dart';
import '../../unit/unit_type.dart';
import '../objective_id.dart';
import 'guide_target.dart';

/// Where the halo of the guide points for each objective of the tutorial,
/// step by step: the building to raise, then the unit to recruit or the
/// research to start.
abstract final class GuideTargets {
  /// What [player] should touch next towards the tutorial objective [id],
  /// `null` past the tutorial.
  static GuideTarget? of(Player player, ObjectiveId id) => switch (id) {
    ObjectiveId.hqLevel1 || ObjectiveId.hqLevel2 => const GuideTarget.building(
      BuildingType.headquarters,
    ),
    ObjectiveId.algaeFarm => const GuideTarget.building(BuildingType.algaeFarm),
    ObjectiveId.mines => GuideTarget.building(
      _built(player, BuildingType.coralMine)
          ? BuildingType.oreExtractor
          : BuildingType.coralMine,
    ),
    ObjectiveId.solarPanel => const GuideTarget.building(
      BuildingType.solarPanel,
    ),
    ObjectiveId.barracksAndScouts =>
      _built(player, BuildingType.barracks)
          ? const GuideTarget.unit(UnitType.scout)
          : const GuideTarget.building(BuildingType.barracks),
    ObjectiveId.explore => const GuideTarget.map(),
    ObjectiveId.laboratoryAndResearch => _research(player),
    ObjectiveId.firstRaid => const GuideTarget.unit(UnitType.harpoonist),
    _ => null,
  };

  static bool _built(Player player, BuildingType type) =>
      (player.buildings[type]?.level ?? 0) > 0;

  /// The laboratory, then the medallions to unlock a branch, then the
  /// first node of the branches unlocked.
  static GuideTarget _research(Player player) {
    if (!_built(player, BuildingType.laboratory)) {
      return const GuideTarget.building(BuildingType.laboratory);
    }
    final Set<TechBranch> unlocked = {
      for (final MapEntry(key: branch, value: state)
          in player.techBranches.entries)
        if (state.unlocked) branch,
    };
    return unlocked.isEmpty
        ? GuideTarget.unlock(TechBranch.values.toSet())
        : GuideTarget.research(unlocked);
  }
}

import '../../domain/objective/goals/all_of_goal.dart';
import '../../domain/objective/goals/building_level_goal.dart';
import '../../domain/objective/goals/level_reached_goal.dart';
import '../../domain/objective/goals/raids_repelled_goal.dart';
import '../../domain/objective/goals/unit_count_goal.dart';
import '../../domain/objective/objective.dart';
import '../../domain/objective/objective_chapter.dart';
import '../../domain/objective/objective_goal.dart';
import '../../domain/objective/objective_id.dart';
import '../l10n/app_localizations.dart';

/// Display primitives for an [ObjectiveChapter].
extension ObjectiveChapterDisplay on ObjectiveChapter {
  /// Name of the chapter, e.g. "Le récif".
  String title(AppLocalizations l10n) => switch (this) {
    ObjectiveChapter.installation => l10n.chapterInstallation,
    ObjectiveChapter.reef => l10n.chapterReef,
    ObjectiveChapter.rift => l10n.chapterRift,
    ObjectiveChapter.chimney => l10n.chapterChimney,
    ObjectiveChapter.kernel => l10n.chapterKernel,
    ObjectiveChapter.awakening => l10n.chapterAwakening,
  };

  /// Name of the chapter after its number, e.g. "2. Le récif".
  String numberedTitle(AppLocalizations l10n) =>
      l10n.chapterNumbered(index + 1, title(l10n));
}

/// Display primitives for an [Objective].
extension ObjectiveDisplay on Objective {
  /// What the player is asked to do, e.g. "Monte le QG au niveau 5", the
  /// level or the count read from its goal.
  String displayTitle(AppLocalizations l10n) => switch (id) {
    ObjectiveId.hqLevel1 ||
    ObjectiveId.hqLevel2 ||
    ObjectiveId.hqLevel5 ||
    ObjectiveId.hqLevel8 ||
    ObjectiveId.hqLevel10 => l10n.objectiveRaiseHq(figure),
    ObjectiveId.algaeFarm => l10n.objectiveAlgaeFarm,
    ObjectiveId.mines => l10n.objectiveMines,
    ObjectiveId.solarPanel => l10n.objectiveSolarPanel,
    ObjectiveId.barracksAndScouts => l10n.objectiveBarracksAndScouts(figure),
    ObjectiveId.explore => l10n.objectiveExplore,
    ObjectiveId.laboratoryAndResearch => l10n.objectiveLaboratoryAndResearch,
    ObjectiveId.firstRaid => l10n.objectiveFirstRaid,
    ObjectiveId.takeLair => l10n.objectiveTakeLair,
    ObjectiveId.coralCitadel => l10n.objectiveCoralCitadel,
    ObjectiveId.takeFaille => l10n.objectiveTakeFaille,
    ObjectiveId.descentModule => l10n.objectiveDescentModule,
    ObjectiveId.descendLevel2 ||
    ObjectiveId.descendLevel3 => l10n.objectiveDescend(figure),
    ObjectiveId.takeCheminee => l10n.objectiveTakeCheminee,
    ObjectiveId.pressureCapsule => l10n.objectivePressureCapsule,
    ObjectiveId.takeKernel => l10n.objectiveTakeKernel,
    ObjectiveId.kernelLevel1 ||
    ObjectiveId.kernelLevel5 ||
    ObjectiveId.kernelLevel10 => l10n.objectiveRaiseKernel(figure),
  };

  /// The number the goal names: the level to reach, or the units or
  /// raids to count; a goal made of several names its last one's.
  int get figure => _figureOf(goal);

  static int _figureOf(ObjectiveGoal goal) => switch (goal) {
    BuildingLevelGoal(:final level) || LevelReachedGoal(:final level) => level,
    UnitCountGoal(:final count) || RaidsRepelledGoal(:final count) => count,
    AllOfGoal(:final goals) => _figureOf(goals.last),
    _ => 1,
  };
}

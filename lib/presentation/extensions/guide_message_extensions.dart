import '../../domain/objective/guide/guide_message.dart';
import '../../domain/objective/objective_catalog.dart';
import '../../domain/objective/objective_id.dart';
import '../../domain/raid/noise_rules.dart';
import '../l10n/app_localizations.dart';
import 'objective_extensions.dart';

/// What the guide of the tutorial says, in the player's language.
extension GuideMessageText on GuideMessage {
  String text(AppLocalizations l10n) => switch (this) {
    GuideLesson(:final objective) => objective.lesson(l10n) ?? '',
    GuideGoalMet() => l10n.guideGoalMet,
    GuideWorksiteTaken() => l10n.guideWorksiteTaken,
    GuideAlreadyRecruited() => l10n.guideAlreadyRecruited,
    GuideExploring() => l10n.guideExploring,
    GuideStorm(:final untilTurn) => l10n.guideStorm(untilTurn),
    GuideWreck(:final untilTurn, hasBarracks: false) => l10n
        .guideWreckWithoutBarracks(untilTurn),
    GuideWreck(:final untilTurn, hasBarracks: true) => l10n
        .guideWreckWithoutScout(untilTurn),
    final GuideRaidAlert alert => alert._text(l10n),
  };
}

extension on GuideRaidAlert {
  /// The raid, then how to push it back.
  String _text(AppLocalizations l10n) =>
      '${l10n.guideRaidIntro(arrivalTurn, monsters)} ${_advice(l10n)}';

  String _advice(AppLocalizations l10n) {
    final int? needed = this.needed;
    if (needed == null) return l10n.guideRaidOutOfReach;
    if (missing <= 0) return l10n.guideRaidHeld;
    final String then =
        canRecruit
            ? l10n.guideRaidRecruitNow(missing)
            : lastTurn
            ? l10n.guideRaidHoldOn
            : l10n.guideRaidRecruitNextTurn(missing);
    return '${l10n.guideRaidNeeded(needed, missing)} $then';
  }
}

/// The lessons of the tutorial objectives.
extension GuideLessonText on ObjectiveId {
  /// The lesson the guide gives on this objective, `null` past the
  /// tutorial.
  String? lesson(AppLocalizations l10n) => switch (this) {
    ObjectiveId.hqLevel1 => l10n.guideLessonHqLevel1,
    ObjectiveId.algaeFarm => l10n.guideLessonAlgaeFarm,
    ObjectiveId.mines => l10n.guideLessonMines,
    ObjectiveId.solarPanel => l10n.guideLessonSolarPanel,
    ObjectiveId.hqLevel2 => l10n.guideLessonHqLevel2(_figure),
    ObjectiveId.barracksAndScouts => l10n.guideLessonBarracksAndScouts(_figure),
    ObjectiveId.explore => l10n.guideLessonExplore,
    ObjectiveId.laboratoryAndResearch => l10n.guideLessonLaboratoryAndResearch,
    ObjectiveId.firstRaid => l10n.guideLessonFirstRaid(NoiseRules.warningTurns),
    _ => null,
  };

  int get _figure => ObjectiveCatalog.byId(this).figure;
}

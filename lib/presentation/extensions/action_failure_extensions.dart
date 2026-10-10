import '../../domain/action/action_failure.dart';
import '../../domain/action/action_result.dart';
import '../l10n/app_localizations.dart';

/// Why an action was refused, told to the player.
extension ActionFailureText on ActionFailure {
  String message(AppLocalizations l10n) => switch (this) {
    ActionFailure.mapNotGenerated => l10n.actionFailureMapNotGenerated,
    ActionFailure.cellNotRevealed => l10n.actionFailureCellNotRevealed,
    ActionFailure.cellNotEligible => l10n.actionFailureCellNotEligible,
    ActionFailure.alreadyCollected => l10n.actionFailureAlreadyCollected,
    ActionFailure.nothingToCollect => l10n.actionFailureNothingToCollect,
    ActionFailure.stormBlocksExploration =>
      l10n.actionFailureStormBlocksExploration,
    ActionFailure.noScoutAvailable => l10n.actionFailureNoScoutAvailable,
    ActionFailure.noMonsterHere => l10n.actionFailureNoMonsterHere,
    ActionFailure.lairAlreadyDefeated => l10n.actionFailureLairAlreadyDefeated,
    ActionFailure.lairEmpty => l10n.actionFailureLairEmpty,
    ActionFailure.notEnoughUnits => l10n.actionFailureNotEnoughUnits,
    ActionFailure.noUnitSelected => l10n.actionFailureNoUnitSelected,
    ActionFailure.admiralRequired => l10n.actionFailureAdmiralRequired,
    ActionFailure.noTransitionBaseHere =>
      l10n.actionFailureNoTransitionBaseHere,
    ActionFailure.baseNotFound => l10n.actionFailureBaseNotFound,
    ActionFailure.baseAlreadyCaptured => l10n.actionFailureBaseAlreadyCaptured,
    ActionFailure.baseNotCaptured => l10n.actionFailureBaseNotCaptured,
    ActionFailure.targetLevelNotExplored =>
      l10n.actionFailureTargetLevelNotExplored,
    ActionFailure.requiredBuildingMissing =>
      l10n.actionFailureRequiredBuildingMissing,
    ActionFailure.requiredBuildingDegraded =>
      l10n.actionFailureRequiredBuildingDegraded,
    ActionFailure.noVolcanicKernelHere =>
      l10n.actionFailureNoVolcanicKernelHere,
    ActionFailure.kernelAlreadyCaptured =>
      l10n.actionFailureKernelAlreadyCaptured,
    ActionFailure.kernelNotCaptured => l10n.actionFailureKernelNotCaptured,
    ActionFailure.kernelDegraded => l10n.actionFailureKernelDegraded,
    ActionFailure.noPendingEvent => l10n.actionFailureNoPendingEvent,
    ActionFailure.notThisChoiceTurn => l10n.actionFailureNotThisChoiceTurn,
    ActionFailure.notEnoughStockToTrade =>
      l10n.actionFailureNotEnoughStockToTrade,
    ActionFailure.branchNotFound => l10n.actionFailureBranchNotFound,
    ActionFailure.branchLocked => l10n.actionFailureBranchLocked,
    ActionFailure.branchAlreadyUnlocked =>
      l10n.actionFailureBranchAlreadyUnlocked,
    ActionFailure.laboratoryRequired => l10n.actionFailureLaboratoryRequired,
    ActionFailure.laboratoryLevelTooLow =>
      l10n.actionFailureLaboratoryLevelTooLow,
    ActionFailure.researchAlreadyStarted =>
      l10n.actionFailureResearchAlreadyStarted,
    ActionFailure.buildingNotFound => l10n.actionFailureBuildingNotFound,
    ActionFailure.worksitesBusy => l10n.actionFailureWorksitesBusy,
    ActionFailure.maxLevelReached => l10n.actionFailureMaxLevelReached,
    ActionFailure.notEnoughResources => l10n.actionFailureNotEnoughResources,
    ActionFailure.unitLocked => l10n.actionFailureUnitLocked,
    ActionFailure.recruitmentAlreadyDone =>
      l10n.actionFailureRecruitmentAlreadyDone,
    ActionFailure.invalidQuantity => l10n.actionFailureInvalidQuantity,
    ActionFailure.gameOver => l10n.actionFailureGameOver,
  };
}

/// What to tell the player when an action did not go through.
extension ActionResultText on ActionResult {
  /// Why the action failed, or a generic refusal when it gave no reason.
  String failureMessage(AppLocalizations l10n) =>
      reason?.message(l10n) ?? l10n.actionFailureUnknown;
}

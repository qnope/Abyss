extends TestCase
## Not in the Dart files: lib/domain/action/action_failure.dart has no test
## of its own. Why an action is refused, ported ahead of the `action` module
## for the random events that refuse a choice.


func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(ActionFailure.Value),
		PackedStringArray([
			"mapNotGenerated", "cellNotRevealed", "cellNotEligible", "alreadyCollected",
			"nothingToCollect", "stormBlocksExploration", "noScoutAvailable", "noMonsterHere",
			"lairAlreadyDefeated", "lairEmpty", "notEnoughUnits", "noUnitSelected",
			"admiralRequired", "noTransitionBaseHere", "baseNotFound", "baseAlreadyCaptured",
			"baseNotCaptured", "targetLevelNotExplored", "requiredBuildingMissing",
			"requiredBuildingDegraded", "noSuchPlayer", "cannotAttackSelf", "playerFallen",
			"baseNotRevealed", "attackTooEarly", "attackAlreadyAnnounced", "raidSameTurn",
			"attackTooSoon", "alreadyAttackedThisTurn", "noVolcanicKernelHere",
			"kernelAlreadyCaptured", "kernelNotCaptured", "kernelDegraded", "kernelNotBuilt",
			"noPendingEvent", "notThisChoiceTurn", "notEnoughStockToTrade", "branchNotFound",
			"branchLocked", "branchAlreadyUnlocked", "laboratoryRequired",
			"laboratoryLevelTooLow", "researchAlreadyStarted", "buildingNotFound",
			"worksitesBusy", "maxLevelReached", "notEnoughResources", "unitLocked",
			"recruitmentAlreadyDone", "invalidQuantity", "gameOver",
		]),
	)
	assert_eq(ActionFailure.Value.size(), 51)

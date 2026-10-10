/// Why an action was refused. The presentation words it for the player.
enum ActionFailure {
  // Map and cells.
  mapNotGenerated,
  cellNotRevealed,
  cellNotEligible,
  alreadyCollected,
  nothingToCollect,

  // Exploration.
  stormBlocksExploration,
  noScoutAvailable,

  // Lairs.
  noMonsterHere,
  lairAlreadyDefeated,
  lairEmpty,

  // Armies.
  notEnoughUnits,
  noUnitSelected,
  admiralRequired,

  // Transition bases and descents.
  noTransitionBaseHere,
  baseNotFound,
  baseAlreadyCaptured,
  baseNotCaptured,
  targetLevelNotExplored,
  requiredBuildingMissing,
  requiredBuildingDegraded,

  // Volcanic kernel.
  noVolcanicKernelHere,
  kernelAlreadyCaptured,
  kernelNotCaptured,
  kernelDegraded,

  // Random events.
  noPendingEvent,
  notThisChoiceTurn,
  notEnoughStockToTrade,

  // Research.
  branchNotFound,
  branchLocked,
  branchAlreadyUnlocked,
  laboratoryRequired,
  laboratoryLevelTooLow,
  researchAlreadyStarted,

  // Buildings and recruitment.
  buildingNotFound,
  worksitesBusy,
  maxLevelReached,
  notEnoughResources,
  unitLocked,
  recruitmentAlreadyDone,
  invalidQuantity,

  // The game itself.
  gameOver,
}

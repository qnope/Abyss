// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get newGameTitle => 'New Game';

  @override
  String get newGameEnterName => 'Enter your name';

  @override
  String get newGameNameHint => 'Player name';

  @override
  String get newGameNameEmpty => 'Please enter a name';

  @override
  String newGameNameTooShort(int min) {
    return 'The name must be at least $min characters long';
  }

  @override
  String get newGameTutorial => 'Tutorial';

  @override
  String get newGameTutorialHint => 'A guide walks you through the first turns';

  @override
  String get newGameStart => 'Start';

  @override
  String get difficultyTitle => 'Difficulty';

  @override
  String get buildingHeadquartersName => 'Headquarters';

  @override
  String buildingHeadquartersDescription(int coral, int ore) {
    return 'Command center of your undersea base. Its level sets what your colony can do. Once built, it provides $coral coral and $ore ore per turn.';
  }

  @override
  String get buildingAlgaeFarmName => 'Algae Farm';

  @override
  String get buildingAlgaeFarmDescription =>
      'Grows algae to feed your undersea colony.';

  @override
  String get buildingCoralMineName => 'Coral Mine';

  @override
  String get buildingCoralMineDescription =>
      'Mines coral from the reefs for construction.';

  @override
  String get buildingCoralCitadelName => 'Coral Citadel';

  @override
  String get buildingCoralCitadelDescription =>
      'Massive coral fortress raising a rampart to defend your base. During a raid, it takes the blows instead of the stationed units.';

  @override
  String get buildingOreExtractorName => 'Ore Extractor';

  @override
  String get buildingOreExtractorDescription =>
      'Drills the depths to extract ocean ore.';

  @override
  String get buildingSolarPanelName => 'Solar Panel';

  @override
  String get buildingSolarPanelDescription =>
      'Captures solar energy to power your facilities.';

  @override
  String get buildingLaboratoryName => 'Laboratory';

  @override
  String get buildingLaboratoryDescription =>
      'Undersea research center to develop new technologies.';

  @override
  String get buildingBarracksName => 'Barracks';

  @override
  String get buildingBarracksDescription =>
      'Trains and drills your undersea military units.';

  @override
  String get buildingDescentModuleName => 'Descent Module';

  @override
  String get buildingDescentModuleDescription =>
      'Specialized module for assaulting abyssal rifts.';

  @override
  String get buildingPressureCapsuleName => 'Pressure Capsule';

  @override
  String get buildingPressureCapsuleDescription =>
      'High-pressure capsule for assaulting hydrothermal vents.';

  @override
  String get buildingVolcanicKernelName => 'Volcanic Core';

  @override
  String get buildingVolcanicKernelDescription =>
      'The burning heart of the abyss. Build it to level 10 to win. Its garrison is managed here, or from its cell on the map.';

  @override
  String get unitScoutName => 'Scout';

  @override
  String get unitScoutRole => 'Scout';

  @override
  String get unitScoutRoleEffect =>
      'Flees instead of dying: always comes back wounded.';

  @override
  String get unitHarpoonistName => 'Harpooner';

  @override
  String get unitHarpoonistRole => 'DPS';

  @override
  String get unitHarpoonistRoleEffect => 'Steady damage, no special rule.';

  @override
  String get unitGuardianName => 'Guardian';

  @override
  String get unitGuardianRole => 'Tank';

  @override
  String get unitGuardianRoleEffect => 'Taunts: monsters target it first.';

  @override
  String get unitDomeBreakerName => 'Breaker';

  @override
  String get unitDomeBreakerRole => 'Siege';

  @override
  String get unitDomeBreakerRoleEffect => 'Deals double damage to bosses.';

  @override
  String get unitAbyssAdmiralName => 'Abyss Admiral';

  @override
  String get unitAbyssAdmiralRole => 'Admiral';

  @override
  String get unitAbyssAdmiralRoleEffect =>
      'Leads the assaults without fighting.';

  @override
  String get unitSaboteurName => 'Saboteur';

  @override
  String get unitSaboteurRole => 'Glass Cannon';

  @override
  String get unitSaboteurRoleEffect => 'Ignores its target\'s defense.';

  @override
  String unitScoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scouts',
      one: '$count scout',
    );
    return '$_temp0';
  }

  @override
  String unitHarpoonistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count harpooners',
      one: '$count harpooner',
    );
    return '$_temp0';
  }

  @override
  String unitGuardianCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guardians',
      one: '$count guardian',
    );
    return '$_temp0';
  }

  @override
  String unitDomeBreakerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count breakers',
      one: '$count breaker',
    );
    return '$_temp0';
  }

  @override
  String unitAbyssAdmiralCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abyss admirals',
      one: '$count abyss admiral',
    );
    return '$_temp0';
  }

  @override
  String unitSaboteurCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saboteurs',
      one: '$count saboteur',
    );
    return '$_temp0';
  }

  @override
  String get resourceAlgaeName => 'Algae';

  @override
  String get resourceAlgaeFlavor =>
      'Food grown in the undersea farms to feed your units.';

  @override
  String get resourceCoralName => 'Coral';

  @override
  String get resourceCoralFlavor =>
      'Building material harvested from the reefs to build your base.';

  @override
  String get resourceOreName => 'Ore';

  @override
  String get resourceOreFlavor =>
      'Metal mined from the depths to forge advanced equipment.';

  @override
  String get resourceEnergyName => 'Energy';

  @override
  String get resourceEnergyFlavor =>
      'Energy captured to power your buildings and machines.';

  @override
  String get resourcePearlName => 'Pearls';

  @override
  String get resourcePearlFlavor =>
      'Rare gems found in ruins and lairs, and gathered every turn in captured rifts and vents.';

  @override
  String get monsterFamilyGenericLabel => 'Prowlers';

  @override
  String get monsterFamilySwarmLabel => 'Swarm';

  @override
  String get monsterFamilyArmouredLabel => 'Shells';

  @override
  String get monsterFamilyHunterLabel => 'Hunters';

  @override
  String get monsterFamilyColossusLabel => 'Colossi';

  @override
  String get monsterFamilyKrakenLabel => 'Kraken';

  @override
  String monsterFamilyGenericCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monsters',
      one: '$count monster',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilySwarmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Glassfangs',
      one: '$count Glassfang',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyArmouredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Armored Isopods',
      one: '$count Armored Isopod',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyHunterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hunter Squids',
      one: '$count Hunter Squid',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyColossusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sleeper Sharks',
      one: '$count Sleeper Shark',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyKrakenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Krakens',
      one: '$count Kraken',
    );
    return '$_temp0';
  }

  @override
  String get monsterFamilySwarmRule =>
      'Swarm: a Harpooner strike hits two fish.';

  @override
  String get monsterFamilyArmouredRule =>
      'Armor: only Saboteurs ignore their DEF.';

  @override
  String get monsterFamilyHunterRule =>
      'Stalk: they go for the frailest unit and strike twice as hard, unless a Guardian or the rampart taunts them.';

  @override
  String get monsterFamilyColossusRule =>
      'Giants: all bosses, which Breakers hit for double.';

  @override
  String get monsterFamilyKrakenRule =>
      'Grip: each tentacle strike also hits a second defender. Bosses, which Breakers hit for double.';

  @override
  String get monsterFamilySwarmWeakness => 'Harpooners';

  @override
  String get monsterFamilyArmouredWeakness => 'Saboteurs';

  @override
  String get monsterFamilyHunterWeakness => 'Guardians';

  @override
  String get monsterFamilyColossusWeakness => 'Dome Breakers';

  @override
  String monsterLairGroupsAnd(String first, String second) {
    return '$first and $second';
  }

  @override
  String monsterLairWave(String monsters, int level) {
    return '$monsters lv. $level';
  }

  @override
  String monsterLairWeakAgainst(String units) {
    return 'Weak against: $units';
  }

  @override
  String get monsterDifficultyEasy => 'Easy';

  @override
  String get monsterDifficultyMedium => 'Medium';

  @override
  String get monsterDifficultyHard => 'Hard';

  @override
  String get randomEventWarmCurrentLabel => 'Warm Current';

  @override
  String get randomEventWreckLabel => 'Wreck';

  @override
  String get randomEventPredatorsLabel => 'Predator Shoal';

  @override
  String get randomEventStormLabel => 'Storm';

  @override
  String get randomEventSurvivorsLabel => 'Survivors';

  @override
  String get randomEventCaravanLabel => 'Turtle Caravan';

  @override
  String get randomEventColdCurrentLabel => 'Cold Current';

  @override
  String eventCountdown(String label, int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turns left',
      one: '$turns turn left',
    );
    return '$label: $_temp0';
  }

  @override
  String eventColdCurrentHeated(String label) {
    return '$label (heated greenhouses)';
  }

  @override
  String get techBranchMilitaryName => 'Military';

  @override
  String get techBranchMilitaryDescription =>
      'Improves the attack and defense of every unit.';

  @override
  String get techBranchResourcesName => 'Resources';

  @override
  String get techBranchResourcesDescription =>
      'Improves the production of every resource.';

  @override
  String get techBranchExplorerName => 'Explorer';

  @override
  String get techBranchExplorerDescription =>
      'Improves the exploration range on the map.';

  @override
  String get techTierEffect => '+20% ATK and DEF';

  @override
  String get techProductionEffect => '+20% production';

  @override
  String techExploredAreaEffect(int size) {
    return 'Explored area $size×$size';
  }

  @override
  String get techMilitary1Name => 'Sharpened Trident';

  @override
  String get techMilitary2aName => 'Coral Blades';

  @override
  String get techMilitary2aEffect => '+35% ATK';

  @override
  String get techMilitary2bName => 'Nacre Shell';

  @override
  String get techMilitary2bEffect => '+35% HP';

  @override
  String get techMilitary3Name => 'Abyssal Discipline';

  @override
  String get techMilitary4aName => 'Living Rampart';

  @override
  String get techMilitary4aEffect => '+35% DEF when defending the base';

  @override
  String get techMilitary4bName => 'Deep Assault';

  @override
  String get techMilitary4bEffect =>
      '+35% ATK against lairs, bases and the Core';

  @override
  String get techMilitary5Name => 'Abyssal Legion';

  @override
  String get techResources1Name => 'Fertile Shoals';

  @override
  String get techResources2aName => 'Intensive Farming';

  @override
  String get techResources2aEffect => '+35% algae and coral';

  @override
  String get techResources2bName => 'Deep Drilling';

  @override
  String get techResources2bEffect => '+35% ore and energy';

  @override
  String get techResources3Name => 'Nourishing Currents';

  @override
  String get techResources4aName => 'Sealed Vaults';

  @override
  String get techResources4aEffect => 'A lost raid loots 15% instead of 30%';

  @override
  String get techResources4bName => 'Thrifty Worksites';

  @override
  String get techResources4bEffect => 'Upgrades cost 15% less';

  @override
  String get techResources5Name => 'Deep-Sea Bounty';

  @override
  String get techExplorer1Name => 'Bioluminescent Lantern';

  @override
  String get techExplorer2aName => 'Deep Sonar';

  @override
  String get techExplorer2aEffect => 'Explored area 2 wider';

  @override
  String get techExplorer2bName => 'Silent Swim';

  @override
  String get techExplorer2bEffect =>
      'Exploring and fighting no longer make noise';

  @override
  String get techExplorer3Name => 'Current Mapping';

  @override
  String get techExplorer4aName => 'Wreck Raiders';

  @override
  String get techExplorer4aEffect =>
      '+50% loot (lairs, treasures, repelled raids)';

  @override
  String get techExplorer4bName => 'Sentinels';

  @override
  String get techExplorer4bEffect =>
      'Raids announced 4 turns ahead instead of 2';

  @override
  String get techExplorer5Name => 'Eye of the Abyss';

  @override
  String get terrainPlain => 'Plain';

  @override
  String get cellContentEmpty => 'Empty';

  @override
  String get cellContentResourceBonus => 'Resources';

  @override
  String get cellContentRuins => 'Ruins';

  @override
  String get cellContentMonsterLair => 'Lair';

  @override
  String get cellContentPassage => 'Passage';

  @override
  String get transitionBaseFailleName => 'Abyssal Rift';

  @override
  String get transitionBaseFailleDescription => 'Passage to the depths';

  @override
  String get transitionBaseChemineeName => 'Core Vent';

  @override
  String get transitionBaseChemineeDescription => 'Passage to the core';

  @override
  String get difficultyEasyName => 'Easy';

  @override
  String get difficultyEasyDescription => 'More resources, fewer monsters.';

  @override
  String get difficultyNormalName => 'Normal';

  @override
  String get difficultyNormalDescription =>
      'The balance the abyss was made for.';

  @override
  String get difficultyHardName => 'Hard';

  @override
  String get difficultyHardDescription => 'Fewer resources, more monsters.';

  @override
  String get temporaryObjectiveWreckShort => 'Wreck';

  @override
  String get temporaryObjectivePredatorsShort => 'Predators';

  @override
  String temporaryObjectiveWreckTitle(int turn) {
    return 'Search the wreck by the end of turn $turn';
  }

  @override
  String get temporaryObjectivePredatorsTitle => 'Repel the predator shoal';

  @override
  String get historyCategoryCombat => 'Combat';

  @override
  String get historyCategoryBuilding => 'Construction';

  @override
  String get historyCategoryResearch => 'Research';

  @override
  String get historyCategoryRecruit => 'Recruitment';

  @override
  String get historyCategoryExplore => 'Exploration';

  @override
  String get historyCategoryCollect => 'Collection';

  @override
  String get historyCategoryTurnEnd => 'End of turn';

  @override
  String get historyCategoryCapture => 'Capture';

  @override
  String get historyCategoryDescent => 'Descent';

  @override
  String get historyCategoryReinforcement => 'Reinforcements';

  @override
  String get historyCategoryRaid => 'Raid';

  @override
  String get historyCategoryVolcano => 'Volcano';

  @override
  String get historyCategoryEvent => 'Event';

  @override
  String get actionFailureUnknown => 'Action not possible';

  @override
  String get actionFailureMapNotGenerated => 'Map not generated';

  @override
  String get actionFailureCellNotRevealed => 'Cell not revealed';

  @override
  String get actionFailureCellNotEligible => 'Cell not eligible';

  @override
  String get actionFailureAlreadyCollected => 'Already collected';

  @override
  String get actionFailureNothingToCollect => 'Nothing to collect';

  @override
  String get actionFailureStormBlocksExploration => 'Storm: no exploring';

  @override
  String get actionFailureNoScoutAvailable => 'No scout available';

  @override
  String get actionFailureNoMonsterHere => 'No monster here';

  @override
  String get actionFailureLairAlreadyDefeated => 'Lair already defeated';

  @override
  String get actionFailureLairEmpty => 'Empty lair';

  @override
  String get actionFailureNotEnoughUnits => 'Not enough units';

  @override
  String get actionFailureNoUnitSelected => 'No unit selected';

  @override
  String get actionFailureAdmiralRequired => 'An Abyss Admiral is required';

  @override
  String get actionFailureNoTransitionBaseHere => 'No transition base here';

  @override
  String get actionFailureBaseNotFound => 'Base not found';

  @override
  String get actionFailureBaseAlreadyCaptured => 'Base already captured';

  @override
  String get actionFailureBaseNotCaptured => 'Base not captured';

  @override
  String get actionFailureTargetLevelNotExplored => 'Target level not explored';

  @override
  String get actionFailureRequiredBuildingMissing =>
      'Required building missing';

  @override
  String get actionFailureNoVolcanicKernelHere => 'No Volcanic Core here';

  @override
  String get actionFailureKernelAlreadyCaptured => 'Core already captured';

  @override
  String get actionFailureKernelNotCaptured => 'Core not captured';

  @override
  String get actionFailureNoPendingEvent => 'No pending event';

  @override
  String get actionFailureNotThisChoiceTurn =>
      'This choice belongs to another turn';

  @override
  String get actionFailureNotEnoughStockToTrade => 'Not enough stock to trade';

  @override
  String get actionFailureBranchNotFound => 'Branch not found';

  @override
  String get actionFailureBranchLocked => 'Branch locked';

  @override
  String get actionFailureBranchAlreadyUnlocked => 'Branch already unlocked';

  @override
  String get actionFailureLaboratoryRequired => 'Laboratory required';

  @override
  String get actionFailureLaboratoryLevelTooLow => 'Laboratory level too low';

  @override
  String get actionFailureResearchAlreadyStarted =>
      'Research already started this turn';

  @override
  String get actionFailureBuildingNotFound => 'Building not found';

  @override
  String get actionFailureWorksitesBusy => 'Worksites busy this turn';

  @override
  String get actionFailureMaxLevelReached => 'Maximum level reached';

  @override
  String get actionFailureNotEnoughResources => 'Not enough resources';

  @override
  String get actionFailureUnitLocked => 'Unit locked';

  @override
  String get actionFailureRecruitmentAlreadyDone =>
      'Already recruited this turn';

  @override
  String get actionFailureInvalidQuantity => 'Invalid quantity';

  @override
  String get actionFailureGameOver => 'Game over';

  @override
  String historyBuildingTitle(String building, int level) {
    return '$building lv. $level';
  }

  @override
  String historyResearchUnlocked(String branch) {
    return '$branch unlocked';
  }

  @override
  String historyResearchLevel(String branch, int level) {
    return '$branch lv. $level';
  }

  @override
  String historyResearchImproved(String branch) {
    return '$branch improved';
  }

  @override
  String historyRecruitTitle(int count, String units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$units recruited',
      one: '$units recruited',
    );
    return '$_temp0';
  }

  @override
  String historyExploreTitle(int x, int y) {
    return 'Exploration ($x, $y)';
  }

  @override
  String historyCollectTitle(int x, int y) {
    return 'Treasure collected ($x, $y)';
  }

  @override
  String historyCombatVictory(int level) {
    return 'Victory vs Lair lv. $level';
  }

  @override
  String historyCombatDefeat(int level) {
    return 'Defeat vs Lair lv. $level';
  }

  @override
  String historyTurnEndTitle(int turn) {
    return 'Turn $turn ended';
  }

  @override
  String historyCaptureTitle(String name) {
    return 'Capture: $name';
  }

  @override
  String historyCaptureVictory(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'Victory in $turns turns',
      one: 'Victory in $turns turn',
    );
    return '$_temp0';
  }

  @override
  String historyDescentTitle(int level) {
    return 'Descent to Level $level';
  }

  @override
  String historyDescentUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units sent',
      one: '$count unit sent',
    );
    return '$_temp0';
  }

  @override
  String historyReinforcementTitle(int level) {
    return 'Reinforcements to Level $level';
  }

  @override
  String historyReinforcementUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units in transit',
      one: '$count unit in transit',
    );
    return '$_temp0';
  }

  @override
  String get historyRaidRepelled => 'Raid repelled';

  @override
  String get historyRaidLost => 'Base looted by a raid';

  @override
  String get historyPredatorsRepelled => 'Predator shoal repelled';

  @override
  String get historyPredatorsLost => 'Base looted by a predator shoal';

  @override
  String get historyVolcanoRepelled => 'Wave repelled at the Core';

  @override
  String get historyVolcanoLost => 'The Core lost a level';

  @override
  String get historyEventAccepted => 'Accepted';

  @override
  String get historyEventRefused => 'Refused';

  @override
  String get historyEventDefaulted => 'Cautious option, no choice made';
}

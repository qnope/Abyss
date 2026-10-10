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

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonOk => 'OK';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get commonSend => 'Send';

  @override
  String get commonBackToBase => 'Back to base';

  @override
  String get commonBackToMap => 'Back to the map';

  @override
  String commonTurn(int turn) {
    return 'Turn $turn';
  }

  @override
  String commonNamedLevel(String name, int level) {
    return '$name lv. $level';
  }

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'ATK';

  @override
  String get statDefense => 'DEF';

  @override
  String get fightVictory => 'VICTORY';

  @override
  String get fightDefeat => 'DEFEAT';

  @override
  String get fightKernelCaptured => 'CORE CAPTURED';

  @override
  String get fightBaseCaptured => 'BASE CAPTURED';

  @override
  String fightTurnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fight over $count turns',
      one: 'Fight over $count turn',
    );
    return '$_temp0';
  }

  @override
  String get fightYourUnits => 'Your units';

  @override
  String fightUnitAccounting(int sent, int intact, int wounded, int dead) {
    return 'Sent: $sent / Unhurt: $intact / Wounded: $wounded / Dead: $dead';
  }

  @override
  String fightEnemiesKilled(int killed, int total) {
    return 'Enemies killed: $killed/$total';
  }

  @override
  String fightGuardiansKilled(int killed, int total) {
    return 'Guardians defeated: $killed/$total';
  }

  @override
  String get fightLoot => 'Loot';

  @override
  String get fightNoLoot => 'No loot';

  @override
  String fightTitle(int x, int y) {
    return 'Fight ($x, $y)';
  }

  @override
  String fightAssaultTitle(int x, int y) {
    return 'Assault ($x, $y)';
  }

  @override
  String fightAssaultOn(String target) {
    return 'Assault: $target';
  }

  @override
  String get fightPrepare => 'Prepare the fight';

  @override
  String get fightLaunch => 'Start the fight';

  @override
  String get fightLaunchAssault => 'Launch the assault';

  @override
  String get fightAdmiralRequired =>
      'An Abyss Admiral is required to launch the assault';

  @override
  String fightStock(int count) {
    return 'Stock: $count';
  }

  @override
  String fightAlliesAlive(int count) {
    return 'Allies alive: $count';
  }

  @override
  String fightAlliesHp(int hp) {
    return 'Allied HP: $hp';
  }

  @override
  String fightDamageDealt(int damage) {
    return 'Damage dealt: $damage';
  }

  @override
  String fightEnemiesAlive(int count) {
    return 'Enemies alive: $count';
  }

  @override
  String fightEnemiesHp(int hp) {
    return 'Enemy HP: $hp';
  }

  @override
  String fightDamageTaken(int damage) {
    return 'Damage taken: $damage';
  }

  @override
  String fightCriticalHits(int count) {
    return 'Critical hits: $count';
  }

  @override
  String fightMilitaryBonus(String bonuses) {
    return 'Military bonus: $bonuses';
  }

  @override
  String get fightMilitaryBonusNone => 'Military bonus: none';

  @override
  String fightLevel(int level) {
    return 'Level $level';
  }

  @override
  String fightWeakAgainst(String unit) {
    return 'Weak against: $unit';
  }

  @override
  String get mapLevelSurface => 'Surface';

  @override
  String get mapLevelDepths => 'Depths';

  @override
  String get mapLevelCore => 'Core';

  @override
  String mapLevelChip(int level, String name) {
    return 'Lv $level: $name';
  }

  @override
  String get mapDifficulty => 'Difficulty';

  @override
  String get mapLevel => 'Level';

  @override
  String get mapUnits => 'Units';

  @override
  String get mapIncomeOnceCaptured => 'Income once captured';

  @override
  String mapPearlsPerTurn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count pearls per turn',
      one: '+$count pearl per turn',
    );
    return '$_temp0';
  }

  @override
  String get mapGuardedNeutral => 'Neutral — Guardians present';

  @override
  String get mapAssault => 'Assault';

  @override
  String get mapCaptured => 'Captured';

  @override
  String mapUnitsOnLevel(int count, int level) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units on Level $level',
      one: '$count unit on Level $level',
    );
    return '$_temp0';
  }

  @override
  String mapBuildingRequired(String building) {
    return 'Building required to send units: $building';
  }

  @override
  String mapSendUnitsToLevel(int level) {
    return 'Send units to Level $level';
  }

  @override
  String mapExploreTitle(int x, int y) {
    return 'Explore ($x, $y)';
  }

  @override
  String get mapCost => 'Cost';

  @override
  String get mapScoutsAvailable => 'Scouts available';

  @override
  String get mapRevealedArea => 'Revealed area';

  @override
  String mapAreaCells(int side) {
    return '$side×$side cells';
  }

  @override
  String get mapKernelUncaptured =>
      'The burning heart of the abyss is held by powerful guardians.';

  @override
  String get mapKernelCaptured =>
      'You captured the Volcanic Core. Raise it to level 10 to win. From level 1, the Kraken comes to take it back every turn: each wave it wins costs the Core a level.';

  @override
  String mapTreasureTitle(int x, int y) {
    return 'Treasure ($x, $y)';
  }

  @override
  String get mapCollectTreasure => 'Collect the treasure';

  @override
  String get mapTreasureResourceBonus => 'Algae, coral and ore';

  @override
  String get mapTreasureRuins => 'Coral, ore and pearls';

  @override
  String get mapTreasureWreck => 'Coral, ore and a pearl';

  @override
  String get raidName => 'Raid';

  @override
  String get raidPillage => 'Looted';

  @override
  String get raidNothingToLoot => 'Nothing to loot';

  @override
  String raidPredatorsTitle(int turn) {
    return 'Predator Shoal (turn $turn)';
  }

  @override
  String raidTitle(int turn) {
    return 'Raid on the base (turn $turn)';
  }

  @override
  String raidRampart(int level) {
    return 'Citadel Rampart lv. $level';
  }

  @override
  String get raidNoise => 'Noise';

  @override
  String raidLostInARow(int lost, int limit) {
    return 'Raids lost in a row: $lost/$limit';
  }

  @override
  String raidIncomingThisTurn(String wave) {
    return 'Raid at the end of this turn: $wave';
  }

  @override
  String raidIncomingOnTurn(int turn, String wave) {
    return 'Raid at the end of turn $turn: $wave';
  }

  @override
  String get raidBaseLooted => 'The base was looted';

  @override
  String raidAnnounced(String wave, int turn) {
    return 'A raid is coming: $wave, end of turn $turn';
  }

  @override
  String raidDueThisTurn(String attacker, String wave, String defenders) {
    return '$attacker this turn: $wave against $defenders';
  }

  @override
  String raidDefenders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count defenders',
      one: '$count defender',
      zero: 'no defender',
    );
    return '$_temp0';
  }

  @override
  String get raidLastChance => 'If this raid is lost, the game is over.';

  @override
  String volcanoWaveTitle(int turn) {
    return 'Wave on the Core (turn $turn)';
  }

  @override
  String volcanoKernelHolds(int level) {
    return 'The Core holds at level $level';
  }

  @override
  String volcanoKernelDrops(int level) {
    return 'The Core falls back to level $level';
  }

  @override
  String volcanoMagmaRampart(String stats) {
    return 'Magma rampart: $stats';
  }

  @override
  String volcanoKernelLevel(int level) {
    return 'Core level $level';
  }

  @override
  String volcanoGarrison(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Garrison: $count units',
      one: 'Garrison: $count unit',
    );
    return '$_temp0';
  }

  @override
  String volcanoNextWave(String wave) {
    return 'Next wave, at the end of the turn: $wave';
  }

  @override
  String volcanoLevelsLost(int count) {
    return 'Levels lost to the waves: $count';
  }

  @override
  String get volcanoGarrisonUnits => 'Garrison units';

  @override
  String get volcanoWithdraw => 'Withdraw';

  @override
  String volcanoDueWarning(String wave) {
    return 'Wave on the Core this turn: $wave, and no garrison. The Core will probably lose a level.';
  }

  @override
  String volcanoStatus(int level, String wave, int size) {
    return 'Core lv. $level, end of turn: $wave against a garrison of $size';
  }

  @override
  String volcanoRepelled(String losses) {
    return 'Volcano: wave repelled, $losses';
  }

  @override
  String volcanoKernelFell(int level) {
    return 'Volcano: the Core falls back to level $level';
  }

  @override
  String volcanoWounded(int count) {
    return '$count wounded';
  }

  @override
  String volcanoDead(int count) {
    return '$count dead';
  }

  @override
  String volcanoKrakenRises(String wave) {
    return 'The Kraken rises: $wave next turn';
  }

  @override
  String get eventCardWarmLine1 => 'A warm current flows through the base.';

  @override
  String get eventCardWarmLine2 =>
      'It boosts production, but its swirl makes noise.';

  @override
  String get eventCardColdLine1 => 'A cold current chills the greenhouses.';

  @override
  String get eventCardColdLine2 => 'Without heating, the algae grow less.';

  @override
  String get eventCardPredatorsLine1 =>
      'A shoal of predators prowls around the base.';

  @override
  String get eventCardPredatorsWatching => 'They are watching the base.';

  @override
  String eventCardPredatorsWave(String wave, String defenders) {
    return '$wave against $defenders on level 1.';
  }

  @override
  String get eventCardSurvivorsLine1 =>
      'A stranded capsule fires a distress flare.';

  @override
  String get eventCardSurvivorsLine2 =>
      'Its survivors can join the base, but they will eat algae.';

  @override
  String get eventCardCaravanLine1 => 'A turtle caravan passes near the base.';

  @override
  String get eventCardCaravanLine2 => 'Its merchant crab offers a trade.';

  @override
  String eventCardStormLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'No exploration for $turns turns.',
      one: 'No exploration for $turns turn.',
    );
    return '$_temp0';
  }

  @override
  String eventCardStormLine2(int relief) {
    return 'The storm covers the noise: gauge −$relief.';
  }

  @override
  String get eventCardWreckLine1 =>
      'A wreck sank at the edge of the explored area.';

  @override
  String eventCardWreckLine2(int turns, int noise) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other:
          'Explore it with a Scout, then search it within $turns turns (+$noise noise).',
      one:
          'Explore it with a Scout, then search it within $turns turn (+$noise noise).',
    );
    return '$_temp0';
  }

  @override
  String eventCardWarmAccept(int percent, int turns, int noise) {
    return 'Exploit (+$percent% algae, coral, ore for $turns turns, +$noise noise/turn)';
  }

  @override
  String get eventCardWarmRefuse => 'Let it pass';

  @override
  String eventCardColdAccept(int energy, int turns) {
    return 'Heat the greenhouses (−$energy energy/turn for $turns turns)';
  }

  @override
  String eventCardColdRefuse(int percent, int turns) {
    return 'Endure it (−$percent% algae for $turns turns)';
  }

  @override
  String eventCardPredatorsAccept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fight it ($count monsters, end of turn)',
      one: 'Fight it ($count monster, end of turn)',
    );
    return '$_temp0';
  }

  @override
  String eventCardPredatorsRefuse(int algae) {
    return 'Lure it away (−$algae algae)';
  }

  @override
  String eventCardSurvivorsAccept(String units) {
    return 'Welcome $units';
  }

  @override
  String get eventCardRefuse => 'Refuse';

  @override
  String eventCardTrade(int give, String from, int get, String to) {
    return 'Trade $give $from for $get $to';
  }

  @override
  String get eventCardLater => 'Later';

  @override
  String eventCardPendingWarning(String event) {
    return '$event: without a choice, the prudent option will apply';
  }

  @override
  String eventCardStatusPending(String event) {
    return 'Event: $event — choose';
  }

  @override
  String get techScreenUnlock => 'Unlock';

  @override
  String get techScreenResearch => 'Research';

  @override
  String techScreenChoiceTitle(String branch, int level) {
    return '$branch · Level $level · Choice';
  }

  @override
  String techScreenNodeSubtitle(String branch, int level, String effect) {
    return '$branch · Level $level · $effect';
  }

  @override
  String get techScreenChoiceWarning =>
      'Only one option per game, the other will be lost.';

  @override
  String get techScreenChoose => 'Choose';

  @override
  String get techScreenChosen => 'Chosen ✓';

  @override
  String get techScreenDiscarded => 'Discarded';

  @override
  String get techScreenOr => 'or';

  @override
  String get techScreenAcquired => 'Acquired ✓';

  @override
  String techScreenSurcharge(String factor) {
    return 'All research will cost ×$factor once this branch is open.';
  }

  @override
  String get techScreenUnlockBranchFirst => 'Unlock the branch first';

  @override
  String techScreenResearchPreviousFirst(int level) {
    return 'Research level $level first';
  }

  @override
  String techScreenLabRequired(int level) {
    return 'Laboratory level $level required';
  }

  @override
  String get techScreenOneResearchPerTurn =>
      'One research per turn: wait for the next turn';

  @override
  String techScreenMedallionLevel(int level) {
    return 'Lv. $level';
  }

  @override
  String get objectiveSheetTitle => 'Objectives';

  @override
  String get objectiveEventHeader => 'Event objectives';

  @override
  String objectiveProgress(String title, int current, int target) {
    return '$title: $current/$target';
  }

  @override
  String objectiveCompleted(String title) {
    return 'Objective complete: $title';
  }

  @override
  String get objectiveMissed => '(missed)';

  @override
  String objectiveRaiseHq(int level) {
    return 'Raise the HQ to level $level';
  }

  @override
  String get objectiveAlgaeFarm => 'Build the Algae Farm';

  @override
  String get objectiveMines => 'Build the Coral Mine and the Ore Extractor';

  @override
  String get objectiveSolarPanel => 'Build the Solar Panel';

  @override
  String objectiveBarracksAndScouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Scouts',
      one: '$count Scout',
    );
    return 'Build the Barracks and recruit $_temp0';
  }

  @override
  String get objectiveExplore => 'Explore a tile around the base';

  @override
  String get objectiveLaboratoryAndResearch =>
      'Build the Laboratory and start a research project';

  @override
  String get objectiveFirstRaid => 'Repel the first raid';

  @override
  String get objectiveTakeLair => 'Take a lair';

  @override
  String get objectiveCoralCitadel => 'Build the Coral Citadel';

  @override
  String get objectiveTakeFaille => 'Take the Rift';

  @override
  String get objectiveDescentModule => 'Build the Descent Module';

  @override
  String objectiveDescend(int level) {
    return 'Go down to level $level';
  }

  @override
  String get objectiveTakeCheminee => 'Take the Vent';

  @override
  String get objectivePressureCapsule => 'Build the Pressure Capsule';

  @override
  String get objectiveTakeKernel => 'Take the Volcanic Core';

  @override
  String objectiveRaiseKernel(int level) {
    return 'Raise the Core to level $level';
  }

  @override
  String get chapterInstallation => 'Settling In';

  @override
  String get chapterReef => 'The Reef';

  @override
  String get chapterRift => 'The Rift';

  @override
  String get chapterChimney => 'The Vent';

  @override
  String get chapterKernel => 'The Core';

  @override
  String get chapterAwakening => 'The Awakening';

  @override
  String chapterNumbered(int number, String title) {
    return '$number. $title';
  }

  @override
  String get tipGuideTitle => 'Guide';

  @override
  String get tipCategoryBase => 'Base';

  @override
  String get tipCategoryThreats => 'Threats';

  @override
  String get tipCategoryMap => 'Map';

  @override
  String get tipCategoryEvents => 'Events';

  @override
  String get tipNoiseGaugeTitle => 'The noise gauge';

  @override
  String get tipNoiseGaugeLine1 =>
      'Every build, every recruit and every exploration makes noise, and your base makes a little every turn.';

  @override
  String tipNoiseGaugeLine2(int threshold) {
    return 'When the gauge reaches $threshold, the monsters hear it: a raid is announced.';
  }

  @override
  String get tipWorksitesTitle => 'Two builds per turn';

  @override
  String tipWorksitesLine1(int level) {
    return 'Your HQ at level $level opens a second build slot: two buildings go up each turn.';
  }

  @override
  String tipWorksitesLine2(int level) {
    return 'HQ level $level will open a third. Research stays at one per turn.';
  }

  @override
  String get tipTechChoiceTitle => 'Research choices';

  @override
  String get tipTechChoiceLine1 =>
      'The next node of your branch is a choice between two options.';

  @override
  String get tipTechChoiceLine2 =>
      'This choice is final: the other option stays closed for the whole game.';

  @override
  String get tipTechChoiceLine3 =>
      'Take the time to read both before you start the research.';

  @override
  String get tipRaidAnnouncedTitle => 'A raid is coming';

  @override
  String tipRaidAnnouncedLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turns',
      one: '$turns turn',
    );
    return 'Your noise drew monsters: they will strike your base in $_temp0.';
  }

  @override
  String get tipRaidAnnouncedLine2 =>
      'Recruit defenders: Harpooners are made for this.';

  @override
  String get tipRaidAnnouncedLine3 =>
      'The rampart of the Coral Citadel will also help you hold.';

  @override
  String get tipRaidReportTitle => 'The raid report';

  @override
  String get tipRaidReportLine1 =>
      'After each raid, the report shows the fight, your losses and the loot.';

  @override
  String get tipRaidReportLine2 =>
      'A lost raid plunders part of your resources.';

  @override
  String get tipRaidReportLine3 =>
      'A repelled raid wipes out your losing streak.';

  @override
  String get tipLastChanceTitle => 'Last chance';

  @override
  String tipLastChanceLine1(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your base has lost $count raids in a row.',
      one: 'Your base has lost $count raid.',
    );
    return '$_temp0';
  }

  @override
  String get tipLastChanceLine2 =>
      'If the next raid is lost too, the game is over.';

  @override
  String get tipLastChanceLine3 =>
      'Put your forces into defense: a victory wipes out the streak.';

  @override
  String get tipMonsterFamiliesTitle => 'Monster families';

  @override
  String get tipMonsterFamiliesLine1 =>
      'Each lair houses a family, with its own combat rule.';

  @override
  String get tipMonsterFamiliesLine2 =>
      'Each family has a weak spot: a unit that counters it.';

  @override
  String get tipMonsterFamiliesLine3 =>
      'Tap the lair on the Map to learn about it before you attack.';

  @override
  String get tipVolcanoWaveTitle => 'The Volcano\'s wave';

  @override
  String get tipVolcanoWaveLine1 =>
      'The Volcano sends its Krakens to take back the Core.';

  @override
  String get tipVolcanoWaveLine2 =>
      'The wave strikes at the end of next turn: keep a garrison at the Core.';

  @override
  String get tipVolcanoWaveLine3 => 'Each lost wave costs the Core a level.';

  @override
  String get tipLairTitle => 'Lairs';

  @override
  String get tipLairLine1 =>
      'On the Map, a monster lair guards its tile: attack it with your army.';

  @override
  String get tipLairLine2 =>
      'Beaten monsters leave their loot, but every fight makes noise.';

  @override
  String get tipLairLine3 => 'Check their numbers before you pick your units.';

  @override
  String get tipChestAndRuinsTitle => 'Chests and ruins';

  @override
  String get tipChestAndRuinsLine1 => 'A chest or ruins hide resources.';

  @override
  String get tipChestAndRuinsLine2 =>
      'Tap the tile on the Map to search them: it\'s safe and silent.';

  @override
  String get tipTransitionBaseTitle => 'Transition bases';

  @override
  String get tipTransitionBaseLine1 =>
      'A guarded base on the Map leads to the depths.';

  @override
  String get tipTransitionBaseLine2 =>
      'Once you storm it, it brings you pearls every turn.';

  @override
  String get tipTransitionBaseLine3 =>
      'It also opens the way to the next level.';

  @override
  String get tipDescentTitle => 'The descent';

  @override
  String get tipDescentLine1 =>
      'Your Descent Module sends units to the level below, through the Rift.';

  @override
  String get tipDescentLine2 =>
      'Careful: a unit sent down never comes back up.';

  @override
  String get tipDescentLine3 =>
      'Down there, more lairs await you, and the road to the Core.';

  @override
  String get tipEventsTitle => 'Events';

  @override
  String tipEventsLine1(int minGap, int maxGap) {
    return 'Every $minGap to $maxGap turns, an event shakes the abyss.';
  }

  @override
  String get tipEventsLine2 =>
      'You have the next turn to choose your answer on its card.';

  @override
  String get tipEventsLine3 =>
      'If you don\'t choose, the cautious option applies automatically.';

  @override
  String tipWarmCurrentLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turns',
      one: '$turns turn',
    );
    return 'A warm current boosts your production for $_temp0.';
  }

  @override
  String get tipWarmCurrentLine2 => 'But its swirl makes noise every turn.';

  @override
  String get tipWarmCurrentLine3 =>
      'Make the most of it if your defenses are ready for a raid.';

  @override
  String tipWreckLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turns',
      one: '$turns turn',
    );
    return 'A sunken galleon stays $_temp0 at the edge of the explored area.';
  }

  @override
  String get tipWreckLine2 =>
      'Explore its tile with a Scout, then search it for its loot.';

  @override
  String tipWreckLine3(int noise) {
    return 'Searching makes noise (+$noise): pick your moment.';
  }

  @override
  String get tipPredatorsLine1 =>
      'A great shark and its shoal prowl around your base.';

  @override
  String get tipPredatorsLine2 =>
      'Fight them for their loot, or give up algae to drive them away.';

  @override
  String get tipPredatorsLine3 => 'Losing to them never ends the game.';

  @override
  String tipStormLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turns',
      one: '$turns turn',
    );
    return 'The storm closes exploration for $_temp0.';
  }

  @override
  String tipStormLine2(int relief) {
    return 'In return, it covers your noise: the gauge drops by $relief.';
  }

  @override
  String get tipSurvivorsLine1 => 'A stranded capsule shelters survivors.';

  @override
  String get tipSurvivorsLine2 =>
      'Taken in, they join your base as Harpooners.';

  @override
  String get tipSurvivorsLine3 =>
      'Like the rest of your army, they eat algae every turn.';

  @override
  String get tipCaravanLine1 => 'A turtle caravan passes near your base.';

  @override
  String get tipCaravanLine2 =>
      'Its merchant crab trades your most plentiful resource for the scarcest one.';

  @override
  String tipColdCurrentLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turns',
      one: '$turns turn',
    );
    return 'A cold current slows your algae for $_temp0.';
  }

  @override
  String get tipColdCurrentLine2 =>
      'Heating the greenhouses costs energy, but saves the harvest.';

  @override
  String get tipColdCurrentLine3 =>
      'Without algae, your army can\'t hold out: watch your stock.';

  @override
  String get guideLessonHqLevel1 =>
      'Welcome to the abyss! Tap the HQ to start your first build: just one per turn to begin with. Then press “Next turn”.';

  @override
  String get guideLessonAlgaeFarm =>
      'Well done on your first build! Algae feed your army: every unit eats some each turn. Build the Algae Farm.';

  @override
  String get guideLessonMines =>
      'Coral and ore pay for almost everything. Build the Coral Mine, then the Ore Extractor, one per turn. Look closely: each level costs more than the one before.';

  @override
  String get guideLessonSolarPanel =>
      'The Extractor uses energy, and the Barracks will too. Without energy, they stop. Build the Solar Panel.';

  @override
  String guideLessonHqLevel2(int level) {
    return 'HQ level $level unlocks the Barracks and the Laboratory. But every build makes noise: watch the gauge at the top of the screen, it draws monsters.';
  }

  @override
  String guideLessonBarracksAndScouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Scouts',
      one: '$count Scout',
    );
    return 'Build the Barracks, then recruit $_temp0 in the Army tab. Every unit eats algae each turn, and every recruit raises the noise.';
  }

  @override
  String get guideLessonExplore =>
      'Around your base, everything is in the fog. On the Map, send a Scout to a nearby tile: you\'ll find monster lairs of different families there, and sometimes chests.';

  @override
  String get guideLessonLaboratoryAndResearch =>
      'Build the Laboratory, open a branch in the Tech tab and start a research project. Only one research per turn, and some choices are final: take the time to read.';

  @override
  String guideLessonFirstRaid(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turns',
      one: '$turns turn',
    );
    return 'Noise always ends up drawing a raid, announced $_temp0 ahead. Recruit Harpooners to defend your base. Later, the Citadel\'s rampart will help you too.';
  }

  @override
  String get guideGoalMet =>
      'Well done, that\'s it! End the turn to complete the objective and collect your reward.';

  @override
  String get guideWorksiteTaken =>
      'Your build for this turn is already taken. End the turn: you\'ll build the next one next turn.';

  @override
  String get guideAlreadyRecruited =>
      'You\'ve already recruited these units this turn. End the turn to recruit more.';

  @override
  String get guideExploring =>
      'Your Scout is on its way. End the turn to find out what the tile hides.';

  @override
  String guideStorm(int turn) {
    return 'A storm closes exploration until the end of turn $turn. Be patient: the objective will wait, end the turn.';
  }

  @override
  String guideWreckWithoutBarracks(int turn) {
    return 'A wreck has sunk near your base, visible until the end of turn $turn. Reaching it takes a Scout, so the Barracks: keep going with your objective, they will come.';
  }

  @override
  String guideWreckWithoutScout(int turn) {
    return 'A wreck has sunk near your base, visible until the end of turn $turn. Recruit a Scout in the Army tab to go and search it.';
  }

  @override
  String guideRaidIntro(int turn, int monsters) {
    String _temp0 = intl.Intl.pluralLogic(
      monsters,
      locale: localeName,
      other: '$monsters monsters',
      one: '$monsters monster',
    );
    return 'The raid arrives on turn $turn with $_temp0.';
  }

  @override
  String get guideRaidOutOfReach =>
      'Recruit as many Harpooners as you can in the Army tab.';

  @override
  String get guideRaidHeld =>
      'Your defense should repel it: end the turn to wait for it.';

  @override
  String guideRaidNeeded(int needed, int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      needed,
      locale: localeName,
      other: '$needed Harpooners',
      one: '$needed Harpooner',
    );
    return 'Have at least $_temp0 on level 1: you\'re $missing short.';
  }

  @override
  String guideRaidRecruitNow(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Recruit them in the Army tab.',
      one: 'Recruit it in the Army tab.',
    );
    return '$_temp0';
  }

  @override
  String guideRaidRecruitNextTurn(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'them',
      one: 'it',
    );
    return 'You\'ve already recruited this turn: recruit $_temp0 next turn.';
  }

  @override
  String get guideRaidHoldOn =>
      'You\'ve already recruited this turn: end it and hold on.';

  @override
  String get tutorialGuideSwitch => 'Tutorial guide';

  @override
  String get tutorialGuideSwitchHint =>
      'The guide shows you what to do, one objective at a time';

  @override
  String get tutorialTipsSwitch => 'Tips';

  @override
  String get tutorialTipsSwitchHint =>
      'A card explains each new feature the first time it shows up';

  @override
  String get tutorialReviewTips => 'Review the tip cards';
}

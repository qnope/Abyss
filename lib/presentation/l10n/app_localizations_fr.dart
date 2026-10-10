// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get newGameTitle => 'Nouvelle Partie';

  @override
  String get newGameEnterName => 'Entrez votre nom';

  @override
  String get newGameNameHint => 'Nom du joueur';

  @override
  String get newGameNameEmpty => 'Veuillez entrer un nom';

  @override
  String newGameNameTooShort(int min) {
    return 'Le nom doit contenir au moins $min caractères';
  }

  @override
  String get newGameTutorial => 'Tutoriel';

  @override
  String get newGameTutorialHint =>
      'Un guide t\'accompagne sur les premiers tours';

  @override
  String get newGameStart => 'Commencer';

  @override
  String get difficultyTitle => 'Difficulté';

  @override
  String get buildingHeadquartersName => 'Quartier Général';

  @override
  String buildingHeadquartersDescription(int coral, int ore) {
    return 'Centre de commandement de votre base sous-marine. Son niveau détermine les capacités de votre colonie. Une fois bâti, il fournit $coral corail et $ore minerai par tour.';
  }

  @override
  String get buildingAlgaeFarmName => 'Ferme d\'algues';

  @override
  String get buildingAlgaeFarmDescription =>
      'Cultive des algues pour nourrir votre colonie sous-marine.';

  @override
  String get buildingCoralMineName => 'Mine de corail';

  @override
  String get buildingCoralMineDescription =>
      'Extrait du corail des récifs pour la construction.';

  @override
  String get buildingCoralCitadelName => 'Citadelle corallienne';

  @override
  String get buildingCoralCitadelDescription =>
      'Forteresse corallienne massive qui dresse un rempart pour la défense de votre base. Pendant un raid, il encaisse les coups à la place des unités stationnées.';

  @override
  String get buildingOreExtractorName => 'Extracteur de minerai';

  @override
  String get buildingOreExtractorDescription =>
      'Fore les profondeurs pour extraire du minerai océanique.';

  @override
  String get buildingSolarPanelName => 'Panneau solaire';

  @override
  String get buildingSolarPanelDescription =>
      'Capte l\'énergie solaire pour alimenter vos installations.';

  @override
  String get buildingLaboratoryName => 'Laboratoire';

  @override
  String get buildingLaboratoryDescription =>
      'Centre de recherche sous-marin pour développer de nouvelles technologies.';

  @override
  String get buildingBarracksName => 'Caserne';

  @override
  String get buildingBarracksDescription =>
      'Forme et entraîne vos unités militaires sous-marines.';

  @override
  String get buildingDescentModuleName => 'Module de Descente';

  @override
  String get buildingDescentModuleDescription =>
      'Module spécialisé permettant l\'assaut des failles abyssales.';

  @override
  String get buildingPressureCapsuleName => 'Capsule Pressurisée';

  @override
  String get buildingPressureCapsuleDescription =>
      'Capsule haute pression permettant l\'assaut des cheminées hydrothermales.';

  @override
  String get buildingVolcanicKernelName => 'Noyau Volcanique';

  @override
  String get buildingVolcanicKernelDescription =>
      'Le cœur brûlant des abysses. Construisez-le au niveau 10 pour remporter la victoire. Sa garnison se gère ici, ou depuis sa case sur la carte.';

  @override
  String get unitScoutName => 'Éclaireur';

  @override
  String get unitScoutRole => 'Éclaireur';

  @override
  String get unitScoutRoleEffect =>
      'Fuit au lieu de mourir : revient toujours blessé.';

  @override
  String get unitHarpoonistName => 'Harponneur';

  @override
  String get unitHarpoonistRole => 'DPS';

  @override
  String get unitHarpoonistRoleEffect =>
      'Dégâts réguliers, sans règle spéciale.';

  @override
  String get unitGuardianName => 'Gardien';

  @override
  String get unitGuardianRole => 'Tank';

  @override
  String get unitGuardianRoleEffect =>
      'Provoque : les monstres le ciblent en priorité.';

  @override
  String get unitDomeBreakerName => 'Briseur';

  @override
  String get unitDomeBreakerRole => 'Siège';

  @override
  String get unitDomeBreakerRoleEffect =>
      'Inflige le double de dégâts aux boss.';

  @override
  String get unitAbyssAdmiralName => 'Amiral des Abysses';

  @override
  String get unitAbyssAdmiralRole => 'Amiral';

  @override
  String get unitAbyssAdmiralRoleEffect =>
      'Commande les assauts, sans combattre.';

  @override
  String get unitSaboteurName => 'Saboteur';

  @override
  String get unitSaboteurRole => 'Verre-canon';

  @override
  String get unitSaboteurRoleEffect => 'Ignore la défense de sa cible.';

  @override
  String unitScoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éclaireurs',
      one: '$count éclaireur',
    );
    return '$_temp0';
  }

  @override
  String unitHarpoonistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count harponneurs',
      one: '$count harponneur',
    );
    return '$_temp0';
  }

  @override
  String unitGuardianCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gardiens',
      one: '$count gardien',
    );
    return '$_temp0';
  }

  @override
  String unitDomeBreakerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count briseurs',
      one: '$count briseur',
    );
    return '$_temp0';
  }

  @override
  String unitAbyssAdmiralCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amiraux des abysses',
      one: '$count amiral des abysses',
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
  String get resourceAlgaeName => 'Algues';

  @override
  String get resourceAlgaeFlavor =>
      'Nourriture cultivée dans les fermes sous-marines pour nourrir vos unités.';

  @override
  String get resourceCoralName => 'Corail';

  @override
  String get resourceCoralFlavor =>
      'Matériau de construction récolté sur les récifs pour bâtir votre base.';

  @override
  String get resourceOreName => 'Minerai';

  @override
  String get resourceOreFlavor =>
      'Métal extrait des profondeurs pour forger des équipements avancés.';

  @override
  String get resourceEnergyName => 'Énergie';

  @override
  String get resourceEnergyFlavor =>
      'Énergie captée pour alimenter vos bâtiments et machines.';

  @override
  String get resourcePearlName => 'Perles';

  @override
  String get resourcePearlFlavor =>
      'Gemmes rares trouvées dans les ruines et les repaires, et récoltées chaque tour dans les failles et cheminées capturées.';

  @override
  String get monsterFamilyGenericLabel => 'Rôdeurs';

  @override
  String get monsterFamilySwarmLabel => 'Nuée';

  @override
  String get monsterFamilyArmouredLabel => 'Carapaces';

  @override
  String get monsterFamilyHunterLabel => 'Chasseurs';

  @override
  String get monsterFamilyColossusLabel => 'Colosses';

  @override
  String get monsterFamilyKrakenLabel => 'Kraken';

  @override
  String monsterFamilyGenericCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monstres',
      one: '$count monstre',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilySwarmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dents-de-verre',
      one: '$count Dents-de-verre',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyArmouredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Isopodes cuirassés',
      one: '$count Isopode cuirassé',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyHunterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Calmars-chasseurs',
      one: '$count Calmar-chasseur',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyColossusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Requins dormeurs',
      one: '$count Requin dormeur',
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
      'Essaim : un coup de Harponneur touche deux poissons.';

  @override
  String get monsterFamilyArmouredRule =>
      'Cuirasse : seuls les Saboteurs ignorent leur DEF.';

  @override
  String get monsterFamilyHunterRule =>
      'Traque : ils visent l\'unité la plus fragile et frappent deux fois plus fort, sauf un Gardien ou le rempart qui provoque.';

  @override
  String get monsterFamilyColossusRule =>
      'Géants : tous des boss, que les Briseurs frappent double.';

  @override
  String get monsterFamilyKrakenRule =>
      'Étreinte : chaque coup de tentacule frappe aussi un deuxième défenseur. Des boss, que les Briseurs frappent double.';

  @override
  String get monsterFamilySwarmWeakness => 'Harponneurs';

  @override
  String get monsterFamilyArmouredWeakness => 'Saboteurs';

  @override
  String get monsterFamilyHunterWeakness => 'Gardiens';

  @override
  String get monsterFamilyColossusWeakness => 'Briseurs de dôme';

  @override
  String monsterLairGroupsAnd(String first, String second) {
    return '$first et $second';
  }

  @override
  String monsterLairWave(String monsters, int level) {
    return '$monsters niv. $level';
  }

  @override
  String monsterLairWeakAgainst(String units) {
    return 'Faibles contre : $units';
  }

  @override
  String get monsterDifficultyEasy => 'Facile';

  @override
  String get monsterDifficultyMedium => 'Moyen';

  @override
  String get monsterDifficultyHard => 'Difficile';

  @override
  String get randomEventWarmCurrentLabel => 'Courant chaud';

  @override
  String get randomEventWreckLabel => 'Épave';

  @override
  String get randomEventPredatorsLabel => 'Banc de prédateurs';

  @override
  String get randomEventStormLabel => 'Tempête';

  @override
  String get randomEventSurvivorsLabel => 'Survivants';

  @override
  String get randomEventCaravanLabel => 'Caravane de tortues';

  @override
  String get randomEventColdCurrentLabel => 'Courant froid';

  @override
  String eventCountdown(String label, int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns tours',
      one: '$turns tour',
    );
    return '$label : encore $_temp0';
  }

  @override
  String eventColdCurrentHeated(String label) {
    return '$label (serres chauffées)';
  }

  @override
  String get techBranchMilitaryName => 'Militaire';

  @override
  String get techBranchMilitaryDescription =>
      'Améliore l\'attaque et la défense de toutes les unités.';

  @override
  String get techBranchResourcesName => 'Ressources';

  @override
  String get techBranchResourcesDescription =>
      'Améliore la production de toutes les ressources.';

  @override
  String get techBranchExplorerName => 'Explorateur';

  @override
  String get techBranchExplorerDescription =>
      'Améliore la portée d\'exploration de la carte.';

  @override
  String get techTierEffect => '+20 % ATK et DEF';

  @override
  String get techProductionEffect => '+20 % de production';

  @override
  String techExploredAreaEffect(int size) {
    return 'Zone explorée $size×$size';
  }

  @override
  String get techMilitary1Name => 'Trident aiguisé';

  @override
  String get techMilitary2aName => 'Lames de corail';

  @override
  String get techMilitary2aEffect => '+35 % ATK';

  @override
  String get techMilitary2bName => 'Carapace de nacre';

  @override
  String get techMilitary2bEffect => '+35 % PV';

  @override
  String get techMilitary3Name => 'Discipline des abysses';

  @override
  String get techMilitary4aName => 'Rempart vivant';

  @override
  String get techMilitary4aEffect => '+35 % DEF en défense de la base';

  @override
  String get techMilitary4bName => 'Assaut des profondeurs';

  @override
  String get techMilitary4bEffect =>
      '+35 % ATK contre repaires, bases et Noyau';

  @override
  String get techMilitary5Name => 'Légion abyssale';

  @override
  String get techResources1Name => 'Bancs fertiles';

  @override
  String get techResources2aName => 'Culture intensive';

  @override
  String get techResources2aEffect => '+35 % d\'algues et de corail';

  @override
  String get techResources2bName => 'Forage profond';

  @override
  String get techResources2bEffect => '+35 % de minerai et d\'énergie';

  @override
  String get techResources3Name => 'Courants nourriciers';

  @override
  String get techResources4aName => 'Coffres scellés';

  @override
  String get techResources4aEffect =>
      'Un raid perdu pille 15 % au lieu de 30 %';

  @override
  String get techResources4bName => 'Chantiers économes';

  @override
  String get techResources4bEffect => 'Améliorations 15 % moins chères';

  @override
  String get techResources5Name => 'Abondance des grands fonds';

  @override
  String get techExplorer1Name => 'Lanterne bioluminescente';

  @override
  String get techExplorer2aName => 'Sonar profond';

  @override
  String get techExplorer2aEffect => 'Zone explorée agrandie de 2';

  @override
  String get techExplorer2bName => 'Nage silencieuse';

  @override
  String get techExplorer2bEffect =>
      'Explorer et combattre ne font plus de bruit';

  @override
  String get techExplorer3Name => 'Cartographie des courants';

  @override
  String get techExplorer4aName => 'Pillards d\'épaves';

  @override
  String get techExplorer4aEffect =>
      '+50 % de butin (repaires, trésors, raids repoussés)';

  @override
  String get techExplorer4bName => 'Sentinelles';

  @override
  String get techExplorer4bEffect =>
      'Raids annoncés 4 tours à l\'avance au lieu de 2';

  @override
  String get techExplorer5Name => 'Œil de l\'abysse';

  @override
  String get terrainPlain => 'Plaine';

  @override
  String get cellContentEmpty => 'Vide';

  @override
  String get cellContentResourceBonus => 'Ressources';

  @override
  String get cellContentRuins => 'Ruines';

  @override
  String get cellContentMonsterLair => 'Repaire';

  @override
  String get cellContentPassage => 'Passage';

  @override
  String get transitionBaseFailleName => 'Faille Abyssale';

  @override
  String get transitionBaseFailleDescription => 'Passage vers les profondeurs';

  @override
  String get transitionBaseChemineeName => 'Cheminée du Noyau';

  @override
  String get transitionBaseChemineeDescription => 'Passage vers le noyau';

  @override
  String get difficultyEasyName => 'Facile';

  @override
  String get difficultyEasyDescription =>
      'Plus de ressources, des monstres moins nombreux.';

  @override
  String get difficultyNormalName => 'Normal';

  @override
  String get difficultyNormalDescription =>
      'L\'équilibre prévu pour les abysses.';

  @override
  String get difficultyHardName => 'Difficile';

  @override
  String get difficultyHardDescription =>
      'Moins de ressources, des monstres plus nombreux.';

  @override
  String get temporaryObjectiveWreckShort => 'Épave';

  @override
  String get temporaryObjectivePredatorsShort => 'Prédateurs';

  @override
  String temporaryObjectiveWreckTitle(int turn) {
    return 'Fouille l\'épave d\'ici la fin du tour $turn';
  }

  @override
  String get temporaryObjectivePredatorsTitle =>
      'Repousse le banc de prédateurs';

  @override
  String get historyCategoryCombat => 'Combat';

  @override
  String get historyCategoryBuilding => 'Construction';

  @override
  String get historyCategoryResearch => 'Recherche';

  @override
  String get historyCategoryRecruit => 'Recrutement';

  @override
  String get historyCategoryExplore => 'Exploration';

  @override
  String get historyCategoryCollect => 'Collecte';

  @override
  String get historyCategoryTurnEnd => 'Fin de tour';

  @override
  String get historyCategoryCapture => 'Capture';

  @override
  String get historyCategoryDescent => 'Descente';

  @override
  String get historyCategoryReinforcement => 'Renfort';

  @override
  String get historyCategoryRaid => 'Raid';

  @override
  String get historyCategoryVolcano => 'Volcan';

  @override
  String get historyCategoryEvent => 'Événement';

  @override
  String get actionFailureUnknown => 'Action impossible';

  @override
  String get actionFailureMapNotGenerated => 'Carte non générée';

  @override
  String get actionFailureCellNotRevealed => 'Case non révélée';

  @override
  String get actionFailureCellNotEligible => 'Cellule non éligible';

  @override
  String get actionFailureAlreadyCollected => 'Déjà collecté';

  @override
  String get actionFailureNothingToCollect => 'Rien à collecter';

  @override
  String get actionFailureStormBlocksExploration =>
      'Tempête : exploration impossible';

  @override
  String get actionFailureNoScoutAvailable => 'Aucun éclaireur disponible';

  @override
  String get actionFailureNoMonsterHere => 'Pas de monstre ici';

  @override
  String get actionFailureLairAlreadyDefeated => 'Repaire déjà vaincu';

  @override
  String get actionFailureLairEmpty => 'Repaire vide';

  @override
  String get actionFailureNotEnoughUnits => 'Unités insuffisantes';

  @override
  String get actionFailureNoUnitSelected => 'Aucune unité sélectionnée';

  @override
  String get actionFailureAdmiralRequired => 'Un Amiral des Abysses est requis';

  @override
  String get actionFailureNoTransitionBaseHere =>
      'Pas de base de transition ici';

  @override
  String get actionFailureBaseNotFound => 'Base introuvable';

  @override
  String get actionFailureBaseAlreadyCaptured => 'Base déjà capturée';

  @override
  String get actionFailureBaseNotCaptured => 'Base non capturée';

  @override
  String get actionFailureTargetLevelNotExplored => 'Niveau cible non exploré';

  @override
  String get actionFailureRequiredBuildingMissing => 'Bâtiment requis manquant';

  @override
  String get actionFailureNoVolcanicKernelHere => 'Pas de noyau volcanique ici';

  @override
  String get actionFailureKernelAlreadyCaptured => 'Noyau déjà capturé';

  @override
  String get actionFailureKernelNotCaptured => 'Noyau non capturé';

  @override
  String get actionFailureNoPendingEvent => 'Aucun événement en attente';

  @override
  String get actionFailureNotThisChoiceTurn =>
      'Ce n\'est pas le tour de ce choix';

  @override
  String get actionFailureNotEnoughStockToTrade =>
      'Stock insuffisant pour échanger';

  @override
  String get actionFailureBranchNotFound => 'Branche introuvable';

  @override
  String get actionFailureBranchLocked => 'Branche verrouillée';

  @override
  String get actionFailureBranchAlreadyUnlocked => 'Branche déjà débloquée';

  @override
  String get actionFailureLaboratoryRequired => 'Laboratoire requis';

  @override
  String get actionFailureLaboratoryLevelTooLow =>
      'Niveau de laboratoire insuffisant';

  @override
  String get actionFailureResearchAlreadyStarted =>
      'Recherche déjà lancée ce tour';

  @override
  String get actionFailureBuildingNotFound => 'Bâtiment introuvable';

  @override
  String get actionFailureWorksitesBusy => 'Chantiers occupés ce tour';

  @override
  String get actionFailureMaxLevelReached => 'Niveau maximum atteint';

  @override
  String get actionFailureNotEnoughResources => 'Ressources insuffisantes';

  @override
  String get actionFailureUnitLocked => 'Unité verrouillée';

  @override
  String get actionFailureRecruitmentAlreadyDone =>
      'Recrutement déjà effectué ce tour';

  @override
  String get actionFailureInvalidQuantity => 'Quantité invalide';

  @override
  String get actionFailureGameOver => 'Partie terminée';

  @override
  String historyBuildingTitle(String building, int level) {
    return '$building niv. $level';
  }

  @override
  String historyResearchUnlocked(String branch) {
    return '$branch débloquée';
  }

  @override
  String historyResearchLevel(String branch, int level) {
    return '$branch niv. $level';
  }

  @override
  String historyResearchImproved(String branch) {
    return '$branch améliorée';
  }

  @override
  String historyRecruitTitle(int count, String units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$units recrutés',
      one: '$units recruté',
    );
    return '$_temp0';
  }

  @override
  String historyExploreTitle(int x, int y) {
    return 'Exploration ($x, $y)';
  }

  @override
  String historyCollectTitle(int x, int y) {
    return 'Trésor collecté ($x, $y)';
  }

  @override
  String historyCombatVictory(int level) {
    return 'Victoire vs Repaire niv. $level';
  }

  @override
  String historyCombatDefeat(int level) {
    return 'Défaite vs Repaire niv. $level';
  }

  @override
  String historyTurnEndTitle(int turn) {
    return 'Tour $turn terminé';
  }

  @override
  String historyCaptureTitle(String name) {
    return 'Capture : $name';
  }

  @override
  String historyCaptureVictory(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'Victoire en $turns tours',
      one: 'Victoire en $turns tour',
    );
    return '$_temp0';
  }

  @override
  String historyDescentTitle(int level) {
    return 'Descente au Niveau $level';
  }

  @override
  String historyDescentUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unités envoyées',
      one: '$count unité envoyée',
    );
    return '$_temp0';
  }

  @override
  String historyReinforcementTitle(int level) {
    return 'Renforts vers Niveau $level';
  }

  @override
  String historyReinforcementUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unités en transit',
      one: '$count unité en transit',
    );
    return '$_temp0';
  }

  @override
  String get historyRaidRepelled => 'Raid repoussé';

  @override
  String get historyRaidLost => 'Base pillée par un raid';

  @override
  String get historyPredatorsRepelled => 'Banc de prédateurs repoussé';

  @override
  String get historyPredatorsLost => 'Base pillée par un banc de prédateurs';

  @override
  String get historyVolcanoRepelled => 'Vague repoussée sur le Noyau';

  @override
  String get historyVolcanoLost => 'Le Noyau a perdu un niveau';

  @override
  String get historyEventAccepted => 'Accepté';

  @override
  String get historyEventRefused => 'Refusé';

  @override
  String get historyEventDefaulted => 'Option prudente, sans choix';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonOk => 'OK';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonGotIt => 'Compris';

  @override
  String get commonSend => 'Envoyer';

  @override
  String get commonBackToBase => 'Retour à la base';

  @override
  String get commonBackToMap => 'Retour à la carte';

  @override
  String commonTurn(int turn) {
    return 'Tour $turn';
  }

  @override
  String get statHp => 'PV';

  @override
  String get statAttack => 'ATK';

  @override
  String get statDefense => 'DEF';

  @override
  String get fightVictory => 'VICTOIRE';

  @override
  String get fightDefeat => 'DÉFAITE';

  @override
  String get fightKernelCaptured => 'NOYAU CAPTURÉ';

  @override
  String get fightBaseCaptured => 'BASE CAPTURÉE';

  @override
  String fightTurnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Combat en $count tours',
      one: 'Combat en $count tour',
    );
    return '$_temp0';
  }

  @override
  String get fightYourUnits => 'Vos unités';

  @override
  String fightUnitAccounting(int sent, int intact, int wounded, int dead) {
    return 'Envoyés : $sent / Intactes : $intact / Blessés : $wounded / Morts : $dead';
  }

  @override
  String fightEnemiesKilled(int killed, int total) {
    return 'Ennemis tués : $killed/$total';
  }

  @override
  String fightGuardiansKilled(int killed, int total) {
    return 'Gardiens éliminés : $killed/$total';
  }

  @override
  String get fightLoot => 'Butin';

  @override
  String get fightNoLoot => 'Aucun butin';

  @override
  String fightTitle(int x, int y) {
    return 'Combat ($x, $y)';
  }

  @override
  String fightAssaultTitle(int x, int y) {
    return 'Assaut ($x, $y)';
  }

  @override
  String fightAssaultOn(String target) {
    return 'Assaut : $target';
  }

  @override
  String get fightPrepare => 'Préparer le combat';

  @override
  String get fightLaunch => 'Lancer le combat';

  @override
  String get fightLaunchAssault => 'Lancer l\'assaut';

  @override
  String get fightAdmiralRequired =>
      'Un Amiral des Abysses est requis pour lancer l\'assaut';

  @override
  String fightStock(int count) {
    return 'Stock : $count';
  }

  @override
  String fightAlliesAlive(int count) {
    return 'Alliés vivants : $count';
  }

  @override
  String fightAlliesHp(int hp) {
    return 'PV alliés : $hp';
  }

  @override
  String fightDamageDealt(int damage) {
    return 'Dégâts infligés : $damage';
  }

  @override
  String fightEnemiesAlive(int count) {
    return 'Ennemis vivants : $count';
  }

  @override
  String fightEnemiesHp(int hp) {
    return 'PV ennemis : $hp';
  }

  @override
  String fightDamageTaken(int damage) {
    return 'Dégâts subis : $damage';
  }

  @override
  String fightCriticalHits(int count) {
    return 'Coups critiques : $count';
  }

  @override
  String fightMilitaryBonus(String bonuses) {
    return 'Bonus militaire : $bonuses';
  }

  @override
  String get fightMilitaryBonusNone => 'Bonus militaire : aucun';

  @override
  String fightLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String fightWeakAgainst(String unit) {
    return 'Faible contre : $unit';
  }

  @override
  String get mapLevelSurface => 'Surface';

  @override
  String get mapLevelDepths => 'Profondeurs';

  @override
  String get mapLevelCore => 'Noyau';

  @override
  String mapLevelChip(int level, String name) {
    return 'Niv. $level : $name';
  }

  @override
  String get mapDifficulty => 'Difficulté';

  @override
  String get mapLevel => 'Niveau';

  @override
  String get mapUnits => 'Unités';

  @override
  String get mapIncomeOnceCaptured => 'Revenu une fois capturée';

  @override
  String mapPearlsPerTurn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count perles par tour',
      one: '+$count perle par tour',
    );
    return '$_temp0';
  }

  @override
  String get mapGuardedNeutral => 'Neutre — Gardiens présents';

  @override
  String get mapAssault => 'Assaut';

  @override
  String get mapCaptured => 'Capturée';

  @override
  String mapUnitsOnLevel(int count, int level) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unités au Niveau $level',
      one: '$count unité au Niveau $level',
    );
    return '$_temp0';
  }

  @override
  String mapBuildingRequired(String building) {
    return 'Bâtiment requis pour envoyer des unités : $building';
  }

  @override
  String mapSendUnitsToLevel(int level) {
    return 'Envoyer des unités au Niveau $level';
  }

  @override
  String mapExploreTitle(int x, int y) {
    return 'Explorer ($x, $y)';
  }

  @override
  String get mapCost => 'Coût';

  @override
  String get mapScoutsAvailable => 'Éclaireurs disponibles';

  @override
  String get mapRevealedArea => 'Zone révélée';

  @override
  String mapAreaCells(int side) {
    return '$side×$side cellules';
  }

  @override
  String get mapKernelUncaptured =>
      'Le cœur brûlant des abysses est gardé par de puissants gardiens.';

  @override
  String get mapKernelCaptured =>
      'Tu as capturé le Noyau Volcanique. Monte-le au niveau 10 pour remporter la victoire. Dès le niveau 1, le Kraken vient le reprendre chaque tour : une vague gagnée lui retire un niveau.';

  @override
  String mapTreasureTitle(int x, int y) {
    return 'Trésor ($x, $y)';
  }

  @override
  String get mapCollectTreasure => 'Collecter le trésor';

  @override
  String get mapTreasureResourceBonus => 'Algues, corail et minerai';

  @override
  String get mapTreasureRuins => 'Corail, minerai et perles';

  @override
  String get mapTreasureWreck => 'Corail, minerai et une perle';

  @override
  String get raidName => 'Raid';

  @override
  String get raidPillage => 'Pillage';

  @override
  String get raidNothingToLoot => 'Rien à piller';

  @override
  String raidPredatorsTitle(int turn) {
    return 'Banc de prédateurs (tour $turn)';
  }

  @override
  String raidTitle(int turn) {
    return 'Raid sur la base (tour $turn)';
  }

  @override
  String raidRampart(int level) {
    return 'Rempart de la Citadelle niv. $level';
  }

  @override
  String get raidNoise => 'Bruit';

  @override
  String raidLostInARow(int lost, int limit) {
    return 'Raids perdus d\'affilée : $lost/$limit';
  }

  @override
  String raidIncomingThisTurn(String wave) {
    return 'Raid à la fin de ce tour : $wave';
  }

  @override
  String raidIncomingOnTurn(int turn, String wave) {
    return 'Raid à la fin du tour $turn : $wave';
  }

  @override
  String get raidBaseLooted => 'La base a été pillée';

  @override
  String raidAnnounced(String wave, int turn) {
    return 'Un raid approche : $wave, fin du tour $turn';
  }

  @override
  String raidDueThisTurn(String attacker, String wave, String defenders) {
    return '$attacker ce tour : $wave contre $defenders';
  }

  @override
  String raidDefenders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count défenseurs',
      one: '$count défenseur',
      zero: 'aucun défenseur',
    );
    return '$_temp0';
  }

  @override
  String get raidLastChance => 'Si ce raid est perdu, la partie est terminée.';

  @override
  String volcanoWaveTitle(int turn) {
    return 'Vague sur le Noyau (tour $turn)';
  }

  @override
  String volcanoKernelHolds(int level) {
    return 'Le Noyau tient au niveau $level';
  }

  @override
  String volcanoKernelDrops(int level) {
    return 'Le Noyau retombe au niveau $level';
  }

  @override
  String volcanoMagmaRampart(String stats) {
    return 'Rempart de magma : $stats';
  }

  @override
  String volcanoKernelLevel(int level) {
    return 'Noyau niveau $level';
  }

  @override
  String volcanoGarrison(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Garnison : $count unités',
      one: 'Garnison : $count unité',
    );
    return '$_temp0';
  }

  @override
  String volcanoNextWave(String wave) {
    return 'Prochaine vague, à la fin du tour : $wave';
  }

  @override
  String volcanoLevelsLost(int count) {
    return 'Niveaux perdus face aux vagues : $count';
  }

  @override
  String get volcanoGarrisonUnits => 'Mettre en garnison';

  @override
  String get volcanoWithdraw => 'Retirer';

  @override
  String volcanoDueWarning(String wave) {
    return 'Vague sur le Noyau ce tour : $wave, et aucune garnison. Le Noyau perdra probablement un niveau.';
  }

  @override
  String volcanoStatus(int level, String wave, int size) {
    return 'Noyau niv. $level, fin du tour : $wave contre une garnison de $size';
  }

  @override
  String volcanoRepelled(String losses) {
    return 'Volcan : vague repoussée, $losses';
  }

  @override
  String volcanoKernelFell(int level) {
    return 'Volcan : le Noyau retombe au niveau $level';
  }

  @override
  String volcanoWounded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blessés',
      one: '$count blessé',
    );
    return '$_temp0';
  }

  @override
  String volcanoDead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morts',
      one: '$count mort',
    );
    return '$_temp0';
  }

  @override
  String volcanoKrakenRises(String wave) {
    return 'Le Kraken remonte : $wave au prochain tour';
  }

  @override
  String get eventCardWarmLine1 => 'Un courant chaud traverse la base.';

  @override
  String get eventCardWarmLine2 =>
      'Il dope la production, mais son remous fait du bruit.';

  @override
  String get eventCardColdLine1 => 'Un courant froid glace les serres.';

  @override
  String get eventCardColdLine2 => 'Sans chauffage, les algues poussent moins.';

  @override
  String get eventCardPredatorsLine1 =>
      'Un banc de prédateurs rôde autour de la base.';

  @override
  String get eventCardPredatorsWatching => 'Ils guettent la base.';

  @override
  String eventCardPredatorsWave(String wave, String defenders) {
    return '$wave contre $defenders du niveau 1.';
  }

  @override
  String get eventCardSurvivorsLine1 =>
      'Une capsule échouée lance une fusée de détresse.';

  @override
  String get eventCardSurvivorsLine2 =>
      'Ses survivants peuvent rejoindre la base, mais mangeront des algues.';

  @override
  String get eventCardCaravanLine1 =>
      'Une caravane de tortues passe près de la base.';

  @override
  String get eventCardCaravanLine2 => 'Son crabe marchand propose un échange.';

  @override
  String eventCardStormLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'Exploration impossible pendant $turns tours.',
      one: 'Exploration impossible pendant $turns tour.',
    );
    return '$_temp0';
  }

  @override
  String eventCardStormLine2(int relief) {
    return 'La tempête couvre le bruit : jauge −$relief.';
  }

  @override
  String get eventCardWreckLine1 =>
      'Une épave a coulé au bord de la zone explorée.';

  @override
  String eventCardWreckLine2(int turns, int noise) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other:
          'Explore-la avec un Éclaireur puis fouille-la avant $turns tours (+$noise bruit).',
      one:
          'Explore-la avec un Éclaireur puis fouille-la avant $turns tour (+$noise bruit).',
    );
    return '$_temp0';
  }

  @override
  String eventCardWarmAccept(int percent, int turns, int noise) {
    return 'Exploiter (+$percent % algues, corail, minerai pendant $turns tours, +$noise bruit/tour)';
  }

  @override
  String get eventCardWarmRefuse => 'Laisser passer';

  @override
  String eventCardColdAccept(int energy, int turns) {
    return 'Chauffer les serres (−$energy énergie/tour pendant $turns tours)';
  }

  @override
  String eventCardColdRefuse(int percent, int turns) {
    return 'Subir (−$percent % d\'algues pendant $turns tours)';
  }

  @override
  String eventCardPredatorsAccept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'L\'affronter ($count monstres, fin du tour)',
      one: 'L\'affronter ($count monstre, fin du tour)',
    );
    return '$_temp0';
  }

  @override
  String eventCardPredatorsRefuse(int algae) {
    return 'L\'appâter (−$algae algues)';
  }

  @override
  String eventCardSurvivorsAccept(String units) {
    return 'Accueillir $units';
  }

  @override
  String get eventCardRefuse => 'Refuser';

  @override
  String eventCardTrade(int give, String from, int get, String to) {
    return 'Échanger $give $from contre $get $to';
  }

  @override
  String get eventCardLater => 'Plus tard';

  @override
  String eventCardPendingWarning(String event) {
    return '$event : sans choix, l\'option prudente s\'appliquera';
  }

  @override
  String eventCardStatusPending(String event) {
    return 'Événement : $event — choisir';
  }

  @override
  String get techScreenUnlock => 'Débloquer';

  @override
  String get techScreenResearch => 'Rechercher';

  @override
  String techScreenChoiceTitle(String branch, int level) {
    return '$branch · Niveau $level · Choix';
  }

  @override
  String techScreenNodeSubtitle(String branch, int level, String effect) {
    return '$branch · Niveau $level · $effect';
  }

  @override
  String get techScreenChoiceWarning =>
      'Une seule option par partie, l\'autre sera perdue.';

  @override
  String get techScreenChoose => 'Choisir';

  @override
  String get techScreenChosen => 'Choisi ✓';

  @override
  String get techScreenDiscarded => 'Écarté';

  @override
  String get techScreenOr => 'ou';

  @override
  String get techScreenAcquired => 'Acquis ✓';

  @override
  String techScreenSurcharge(String factor) {
    return 'Toutes les recherches coûteront ×$factor une fois cette branche ouverte.';
  }

  @override
  String get techScreenUnlockBranchFirst => 'Débloque d\'abord la branche';

  @override
  String techScreenResearchPreviousFirst(int level) {
    return 'Recherche d\'abord le niveau $level';
  }

  @override
  String techScreenLabRequired(int level) {
    return 'Laboratoire niveau $level requis';
  }

  @override
  String get techScreenOneResearchPerTurn =>
      'Une recherche par tour : attends le prochain tour';

  @override
  String techScreenMedallionLevel(int level) {
    return 'Niv. $level';
  }

  @override
  String get objectiveSheetTitle => 'Objectifs';

  @override
  String get objectiveEventHeader => 'Objectifs d\'événement';

  @override
  String objectiveProgress(String title, int current, int target) {
    return '$title : $current/$target';
  }

  @override
  String objectiveCompleted(String title) {
    return 'Objectif accompli : $title';
  }

  @override
  String get objectiveMissed => '(raté)';

  @override
  String objectiveRaiseHq(int level) {
    return 'Monte le QG au niveau $level';
  }

  @override
  String get objectiveAlgaeFarm => 'Construis la Ferme d\'algues';

  @override
  String get objectiveMines =>
      'Construis la Mine de corail et l\'Extracteur de minerai';

  @override
  String get objectiveSolarPanel => 'Construis le Panneau solaire';

  @override
  String objectiveBarracksAndScouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Éclaireurs',
      one: '$count Éclaireur',
    );
    return 'Construis la Caserne et recrute $_temp0';
  }

  @override
  String get objectiveExplore => 'Explore une case autour de la base';

  @override
  String get objectiveLaboratoryAndResearch =>
      'Construis le Laboratoire et lance une recherche';

  @override
  String get objectiveFirstRaid => 'Repousse le premier raid';

  @override
  String get objectiveTakeLair => 'Prends un repaire';

  @override
  String get objectiveCoralCitadel => 'Construis la Citadelle corallienne';

  @override
  String get objectiveTakeFaille => 'Prends la Faille';

  @override
  String get objectiveDescentModule => 'Construis le Module de Descente';

  @override
  String objectiveDescend(int level) {
    return 'Descends au niveau $level';
  }

  @override
  String get objectiveTakeCheminee => 'Prends la Cheminée';

  @override
  String get objectivePressureCapsule => 'Construis la Capsule Pressurisée';

  @override
  String get objectiveTakeKernel => 'Prends le Noyau Volcanique';

  @override
  String objectiveRaiseKernel(int level) {
    return 'Monte le Noyau au niveau $level';
  }

  @override
  String get chapterInstallation => 'Installation';

  @override
  String get chapterReef => 'Le récif';

  @override
  String get chapterRift => 'La Faille';

  @override
  String get chapterChimney => 'La Cheminée';

  @override
  String get chapterKernel => 'Le Noyau';

  @override
  String get chapterAwakening => 'Le réveil';

  @override
  String chapterNumbered(int number, String title) {
    return '$number. $title';
  }

  @override
  String get tipGuideTitle => 'Guide';

  @override
  String get tipCategoryBase => 'Base';

  @override
  String get tipCategoryThreats => 'Menaces';

  @override
  String get tipCategoryMap => 'Carte';

  @override
  String get tipCategoryEvents => 'Événements';

  @override
  String get tipNoiseGaugeTitle => 'La jauge de bruit';

  @override
  String get tipNoiseGaugeLine1 =>
      'Chaque chantier, chaque recrue et chaque exploration font du bruit, et ta base en fait un peu à chaque tour.';

  @override
  String tipNoiseGaugeLine2(int threshold) {
    return 'Quand la jauge atteint $threshold, les monstres l\'entendent : un raid est annoncé.';
  }

  @override
  String get tipWorksitesTitle => 'Deux chantiers par tour';

  @override
  String tipWorksitesLine1(int level) {
    return 'Ton QG niveau $level ouvre un deuxième chantier : deux bâtiments montent à chaque tour.';
  }

  @override
  String tipWorksitesLine2(int level) {
    return 'Le QG niveau $level en ouvrira un troisième. La recherche, elle, reste à une par tour.';
  }

  @override
  String get tipTechChoiceTitle => 'Les choix de la recherche';

  @override
  String get tipTechChoiceLine1 =>
      'Le prochain nœud de ta branche est un choix entre deux options.';

  @override
  String get tipTechChoiceLine2 =>
      'Ce choix est définitif : l\'autre option restera fermée pour toute la partie.';

  @override
  String get tipTechChoiceLine3 =>
      'Prends le temps de lire les deux avant de lancer la recherche.';

  @override
  String get tipRaidAnnouncedTitle => 'Un raid approche';

  @override
  String tipRaidAnnouncedLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns tours',
      one: '$turns tour',
    );
    return 'Ton bruit a attiré des monstres : ils frapperont ta base dans $_temp0.';
  }

  @override
  String get tipRaidAnnouncedLine2 =>
      'Recrute des défenseurs, les Harponneurs sont faits pour ça.';

  @override
  String get tipRaidAnnouncedLine3 =>
      'Le rempart de la Citadelle corallienne t\'aidera aussi à tenir.';

  @override
  String get tipRaidReportTitle => 'Le rapport de raid';

  @override
  String get tipRaidReportLine1 =>
      'Après chaque raid, le rapport montre le combat, tes pertes et le butin.';

  @override
  String get tipRaidReportLine2 =>
      'Un raid perdu pille une partie de tes ressources.';

  @override
  String get tipRaidReportLine3 =>
      'Un raid repoussé efface ta série de défaites.';

  @override
  String get tipLastChanceTitle => 'Dernière chance';

  @override
  String tipLastChanceLine1(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ta base a perdu $count raids d\'affilée.',
      one: 'Ta base a perdu $count raid.',
    );
    return '$_temp0';
  }

  @override
  String get tipLastChanceLine2 =>
      'Si le prochain raid est perdu lui aussi, la partie est finie.';

  @override
  String get tipLastChanceLine3 =>
      'Mets tes forces dans la défense : une victoire efface la série.';

  @override
  String get tipMonsterFamiliesTitle => 'Les familles de monstres';

  @override
  String get tipMonsterFamiliesLine1 =>
      'Chaque repaire abrite une famille, avec sa propre règle de combat.';

  @override
  String get tipMonsterFamiliesLine2 =>
      'Chaque famille a son point faible : une unité qui la contre.';

  @override
  String get tipMonsterFamiliesLine3 =>
      'Touche le repaire sur la Carte pour la connaître avant d\'attaquer.';

  @override
  String get tipVolcanoWaveTitle => 'La vague du Volcan';

  @override
  String get tipVolcanoWaveLine1 =>
      'Le Volcan envoie ses Krakens reprendre le Noyau.';

  @override
  String get tipVolcanoWaveLine2 =>
      'La vague frappe à la fin du prochain tour : garde une garnison au Noyau.';

  @override
  String get tipVolcanoWaveLine3 =>
      'Chaque vague perdue fait perdre un niveau au Noyau.';

  @override
  String get tipLairTitle => 'Les repaires';

  @override
  String get tipLairLine1 =>
      'Sur la Carte, un repaire de monstres garde sa case : attaque-le avec ton armée.';

  @override
  String get tipLairLine2 =>
      'Vaincus, les monstres laissent leur butin, mais chaque combat fait du bruit.';

  @override
  String get tipLairLine3 => 'Regarde leur nombre avant de choisir tes unités.';

  @override
  String get tipChestAndRuinsTitle => 'Coffres et ruines';

  @override
  String get tipChestAndRuinsLine1 =>
      'Un coffre ou des ruines cachent des ressources.';

  @override
  String get tipChestAndRuinsLine2 =>
      'Touche la case sur la Carte pour les fouiller : c\'est sans danger et sans bruit.';

  @override
  String get tipTransitionBaseTitle => 'Les bases de transition';

  @override
  String get tipTransitionBaseLine1 =>
      'Une base gardée, sur la Carte, mène vers les profondeurs.';

  @override
  String get tipTransitionBaseLine2 =>
      'Prise d\'assaut, elle te rapporte des perles à chaque tour.';

  @override
  String get tipTransitionBaseLine3 =>
      'Elle ouvre aussi la route du niveau suivant.';

  @override
  String get tipDescentTitle => 'La descente';

  @override
  String get tipDescentLine1 =>
      'Ton Module de Descente envoie des unités au niveau inférieur, par la Faille.';

  @override
  String get tipDescentLine2 =>
      'Attention : une unité descendue ne remonte plus.';

  @override
  String get tipDescentLine3 =>
      'En bas t\'attendent d\'autres repaires, et la route du Noyau.';

  @override
  String get tipEventsTitle => 'Les événements';

  @override
  String tipEventsLine1(int minGap, int maxGap) {
    return 'Tous les $minGap à $maxGap tours, un événement secoue les abysses.';
  }

  @override
  String get tipEventsLine2 =>
      'Tu as le tour suivant pour choisir ta réponse sur sa carte.';

  @override
  String get tipEventsLine3 =>
      'Sans choix de ta part, l\'option prudente s\'applique d\'office.';

  @override
  String tipWarmCurrentLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns tours',
      one: '$turns tour',
    );
    return 'Un courant chaud dope ta production pendant $_temp0.';
  }

  @override
  String get tipWarmCurrentLine2 =>
      'Mais son remous fait du bruit à chaque tour.';

  @override
  String get tipWarmCurrentLine3 =>
      'Exploite-le si tes défenses sont prêtes à recevoir un raid.';

  @override
  String tipWreckLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns tours',
      one: '$turns tour',
    );
    return 'Un galion englouti reste $_temp0 au bord de la zone explorée.';
  }

  @override
  String get tipWreckLine2 =>
      'Explore sa case avec un Éclaireur, puis fouille-la pour son butin.';

  @override
  String tipWreckLine3(int noise) {
    return 'La fouille fait du bruit (+$noise) : choisis ton moment.';
  }

  @override
  String get tipPredatorsLine1 =>
      'Un grand requin et son banc rôdent autour de ta base.';

  @override
  String get tipPredatorsLine2 =>
      'Affronte-les pour leur butin, ou cède des algues pour les éloigner.';

  @override
  String get tipPredatorsLine3 =>
      'Perdre contre eux ne met jamais fin à la partie.';

  @override
  String tipStormLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns tours',
      one: '$turns tour',
    );
    return 'La tempête ferme l\'exploration pendant $_temp0.';
  }

  @override
  String tipStormLine2(int relief) {
    return 'En échange, elle couvre ton bruit : la jauge baisse de $relief.';
  }

  @override
  String get tipSurvivorsLine1 => 'Une capsule échouée abrite des survivants.';

  @override
  String get tipSurvivorsLine2 =>
      'Accueillis, ils rejoignent ta base comme Harponneurs.';

  @override
  String get tipSurvivorsLine3 =>
      'Comme toute ton armée, ils mangent des algues à chaque tour.';

  @override
  String get tipCaravanLine1 =>
      'Une caravane de tortues passe près de ta base.';

  @override
  String get tipCaravanLine2 =>
      'Son crabe marchand échange ta ressource la plus abondante contre la plus rare.';

  @override
  String tipColdCurrentLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns tours',
      one: '$turns tour',
    );
    return 'Un courant froid ralentit tes algues pendant $_temp0.';
  }

  @override
  String get tipColdCurrentLine2 =>
      'Chauffer les serres coûte de l\'énergie, mais sauve la récolte.';

  @override
  String get tipColdCurrentLine3 =>
      'Sans algues, ton armée ne tient pas : surveille ton stock.';

  @override
  String get guideLessonHqLevel1 =>
      'Bienvenue dans les abysses ! Touche le QG pour lancer ton premier chantier : un seul par tour pour commencer. Puis appuie sur « Tour suivant ».';

  @override
  String get guideLessonAlgaeFarm =>
      'Bravo pour ce premier chantier ! Les algues nourrissent ton armée : chaque unité en mange à chaque tour. Construis la Ferme d\'algues.';

  @override
  String get guideLessonMines =>
      'Le corail et le minerai paient presque tout. Construis la Mine de corail puis l\'Extracteur de minerai, un par tour. Regarde bien : chaque niveau coûte plus cher que le précédent.';

  @override
  String get guideLessonSolarPanel =>
      'L\'Extracteur consomme de l\'énergie, et la Caserne en consommera aussi. Sans énergie, ils s\'arrêtent. Construis le Panneau solaire.';

  @override
  String guideLessonHqLevel2(int level) {
    return 'Le QG niveau $level débloque la Caserne et le Laboratoire. Mais chaque chantier fait du bruit : surveille la jauge en haut de l\'écran, elle attire les monstres.';
  }

  @override
  String guideLessonBarracksAndScouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Éclaireurs',
      one: '$count Éclaireur',
    );
    return 'Construis la Caserne, puis recrute $_temp0 dans l\'onglet Armée. Chaque unité mange des algues à chaque tour, et chaque recrue fait monter le bruit.';
  }

  @override
  String get guideLessonExplore =>
      'Autour de ta base, tout est dans le brouillard. Sur la Carte, envoie un Éclaireur sur une case voisine : tu y trouveras des repaires de monstres de différentes familles, et parfois des coffres.';

  @override
  String get guideLessonLaboratoryAndResearch =>
      'Construis le Laboratoire, ouvre une branche dans l\'onglet Tech et lance une recherche. Une seule recherche par tour, et certains choix sont définitifs : prends le temps de lire.';

  @override
  String guideLessonFirstRaid(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns tours',
      one: '$turns tour',
    );
    return 'Le bruit finit toujours par attirer un raid, annoncé $_temp0 à l\'avance. Recrute des Harponneurs pour défendre ta base. Plus tard, le rempart de la Citadelle t\'aidera aussi.';
  }

  @override
  String get guideGoalMet =>
      'Bravo, c\'est fait ! Termine le tour pour valider l\'objectif et toucher ta récompense.';

  @override
  String get guideWorksiteTaken =>
      'Ton chantier du tour est déjà pris. Termine le tour : tu construiras la suite au prochain.';

  @override
  String get guideAlreadyRecruited =>
      'Tu as déjà recruté ces unités ce tour. Termine le tour pour en recruter d\'autres.';

  @override
  String get guideExploring =>
      'Ton Éclaireur est en route. Termine le tour pour découvrir ce que cache la case.';

  @override
  String guideStorm(int turn) {
    return 'Une tempête ferme l\'exploration jusqu\'à la fin du tour $turn. Patiente : l\'objectif t\'attend, termine le tour.';
  }

  @override
  String guideWreckWithoutBarracks(int turn) {
    return 'Une épave a coulé près de ta base, visible jusqu\'à la fin du tour $turn. Il faut un Éclaireur pour l\'atteindre, donc une Caserne : continue ton objectif, elle viendra.';
  }

  @override
  String guideWreckWithoutScout(int turn) {
    return 'Une épave a coulé près de ta base, visible jusqu\'à la fin du tour $turn. Recrute un Éclaireur dans l\'onglet Armée pour aller la fouiller.';
  }

  @override
  String guideRaidIntro(int turn, int monsters) {
    String _temp0 = intl.Intl.pluralLogic(
      monsters,
      locale: localeName,
      other: '$monsters monstres',
      one: '$monsters monstre',
    );
    return 'Le raid arrive au tour $turn avec $_temp0.';
  }

  @override
  String get guideRaidOutOfReach =>
      'Recrute autant de Harponneurs que tu peux dans l\'onglet Armée.';

  @override
  String get guideRaidHeld =>
      'Ta défense devrait le repousser : termine le tour pour l\'attendre.';

  @override
  String guideRaidNeeded(int needed, int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      needed,
      locale: localeName,
      other: '$needed Harponneurs',
      one: '$needed Harponneur',
    );
    return 'Aie au moins $_temp0 au niveau 1 : il t\'en manque $missing.';
  }

  @override
  String guideRaidRecruitNow(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Recrute-les dans l\'onglet Armée.',
      one: 'Recrute-le dans l\'onglet Armée.',
    );
    return '$_temp0';
  }

  @override
  String guideRaidRecruitNextTurn(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'recrute-les',
      one: 'recrute-le',
    );
    return 'Tu as déjà recruté ce tour : $_temp0 au prochain tour.';
  }

  @override
  String get guideRaidHoldOn =>
      'Tu as déjà recruté ce tour : termine-le et tiens bon.';

  @override
  String get tutorialGuideSwitch => 'Guide du tutoriel';

  @override
  String get tutorialGuideSwitchHint =>
      'Le guide te montre quoi faire, objectif après objectif';

  @override
  String get tutorialTipsSwitch => 'Conseils';

  @override
  String get tutorialTipsSwitchHint =>
      'Une fiche explique chaque nouveauté à sa première apparition';

  @override
  String get tutorialReviewTips => 'Revoir les fiches';

  @override
  String get gameOverDefeatTitle => 'DÉFAITE';

  @override
  String gameOverDefeatSubtitle(int turn, int raids) {
    String _temp0 = intl.Intl.pluralLogic(
      raids,
      locale: localeName,
      other:
          'Votre base est tombée à la fin du tour $turn, après $raids raids perdus d\'affilée.',
      one:
          'Votre base est tombée à la fin du tour $turn, après $raids raid perdu d\'affilée.',
    );
    return '$_temp0';
  }

  @override
  String get gameOverVictoryTitle => 'VICTOIRE !';

  @override
  String get gameOverVictorySubtitle =>
      'Vous avez conquis le Noyau Volcanique !';

  @override
  String get gameOverContinueFreePlay => 'Continuer en mode libre';

  @override
  String get gameOverBackToMenu => 'Retour au menu';

  @override
  String gameOverTurnsPlayed(int count) {
    return 'Tours joués : $count';
  }

  @override
  String gameOverMonstersDefeated(int count) {
    return 'Monstres vaincus : $count';
  }

  @override
  String gameOverBasesCaptured(int count) {
    return 'Bases capturées : $count';
  }

  @override
  String gameOverResourcesCollected(int count) {
    return 'Ressources collectées : $count';
  }

  @override
  String gameOverRaidsRepelled(int count) {
    return 'Raids repoussés : $count';
  }

  @override
  String gameOverRaidsLost(int count) {
    return 'Raids perdus : $count';
  }

  @override
  String get menuSubtitle => 'Les profondeurs vous attendent';

  @override
  String get menuContinue => 'CONTINUER';

  @override
  String get menuNewGame => 'NOUVELLE PARTIE';

  @override
  String get menuLoadGame => 'CHARGER UNE PARTIE';

  @override
  String menuBetaVersion(String version) {
    return 'Version bêta $version';
  }

  @override
  String get menuBetaWarning => 'les sauvegardes peuvent être effacées';

  @override
  String get saveLoadTitle => 'Charger une partie';

  @override
  String get saveDeleteTitle => 'Supprimer la partie ?';

  @override
  String saveDeleteMessage(String name) {
    return 'La partie de $name sera définitivement supprimée.';
  }

  @override
  String get saveDelete => 'Supprimer';

  @override
  String get saveOptions => 'Options';

  @override
  String get saveEmptyTitle => 'Aucune colonie détectée';

  @override
  String get saveEmptyMessage => 'Fondez votre première base dans les abysses.';

  @override
  String get saveInProgress => 'En cours';

  @override
  String get saveFinished => 'Terminées';

  @override
  String get saveVictoryBadge => '★ VICTOIRE';

  @override
  String get saveDefeatBadge => 'DÉFAITE';

  @override
  String saveMetaInProgress(int turn, String depth, int level) {
    return 'Tour $turn · $depth · QG niv. $level';
  }

  @override
  String saveMetaWon(int turn, String depth, String difficulty) {
    return 'Tour $turn · $depth · $difficulty';
  }

  @override
  String saveMetaFallen(int turn, String depth, String difficulty) {
    return 'Tombée au tour $turn · $depth · $difficulty';
  }

  @override
  String get saveKernelConquered => 'Noyau Volcanique conquis';

  @override
  String get saveVictory => 'Victoire';

  @override
  String get saveSeeReport => 'Voir le bilan de la partie';

  @override
  String saveResumeLabel(String name, int turn, String difficulty) {
    return '$name · Tour $turn · $difficulty';
  }

  @override
  String get saveJustNow => 'à l\'instant';

  @override
  String saveMinutesAgo(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String saveHoursAgo(int hours) {
    return 'il y a $hours h';
  }

  @override
  String get saveYesterday => 'hier';

  @override
  String saveShortDate(int day, String month) {
    return '$day $month';
  }

  @override
  String saveShortDateWithYear(int day, String month, int year) {
    return '$day $month $year';
  }

  @override
  String saveMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'janv.',
      'feb': 'févr.',
      'mar': 'mars',
      'apr': 'avr.',
      'may': 'mai',
      'jun': 'juin',
      'jul': 'juil.',
      'aug': 'août',
      'sep': 'sept.',
      'oct': 'oct.',
      'nov': 'nov.',
      'other': 'déc.',
    });
    return '$_temp0';
  }

  @override
  String get screenSettings => 'Paramètres';

  @override
  String get screenNextTurn => 'Tour suivant';

  @override
  String get screenTabBase => 'Base';

  @override
  String get screenTabMap => 'Carte';

  @override
  String get screenTabArmy => 'Armée';

  @override
  String get screenTabTech => 'Tech';

  @override
  String get screenComingSoon => 'Bientôt disponible';

  @override
  String get screenGameInProgress => 'Partie en cours';

  @override
  String get screenViewHistory => 'Voir l\'historique';

  @override
  String get screenExportGame => 'Exporter la partie';

  @override
  String get screenSaveAndQuit => 'Sauvegarder et quitter';

  @override
  String get screenCopy => 'Copier';

  @override
  String get screenShareFile => 'Partager le fichier';

  @override
  String get screenReplayUnavailable =>
      'Cette partie a commencé avant l\'enregistrement des replays : elle ne peut pas être exportée. Les nouvelles parties le peuvent.';

  @override
  String screenReplaySummary(String file, String actions, String turns) {
    return 'Le fichier $file contient $actions sur $turns.';
  }

  @override
  String screenReplayActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions',
      one: '$count action',
    );
    return '$_temp0';
  }

  @override
  String screenReplayTurns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tours joués',
      one: '$count tour joué',
    );
    return '$_temp0';
  }

  @override
  String get screenReplayExact =>
      'Les combats et les raids seront rejoués à l\'identique.';

  @override
  String get screenReplayInexact =>
      'Certains dés n\'ont pas été enregistrés : le rejeu pourra différer sur quelques combats.';

  @override
  String get screenReplayCopied => 'Replay copié dans le presse-papiers';

  @override
  String get screenReplayShareTitle => 'Replay Abysses';

  @override
  String get screenTreasureCollected => 'Trésor collecté !';

  @override
  String get screenRuinsSearched => 'Ruines fouillées !';

  @override
  String get screenWreckSearched => 'Épave fouillée !';

  @override
  String get screenCollectTitle => 'Collecte';

  @override
  String get screenRuinsEmpty => 'Les ruines étaient vides...';

  @override
  String get screenWreckEmpty => 'L\'épave était vide...';

  @override
  String get screenNothingToCollect => 'Rien à récupérer ici...';

  @override
  String screenEventChosen(String event, String choice) {
    return '$event : $choice';
  }

  @override
  String get screenGarrisonSendTitle => 'Mettre en garnison';

  @override
  String get screenGarrisonWithdrawTitle => 'Retirer de la garnison';

  @override
  String get screenGarrisonWithdraw => 'Retirer';

  @override
  String get screenGarrisonSendInfo =>
      'Seule la garnison défend le Noyau contre les vagues du Kraken.';

  @override
  String get screenGarrisonWithdrawInfo =>
      'Les unités retirées rejoignent le niveau 3.';

  @override
  String screenGarrisonSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Garnison : $count unités',
      one: 'Garnison : $count unité',
    );
    return '$_temp0';
  }

  @override
  String get screenAlreadyVisitedTitle => 'Déjà visité';

  @override
  String get screenAlreadyVisitedMessage => 'Vous êtes déjà venu par ici';

  @override
  String get screenYourBaseTitle => 'Votre base';

  @override
  String get screenYourBaseMessage => 'Votre quartier général';

  @override
  String screenPlainTitle(int x, int y) {
    return 'Plaine ($x, $y)';
  }

  @override
  String get screenNothingToSee => 'Il n\'y a rien à voir ici';

  @override
  String screenPassageTitle(String name) {
    return 'Passage vers $name';
  }

  @override
  String get screenUnknownPassage => 'passage inconnu';

  @override
  String get screenPassageMessage =>
      'Ce lieu marque un passage vers le niveau inférieur.';

  @override
  String screenDescendThrough(String base) {
    return 'Descendre des troupes par $base';
  }

  @override
  String screenDescentTitle(int level) {
    return 'Descente vers le Niveau $level';
  }

  @override
  String get screenDescentWarning =>
      'Attention : la descente est définitive. Les unités ne pourront pas remonter.';

  @override
  String screenDescentConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descendre ($count unités)',
      one: 'Descendre ($count unité)',
    );
    return '$_temp0';
  }

  @override
  String screenDescentDone(int level) {
    return 'Descente au Niveau $level effectuée';
  }

  @override
  String screenReinforcementTitle(int level) {
    return 'Renforts vers le Niveau $level';
  }

  @override
  String get screenReinforcementInfo =>
      'Les renforts arriveront au prochain tour.';

  @override
  String screenReinforcementConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyer ($count unités)',
      one: 'Envoyer ($count unité)',
    );
    return '$_temp0';
  }

  @override
  String screenReinforcementsSent(int count, int level) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unités en transit vers le Niveau $level',
      one: '$count unité en transit vers le Niveau $level',
    );
    return '$_temp0';
  }

  @override
  String get baseFailleAlpha => 'Faille Alpha';

  @override
  String get baseFailleBeta => 'Faille Bêta';

  @override
  String get baseFailleGamma => 'Faille Gamma';

  @override
  String get baseFailleDelta => 'Faille Delta';

  @override
  String get baseChemineePrimary => 'Cheminée Primaire';

  @override
  String get baseChemineeSecondary => 'Cheminée Secondaire';

  @override
  String get baseChemineeTertiary => 'Cheminée Tertiaire';

  @override
  String baseOtherName(String type, int number) {
    return '$type $number';
  }

  @override
  String baseLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String baseLevelShort(int level) {
    return 'Niv. $level';
  }

  @override
  String get baseNotBuilt => 'Non construit';

  @override
  String get baseMaxLevel => 'Niveau maximum atteint';

  @override
  String baseUpgradeLevels(int from, int to) {
    return 'Niveau $from → $to';
  }

  @override
  String get baseWorksitesBusy => 'Chantiers occupés ce tour';

  @override
  String get baseBuild => 'Construire';

  @override
  String get baseUpgrade => 'Améliorer';

  @override
  String baseCapturedBaseRequired(String base) {
    return '$base capturée requise';
  }

  @override
  String get baseKernelRequired => 'Noyau Volcanique capturé requis';

  @override
  String baseWorksitesFree(int free, int total) {
    return 'Chantiers libres ce tour : $free/$total';
  }

  @override
  String baseWorksitesNext(int level) {
    return '+1 au QG $level';
  }

  @override
  String baseShield(String rampart) {
    return 'Rempart de la base : $rampart';
  }

  @override
  String baseRampartCurrent(String rampart) {
    return 'Rempart actuel : $rampart';
  }

  @override
  String baseRampartNext(String rampart) {
    return 'Prochain niveau : $rampart';
  }

  @override
  String get baseRampartMax => 'Rempart à son apogée';

  @override
  String get baseRampartHint =>
      'Pendant un raid, le rempart combat avec les défenseurs du niveau 1 et attire toutes les attaques.';

  @override
  String get baseRampartNone => 'aucun';

  @override
  String baseCoralRampartStats(int hp, int def) {
    return '$hp PV, DEF $def';
  }

  @override
  String baseMagmaRampartStats(int hp, int atk, int def) {
    return '$hp PV, ATK $atk, DEF $def';
  }

  @override
  String get unitRecruitDone => 'Recrutement déjà effectué ce tour';

  @override
  String get unitNotEnoughResources => 'Ressources insuffisantes';

  @override
  String get unitRecruit => 'Recruter';

  @override
  String unitTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unités',
      one: '$count unité',
    );
    return '$_temp0';
  }

  @override
  String get unitPlaceKernel => 'Noyau';

  @override
  String get unitLocked => 'Verrouillé';

  @override
  String unitBarracksRequired(int level) {
    return 'Caserne niveau $level requise pour débloquer';
  }

  @override
  String unitInService(int count) {
    return 'En service : $count';
  }

  @override
  String get unitNoneAvailable => 'Aucune unité disponible.';

  @override
  String get resourceProduction => 'Production';

  @override
  String get resourceMainBuilding => 'Bâtiment principal';

  @override
  String turnTransition(int from, int to) {
    return 'Tour $from → Tour $to';
  }

  @override
  String get turnNoProduction => 'Aucune production ce tour.';

  @override
  String get turnNoChange => 'Aucun changement ce tour.';

  @override
  String get turnStorageFull => '(max atteint)';

  @override
  String get turnRecruitAvailable => 'Recrutement disponible';

  @override
  String turnPendingExplorations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count explorations en attente',
      one: '$count exploration en attente',
    );
    return '$_temp0';
  }

  @override
  String get turnBuildingsDeactivated => 'Bâtiments désactivés';

  @override
  String get turnUnitsLost => 'Unités perdues';

  @override
  String get turnPredatorsLooted => 'Le banc de prédateurs a pillé la base';

  @override
  String turnEventDefaulted(String event) {
    return '$event : option prudente appliquée';
  }

  @override
  String turnEventDrawn(String event) {
    return 'Événement : $event';
  }

  @override
  String turnExplorationTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exploration : $count nouvelles cellules',
      one: 'Exploration : $count nouvelle cellule',
    );
    return '$_temp0';
  }

  @override
  String turnExplorationCells(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cellules',
      one: '$count cellule',
    );
    return '$_temp0';
  }

  @override
  String get historyFilterAll => 'Tous';

  @override
  String get historyFilterCombat => 'Combats';

  @override
  String get historyFilterBuilding => 'Construction';

  @override
  String get historyFilterResearch => 'Recherche';

  @override
  String get historyFilterEvent => 'Événements';

  @override
  String get historyFilterOther => 'Autres';

  @override
  String get historyEmpty => 'Aucune action enregistrée pour l\'instant.';

  @override
  String get historyEmptyFilter => 'Aucune action pour ce filtre.';

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsLanguageAutomatic => 'Automatique';

  @override
  String get settingsLanguageAutomaticHint => 'Langue de l\'appareil';

  @override
  String get screenViewRanking => 'Classement';

  @override
  String get factionRankingTitle => 'Classement des factions';

  @override
  String get factionRankingYou => 'Vous';

  @override
  String factionRankingHeadquarters(int level) {
    return 'QG niveau $level';
  }

  @override
  String factionRankingDepth(int level) {
    return 'Profondeur : niveau $level';
  }

  @override
  String get factionRankingKernel => 'Tient le Noyau du Volcan';

  @override
  String get factionRankingFallen => 'Tombée';
}

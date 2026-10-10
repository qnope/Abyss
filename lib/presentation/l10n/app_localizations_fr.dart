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
  String commonNamedLevel(String name, int level) {
    return '$name niv. $level';
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
    return 'Envoyés: $sent / Intactes: $intact / Blessés: $wounded / Morts: $dead';
  }

  @override
  String fightEnemiesKilled(int killed, int total) {
    return 'Ennemis tués: $killed/$total';
  }

  @override
  String fightGuardiansKilled(int killed, int total) {
    return 'Gardiens éliminés: $killed/$total';
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
    return 'Assaut: $target';
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
    return 'Stock: $count';
  }

  @override
  String fightAlliesAlive(int count) {
    return 'Alliés vivants: $count';
  }

  @override
  String fightAlliesHp(int hp) {
    return 'PV alliés: $hp';
  }

  @override
  String fightDamageDealt(int damage) {
    return 'Dégâts infligés: $damage';
  }

  @override
  String fightEnemiesAlive(int count) {
    return 'Ennemis vivants: $count';
  }

  @override
  String fightEnemiesHp(int hp) {
    return 'PV ennemis: $hp';
  }

  @override
  String fightDamageTaken(int damage) {
    return 'Dégâts subis: $damage';
  }

  @override
  String fightCriticalHits(int count) {
    return 'Coups critiques: $count';
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
    return 'Niv $level: $name';
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
}

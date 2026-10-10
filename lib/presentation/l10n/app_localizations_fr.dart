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
}

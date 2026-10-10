import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @newGameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Partie'**
  String get newGameTitle;

  /// No description provided for @newGameEnterName.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre nom'**
  String get newGameEnterName;

  /// No description provided for @newGameNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom du joueur'**
  String get newGameNameHint;

  /// No description provided for @newGameNameEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un nom'**
  String get newGameNameEmpty;

  /// No description provided for @newGameNameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le nom doit contenir au moins {min} caractères'**
  String newGameNameTooShort(int min);

  /// No description provided for @newGameTutorial.
  ///
  /// In fr, this message translates to:
  /// **'Tutoriel'**
  String get newGameTutorial;

  /// No description provided for @newGameTutorialHint.
  ///
  /// In fr, this message translates to:
  /// **'Un guide t\'accompagne sur les premiers tours'**
  String get newGameTutorialHint;

  /// No description provided for @newGameStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get newGameStart;

  /// No description provided for @difficultyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get difficultyTitle;

  /// No description provided for @buildingHeadquartersName.
  ///
  /// In fr, this message translates to:
  /// **'Quartier Général'**
  String get buildingHeadquartersName;

  /// No description provided for @buildingHeadquartersDescription.
  ///
  /// In fr, this message translates to:
  /// **'Centre de commandement de votre base sous-marine. Son niveau détermine les capacités de votre colonie. Une fois bâti, il fournit {coral} corail et {ore} minerai par tour.'**
  String buildingHeadquartersDescription(int coral, int ore);

  /// No description provided for @buildingAlgaeFarmName.
  ///
  /// In fr, this message translates to:
  /// **'Ferme d\'algues'**
  String get buildingAlgaeFarmName;

  /// No description provided for @buildingAlgaeFarmDescription.
  ///
  /// In fr, this message translates to:
  /// **'Cultive des algues pour nourrir votre colonie sous-marine.'**
  String get buildingAlgaeFarmDescription;

  /// No description provided for @buildingCoralMineName.
  ///
  /// In fr, this message translates to:
  /// **'Mine de corail'**
  String get buildingCoralMineName;

  /// No description provided for @buildingCoralMineDescription.
  ///
  /// In fr, this message translates to:
  /// **'Extrait du corail des récifs pour la construction.'**
  String get buildingCoralMineDescription;

  /// No description provided for @buildingCoralCitadelName.
  ///
  /// In fr, this message translates to:
  /// **'Citadelle corallienne'**
  String get buildingCoralCitadelName;

  /// No description provided for @buildingCoralCitadelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Forteresse corallienne massive qui dresse un rempart pour la défense de votre base. Pendant un raid, il encaisse les coups à la place des unités stationnées.'**
  String get buildingCoralCitadelDescription;

  /// No description provided for @buildingOreExtractorName.
  ///
  /// In fr, this message translates to:
  /// **'Extracteur de minerai'**
  String get buildingOreExtractorName;

  /// No description provided for @buildingOreExtractorDescription.
  ///
  /// In fr, this message translates to:
  /// **'Fore les profondeurs pour extraire du minerai océanique.'**
  String get buildingOreExtractorDescription;

  /// No description provided for @buildingSolarPanelName.
  ///
  /// In fr, this message translates to:
  /// **'Panneau solaire'**
  String get buildingSolarPanelName;

  /// No description provided for @buildingSolarPanelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Capte l\'énergie solaire pour alimenter vos installations.'**
  String get buildingSolarPanelDescription;

  /// No description provided for @buildingLaboratoryName.
  ///
  /// In fr, this message translates to:
  /// **'Laboratoire'**
  String get buildingLaboratoryName;

  /// No description provided for @buildingLaboratoryDescription.
  ///
  /// In fr, this message translates to:
  /// **'Centre de recherche sous-marin pour développer de nouvelles technologies.'**
  String get buildingLaboratoryDescription;

  /// No description provided for @buildingBarracksName.
  ///
  /// In fr, this message translates to:
  /// **'Caserne'**
  String get buildingBarracksName;

  /// No description provided for @buildingBarracksDescription.
  ///
  /// In fr, this message translates to:
  /// **'Forme et entraîne vos unités militaires sous-marines.'**
  String get buildingBarracksDescription;

  /// No description provided for @buildingDescentModuleName.
  ///
  /// In fr, this message translates to:
  /// **'Module de Descente'**
  String get buildingDescentModuleName;

  /// No description provided for @buildingDescentModuleDescription.
  ///
  /// In fr, this message translates to:
  /// **'Module spécialisé permettant l\'assaut des failles abyssales.'**
  String get buildingDescentModuleDescription;

  /// No description provided for @buildingPressureCapsuleName.
  ///
  /// In fr, this message translates to:
  /// **'Capsule Pressurisée'**
  String get buildingPressureCapsuleName;

  /// No description provided for @buildingPressureCapsuleDescription.
  ///
  /// In fr, this message translates to:
  /// **'Capsule haute pression permettant l\'assaut des cheminées hydrothermales.'**
  String get buildingPressureCapsuleDescription;

  /// No description provided for @buildingVolcanicKernelName.
  ///
  /// In fr, this message translates to:
  /// **'Noyau Volcanique'**
  String get buildingVolcanicKernelName;

  /// No description provided for @buildingVolcanicKernelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Le cœur brûlant des abysses. Construisez-le au niveau 10 pour remporter la victoire. Sa garnison se gère ici, ou depuis sa case sur la carte.'**
  String get buildingVolcanicKernelDescription;

  /// No description provided for @unitScoutName.
  ///
  /// In fr, this message translates to:
  /// **'Éclaireur'**
  String get unitScoutName;

  /// No description provided for @unitScoutRole.
  ///
  /// In fr, this message translates to:
  /// **'Éclaireur'**
  String get unitScoutRole;

  /// No description provided for @unitScoutRoleEffect.
  ///
  /// In fr, this message translates to:
  /// **'Fuit au lieu de mourir : revient toujours blessé.'**
  String get unitScoutRoleEffect;

  /// No description provided for @unitHarpoonistName.
  ///
  /// In fr, this message translates to:
  /// **'Harponneur'**
  String get unitHarpoonistName;

  /// No description provided for @unitHarpoonistRole.
  ///
  /// In fr, this message translates to:
  /// **'DPS'**
  String get unitHarpoonistRole;

  /// No description provided for @unitHarpoonistRoleEffect.
  ///
  /// In fr, this message translates to:
  /// **'Dégâts réguliers, sans règle spéciale.'**
  String get unitHarpoonistRoleEffect;

  /// No description provided for @unitGuardianName.
  ///
  /// In fr, this message translates to:
  /// **'Gardien'**
  String get unitGuardianName;

  /// No description provided for @unitGuardianRole.
  ///
  /// In fr, this message translates to:
  /// **'Tank'**
  String get unitGuardianRole;

  /// No description provided for @unitGuardianRoleEffect.
  ///
  /// In fr, this message translates to:
  /// **'Provoque : les monstres le ciblent en priorité.'**
  String get unitGuardianRoleEffect;

  /// No description provided for @unitDomeBreakerName.
  ///
  /// In fr, this message translates to:
  /// **'Briseur'**
  String get unitDomeBreakerName;

  /// No description provided for @unitDomeBreakerRole.
  ///
  /// In fr, this message translates to:
  /// **'Siège'**
  String get unitDomeBreakerRole;

  /// No description provided for @unitDomeBreakerRoleEffect.
  ///
  /// In fr, this message translates to:
  /// **'Inflige le double de dégâts aux boss.'**
  String get unitDomeBreakerRoleEffect;

  /// No description provided for @unitAbyssAdmiralName.
  ///
  /// In fr, this message translates to:
  /// **'Amiral des Abysses'**
  String get unitAbyssAdmiralName;

  /// No description provided for @unitAbyssAdmiralRole.
  ///
  /// In fr, this message translates to:
  /// **'Amiral'**
  String get unitAbyssAdmiralRole;

  /// No description provided for @unitAbyssAdmiralRoleEffect.
  ///
  /// In fr, this message translates to:
  /// **'Commande les assauts, sans combattre.'**
  String get unitAbyssAdmiralRoleEffect;

  /// No description provided for @unitSaboteurName.
  ///
  /// In fr, this message translates to:
  /// **'Saboteur'**
  String get unitSaboteurName;

  /// No description provided for @unitSaboteurRole.
  ///
  /// In fr, this message translates to:
  /// **'Verre-canon'**
  String get unitSaboteurRole;

  /// No description provided for @unitSaboteurRoleEffect.
  ///
  /// In fr, this message translates to:
  /// **'Ignore la défense de sa cible.'**
  String get unitSaboteurRoleEffect;

  /// No description provided for @unitScoutCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} éclaireur} other{{count} éclaireurs}}'**
  String unitScoutCount(int count);

  /// No description provided for @unitHarpoonistCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} harponneur} other{{count} harponneurs}}'**
  String unitHarpoonistCount(int count);

  /// No description provided for @unitGuardianCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} gardien} other{{count} gardiens}}'**
  String unitGuardianCount(int count);

  /// No description provided for @unitDomeBreakerCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} briseur} other{{count} briseurs}}'**
  String unitDomeBreakerCount(int count);

  /// No description provided for @unitAbyssAdmiralCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} amiral des abysses} other{{count} amiraux des abysses}}'**
  String unitAbyssAdmiralCount(int count);

  /// No description provided for @unitSaboteurCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} saboteur} other{{count} saboteurs}}'**
  String unitSaboteurCount(int count);

  /// No description provided for @resourceAlgaeName.
  ///
  /// In fr, this message translates to:
  /// **'Algues'**
  String get resourceAlgaeName;

  /// No description provided for @resourceAlgaeFlavor.
  ///
  /// In fr, this message translates to:
  /// **'Nourriture cultivée dans les fermes sous-marines pour nourrir vos unités.'**
  String get resourceAlgaeFlavor;

  /// No description provided for @resourceCoralName.
  ///
  /// In fr, this message translates to:
  /// **'Corail'**
  String get resourceCoralName;

  /// No description provided for @resourceCoralFlavor.
  ///
  /// In fr, this message translates to:
  /// **'Matériau de construction récolté sur les récifs pour bâtir votre base.'**
  String get resourceCoralFlavor;

  /// No description provided for @resourceOreName.
  ///
  /// In fr, this message translates to:
  /// **'Minerai'**
  String get resourceOreName;

  /// No description provided for @resourceOreFlavor.
  ///
  /// In fr, this message translates to:
  /// **'Métal extrait des profondeurs pour forger des équipements avancés.'**
  String get resourceOreFlavor;

  /// No description provided for @resourceEnergyName.
  ///
  /// In fr, this message translates to:
  /// **'Énergie'**
  String get resourceEnergyName;

  /// No description provided for @resourceEnergyFlavor.
  ///
  /// In fr, this message translates to:
  /// **'Énergie captée pour alimenter vos bâtiments et machines.'**
  String get resourceEnergyFlavor;

  /// No description provided for @resourcePearlName.
  ///
  /// In fr, this message translates to:
  /// **'Perles'**
  String get resourcePearlName;

  /// No description provided for @resourcePearlFlavor.
  ///
  /// In fr, this message translates to:
  /// **'Gemmes rares trouvées dans les ruines et les repaires, et récoltées chaque tour dans les failles et cheminées capturées.'**
  String get resourcePearlFlavor;

  /// No description provided for @monsterFamilyGenericLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rôdeurs'**
  String get monsterFamilyGenericLabel;

  /// No description provided for @monsterFamilySwarmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nuée'**
  String get monsterFamilySwarmLabel;

  /// No description provided for @monsterFamilyArmouredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Carapaces'**
  String get monsterFamilyArmouredLabel;

  /// No description provided for @monsterFamilyHunterLabel.
  ///
  /// In fr, this message translates to:
  /// **'Chasseurs'**
  String get monsterFamilyHunterLabel;

  /// No description provided for @monsterFamilyColossusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Colosses'**
  String get monsterFamilyColossusLabel;

  /// No description provided for @monsterFamilyKrakenLabel.
  ///
  /// In fr, this message translates to:
  /// **'Kraken'**
  String get monsterFamilyKrakenLabel;

  /// No description provided for @monsterFamilyGenericCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} monstre} other{{count} monstres}}'**
  String monsterFamilyGenericCount(int count);

  /// No description provided for @monsterFamilySwarmCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} Dents-de-verre} other{{count} Dents-de-verre}}'**
  String monsterFamilySwarmCount(int count);

  /// No description provided for @monsterFamilyArmouredCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} Isopode cuirassé} other{{count} Isopodes cuirassés}}'**
  String monsterFamilyArmouredCount(int count);

  /// No description provided for @monsterFamilyHunterCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} Calmar-chasseur} other{{count} Calmars-chasseurs}}'**
  String monsterFamilyHunterCount(int count);

  /// No description provided for @monsterFamilyColossusCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} Requin dormeur} other{{count} Requins dormeurs}}'**
  String monsterFamilyColossusCount(int count);

  /// No description provided for @monsterFamilyKrakenCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} Kraken} other{{count} Krakens}}'**
  String monsterFamilyKrakenCount(int count);

  /// No description provided for @monsterFamilySwarmRule.
  ///
  /// In fr, this message translates to:
  /// **'Essaim : un coup de Harponneur touche deux poissons.'**
  String get monsterFamilySwarmRule;

  /// No description provided for @monsterFamilyArmouredRule.
  ///
  /// In fr, this message translates to:
  /// **'Cuirasse : seuls les Saboteurs ignorent leur DEF.'**
  String get monsterFamilyArmouredRule;

  /// No description provided for @monsterFamilyHunterRule.
  ///
  /// In fr, this message translates to:
  /// **'Traque : ils visent l\'unité la plus fragile et frappent deux fois plus fort, sauf un Gardien ou le rempart qui provoque.'**
  String get monsterFamilyHunterRule;

  /// No description provided for @monsterFamilyColossusRule.
  ///
  /// In fr, this message translates to:
  /// **'Géants : tous des boss, que les Briseurs frappent double.'**
  String get monsterFamilyColossusRule;

  /// No description provided for @monsterFamilyKrakenRule.
  ///
  /// In fr, this message translates to:
  /// **'Étreinte : chaque coup de tentacule frappe aussi un deuxième défenseur. Des boss, que les Briseurs frappent double.'**
  String get monsterFamilyKrakenRule;

  /// No description provided for @monsterFamilySwarmWeakness.
  ///
  /// In fr, this message translates to:
  /// **'Harponneurs'**
  String get monsterFamilySwarmWeakness;

  /// No description provided for @monsterFamilyArmouredWeakness.
  ///
  /// In fr, this message translates to:
  /// **'Saboteurs'**
  String get monsterFamilyArmouredWeakness;

  /// No description provided for @monsterFamilyHunterWeakness.
  ///
  /// In fr, this message translates to:
  /// **'Gardiens'**
  String get monsterFamilyHunterWeakness;

  /// No description provided for @monsterFamilyColossusWeakness.
  ///
  /// In fr, this message translates to:
  /// **'Briseurs de dôme'**
  String get monsterFamilyColossusWeakness;

  /// No description provided for @monsterLairGroupsAnd.
  ///
  /// In fr, this message translates to:
  /// **'{first} et {second}'**
  String monsterLairGroupsAnd(String first, String second);

  /// No description provided for @monsterLairWave.
  ///
  /// In fr, this message translates to:
  /// **'{monsters} niv. {level}'**
  String monsterLairWave(String monsters, int level);

  /// No description provided for @monsterLairWeakAgainst.
  ///
  /// In fr, this message translates to:
  /// **'Faibles contre : {units}'**
  String monsterLairWeakAgainst(String units);

  /// No description provided for @monsterDifficultyEasy.
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get monsterDifficultyEasy;

  /// No description provided for @monsterDifficultyMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get monsterDifficultyMedium;

  /// No description provided for @monsterDifficultyHard.
  ///
  /// In fr, this message translates to:
  /// **'Difficile'**
  String get monsterDifficultyHard;

  /// No description provided for @randomEventWarmCurrentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Courant chaud'**
  String get randomEventWarmCurrentLabel;

  /// No description provided for @randomEventWreckLabel.
  ///
  /// In fr, this message translates to:
  /// **'Épave'**
  String get randomEventWreckLabel;

  /// No description provided for @randomEventPredatorsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Banc de prédateurs'**
  String get randomEventPredatorsLabel;

  /// No description provided for @randomEventStormLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tempête'**
  String get randomEventStormLabel;

  /// No description provided for @randomEventSurvivorsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Survivants'**
  String get randomEventSurvivorsLabel;

  /// No description provided for @randomEventCaravanLabel.
  ///
  /// In fr, this message translates to:
  /// **'Caravane de tortues'**
  String get randomEventCaravanLabel;

  /// No description provided for @randomEventColdCurrentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Courant froid'**
  String get randomEventColdCurrentLabel;

  /// No description provided for @eventCountdown.
  ///
  /// In fr, this message translates to:
  /// **'{label} : encore {turns, plural, one{{turns} tour} other{{turns} tours}}'**
  String eventCountdown(String label, int turns);

  /// No description provided for @eventColdCurrentHeated.
  ///
  /// In fr, this message translates to:
  /// **'{label} (serres chauffées)'**
  String eventColdCurrentHeated(String label);

  /// No description provided for @techBranchMilitaryName.
  ///
  /// In fr, this message translates to:
  /// **'Militaire'**
  String get techBranchMilitaryName;

  /// No description provided for @techBranchMilitaryDescription.
  ///
  /// In fr, this message translates to:
  /// **'Améliore l\'attaque et la défense de toutes les unités.'**
  String get techBranchMilitaryDescription;

  /// No description provided for @techBranchResourcesName.
  ///
  /// In fr, this message translates to:
  /// **'Ressources'**
  String get techBranchResourcesName;

  /// No description provided for @techBranchResourcesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Améliore la production de toutes les ressources.'**
  String get techBranchResourcesDescription;

  /// No description provided for @techBranchExplorerName.
  ///
  /// In fr, this message translates to:
  /// **'Explorateur'**
  String get techBranchExplorerName;

  /// No description provided for @techBranchExplorerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Améliore la portée d\'exploration de la carte.'**
  String get techBranchExplorerDescription;

  /// No description provided for @techTierEffect.
  ///
  /// In fr, this message translates to:
  /// **'+20 % ATK et DEF'**
  String get techTierEffect;

  /// No description provided for @techProductionEffect.
  ///
  /// In fr, this message translates to:
  /// **'+20 % de production'**
  String get techProductionEffect;

  /// No description provided for @techExploredAreaEffect.
  ///
  /// In fr, this message translates to:
  /// **'Zone explorée {size}×{size}'**
  String techExploredAreaEffect(int size);

  /// No description provided for @techMilitary1Name.
  ///
  /// In fr, this message translates to:
  /// **'Trident aiguisé'**
  String get techMilitary1Name;

  /// No description provided for @techMilitary2aName.
  ///
  /// In fr, this message translates to:
  /// **'Lames de corail'**
  String get techMilitary2aName;

  /// No description provided for @techMilitary2aEffect.
  ///
  /// In fr, this message translates to:
  /// **'+35 % ATK'**
  String get techMilitary2aEffect;

  /// No description provided for @techMilitary2bName.
  ///
  /// In fr, this message translates to:
  /// **'Carapace de nacre'**
  String get techMilitary2bName;

  /// No description provided for @techMilitary2bEffect.
  ///
  /// In fr, this message translates to:
  /// **'+35 % PV'**
  String get techMilitary2bEffect;

  /// No description provided for @techMilitary3Name.
  ///
  /// In fr, this message translates to:
  /// **'Discipline des abysses'**
  String get techMilitary3Name;

  /// No description provided for @techMilitary4aName.
  ///
  /// In fr, this message translates to:
  /// **'Rempart vivant'**
  String get techMilitary4aName;

  /// No description provided for @techMilitary4aEffect.
  ///
  /// In fr, this message translates to:
  /// **'+35 % DEF en défense de la base'**
  String get techMilitary4aEffect;

  /// No description provided for @techMilitary4bName.
  ///
  /// In fr, this message translates to:
  /// **'Assaut des profondeurs'**
  String get techMilitary4bName;

  /// No description provided for @techMilitary4bEffect.
  ///
  /// In fr, this message translates to:
  /// **'+35 % ATK contre repaires, bases et Noyau'**
  String get techMilitary4bEffect;

  /// No description provided for @techMilitary5Name.
  ///
  /// In fr, this message translates to:
  /// **'Légion abyssale'**
  String get techMilitary5Name;

  /// No description provided for @techResources1Name.
  ///
  /// In fr, this message translates to:
  /// **'Bancs fertiles'**
  String get techResources1Name;

  /// No description provided for @techResources2aName.
  ///
  /// In fr, this message translates to:
  /// **'Culture intensive'**
  String get techResources2aName;

  /// No description provided for @techResources2aEffect.
  ///
  /// In fr, this message translates to:
  /// **'+35 % d\'algues et de corail'**
  String get techResources2aEffect;

  /// No description provided for @techResources2bName.
  ///
  /// In fr, this message translates to:
  /// **'Forage profond'**
  String get techResources2bName;

  /// No description provided for @techResources2bEffect.
  ///
  /// In fr, this message translates to:
  /// **'+35 % de minerai et d\'énergie'**
  String get techResources2bEffect;

  /// No description provided for @techResources3Name.
  ///
  /// In fr, this message translates to:
  /// **'Courants nourriciers'**
  String get techResources3Name;

  /// No description provided for @techResources4aName.
  ///
  /// In fr, this message translates to:
  /// **'Coffres scellés'**
  String get techResources4aName;

  /// No description provided for @techResources4aEffect.
  ///
  /// In fr, this message translates to:
  /// **'Un raid perdu pille 15 % au lieu de 30 %'**
  String get techResources4aEffect;

  /// No description provided for @techResources4bName.
  ///
  /// In fr, this message translates to:
  /// **'Chantiers économes'**
  String get techResources4bName;

  /// No description provided for @techResources4bEffect.
  ///
  /// In fr, this message translates to:
  /// **'Améliorations 15 % moins chères'**
  String get techResources4bEffect;

  /// No description provided for @techResources5Name.
  ///
  /// In fr, this message translates to:
  /// **'Abondance des grands fonds'**
  String get techResources5Name;

  /// No description provided for @techExplorer1Name.
  ///
  /// In fr, this message translates to:
  /// **'Lanterne bioluminescente'**
  String get techExplorer1Name;

  /// No description provided for @techExplorer2aName.
  ///
  /// In fr, this message translates to:
  /// **'Sonar profond'**
  String get techExplorer2aName;

  /// No description provided for @techExplorer2aEffect.
  ///
  /// In fr, this message translates to:
  /// **'Zone explorée agrandie de 2'**
  String get techExplorer2aEffect;

  /// No description provided for @techExplorer2bName.
  ///
  /// In fr, this message translates to:
  /// **'Nage silencieuse'**
  String get techExplorer2bName;

  /// No description provided for @techExplorer2bEffect.
  ///
  /// In fr, this message translates to:
  /// **'Explorer et combattre ne font plus de bruit'**
  String get techExplorer2bEffect;

  /// No description provided for @techExplorer3Name.
  ///
  /// In fr, this message translates to:
  /// **'Cartographie des courants'**
  String get techExplorer3Name;

  /// No description provided for @techExplorer4aName.
  ///
  /// In fr, this message translates to:
  /// **'Pillards d\'épaves'**
  String get techExplorer4aName;

  /// No description provided for @techExplorer4aEffect.
  ///
  /// In fr, this message translates to:
  /// **'+50 % de butin (repaires, trésors, raids repoussés)'**
  String get techExplorer4aEffect;

  /// No description provided for @techExplorer4bName.
  ///
  /// In fr, this message translates to:
  /// **'Sentinelles'**
  String get techExplorer4bName;

  /// No description provided for @techExplorer4bEffect.
  ///
  /// In fr, this message translates to:
  /// **'Raids annoncés 4 tours à l\'avance au lieu de 2'**
  String get techExplorer4bEffect;

  /// No description provided for @techExplorer5Name.
  ///
  /// In fr, this message translates to:
  /// **'Œil de l\'abysse'**
  String get techExplorer5Name;

  /// No description provided for @terrainPlain.
  ///
  /// In fr, this message translates to:
  /// **'Plaine'**
  String get terrainPlain;

  /// No description provided for @cellContentEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Vide'**
  String get cellContentEmpty;

  /// No description provided for @cellContentResourceBonus.
  ///
  /// In fr, this message translates to:
  /// **'Ressources'**
  String get cellContentResourceBonus;

  /// No description provided for @cellContentRuins.
  ///
  /// In fr, this message translates to:
  /// **'Ruines'**
  String get cellContentRuins;

  /// No description provided for @cellContentMonsterLair.
  ///
  /// In fr, this message translates to:
  /// **'Repaire'**
  String get cellContentMonsterLair;

  /// No description provided for @cellContentPassage.
  ///
  /// In fr, this message translates to:
  /// **'Passage'**
  String get cellContentPassage;

  /// No description provided for @transitionBaseFailleName.
  ///
  /// In fr, this message translates to:
  /// **'Faille Abyssale'**
  String get transitionBaseFailleName;

  /// No description provided for @transitionBaseFailleDescription.
  ///
  /// In fr, this message translates to:
  /// **'Passage vers les profondeurs'**
  String get transitionBaseFailleDescription;

  /// No description provided for @transitionBaseChemineeName.
  ///
  /// In fr, this message translates to:
  /// **'Cheminée du Noyau'**
  String get transitionBaseChemineeName;

  /// No description provided for @transitionBaseChemineeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Passage vers le noyau'**
  String get transitionBaseChemineeDescription;

  /// No description provided for @difficultyEasyName.
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get difficultyEasyName;

  /// No description provided for @difficultyEasyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Plus de ressources, des monstres moins nombreux.'**
  String get difficultyEasyDescription;

  /// No description provided for @difficultyNormalName.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get difficultyNormalName;

  /// No description provided for @difficultyNormalDescription.
  ///
  /// In fr, this message translates to:
  /// **'L\'équilibre prévu pour les abysses.'**
  String get difficultyNormalDescription;

  /// No description provided for @difficultyHardName.
  ///
  /// In fr, this message translates to:
  /// **'Difficile'**
  String get difficultyHardName;

  /// No description provided for @difficultyHardDescription.
  ///
  /// In fr, this message translates to:
  /// **'Moins de ressources, des monstres plus nombreux.'**
  String get difficultyHardDescription;

  /// No description provided for @temporaryObjectiveWreckShort.
  ///
  /// In fr, this message translates to:
  /// **'Épave'**
  String get temporaryObjectiveWreckShort;

  /// No description provided for @temporaryObjectivePredatorsShort.
  ///
  /// In fr, this message translates to:
  /// **'Prédateurs'**
  String get temporaryObjectivePredatorsShort;

  /// No description provided for @temporaryObjectiveWreckTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fouille l\'épave d\'ici la fin du tour {turn}'**
  String temporaryObjectiveWreckTitle(int turn);

  /// No description provided for @temporaryObjectivePredatorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Repousse le banc de prédateurs'**
  String get temporaryObjectivePredatorsTitle;

  /// No description provided for @historyCategoryCombat.
  ///
  /// In fr, this message translates to:
  /// **'Combat'**
  String get historyCategoryCombat;

  /// No description provided for @historyCategoryBuilding.
  ///
  /// In fr, this message translates to:
  /// **'Construction'**
  String get historyCategoryBuilding;

  /// No description provided for @historyCategoryResearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get historyCategoryResearch;

  /// No description provided for @historyCategoryRecruit.
  ///
  /// In fr, this message translates to:
  /// **'Recrutement'**
  String get historyCategoryRecruit;

  /// No description provided for @historyCategoryExplore.
  ///
  /// In fr, this message translates to:
  /// **'Exploration'**
  String get historyCategoryExplore;

  /// No description provided for @historyCategoryCollect.
  ///
  /// In fr, this message translates to:
  /// **'Collecte'**
  String get historyCategoryCollect;

  /// No description provided for @historyCategoryTurnEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin de tour'**
  String get historyCategoryTurnEnd;

  /// No description provided for @historyCategoryCapture.
  ///
  /// In fr, this message translates to:
  /// **'Capture'**
  String get historyCategoryCapture;

  /// No description provided for @historyCategoryDescent.
  ///
  /// In fr, this message translates to:
  /// **'Descente'**
  String get historyCategoryDescent;

  /// No description provided for @historyCategoryReinforcement.
  ///
  /// In fr, this message translates to:
  /// **'Renfort'**
  String get historyCategoryReinforcement;

  /// No description provided for @historyCategoryRaid.
  ///
  /// In fr, this message translates to:
  /// **'Raid'**
  String get historyCategoryRaid;

  /// No description provided for @historyCategoryVolcano.
  ///
  /// In fr, this message translates to:
  /// **'Volcan'**
  String get historyCategoryVolcano;

  /// No description provided for @historyCategoryEvent.
  ///
  /// In fr, this message translates to:
  /// **'Événement'**
  String get historyCategoryEvent;

  /// No description provided for @historyCategoryAssault.
  ///
  /// In fr, this message translates to:
  /// **'Assaut'**
  String get historyCategoryAssault;

  /// No description provided for @actionFailureUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Action impossible'**
  String get actionFailureUnknown;

  /// No description provided for @actionFailureMapNotGenerated.
  ///
  /// In fr, this message translates to:
  /// **'Carte non générée'**
  String get actionFailureMapNotGenerated;

  /// No description provided for @actionFailureCellNotRevealed.
  ///
  /// In fr, this message translates to:
  /// **'Case non révélée'**
  String get actionFailureCellNotRevealed;

  /// No description provided for @actionFailureCellNotEligible.
  ///
  /// In fr, this message translates to:
  /// **'Cellule non éligible'**
  String get actionFailureCellNotEligible;

  /// No description provided for @actionFailureAlreadyCollected.
  ///
  /// In fr, this message translates to:
  /// **'Déjà collecté'**
  String get actionFailureAlreadyCollected;

  /// No description provided for @actionFailureNothingToCollect.
  ///
  /// In fr, this message translates to:
  /// **'Rien à collecter'**
  String get actionFailureNothingToCollect;

  /// No description provided for @actionFailureStormBlocksExploration.
  ///
  /// In fr, this message translates to:
  /// **'Tempête : exploration impossible'**
  String get actionFailureStormBlocksExploration;

  /// No description provided for @actionFailureNoScoutAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun éclaireur disponible'**
  String get actionFailureNoScoutAvailable;

  /// No description provided for @actionFailureNoMonsterHere.
  ///
  /// In fr, this message translates to:
  /// **'Pas de monstre ici'**
  String get actionFailureNoMonsterHere;

  /// No description provided for @actionFailureLairAlreadyDefeated.
  ///
  /// In fr, this message translates to:
  /// **'Repaire déjà vaincu'**
  String get actionFailureLairAlreadyDefeated;

  /// No description provided for @actionFailureLairEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Repaire vide'**
  String get actionFailureLairEmpty;

  /// No description provided for @actionFailureNotEnoughUnits.
  ///
  /// In fr, this message translates to:
  /// **'Unités insuffisantes'**
  String get actionFailureNotEnoughUnits;

  /// No description provided for @actionFailureNoUnitSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucune unité sélectionnée'**
  String get actionFailureNoUnitSelected;

  /// No description provided for @actionFailureAdmiralRequired.
  ///
  /// In fr, this message translates to:
  /// **'Un Amiral des Abysses est requis'**
  String get actionFailureAdmiralRequired;

  /// No description provided for @actionFailureNoTransitionBaseHere.
  ///
  /// In fr, this message translates to:
  /// **'Pas de base de transition ici'**
  String get actionFailureNoTransitionBaseHere;

  /// No description provided for @actionFailureBaseNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Base introuvable'**
  String get actionFailureBaseNotFound;

  /// No description provided for @actionFailureBaseAlreadyCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Base déjà capturée'**
  String get actionFailureBaseAlreadyCaptured;

  /// No description provided for @actionFailureBaseNotCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Base non capturée'**
  String get actionFailureBaseNotCaptured;

  /// No description provided for @actionFailureTargetLevelNotExplored.
  ///
  /// In fr, this message translates to:
  /// **'Niveau cible non exploré'**
  String get actionFailureTargetLevelNotExplored;

  /// No description provided for @actionFailureRequiredBuildingMissing.
  ///
  /// In fr, this message translates to:
  /// **'Bâtiment requis manquant'**
  String get actionFailureRequiredBuildingMissing;

  /// No description provided for @actionFailureRequiredBuildingDegraded.
  ///
  /// In fr, this message translates to:
  /// **'Bâtiment dégradé : remontez le QG'**
  String get actionFailureRequiredBuildingDegraded;

  /// No description provided for @actionFailureNoVolcanicKernelHere.
  ///
  /// In fr, this message translates to:
  /// **'Pas de noyau volcanique ici'**
  String get actionFailureNoVolcanicKernelHere;

  /// No description provided for @actionFailureKernelAlreadyCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Noyau déjà capturé'**
  String get actionFailureKernelAlreadyCaptured;

  /// No description provided for @actionFailureKernelNotCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Noyau non capturé'**
  String get actionFailureKernelNotCaptured;

  /// No description provided for @actionFailureKernelDegraded.
  ///
  /// In fr, this message translates to:
  /// **'Noyau dégradé : remontez le QG'**
  String get actionFailureKernelDegraded;

  /// No description provided for @actionFailureNoSuchPlayer.
  ///
  /// In fr, this message translates to:
  /// **'Joueur introuvable'**
  String get actionFailureNoSuchPlayer;

  /// No description provided for @actionFailureCannotAttackSelf.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de s\'attaquer soi-même'**
  String get actionFailureCannotAttackSelf;

  /// No description provided for @actionFailurePlayerFallen.
  ///
  /// In fr, this message translates to:
  /// **'Cette base est tombée'**
  String get actionFailurePlayerFallen;

  /// No description provided for @actionFailureBaseNotRevealed.
  ///
  /// In fr, this message translates to:
  /// **'Base non repérée : explorez jusqu\'à elle'**
  String get actionFailureBaseNotRevealed;

  /// No description provided for @actionFailureAttackTooEarly.
  ///
  /// In fr, this message translates to:
  /// **'Trop tôt pour attaquer une base'**
  String get actionFailureAttackTooEarly;

  /// No description provided for @actionFailureNoPendingEvent.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement en attente'**
  String get actionFailureNoPendingEvent;

  /// No description provided for @actionFailureNotThisChoiceTurn.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas le tour de ce choix'**
  String get actionFailureNotThisChoiceTurn;

  /// No description provided for @actionFailureNotEnoughStockToTrade.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant pour échanger'**
  String get actionFailureNotEnoughStockToTrade;

  /// No description provided for @actionFailureBranchNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Branche introuvable'**
  String get actionFailureBranchNotFound;

  /// No description provided for @actionFailureBranchLocked.
  ///
  /// In fr, this message translates to:
  /// **'Branche verrouillée'**
  String get actionFailureBranchLocked;

  /// No description provided for @actionFailureBranchAlreadyUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Branche déjà débloquée'**
  String get actionFailureBranchAlreadyUnlocked;

  /// No description provided for @actionFailureLaboratoryRequired.
  ///
  /// In fr, this message translates to:
  /// **'Laboratoire requis'**
  String get actionFailureLaboratoryRequired;

  /// No description provided for @actionFailureLaboratoryLevelTooLow.
  ///
  /// In fr, this message translates to:
  /// **'Niveau de laboratoire insuffisant'**
  String get actionFailureLaboratoryLevelTooLow;

  /// No description provided for @actionFailureResearchAlreadyStarted.
  ///
  /// In fr, this message translates to:
  /// **'Recherche déjà lancée ce tour'**
  String get actionFailureResearchAlreadyStarted;

  /// No description provided for @actionFailureBuildingNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Bâtiment introuvable'**
  String get actionFailureBuildingNotFound;

  /// No description provided for @actionFailureWorksitesBusy.
  ///
  /// In fr, this message translates to:
  /// **'Chantiers occupés ce tour'**
  String get actionFailureWorksitesBusy;

  /// No description provided for @actionFailureMaxLevelReached.
  ///
  /// In fr, this message translates to:
  /// **'Niveau maximum atteint'**
  String get actionFailureMaxLevelReached;

  /// No description provided for @actionFailureNotEnoughResources.
  ///
  /// In fr, this message translates to:
  /// **'Ressources insuffisantes'**
  String get actionFailureNotEnoughResources;

  /// No description provided for @actionFailureUnitLocked.
  ///
  /// In fr, this message translates to:
  /// **'Unité verrouillée'**
  String get actionFailureUnitLocked;

  /// No description provided for @actionFailureRecruitmentAlreadyDone.
  ///
  /// In fr, this message translates to:
  /// **'Recrutement déjà effectué ce tour'**
  String get actionFailureRecruitmentAlreadyDone;

  /// No description provided for @actionFailureInvalidQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité invalide'**
  String get actionFailureInvalidQuantity;

  /// No description provided for @actionFailureGameOver.
  ///
  /// In fr, this message translates to:
  /// **'Partie terminée'**
  String get actionFailureGameOver;

  /// No description provided for @historyBuildingTitle.
  ///
  /// In fr, this message translates to:
  /// **'{building} niv. {level}'**
  String historyBuildingTitle(String building, int level);

  /// No description provided for @historyResearchUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'{branch} débloquée'**
  String historyResearchUnlocked(String branch);

  /// No description provided for @historyResearchLevel.
  ///
  /// In fr, this message translates to:
  /// **'{branch} niv. {level}'**
  String historyResearchLevel(String branch, int level);

  /// No description provided for @historyResearchImproved.
  ///
  /// In fr, this message translates to:
  /// **'{branch} améliorée'**
  String historyResearchImproved(String branch);

  /// No description provided for @historyRecruitTitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{units} recruté} other{{units} recrutés}}'**
  String historyRecruitTitle(int count, String units);

  /// No description provided for @historyExploreTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exploration ({x}, {y})'**
  String historyExploreTitle(int x, int y);

  /// No description provided for @historyCollectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trésor collecté ({x}, {y})'**
  String historyCollectTitle(int x, int y);

  /// No description provided for @historyCombatVictory.
  ///
  /// In fr, this message translates to:
  /// **'Victoire vs Repaire niv. {level}'**
  String historyCombatVictory(int level);

  /// No description provided for @historyCombatDefeat.
  ///
  /// In fr, this message translates to:
  /// **'Défaite vs Repaire niv. {level}'**
  String historyCombatDefeat(int level);

  /// No description provided for @historyTurnEndTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tour {turn} terminé'**
  String historyTurnEndTitle(int turn);

  /// No description provided for @historyCaptureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Capture : {name}'**
  String historyCaptureTitle(String name);

  /// No description provided for @historyCaptureVictory.
  ///
  /// In fr, this message translates to:
  /// **'{turns, plural, one{Victoire en {turns} tour} other{Victoire en {turns} tours}}'**
  String historyCaptureVictory(int turns);

  /// No description provided for @historyDescentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Descente au Niveau {level}'**
  String historyDescentTitle(int level);

  /// No description provided for @historyDescentUnits.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} unité envoyée} other{{count} unités envoyées}}'**
  String historyDescentUnits(int count);

  /// No description provided for @historyReinforcementTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renforts vers Niveau {level}'**
  String historyReinforcementTitle(int level);

  /// No description provided for @historyReinforcementUnits.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} unité en transit} other{{count} unités en transit}}'**
  String historyReinforcementUnits(int count);

  /// No description provided for @historyRaidRepelled.
  ///
  /// In fr, this message translates to:
  /// **'Raid repoussé'**
  String get historyRaidRepelled;

  /// No description provided for @historyRaidLost.
  ///
  /// In fr, this message translates to:
  /// **'Base pillée par un raid'**
  String get historyRaidLost;

  /// No description provided for @historyAssaultWon.
  ///
  /// In fr, this message translates to:
  /// **'Assaut réussi contre {name}'**
  String historyAssaultWon(String name);

  /// No description provided for @historyAssaultFailed.
  ///
  /// In fr, this message translates to:
  /// **'Assaut repoussé par {name}'**
  String historyAssaultFailed(String name);

  /// No description provided for @historyAssaultSuffered.
  ///
  /// In fr, this message translates to:
  /// **'Base attaquée par {name}'**
  String historyAssaultSuffered(String name);

  /// No description provided for @historyAssaultRepelled.
  ///
  /// In fr, this message translates to:
  /// **'Assaut de {name} repoussé'**
  String historyAssaultRepelled(String name);

  /// No description provided for @historyPredatorsRepelled.
  ///
  /// In fr, this message translates to:
  /// **'Banc de prédateurs repoussé'**
  String get historyPredatorsRepelled;

  /// No description provided for @historyPredatorsLost.
  ///
  /// In fr, this message translates to:
  /// **'Base pillée par un banc de prédateurs'**
  String get historyPredatorsLost;

  /// No description provided for @historyVolcanoRepelled.
  ///
  /// In fr, this message translates to:
  /// **'Vague repoussée sur le Noyau'**
  String get historyVolcanoRepelled;

  /// No description provided for @historyVolcanoLost.
  ///
  /// In fr, this message translates to:
  /// **'Le Noyau a perdu un niveau'**
  String get historyVolcanoLost;

  /// No description provided for @historyEventAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Accepté'**
  String get historyEventAccepted;

  /// No description provided for @historyEventRefused.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get historyEventRefused;

  /// No description provided for @historyEventDefaulted.
  ///
  /// In fr, this message translates to:
  /// **'Option prudente, sans choix'**
  String get historyEventDefaulted;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get commonConfirm;

  /// No description provided for @commonGotIt.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get commonGotIt;

  /// No description provided for @commonSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get commonSend;

  /// No description provided for @commonBackToBase.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la base'**
  String get commonBackToBase;

  /// No description provided for @commonBackToMap.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la carte'**
  String get commonBackToMap;

  /// No description provided for @commonTurn.
  ///
  /// In fr, this message translates to:
  /// **'Tour {turn}'**
  String commonTurn(int turn);

  /// No description provided for @statHp.
  ///
  /// In fr, this message translates to:
  /// **'PV'**
  String get statHp;

  /// No description provided for @statAttack.
  ///
  /// In fr, this message translates to:
  /// **'ATK'**
  String get statAttack;

  /// No description provided for @statDefense.
  ///
  /// In fr, this message translates to:
  /// **'DEF'**
  String get statDefense;

  /// No description provided for @fightVictory.
  ///
  /// In fr, this message translates to:
  /// **'VICTOIRE'**
  String get fightVictory;

  /// No description provided for @fightDefeat.
  ///
  /// In fr, this message translates to:
  /// **'DÉFAITE'**
  String get fightDefeat;

  /// No description provided for @fightKernelCaptured.
  ///
  /// In fr, this message translates to:
  /// **'NOYAU CAPTURÉ'**
  String get fightKernelCaptured;

  /// No description provided for @fightBaseCaptured.
  ///
  /// In fr, this message translates to:
  /// **'BASE CAPTURÉE'**
  String get fightBaseCaptured;

  /// No description provided for @fightTurnCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Combat en {count} tour} other{Combat en {count} tours}}'**
  String fightTurnCount(int count);

  /// No description provided for @fightYourUnits.
  ///
  /// In fr, this message translates to:
  /// **'Vos unités'**
  String get fightYourUnits;

  /// No description provided for @fightUnitAccounting.
  ///
  /// In fr, this message translates to:
  /// **'Envoyés : {sent} / Intactes : {intact} / Blessés : {wounded} / Morts : {dead}'**
  String fightUnitAccounting(int sent, int intact, int wounded, int dead);

  /// No description provided for @fightEnemiesKilled.
  ///
  /// In fr, this message translates to:
  /// **'Ennemis tués : {killed}/{total}'**
  String fightEnemiesKilled(int killed, int total);

  /// No description provided for @fightGuardiansKilled.
  ///
  /// In fr, this message translates to:
  /// **'Gardiens éliminés : {killed}/{total}'**
  String fightGuardiansKilled(int killed, int total);

  /// No description provided for @fightLoot.
  ///
  /// In fr, this message translates to:
  /// **'Butin'**
  String get fightLoot;

  /// No description provided for @fightNoLoot.
  ///
  /// In fr, this message translates to:
  /// **'Aucun butin'**
  String get fightNoLoot;

  /// No description provided for @fightTitle.
  ///
  /// In fr, this message translates to:
  /// **'Combat ({x}, {y})'**
  String fightTitle(int x, int y);

  /// No description provided for @fightAssaultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assaut ({x}, {y})'**
  String fightAssaultTitle(int x, int y);

  /// No description provided for @fightAssaultOn.
  ///
  /// In fr, this message translates to:
  /// **'Assaut : {target}'**
  String fightAssaultOn(String target);

  /// No description provided for @fightPrepare.
  ///
  /// In fr, this message translates to:
  /// **'Préparer le combat'**
  String get fightPrepare;

  /// No description provided for @fightLaunch.
  ///
  /// In fr, this message translates to:
  /// **'Lancer le combat'**
  String get fightLaunch;

  /// No description provided for @fightLaunchAssault.
  ///
  /// In fr, this message translates to:
  /// **'Lancer l\'assaut'**
  String get fightLaunchAssault;

  /// No description provided for @fightAdmiralRequired.
  ///
  /// In fr, this message translates to:
  /// **'Un Amiral des Abysses est requis pour lancer l\'assaut'**
  String get fightAdmiralRequired;

  /// No description provided for @fightStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock : {count}'**
  String fightStock(int count);

  /// No description provided for @fightAlliesAlive.
  ///
  /// In fr, this message translates to:
  /// **'Alliés vivants : {count}'**
  String fightAlliesAlive(int count);

  /// No description provided for @fightAlliesHp.
  ///
  /// In fr, this message translates to:
  /// **'PV alliés : {hp}'**
  String fightAlliesHp(int hp);

  /// No description provided for @fightDamageDealt.
  ///
  /// In fr, this message translates to:
  /// **'Dégâts infligés : {damage}'**
  String fightDamageDealt(int damage);

  /// No description provided for @fightEnemiesAlive.
  ///
  /// In fr, this message translates to:
  /// **'Ennemis vivants : {count}'**
  String fightEnemiesAlive(int count);

  /// No description provided for @fightEnemiesHp.
  ///
  /// In fr, this message translates to:
  /// **'PV ennemis : {hp}'**
  String fightEnemiesHp(int hp);

  /// No description provided for @fightDamageTaken.
  ///
  /// In fr, this message translates to:
  /// **'Dégâts subis : {damage}'**
  String fightDamageTaken(int damage);

  /// No description provided for @fightCriticalHits.
  ///
  /// In fr, this message translates to:
  /// **'Coups critiques : {count}'**
  String fightCriticalHits(int count);

  /// No description provided for @fightMilitaryBonus.
  ///
  /// In fr, this message translates to:
  /// **'Bonus militaire : {bonuses}'**
  String fightMilitaryBonus(String bonuses);

  /// No description provided for @fightMilitaryBonusNone.
  ///
  /// In fr, this message translates to:
  /// **'Bonus militaire : aucun'**
  String get fightMilitaryBonusNone;

  /// No description provided for @fightLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String fightLevel(int level);

  /// No description provided for @fightWeakAgainst.
  ///
  /// In fr, this message translates to:
  /// **'Faible contre : {unit}'**
  String fightWeakAgainst(String unit);

  /// No description provided for @mapLevelSurface.
  ///
  /// In fr, this message translates to:
  /// **'Surface'**
  String get mapLevelSurface;

  /// No description provided for @mapLevelDepths.
  ///
  /// In fr, this message translates to:
  /// **'Profondeurs'**
  String get mapLevelDepths;

  /// No description provided for @mapLevelCore.
  ///
  /// In fr, this message translates to:
  /// **'Noyau'**
  String get mapLevelCore;

  /// No description provided for @mapLevelChip.
  ///
  /// In fr, this message translates to:
  /// **'Niv. {level} : {name}'**
  String mapLevelChip(int level, String name);

  /// No description provided for @mapDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get mapDifficulty;

  /// No description provided for @mapLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get mapLevel;

  /// No description provided for @mapUnits.
  ///
  /// In fr, this message translates to:
  /// **'Unités'**
  String get mapUnits;

  /// No description provided for @mapIncomeOnceCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Revenu une fois capturée'**
  String get mapIncomeOnceCaptured;

  /// No description provided for @mapPearlsPerTurn.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{+{count} perle par tour} other{+{count} perles par tour}}'**
  String mapPearlsPerTurn(int count);

  /// No description provided for @mapGuardedNeutral.
  ///
  /// In fr, this message translates to:
  /// **'Neutre — Gardiens présents'**
  String get mapGuardedNeutral;

  /// No description provided for @mapAssault.
  ///
  /// In fr, this message translates to:
  /// **'Assaut'**
  String get mapAssault;

  /// No description provided for @mapCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Capturée'**
  String get mapCaptured;

  /// No description provided for @mapUnitsOnLevel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} unité au Niveau {level}} other{{count} unités au Niveau {level}}}'**
  String mapUnitsOnLevel(int count, int level);

  /// No description provided for @mapBuildingRequired.
  ///
  /// In fr, this message translates to:
  /// **'Bâtiment requis pour envoyer des unités : {building}'**
  String mapBuildingRequired(String building);

  /// No description provided for @mapSendUnitsToLevel.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer des unités au Niveau {level}'**
  String mapSendUnitsToLevel(int level);

  /// No description provided for @mapExploreTitle.
  ///
  /// In fr, this message translates to:
  /// **'Explorer ({x}, {y})'**
  String mapExploreTitle(int x, int y);

  /// No description provided for @mapCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût'**
  String get mapCost;

  /// No description provided for @mapScoutsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Éclaireurs disponibles'**
  String get mapScoutsAvailable;

  /// No description provided for @mapRevealedArea.
  ///
  /// In fr, this message translates to:
  /// **'Zone révélée'**
  String get mapRevealedArea;

  /// No description provided for @mapAreaCells.
  ///
  /// In fr, this message translates to:
  /// **'{side}×{side} cellules'**
  String mapAreaCells(int side);

  /// No description provided for @mapKernelUncaptured.
  ///
  /// In fr, this message translates to:
  /// **'Le cœur brûlant des abysses est gardé par de puissants gardiens.'**
  String get mapKernelUncaptured;

  /// No description provided for @mapKernelCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Tu as capturé le Noyau Volcanique. Monte-le au niveau 10 pour remporter la victoire. Dès le niveau 1, le Kraken vient le reprendre chaque tour : une vague gagnée lui retire un niveau.'**
  String get mapKernelCaptured;

  /// No description provided for @mapTreasureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trésor ({x}, {y})'**
  String mapTreasureTitle(int x, int y);

  /// No description provided for @mapCollectTreasure.
  ///
  /// In fr, this message translates to:
  /// **'Collecter le trésor'**
  String get mapCollectTreasure;

  /// No description provided for @mapTreasureResourceBonus.
  ///
  /// In fr, this message translates to:
  /// **'Algues, corail et minerai'**
  String get mapTreasureResourceBonus;

  /// No description provided for @mapTreasureRuins.
  ///
  /// In fr, this message translates to:
  /// **'Corail, minerai et perles'**
  String get mapTreasureRuins;

  /// No description provided for @mapTreasureWreck.
  ///
  /// In fr, this message translates to:
  /// **'Corail, minerai et une perle'**
  String get mapTreasureWreck;

  /// No description provided for @raidName.
  ///
  /// In fr, this message translates to:
  /// **'Raid'**
  String get raidName;

  /// No description provided for @raidPillage.
  ///
  /// In fr, this message translates to:
  /// **'Pillage'**
  String get raidPillage;

  /// No description provided for @raidNothingToLoot.
  ///
  /// In fr, this message translates to:
  /// **'Rien à piller'**
  String get raidNothingToLoot;

  /// No description provided for @raidPredatorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Banc de prédateurs (tour {turn})'**
  String raidPredatorsTitle(int turn);

  /// No description provided for @raidTitle.
  ///
  /// In fr, this message translates to:
  /// **'Raid sur la base (tour {turn})'**
  String raidTitle(int turn);

  /// No description provided for @raidRampart.
  ///
  /// In fr, this message translates to:
  /// **'Rempart de la Citadelle niv. {level}'**
  String raidRampart(int level);

  /// No description provided for @raidNoise.
  ///
  /// In fr, this message translates to:
  /// **'Bruit'**
  String get raidNoise;

  /// No description provided for @raidLostInARow.
  ///
  /// In fr, this message translates to:
  /// **'Raids perdus d\'affilée : {lost}/{limit}'**
  String raidLostInARow(int lost, int limit);

  /// No description provided for @raidIncomingThisTurn.
  ///
  /// In fr, this message translates to:
  /// **'Raid à la fin de ce tour : {wave}'**
  String raidIncomingThisTurn(String wave);

  /// No description provided for @raidIncomingOnTurn.
  ///
  /// In fr, this message translates to:
  /// **'Raid à la fin du tour {turn} : {wave}'**
  String raidIncomingOnTurn(int turn, String wave);

  /// No description provided for @raidBaseLooted.
  ///
  /// In fr, this message translates to:
  /// **'La base a été pillée'**
  String get raidBaseLooted;

  /// No description provided for @raidAnnounced.
  ///
  /// In fr, this message translates to:
  /// **'Un raid approche : {wave}, fin du tour {turn}'**
  String raidAnnounced(String wave, int turn);

  /// No description provided for @raidDueThisTurn.
  ///
  /// In fr, this message translates to:
  /// **'{attacker} ce tour : {wave} contre {defenders}'**
  String raidDueThisTurn(String attacker, String wave, String defenders);

  /// No description provided for @raidDefenders.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun défenseur} one{{count} défenseur} other{{count} défenseurs}}'**
  String raidDefenders(int count);

  /// No description provided for @raidLastChance.
  ///
  /// In fr, this message translates to:
  /// **'Si ce raid est perdu, la partie est terminée.'**
  String get raidLastChance;

  /// No description provided for @volcanoWaveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vague sur le Noyau (tour {turn})'**
  String volcanoWaveTitle(int turn);

  /// No description provided for @volcanoKernelHolds.
  ///
  /// In fr, this message translates to:
  /// **'Le Noyau tient au niveau {level}'**
  String volcanoKernelHolds(int level);

  /// No description provided for @volcanoKernelDrops.
  ///
  /// In fr, this message translates to:
  /// **'Le Noyau retombe au niveau {level}'**
  String volcanoKernelDrops(int level);

  /// No description provided for @volcanoMagmaRampart.
  ///
  /// In fr, this message translates to:
  /// **'Rempart de magma : {stats}'**
  String volcanoMagmaRampart(String stats);

  /// No description provided for @volcanoKernelLevel.
  ///
  /// In fr, this message translates to:
  /// **'Noyau niveau {level}'**
  String volcanoKernelLevel(int level);

  /// No description provided for @volcanoGarrison.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Garnison : {count} unité} other{Garnison : {count} unités}}'**
  String volcanoGarrison(int count);

  /// No description provided for @volcanoNextWave.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine vague, à la fin du tour : {wave}'**
  String volcanoNextWave(String wave);

  /// No description provided for @volcanoLevelsLost.
  ///
  /// In fr, this message translates to:
  /// **'Niveaux perdus face aux vagues : {count}'**
  String volcanoLevelsLost(int count);

  /// No description provided for @volcanoGarrisonUnits.
  ///
  /// In fr, this message translates to:
  /// **'Mettre en garnison'**
  String get volcanoGarrisonUnits;

  /// No description provided for @volcanoWithdraw.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get volcanoWithdraw;

  /// No description provided for @volcanoDueWarning.
  ///
  /// In fr, this message translates to:
  /// **'Vague sur le Noyau ce tour : {wave}, et aucune garnison. Le Noyau perdra probablement un niveau.'**
  String volcanoDueWarning(String wave);

  /// No description provided for @volcanoStatus.
  ///
  /// In fr, this message translates to:
  /// **'Noyau niv. {level}, fin du tour : {wave} contre une garnison de {size}'**
  String volcanoStatus(int level, String wave, int size);

  /// No description provided for @volcanoRepelled.
  ///
  /// In fr, this message translates to:
  /// **'Volcan : vague repoussée, {losses}'**
  String volcanoRepelled(String losses);

  /// No description provided for @volcanoKernelFell.
  ///
  /// In fr, this message translates to:
  /// **'Volcan : le Noyau retombe au niveau {level}'**
  String volcanoKernelFell(int level);

  /// No description provided for @volcanoWounded.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} blessé} other{{count} blessés}}'**
  String volcanoWounded(int count);

  /// No description provided for @volcanoDead.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} mort} other{{count} morts}}'**
  String volcanoDead(int count);

  /// No description provided for @volcanoKrakenRises.
  ///
  /// In fr, this message translates to:
  /// **'Le Kraken remonte : {wave} au prochain tour'**
  String volcanoKrakenRises(String wave);

  /// No description provided for @eventCardWarmLine1.
  ///
  /// In fr, this message translates to:
  /// **'Un courant chaud traverse la base.'**
  String get eventCardWarmLine1;

  /// No description provided for @eventCardWarmLine2.
  ///
  /// In fr, this message translates to:
  /// **'Il dope la production, mais son remous fait du bruit.'**
  String get eventCardWarmLine2;

  /// No description provided for @eventCardColdLine1.
  ///
  /// In fr, this message translates to:
  /// **'Un courant froid glace les serres.'**
  String get eventCardColdLine1;

  /// No description provided for @eventCardColdLine2.
  ///
  /// In fr, this message translates to:
  /// **'Sans chauffage, les algues poussent moins.'**
  String get eventCardColdLine2;

  /// No description provided for @eventCardPredatorsLine1.
  ///
  /// In fr, this message translates to:
  /// **'Un banc de prédateurs rôde autour de la base.'**
  String get eventCardPredatorsLine1;

  /// No description provided for @eventCardPredatorsWatching.
  ///
  /// In fr, this message translates to:
  /// **'Ils guettent la base.'**
  String get eventCardPredatorsWatching;

  /// No description provided for @eventCardPredatorsWave.
  ///
  /// In fr, this message translates to:
  /// **'{wave} contre {defenders} du niveau 1.'**
  String eventCardPredatorsWave(String wave, String defenders);

  /// No description provided for @eventCardSurvivorsLine1.
  ///
  /// In fr, this message translates to:
  /// **'Une capsule échouée lance une fusée de détresse.'**
  String get eventCardSurvivorsLine1;

  /// No description provided for @eventCardSurvivorsLine2.
  ///
  /// In fr, this message translates to:
  /// **'Ses survivants peuvent rejoindre la base, mais mangeront des algues.'**
  String get eventCardSurvivorsLine2;

  /// No description provided for @eventCardCaravanLine1.
  ///
  /// In fr, this message translates to:
  /// **'Une caravane de tortues passe près de la base.'**
  String get eventCardCaravanLine1;

  /// No description provided for @eventCardCaravanLine2.
  ///
  /// In fr, this message translates to:
  /// **'Son crabe marchand propose un échange.'**
  String get eventCardCaravanLine2;

  /// No description provided for @eventCardStormLine1.
  ///
  /// In fr, this message translates to:
  /// **'{turns, plural, one{Exploration impossible pendant {turns} tour.} other{Exploration impossible pendant {turns} tours.}}'**
  String eventCardStormLine1(int turns);

  /// No description provided for @eventCardStormLine2.
  ///
  /// In fr, this message translates to:
  /// **'La tempête couvre le bruit : jauge −{relief}.'**
  String eventCardStormLine2(int relief);

  /// No description provided for @eventCardWreckLine1.
  ///
  /// In fr, this message translates to:
  /// **'Une épave a coulé au bord de la zone explorée.'**
  String get eventCardWreckLine1;

  /// No description provided for @eventCardWreckLine2.
  ///
  /// In fr, this message translates to:
  /// **'{turns, plural, one{Explore-la avec un Éclaireur puis fouille-la avant {turns} tour (+{noise} bruit).} other{Explore-la avec un Éclaireur puis fouille-la avant {turns} tours (+{noise} bruit).}}'**
  String eventCardWreckLine2(int turns, int noise);

  /// No description provided for @eventCardWarmAccept.
  ///
  /// In fr, this message translates to:
  /// **'Exploiter (+{percent} % algues, corail, minerai pendant {turns} tours, +{noise} bruit/tour)'**
  String eventCardWarmAccept(int percent, int turns, int noise);

  /// No description provided for @eventCardWarmRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Laisser passer'**
  String get eventCardWarmRefuse;

  /// No description provided for @eventCardColdAccept.
  ///
  /// In fr, this message translates to:
  /// **'Chauffer les serres (−{energy} énergie/tour pendant {turns} tours)'**
  String eventCardColdAccept(int energy, int turns);

  /// No description provided for @eventCardColdRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Subir (−{percent} % d\'algues pendant {turns} tours)'**
  String eventCardColdRefuse(int percent, int turns);

  /// No description provided for @eventCardPredatorsAccept.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{L\'affronter ({count} monstre, fin du tour)} other{L\'affronter ({count} monstres, fin du tour)}}'**
  String eventCardPredatorsAccept(int count);

  /// No description provided for @eventCardPredatorsRefuse.
  ///
  /// In fr, this message translates to:
  /// **'L\'appâter (−{algae} algues)'**
  String eventCardPredatorsRefuse(int algae);

  /// No description provided for @eventCardSurvivorsAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accueillir {units}'**
  String eventCardSurvivorsAccept(String units);

  /// No description provided for @eventCardRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get eventCardRefuse;

  /// No description provided for @eventCardTrade.
  ///
  /// In fr, this message translates to:
  /// **'Échanger {give} {from} contre {get} {to}'**
  String eventCardTrade(int give, String from, int get, String to);

  /// No description provided for @eventCardLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get eventCardLater;

  /// No description provided for @eventCardPendingWarning.
  ///
  /// In fr, this message translates to:
  /// **'{event} : sans choix, l\'option prudente s\'appliquera'**
  String eventCardPendingWarning(String event);

  /// No description provided for @eventCardStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'Événement : {event} — choisir'**
  String eventCardStatusPending(String event);

  /// No description provided for @techScreenUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get techScreenUnlock;

  /// No description provided for @techScreenResearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get techScreenResearch;

  /// No description provided for @techScreenChoiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'{branch} · Niveau {level} · Choix'**
  String techScreenChoiceTitle(String branch, int level);

  /// No description provided for @techScreenNodeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{branch} · Niveau {level} · {effect}'**
  String techScreenNodeSubtitle(String branch, int level, String effect);

  /// No description provided for @techScreenChoiceWarning.
  ///
  /// In fr, this message translates to:
  /// **'Une seule option par partie, l\'autre sera perdue.'**
  String get techScreenChoiceWarning;

  /// No description provided for @techScreenChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir'**
  String get techScreenChoose;

  /// No description provided for @techScreenChosen.
  ///
  /// In fr, this message translates to:
  /// **'Choisi ✓'**
  String get techScreenChosen;

  /// No description provided for @techScreenDiscarded.
  ///
  /// In fr, this message translates to:
  /// **'Écarté'**
  String get techScreenDiscarded;

  /// No description provided for @techScreenOr.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get techScreenOr;

  /// No description provided for @techScreenAcquired.
  ///
  /// In fr, this message translates to:
  /// **'Acquis ✓'**
  String get techScreenAcquired;

  /// No description provided for @techScreenSurcharge.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les recherches coûteront ×{factor} une fois cette branche ouverte.'**
  String techScreenSurcharge(String factor);

  /// No description provided for @techScreenUnlockBranchFirst.
  ///
  /// In fr, this message translates to:
  /// **'Débloque d\'abord la branche'**
  String get techScreenUnlockBranchFirst;

  /// No description provided for @techScreenResearchPreviousFirst.
  ///
  /// In fr, this message translates to:
  /// **'Recherche d\'abord le niveau {level}'**
  String techScreenResearchPreviousFirst(int level);

  /// No description provided for @techScreenLabRequired.
  ///
  /// In fr, this message translates to:
  /// **'Laboratoire niveau {level} requis'**
  String techScreenLabRequired(int level);

  /// No description provided for @techScreenOneResearchPerTurn.
  ///
  /// In fr, this message translates to:
  /// **'Une recherche par tour : attends le prochain tour'**
  String get techScreenOneResearchPerTurn;

  /// No description provided for @techScreenMedallionLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niv. {level}'**
  String techScreenMedallionLevel(int level);

  /// No description provided for @objectiveSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get objectiveSheetTitle;

  /// No description provided for @objectiveEventHeader.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs d\'événement'**
  String get objectiveEventHeader;

  /// No description provided for @objectiveProgress.
  ///
  /// In fr, this message translates to:
  /// **'{title} : {current}/{target}'**
  String objectiveProgress(String title, int current, int target);

  /// No description provided for @objectiveCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Objectif accompli : {title}'**
  String objectiveCompleted(String title);

  /// No description provided for @objectiveMissed.
  ///
  /// In fr, this message translates to:
  /// **'(raté)'**
  String get objectiveMissed;

  /// No description provided for @objectiveRaiseHq.
  ///
  /// In fr, this message translates to:
  /// **'Monte le QG au niveau {level}'**
  String objectiveRaiseHq(int level);

  /// No description provided for @objectiveAlgaeFarm.
  ///
  /// In fr, this message translates to:
  /// **'Construis la Ferme d\'algues'**
  String get objectiveAlgaeFarm;

  /// No description provided for @objectiveMines.
  ///
  /// In fr, this message translates to:
  /// **'Construis la Mine de corail et l\'Extracteur de minerai'**
  String get objectiveMines;

  /// No description provided for @objectiveSolarPanel.
  ///
  /// In fr, this message translates to:
  /// **'Construis le Panneau solaire'**
  String get objectiveSolarPanel;

  /// No description provided for @objectiveBarracksAndScouts.
  ///
  /// In fr, this message translates to:
  /// **'Construis la Caserne et recrute {count, plural, one{{count} Éclaireur} other{{count} Éclaireurs}}'**
  String objectiveBarracksAndScouts(int count);

  /// No description provided for @objectiveExplore.
  ///
  /// In fr, this message translates to:
  /// **'Explore une case autour de la base'**
  String get objectiveExplore;

  /// No description provided for @objectiveLaboratoryAndResearch.
  ///
  /// In fr, this message translates to:
  /// **'Construis le Laboratoire et lance une recherche'**
  String get objectiveLaboratoryAndResearch;

  /// No description provided for @objectiveFirstRaid.
  ///
  /// In fr, this message translates to:
  /// **'Repousse le premier raid'**
  String get objectiveFirstRaid;

  /// No description provided for @objectiveTakeLair.
  ///
  /// In fr, this message translates to:
  /// **'Prends un repaire'**
  String get objectiveTakeLair;

  /// No description provided for @objectiveCoralCitadel.
  ///
  /// In fr, this message translates to:
  /// **'Construis la Citadelle corallienne'**
  String get objectiveCoralCitadel;

  /// No description provided for @objectiveTakeFaille.
  ///
  /// In fr, this message translates to:
  /// **'Prends la Faille'**
  String get objectiveTakeFaille;

  /// No description provided for @objectiveDescentModule.
  ///
  /// In fr, this message translates to:
  /// **'Construis le Module de Descente'**
  String get objectiveDescentModule;

  /// No description provided for @objectiveDescend.
  ///
  /// In fr, this message translates to:
  /// **'Descends au niveau {level}'**
  String objectiveDescend(int level);

  /// No description provided for @objectiveTakeCheminee.
  ///
  /// In fr, this message translates to:
  /// **'Prends la Cheminée'**
  String get objectiveTakeCheminee;

  /// No description provided for @objectivePressureCapsule.
  ///
  /// In fr, this message translates to:
  /// **'Construis la Capsule Pressurisée'**
  String get objectivePressureCapsule;

  /// No description provided for @objectiveTakeKernel.
  ///
  /// In fr, this message translates to:
  /// **'Prends le Noyau Volcanique'**
  String get objectiveTakeKernel;

  /// No description provided for @objectiveRaiseKernel.
  ///
  /// In fr, this message translates to:
  /// **'Monte le Noyau au niveau {level}'**
  String objectiveRaiseKernel(int level);

  /// No description provided for @chapterInstallation.
  ///
  /// In fr, this message translates to:
  /// **'Installation'**
  String get chapterInstallation;

  /// No description provided for @chapterReef.
  ///
  /// In fr, this message translates to:
  /// **'Le récif'**
  String get chapterReef;

  /// No description provided for @chapterRift.
  ///
  /// In fr, this message translates to:
  /// **'La Faille'**
  String get chapterRift;

  /// No description provided for @chapterChimney.
  ///
  /// In fr, this message translates to:
  /// **'La Cheminée'**
  String get chapterChimney;

  /// No description provided for @chapterKernel.
  ///
  /// In fr, this message translates to:
  /// **'Le Noyau'**
  String get chapterKernel;

  /// No description provided for @chapterAwakening.
  ///
  /// In fr, this message translates to:
  /// **'Le réveil'**
  String get chapterAwakening;

  /// No description provided for @chapterNumbered.
  ///
  /// In fr, this message translates to:
  /// **'{number}. {title}'**
  String chapterNumbered(int number, String title);

  /// No description provided for @tipGuideTitle.
  ///
  /// In fr, this message translates to:
  /// **'Guide'**
  String get tipGuideTitle;

  /// No description provided for @tipCategoryBase.
  ///
  /// In fr, this message translates to:
  /// **'Base'**
  String get tipCategoryBase;

  /// No description provided for @tipCategoryThreats.
  ///
  /// In fr, this message translates to:
  /// **'Menaces'**
  String get tipCategoryThreats;

  /// No description provided for @tipCategoryMap.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get tipCategoryMap;

  /// No description provided for @tipCategoryEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get tipCategoryEvents;

  /// No description provided for @tipNoiseGaugeTitle.
  ///
  /// In fr, this message translates to:
  /// **'La jauge de bruit'**
  String get tipNoiseGaugeTitle;

  /// No description provided for @tipNoiseGaugeLine1.
  ///
  /// In fr, this message translates to:
  /// **'Chaque chantier, chaque recrue et chaque exploration font du bruit, et ta base en fait un peu à chaque tour.'**
  String get tipNoiseGaugeLine1;

  /// No description provided for @tipNoiseGaugeLine2.
  ///
  /// In fr, this message translates to:
  /// **'Quand la jauge atteint {threshold}, les monstres l\'entendent : un raid est annoncé.'**
  String tipNoiseGaugeLine2(int threshold);

  /// No description provided for @tipWorksitesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Deux chantiers par tour'**
  String get tipWorksitesTitle;

  /// No description provided for @tipWorksitesLine1.
  ///
  /// In fr, this message translates to:
  /// **'Ton QG niveau {level} ouvre un deuxième chantier : deux bâtiments montent à chaque tour.'**
  String tipWorksitesLine1(int level);

  /// No description provided for @tipWorksitesLine2.
  ///
  /// In fr, this message translates to:
  /// **'Le QG niveau {level} en ouvrira un troisième. La recherche, elle, reste à une par tour.'**
  String tipWorksitesLine2(int level);

  /// No description provided for @tipTechChoiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les choix de la recherche'**
  String get tipTechChoiceTitle;

  /// No description provided for @tipTechChoiceLine1.
  ///
  /// In fr, this message translates to:
  /// **'Le prochain nœud de ta branche est un choix entre deux options.'**
  String get tipTechChoiceLine1;

  /// No description provided for @tipTechChoiceLine2.
  ///
  /// In fr, this message translates to:
  /// **'Ce choix est définitif : l\'autre option restera fermée pour toute la partie.'**
  String get tipTechChoiceLine2;

  /// No description provided for @tipTechChoiceLine3.
  ///
  /// In fr, this message translates to:
  /// **'Prends le temps de lire les deux avant de lancer la recherche.'**
  String get tipTechChoiceLine3;

  /// No description provided for @tipRaidAnnouncedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Un raid approche'**
  String get tipRaidAnnouncedTitle;

  /// No description provided for @tipRaidAnnouncedLine1.
  ///
  /// In fr, this message translates to:
  /// **'Ton bruit a attiré des monstres : ils frapperont ta base dans {turns, plural, one{{turns} tour} other{{turns} tours}}.'**
  String tipRaidAnnouncedLine1(int turns);

  /// No description provided for @tipRaidAnnouncedLine2.
  ///
  /// In fr, this message translates to:
  /// **'Recrute des défenseurs, les Harponneurs sont faits pour ça.'**
  String get tipRaidAnnouncedLine2;

  /// No description provided for @tipRaidAnnouncedLine3.
  ///
  /// In fr, this message translates to:
  /// **'Le rempart de la Citadelle corallienne t\'aidera aussi à tenir.'**
  String get tipRaidAnnouncedLine3;

  /// No description provided for @tipRaidReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Le rapport de raid'**
  String get tipRaidReportTitle;

  /// No description provided for @tipRaidReportLine1.
  ///
  /// In fr, this message translates to:
  /// **'Après chaque raid, le rapport montre le combat, tes pertes et le butin.'**
  String get tipRaidReportLine1;

  /// No description provided for @tipRaidReportLine2.
  ///
  /// In fr, this message translates to:
  /// **'Un raid perdu pille une partie de tes ressources.'**
  String get tipRaidReportLine2;

  /// No description provided for @tipRaidReportLine3.
  ///
  /// In fr, this message translates to:
  /// **'Un raid repoussé efface ta série de défaites.'**
  String get tipRaidReportLine3;

  /// No description provided for @tipLastChanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dernière chance'**
  String get tipLastChanceTitle;

  /// No description provided for @tipLastChanceLine1.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Ta base a perdu {count} raid.} other{Ta base a perdu {count} raids d\'affilée.}}'**
  String tipLastChanceLine1(int count);

  /// No description provided for @tipLastChanceLine2.
  ///
  /// In fr, this message translates to:
  /// **'Si le prochain raid est perdu lui aussi, la partie est finie.'**
  String get tipLastChanceLine2;

  /// No description provided for @tipLastChanceLine3.
  ///
  /// In fr, this message translates to:
  /// **'Mets tes forces dans la défense : une victoire efface la série.'**
  String get tipLastChanceLine3;

  /// No description provided for @tipMonsterFamiliesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les familles de monstres'**
  String get tipMonsterFamiliesTitle;

  /// No description provided for @tipMonsterFamiliesLine1.
  ///
  /// In fr, this message translates to:
  /// **'Chaque repaire abrite une famille, avec sa propre règle de combat.'**
  String get tipMonsterFamiliesLine1;

  /// No description provided for @tipMonsterFamiliesLine2.
  ///
  /// In fr, this message translates to:
  /// **'Chaque famille a son point faible : une unité qui la contre.'**
  String get tipMonsterFamiliesLine2;

  /// No description provided for @tipMonsterFamiliesLine3.
  ///
  /// In fr, this message translates to:
  /// **'Touche le repaire sur la Carte pour la connaître avant d\'attaquer.'**
  String get tipMonsterFamiliesLine3;

  /// No description provided for @tipVolcanoWaveTitle.
  ///
  /// In fr, this message translates to:
  /// **'La vague du Volcan'**
  String get tipVolcanoWaveTitle;

  /// No description provided for @tipVolcanoWaveLine1.
  ///
  /// In fr, this message translates to:
  /// **'Le Volcan envoie ses Krakens reprendre le Noyau.'**
  String get tipVolcanoWaveLine1;

  /// No description provided for @tipVolcanoWaveLine2.
  ///
  /// In fr, this message translates to:
  /// **'La vague frappe à la fin du prochain tour : garde une garnison au Noyau.'**
  String get tipVolcanoWaveLine2;

  /// No description provided for @tipVolcanoWaveLine3.
  ///
  /// In fr, this message translates to:
  /// **'Chaque vague perdue fait perdre un niveau au Noyau.'**
  String get tipVolcanoWaveLine3;

  /// No description provided for @tipLairTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les repaires'**
  String get tipLairTitle;

  /// No description provided for @tipLairLine1.
  ///
  /// In fr, this message translates to:
  /// **'Sur la Carte, un repaire de monstres garde sa case : attaque-le avec ton armée.'**
  String get tipLairLine1;

  /// No description provided for @tipLairLine2.
  ///
  /// In fr, this message translates to:
  /// **'Vaincus, les monstres laissent leur butin, mais chaque combat fait du bruit.'**
  String get tipLairLine2;

  /// No description provided for @tipLairLine3.
  ///
  /// In fr, this message translates to:
  /// **'Regarde leur nombre avant de choisir tes unités.'**
  String get tipLairLine3;

  /// No description provided for @tipChestAndRuinsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Coffres et ruines'**
  String get tipChestAndRuinsTitle;

  /// No description provided for @tipChestAndRuinsLine1.
  ///
  /// In fr, this message translates to:
  /// **'Un coffre ou des ruines cachent des ressources.'**
  String get tipChestAndRuinsLine1;

  /// No description provided for @tipChestAndRuinsLine2.
  ///
  /// In fr, this message translates to:
  /// **'Touche la case sur la Carte pour les fouiller : c\'est sans danger et sans bruit.'**
  String get tipChestAndRuinsLine2;

  /// No description provided for @tipTransitionBaseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les bases de transition'**
  String get tipTransitionBaseTitle;

  /// No description provided for @tipTransitionBaseLine1.
  ///
  /// In fr, this message translates to:
  /// **'Une base gardée, sur la Carte, mène vers les profondeurs.'**
  String get tipTransitionBaseLine1;

  /// No description provided for @tipTransitionBaseLine2.
  ///
  /// In fr, this message translates to:
  /// **'Prise d\'assaut, elle te rapporte des perles à chaque tour.'**
  String get tipTransitionBaseLine2;

  /// No description provided for @tipTransitionBaseLine3.
  ///
  /// In fr, this message translates to:
  /// **'Elle ouvre aussi la route du niveau suivant.'**
  String get tipTransitionBaseLine3;

  /// No description provided for @tipDescentTitle.
  ///
  /// In fr, this message translates to:
  /// **'La descente'**
  String get tipDescentTitle;

  /// No description provided for @tipDescentLine1.
  ///
  /// In fr, this message translates to:
  /// **'Ton Module de Descente envoie des unités au niveau inférieur, par la Faille.'**
  String get tipDescentLine1;

  /// No description provided for @tipDescentLine2.
  ///
  /// In fr, this message translates to:
  /// **'Attention : une unité descendue ne remonte plus.'**
  String get tipDescentLine2;

  /// No description provided for @tipDescentLine3.
  ///
  /// In fr, this message translates to:
  /// **'En bas t\'attendent d\'autres repaires, et la route du Noyau.'**
  String get tipDescentLine3;

  /// No description provided for @tipEventsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les événements'**
  String get tipEventsTitle;

  /// No description provided for @tipEventsLine1.
  ///
  /// In fr, this message translates to:
  /// **'Tous les {minGap} à {maxGap} tours, un événement secoue les abysses.'**
  String tipEventsLine1(int minGap, int maxGap);

  /// No description provided for @tipEventsLine2.
  ///
  /// In fr, this message translates to:
  /// **'Tu as le tour suivant pour choisir ta réponse sur sa carte.'**
  String get tipEventsLine2;

  /// No description provided for @tipEventsLine3.
  ///
  /// In fr, this message translates to:
  /// **'Sans choix de ta part, l\'option prudente s\'applique d\'office.'**
  String get tipEventsLine3;

  /// No description provided for @tipWarmCurrentLine1.
  ///
  /// In fr, this message translates to:
  /// **'Un courant chaud dope ta production pendant {turns, plural, one{{turns} tour} other{{turns} tours}}.'**
  String tipWarmCurrentLine1(int turns);

  /// No description provided for @tipWarmCurrentLine2.
  ///
  /// In fr, this message translates to:
  /// **'Mais son remous fait du bruit à chaque tour.'**
  String get tipWarmCurrentLine2;

  /// No description provided for @tipWarmCurrentLine3.
  ///
  /// In fr, this message translates to:
  /// **'Exploite-le si tes défenses sont prêtes à recevoir un raid.'**
  String get tipWarmCurrentLine3;

  /// No description provided for @tipWreckLine1.
  ///
  /// In fr, this message translates to:
  /// **'Un galion englouti reste {turns, plural, one{{turns} tour} other{{turns} tours}} au bord de la zone explorée.'**
  String tipWreckLine1(int turns);

  /// No description provided for @tipWreckLine2.
  ///
  /// In fr, this message translates to:
  /// **'Explore sa case avec un Éclaireur, puis fouille-la pour son butin.'**
  String get tipWreckLine2;

  /// No description provided for @tipWreckLine3.
  ///
  /// In fr, this message translates to:
  /// **'La fouille fait du bruit (+{noise}) : choisis ton moment.'**
  String tipWreckLine3(int noise);

  /// No description provided for @tipPredatorsLine1.
  ///
  /// In fr, this message translates to:
  /// **'Un grand requin et son banc rôdent autour de ta base.'**
  String get tipPredatorsLine1;

  /// No description provided for @tipPredatorsLine2.
  ///
  /// In fr, this message translates to:
  /// **'Affronte-les pour leur butin, ou cède des algues pour les éloigner.'**
  String get tipPredatorsLine2;

  /// No description provided for @tipPredatorsLine3.
  ///
  /// In fr, this message translates to:
  /// **'Perdre contre eux ne met jamais fin à la partie.'**
  String get tipPredatorsLine3;

  /// No description provided for @tipStormLine1.
  ///
  /// In fr, this message translates to:
  /// **'La tempête ferme l\'exploration pendant {turns, plural, one{{turns} tour} other{{turns} tours}}.'**
  String tipStormLine1(int turns);

  /// No description provided for @tipStormLine2.
  ///
  /// In fr, this message translates to:
  /// **'En échange, elle couvre ton bruit : la jauge baisse de {relief}.'**
  String tipStormLine2(int relief);

  /// No description provided for @tipSurvivorsLine1.
  ///
  /// In fr, this message translates to:
  /// **'Une capsule échouée abrite des survivants.'**
  String get tipSurvivorsLine1;

  /// No description provided for @tipSurvivorsLine2.
  ///
  /// In fr, this message translates to:
  /// **'Accueillis, ils rejoignent ta base comme Harponneurs.'**
  String get tipSurvivorsLine2;

  /// No description provided for @tipSurvivorsLine3.
  ///
  /// In fr, this message translates to:
  /// **'Comme toute ton armée, ils mangent des algues à chaque tour.'**
  String get tipSurvivorsLine3;

  /// No description provided for @tipCaravanLine1.
  ///
  /// In fr, this message translates to:
  /// **'Une caravane de tortues passe près de ta base.'**
  String get tipCaravanLine1;

  /// No description provided for @tipCaravanLine2.
  ///
  /// In fr, this message translates to:
  /// **'Son crabe marchand échange ta ressource la plus abondante contre la plus rare.'**
  String get tipCaravanLine2;

  /// No description provided for @tipColdCurrentLine1.
  ///
  /// In fr, this message translates to:
  /// **'Un courant froid ralentit tes algues pendant {turns, plural, one{{turns} tour} other{{turns} tours}}.'**
  String tipColdCurrentLine1(int turns);

  /// No description provided for @tipColdCurrentLine2.
  ///
  /// In fr, this message translates to:
  /// **'Chauffer les serres coûte de l\'énergie, mais sauve la récolte.'**
  String get tipColdCurrentLine2;

  /// No description provided for @tipColdCurrentLine3.
  ///
  /// In fr, this message translates to:
  /// **'Sans algues, ton armée ne tient pas : surveille ton stock.'**
  String get tipColdCurrentLine3;

  /// No description provided for @guideLessonHqLevel1.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans les abysses ! Touche le QG pour lancer ton premier chantier : un seul par tour pour commencer. Puis appuie sur « Tour suivant ».'**
  String get guideLessonHqLevel1;

  /// No description provided for @guideLessonAlgaeFarm.
  ///
  /// In fr, this message translates to:
  /// **'Bravo pour ce premier chantier ! Les algues nourrissent ton armée : chaque unité en mange à chaque tour. Construis la Ferme d\'algues.'**
  String get guideLessonAlgaeFarm;

  /// No description provided for @guideLessonMines.
  ///
  /// In fr, this message translates to:
  /// **'Le corail et le minerai paient presque tout. Construis la Mine de corail puis l\'Extracteur de minerai, un par tour. Regarde bien : chaque niveau coûte plus cher que le précédent.'**
  String get guideLessonMines;

  /// No description provided for @guideLessonSolarPanel.
  ///
  /// In fr, this message translates to:
  /// **'L\'Extracteur consomme de l\'énergie, et la Caserne en consommera aussi. Sans énergie, ils s\'arrêtent. Construis le Panneau solaire.'**
  String get guideLessonSolarPanel;

  /// No description provided for @guideLessonHqLevel2.
  ///
  /// In fr, this message translates to:
  /// **'Le QG niveau {level} débloque la Caserne et le Laboratoire. Mais chaque chantier fait du bruit : surveille la jauge en haut de l\'écran, elle attire les monstres.'**
  String guideLessonHqLevel2(int level);

  /// No description provided for @guideLessonBarracksAndScouts.
  ///
  /// In fr, this message translates to:
  /// **'Construis la Caserne, puis recrute {count, plural, one{{count} Éclaireur} other{{count} Éclaireurs}} dans l\'onglet Armée. Chaque unité mange des algues à chaque tour, et chaque recrue fait monter le bruit.'**
  String guideLessonBarracksAndScouts(int count);

  /// No description provided for @guideLessonExplore.
  ///
  /// In fr, this message translates to:
  /// **'Autour de ta base, tout est dans le brouillard. Sur la Carte, envoie un Éclaireur sur une case voisine : tu y trouveras des repaires de monstres de différentes familles, et parfois des coffres.'**
  String get guideLessonExplore;

  /// No description provided for @guideLessonLaboratoryAndResearch.
  ///
  /// In fr, this message translates to:
  /// **'Construis le Laboratoire, ouvre une branche dans l\'onglet Tech et lance une recherche. Une seule recherche par tour, et certains choix sont définitifs : prends le temps de lire.'**
  String get guideLessonLaboratoryAndResearch;

  /// No description provided for @guideLessonFirstRaid.
  ///
  /// In fr, this message translates to:
  /// **'Le bruit finit toujours par attirer un raid, annoncé {turns, plural, one{{turns} tour} other{{turns} tours}} à l\'avance. Recrute des Harponneurs pour défendre ta base. Plus tard, le rempart de la Citadelle t\'aidera aussi.'**
  String guideLessonFirstRaid(int turns);

  /// No description provided for @guideGoalMet.
  ///
  /// In fr, this message translates to:
  /// **'Bravo, c\'est fait ! Termine le tour pour valider l\'objectif et toucher ta récompense.'**
  String get guideGoalMet;

  /// No description provided for @guideWorksiteTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ton chantier du tour est déjà pris. Termine le tour : tu construiras la suite au prochain.'**
  String get guideWorksiteTaken;

  /// No description provided for @guideAlreadyRecruited.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà recruté ces unités ce tour. Termine le tour pour en recruter d\'autres.'**
  String get guideAlreadyRecruited;

  /// No description provided for @guideExploring.
  ///
  /// In fr, this message translates to:
  /// **'Ton Éclaireur est en route. Termine le tour pour découvrir ce que cache la case.'**
  String get guideExploring;

  /// No description provided for @guideStorm.
  ///
  /// In fr, this message translates to:
  /// **'Une tempête ferme l\'exploration jusqu\'à la fin du tour {turn}. Patiente : l\'objectif t\'attend, termine le tour.'**
  String guideStorm(int turn);

  /// No description provided for @guideWreckWithoutBarracks.
  ///
  /// In fr, this message translates to:
  /// **'Une épave a coulé près de ta base, visible jusqu\'à la fin du tour {turn}. Il faut un Éclaireur pour l\'atteindre, donc une Caserne : continue ton objectif, elle viendra.'**
  String guideWreckWithoutBarracks(int turn);

  /// No description provided for @guideWreckWithoutScout.
  ///
  /// In fr, this message translates to:
  /// **'Une épave a coulé près de ta base, visible jusqu\'à la fin du tour {turn}. Recrute un Éclaireur dans l\'onglet Armée pour aller la fouiller.'**
  String guideWreckWithoutScout(int turn);

  /// No description provided for @guideRaidIntro.
  ///
  /// In fr, this message translates to:
  /// **'Le raid arrive au tour {turn} avec {monsters, plural, one{{monsters} monstre} other{{monsters} monstres}}.'**
  String guideRaidIntro(int turn, int monsters);

  /// No description provided for @guideRaidOutOfReach.
  ///
  /// In fr, this message translates to:
  /// **'Recrute autant de Harponneurs que tu peux dans l\'onglet Armée.'**
  String get guideRaidOutOfReach;

  /// No description provided for @guideRaidHeld.
  ///
  /// In fr, this message translates to:
  /// **'Ta défense devrait le repousser : termine le tour pour l\'attendre.'**
  String get guideRaidHeld;

  /// No description provided for @guideRaidNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Aie au moins {needed, plural, one{{needed} Harponneur} other{{needed} Harponneurs}} au niveau 1 : il t\'en manque {missing}.'**
  String guideRaidNeeded(int needed, int missing);

  /// No description provided for @guideRaidRecruitNow.
  ///
  /// In fr, this message translates to:
  /// **'{missing, plural, one{Recrute-le dans l\'onglet Armée.} other{Recrute-les dans l\'onglet Armée.}}'**
  String guideRaidRecruitNow(int missing);

  /// No description provided for @guideRaidRecruitNextTurn.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà recruté ce tour : {missing, plural, one{recrute-le} other{recrute-les}} au prochain tour.'**
  String guideRaidRecruitNextTurn(int missing);

  /// No description provided for @guideRaidHoldOn.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà recruté ce tour : termine-le et tiens bon.'**
  String get guideRaidHoldOn;

  /// No description provided for @tutorialGuideSwitch.
  ///
  /// In fr, this message translates to:
  /// **'Guide du tutoriel'**
  String get tutorialGuideSwitch;

  /// No description provided for @tutorialGuideSwitchHint.
  ///
  /// In fr, this message translates to:
  /// **'Le guide te montre quoi faire, objectif après objectif'**
  String get tutorialGuideSwitchHint;

  /// No description provided for @tutorialTipsSwitch.
  ///
  /// In fr, this message translates to:
  /// **'Conseils'**
  String get tutorialTipsSwitch;

  /// No description provided for @tutorialTipsSwitchHint.
  ///
  /// In fr, this message translates to:
  /// **'Une fiche explique chaque nouveauté à sa première apparition'**
  String get tutorialTipsSwitchHint;

  /// No description provided for @tutorialReviewTips.
  ///
  /// In fr, this message translates to:
  /// **'Revoir les fiches'**
  String get tutorialReviewTips;

  /// No description provided for @gameOverDefeatTitle.
  ///
  /// In fr, this message translates to:
  /// **'DÉFAITE'**
  String get gameOverDefeatTitle;

  /// No description provided for @gameOverDefeatSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{raids, plural, one{Votre base est tombée à la fin du tour {turn}, après {raids} raid perdu d\'affilée.} other{Votre base est tombée à la fin du tour {turn}, après {raids} raids perdus d\'affilée.}}'**
  String gameOverDefeatSubtitle(int turn, int raids);

  /// No description provided for @gameOverVictoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'VICTOIRE !'**
  String get gameOverVictoryTitle;

  /// No description provided for @gameOverVictorySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez conquis le Noyau Volcanique !'**
  String get gameOverVictorySubtitle;

  /// No description provided for @gameOverContinueFreePlay.
  ///
  /// In fr, this message translates to:
  /// **'Continuer en mode libre'**
  String get gameOverContinueFreePlay;

  /// No description provided for @gameOverBackToMenu.
  ///
  /// In fr, this message translates to:
  /// **'Retour au menu'**
  String get gameOverBackToMenu;

  /// No description provided for @gameOverTurnsPlayed.
  ///
  /// In fr, this message translates to:
  /// **'Tours joués : {count}'**
  String gameOverTurnsPlayed(int count);

  /// No description provided for @gameOverMonstersDefeated.
  ///
  /// In fr, this message translates to:
  /// **'Monstres vaincus : {count}'**
  String gameOverMonstersDefeated(int count);

  /// No description provided for @gameOverBasesCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Bases capturées : {count}'**
  String gameOverBasesCaptured(int count);

  /// No description provided for @gameOverResourcesCollected.
  ///
  /// In fr, this message translates to:
  /// **'Ressources collectées : {count}'**
  String gameOverResourcesCollected(int count);

  /// No description provided for @gameOverRaidsRepelled.
  ///
  /// In fr, this message translates to:
  /// **'Raids repoussés : {count}'**
  String gameOverRaidsRepelled(int count);

  /// No description provided for @gameOverRaidsLost.
  ///
  /// In fr, this message translates to:
  /// **'Raids perdus : {count}'**
  String gameOverRaidsLost(int count);

  /// No description provided for @menuSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les profondeurs vous attendent'**
  String get menuSubtitle;

  /// No description provided for @menuContinue.
  ///
  /// In fr, this message translates to:
  /// **'CONTINUER'**
  String get menuContinue;

  /// No description provided for @menuNewGame.
  ///
  /// In fr, this message translates to:
  /// **'NOUVELLE PARTIE'**
  String get menuNewGame;

  /// No description provided for @menuLoadGame.
  ///
  /// In fr, this message translates to:
  /// **'CHARGER UNE PARTIE'**
  String get menuLoadGame;

  /// No description provided for @menuBetaVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version bêta {version}'**
  String menuBetaVersion(String version);

  /// No description provided for @menuBetaWarning.
  ///
  /// In fr, this message translates to:
  /// **'les sauvegardes peuvent être effacées'**
  String get menuBetaWarning;

  /// No description provided for @saveLoadTitle.
  ///
  /// In fr, this message translates to:
  /// **'Charger une partie'**
  String get saveLoadTitle;

  /// No description provided for @saveDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la partie ?'**
  String get saveDeleteTitle;

  /// No description provided for @saveDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'La partie de {name} sera définitivement supprimée.'**
  String saveDeleteMessage(String name);

  /// No description provided for @saveDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get saveDelete;

  /// No description provided for @saveOptions.
  ///
  /// In fr, this message translates to:
  /// **'Options'**
  String get saveOptions;

  /// No description provided for @saveEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune colonie détectée'**
  String get saveEmptyTitle;

  /// No description provided for @saveEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Fondez votre première base dans les abysses.'**
  String get saveEmptyMessage;

  /// No description provided for @saveInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get saveInProgress;

  /// No description provided for @saveFinished.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get saveFinished;

  /// No description provided for @saveVictoryBadge.
  ///
  /// In fr, this message translates to:
  /// **'★ VICTOIRE'**
  String get saveVictoryBadge;

  /// No description provided for @saveDefeatBadge.
  ///
  /// In fr, this message translates to:
  /// **'DÉFAITE'**
  String get saveDefeatBadge;

  /// No description provided for @saveMetaInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Tour {turn} · {depth} · QG niv. {level}'**
  String saveMetaInProgress(int turn, String depth, int level);

  /// No description provided for @saveMetaWon.
  ///
  /// In fr, this message translates to:
  /// **'Tour {turn} · {depth} · {difficulty}'**
  String saveMetaWon(int turn, String depth, String difficulty);

  /// No description provided for @saveMetaFallen.
  ///
  /// In fr, this message translates to:
  /// **'Tombée au tour {turn} · {depth} · {difficulty}'**
  String saveMetaFallen(int turn, String depth, String difficulty);

  /// No description provided for @saveKernelConquered.
  ///
  /// In fr, this message translates to:
  /// **'Noyau Volcanique conquis'**
  String get saveKernelConquered;

  /// No description provided for @saveVictory.
  ///
  /// In fr, this message translates to:
  /// **'Victoire'**
  String get saveVictory;

  /// No description provided for @saveSeeReport.
  ///
  /// In fr, this message translates to:
  /// **'Voir le bilan de la partie'**
  String get saveSeeReport;

  /// No description provided for @saveResumeLabel.
  ///
  /// In fr, this message translates to:
  /// **'{name} · Tour {turn} · {difficulty}'**
  String saveResumeLabel(String name, int turn, String difficulty);

  /// No description provided for @saveJustNow.
  ///
  /// In fr, this message translates to:
  /// **'à l\'instant'**
  String get saveJustNow;

  /// No description provided for @saveMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {minutes} min'**
  String saveMinutesAgo(int minutes);

  /// No description provided for @saveHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {hours} h'**
  String saveHoursAgo(int hours);

  /// No description provided for @saveYesterday.
  ///
  /// In fr, this message translates to:
  /// **'hier'**
  String get saveYesterday;

  /// No description provided for @saveShortDate.
  ///
  /// In fr, this message translates to:
  /// **'{day} {month}'**
  String saveShortDate(int day, String month);

  /// No description provided for @saveShortDateWithYear.
  ///
  /// In fr, this message translates to:
  /// **'{day} {month} {year}'**
  String saveShortDateWithYear(int day, String month, int year);

  /// No description provided for @saveMonth.
  ///
  /// In fr, this message translates to:
  /// **'{month, select, jan{janv.} feb{févr.} mar{mars} apr{avr.} may{mai} jun{juin} jul{juil.} aug{août} sep{sept.} oct{oct.} nov{nov.} other{déc.}}'**
  String saveMonth(String month);

  /// No description provided for @screenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get screenSettings;

  /// No description provided for @screenNextTurn.
  ///
  /// In fr, this message translates to:
  /// **'Tour suivant'**
  String get screenNextTurn;

  /// No description provided for @screenTabBase.
  ///
  /// In fr, this message translates to:
  /// **'Base'**
  String get screenTabBase;

  /// No description provided for @screenTabMap.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get screenTabMap;

  /// No description provided for @screenTabArmy.
  ///
  /// In fr, this message translates to:
  /// **'Armée'**
  String get screenTabArmy;

  /// No description provided for @screenTabTech.
  ///
  /// In fr, this message translates to:
  /// **'Tech'**
  String get screenTabTech;

  /// No description provided for @screenComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get screenComingSoon;

  /// No description provided for @screenGameInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Partie en cours'**
  String get screenGameInProgress;

  /// No description provided for @screenViewHistory.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'historique'**
  String get screenViewHistory;

  /// No description provided for @screenExportGame.
  ///
  /// In fr, this message translates to:
  /// **'Exporter la partie'**
  String get screenExportGame;

  /// No description provided for @screenSaveAndQuit.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder et quitter'**
  String get screenSaveAndQuit;

  /// No description provided for @screenCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get screenCopy;

  /// No description provided for @screenShareFile.
  ///
  /// In fr, this message translates to:
  /// **'Partager le fichier'**
  String get screenShareFile;

  /// No description provided for @screenReplayUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cette partie a commencé avant l\'enregistrement des replays : elle ne peut pas être exportée. Les nouvelles parties le peuvent.'**
  String get screenReplayUnavailable;

  /// No description provided for @screenReplaySummary.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier {file} contient {actions} sur {turns}.'**
  String screenReplaySummary(String file, String actions, String turns);

  /// No description provided for @screenReplayActions.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} action} other{{count} actions}}'**
  String screenReplayActions(int count);

  /// No description provided for @screenReplayTurns.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} tour joué} other{{count} tours joués}}'**
  String screenReplayTurns(int count);

  /// No description provided for @screenReplayExact.
  ///
  /// In fr, this message translates to:
  /// **'Les combats et les raids seront rejoués à l\'identique.'**
  String get screenReplayExact;

  /// No description provided for @screenReplayInexact.
  ///
  /// In fr, this message translates to:
  /// **'Certains dés n\'ont pas été enregistrés : le rejeu pourra différer sur quelques combats.'**
  String get screenReplayInexact;

  /// No description provided for @screenReplayCopied.
  ///
  /// In fr, this message translates to:
  /// **'Replay copié dans le presse-papiers'**
  String get screenReplayCopied;

  /// No description provided for @screenReplayShareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Replay Abysses'**
  String get screenReplayShareTitle;

  /// No description provided for @screenTreasureCollected.
  ///
  /// In fr, this message translates to:
  /// **'Trésor collecté !'**
  String get screenTreasureCollected;

  /// No description provided for @screenRuinsSearched.
  ///
  /// In fr, this message translates to:
  /// **'Ruines fouillées !'**
  String get screenRuinsSearched;

  /// No description provided for @screenWreckSearched.
  ///
  /// In fr, this message translates to:
  /// **'Épave fouillée !'**
  String get screenWreckSearched;

  /// No description provided for @screenCollectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Collecte'**
  String get screenCollectTitle;

  /// No description provided for @screenRuinsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Les ruines étaient vides...'**
  String get screenRuinsEmpty;

  /// No description provided for @screenWreckEmpty.
  ///
  /// In fr, this message translates to:
  /// **'L\'épave était vide...'**
  String get screenWreckEmpty;

  /// No description provided for @screenNothingToCollect.
  ///
  /// In fr, this message translates to:
  /// **'Rien à récupérer ici...'**
  String get screenNothingToCollect;

  /// No description provided for @screenEventChosen.
  ///
  /// In fr, this message translates to:
  /// **'{event} : {choice}'**
  String screenEventChosen(String event, String choice);

  /// No description provided for @screenGarrisonSendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mettre en garnison'**
  String get screenGarrisonSendTitle;

  /// No description provided for @screenGarrisonWithdrawTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de la garnison'**
  String get screenGarrisonWithdrawTitle;

  /// No description provided for @screenGarrisonWithdraw.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get screenGarrisonWithdraw;

  /// No description provided for @screenGarrisonSendInfo.
  ///
  /// In fr, this message translates to:
  /// **'Seule la garnison défend le Noyau contre les vagues du Kraken.'**
  String get screenGarrisonSendInfo;

  /// No description provided for @screenGarrisonWithdrawInfo.
  ///
  /// In fr, this message translates to:
  /// **'Les unités retirées rejoignent le niveau 3.'**
  String get screenGarrisonWithdrawInfo;

  /// No description provided for @screenGarrisonSize.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Garnison : {count} unité} other{Garnison : {count} unités}}'**
  String screenGarrisonSize(int count);

  /// No description provided for @screenAlreadyVisitedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déjà visité'**
  String get screenAlreadyVisitedTitle;

  /// No description provided for @screenAlreadyVisitedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes déjà venu par ici'**
  String get screenAlreadyVisitedMessage;

  /// No description provided for @screenYourBaseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre base'**
  String get screenYourBaseTitle;

  /// No description provided for @screenYourBaseMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre quartier général'**
  String get screenYourBaseMessage;

  /// No description provided for @screenPlainTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plaine ({x}, {y})'**
  String screenPlainTitle(int x, int y);

  /// No description provided for @screenNothingToSee.
  ///
  /// In fr, this message translates to:
  /// **'Il n\'y a rien à voir ici'**
  String get screenNothingToSee;

  /// No description provided for @screenPassageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passage vers {name}'**
  String screenPassageTitle(String name);

  /// No description provided for @screenUnknownPassage.
  ///
  /// In fr, this message translates to:
  /// **'passage inconnu'**
  String get screenUnknownPassage;

  /// No description provided for @screenPassageMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce lieu marque un passage vers le niveau inférieur.'**
  String get screenPassageMessage;

  /// No description provided for @screenDescendThrough.
  ///
  /// In fr, this message translates to:
  /// **'Descendre des troupes par {base}'**
  String screenDescendThrough(String base);

  /// No description provided for @screenDescentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Descente vers le Niveau {level}'**
  String screenDescentTitle(int level);

  /// No description provided for @screenDescentWarning.
  ///
  /// In fr, this message translates to:
  /// **'Attention : la descente est définitive. Les unités ne pourront pas remonter.'**
  String get screenDescentWarning;

  /// No description provided for @screenDescentConfirm.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Descendre ({count} unité)} other{Descendre ({count} unités)}}'**
  String screenDescentConfirm(int count);

  /// No description provided for @screenDescentDone.
  ///
  /// In fr, this message translates to:
  /// **'Descente au Niveau {level} effectuée'**
  String screenDescentDone(int level);

  /// No description provided for @screenReinforcementTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renforts vers le Niveau {level}'**
  String screenReinforcementTitle(int level);

  /// No description provided for @screenReinforcementInfo.
  ///
  /// In fr, this message translates to:
  /// **'Les renforts arriveront au prochain tour.'**
  String get screenReinforcementInfo;

  /// No description provided for @screenReinforcementConfirm.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Envoyer ({count} unité)} other{Envoyer ({count} unités)}}'**
  String screenReinforcementConfirm(int count);

  /// No description provided for @screenReinforcementsSent.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} unité en transit vers le Niveau {level}} other{{count} unités en transit vers le Niveau {level}}}'**
  String screenReinforcementsSent(int count, int level);

  /// No description provided for @baseFailleAlpha.
  ///
  /// In fr, this message translates to:
  /// **'Faille Alpha'**
  String get baseFailleAlpha;

  /// No description provided for @baseFailleBeta.
  ///
  /// In fr, this message translates to:
  /// **'Faille Bêta'**
  String get baseFailleBeta;

  /// No description provided for @baseFailleGamma.
  ///
  /// In fr, this message translates to:
  /// **'Faille Gamma'**
  String get baseFailleGamma;

  /// No description provided for @baseFailleDelta.
  ///
  /// In fr, this message translates to:
  /// **'Faille Delta'**
  String get baseFailleDelta;

  /// No description provided for @baseChemineePrimary.
  ///
  /// In fr, this message translates to:
  /// **'Cheminée Primaire'**
  String get baseChemineePrimary;

  /// No description provided for @baseChemineeSecondary.
  ///
  /// In fr, this message translates to:
  /// **'Cheminée Secondaire'**
  String get baseChemineeSecondary;

  /// No description provided for @baseChemineeTertiary.
  ///
  /// In fr, this message translates to:
  /// **'Cheminée Tertiaire'**
  String get baseChemineeTertiary;

  /// No description provided for @baseOtherName.
  ///
  /// In fr, this message translates to:
  /// **'{type} {number}'**
  String baseOtherName(String type, int number);

  /// No description provided for @baseLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String baseLevel(int level);

  /// No description provided for @baseLevelShort.
  ///
  /// In fr, this message translates to:
  /// **'Niv. {level}'**
  String baseLevelShort(int level);

  /// No description provided for @baseNotBuilt.
  ///
  /// In fr, this message translates to:
  /// **'Non construit'**
  String get baseNotBuilt;

  /// No description provided for @baseMaxLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau maximum atteint'**
  String get baseMaxLevel;

  /// No description provided for @baseUpgradeLevels.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {from} → {to}'**
  String baseUpgradeLevels(int from, int to);

  /// No description provided for @baseWorksitesBusy.
  ///
  /// In fr, this message translates to:
  /// **'Chantiers occupés ce tour'**
  String get baseWorksitesBusy;

  /// No description provided for @baseBuild.
  ///
  /// In fr, this message translates to:
  /// **'Construire'**
  String get baseBuild;

  /// No description provided for @baseUpgrade.
  ///
  /// In fr, this message translates to:
  /// **'Améliorer'**
  String get baseUpgrade;

  /// No description provided for @baseCapturedBaseRequired.
  ///
  /// In fr, this message translates to:
  /// **'{base} capturée requise'**
  String baseCapturedBaseRequired(String base);

  /// No description provided for @baseKernelRequired.
  ///
  /// In fr, this message translates to:
  /// **'Noyau Volcanique capturé requis'**
  String get baseKernelRequired;

  /// No description provided for @baseWorksitesFree.
  ///
  /// In fr, this message translates to:
  /// **'Chantiers libres ce tour : {free}/{total}'**
  String baseWorksitesFree(int free, int total);

  /// No description provided for @baseWorksitesNext.
  ///
  /// In fr, this message translates to:
  /// **'+1 au QG {level}'**
  String baseWorksitesNext(int level);

  /// No description provided for @baseShield.
  ///
  /// In fr, this message translates to:
  /// **'Rempart de la base : {rampart}'**
  String baseShield(String rampart);

  /// No description provided for @baseRampartCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Rempart actuel : {rampart}'**
  String baseRampartCurrent(String rampart);

  /// No description provided for @baseRampartNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochain niveau : {rampart}'**
  String baseRampartNext(String rampart);

  /// No description provided for @baseRampartMax.
  ///
  /// In fr, this message translates to:
  /// **'Rempart à son apogée'**
  String get baseRampartMax;

  /// No description provided for @baseRampartHint.
  ///
  /// In fr, this message translates to:
  /// **'Pendant un raid, le rempart combat avec les défenseurs du niveau 1 et attire toutes les attaques.'**
  String get baseRampartHint;

  /// No description provided for @baseRampartNone.
  ///
  /// In fr, this message translates to:
  /// **'aucun'**
  String get baseRampartNone;

  /// No description provided for @baseCoralRampartStats.
  ///
  /// In fr, this message translates to:
  /// **'{hp} PV, DEF {def}'**
  String baseCoralRampartStats(int hp, int def);

  /// No description provided for @baseMagmaRampartStats.
  ///
  /// In fr, this message translates to:
  /// **'{hp} PV, ATK {atk}, DEF {def}'**
  String baseMagmaRampartStats(int hp, int atk, int def);

  /// No description provided for @unitRecruitDone.
  ///
  /// In fr, this message translates to:
  /// **'Recrutement déjà effectué ce tour'**
  String get unitRecruitDone;

  /// No description provided for @unitNotEnoughResources.
  ///
  /// In fr, this message translates to:
  /// **'Ressources insuffisantes'**
  String get unitNotEnoughResources;

  /// No description provided for @unitRecruit.
  ///
  /// In fr, this message translates to:
  /// **'Recruter'**
  String get unitRecruit;

  /// No description provided for @unitTotalCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} unité} other{{count} unités}}'**
  String unitTotalCount(int count);

  /// No description provided for @unitPlaceKernel.
  ///
  /// In fr, this message translates to:
  /// **'Noyau'**
  String get unitPlaceKernel;

  /// No description provided for @unitLocked.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillé'**
  String get unitLocked;

  /// No description provided for @unitBarracksRequired.
  ///
  /// In fr, this message translates to:
  /// **'Caserne niveau {level} requise pour débloquer'**
  String unitBarracksRequired(int level);

  /// No description provided for @unitInService.
  ///
  /// In fr, this message translates to:
  /// **'En service : {count}'**
  String unitInService(int count);

  /// No description provided for @unitNoneAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune unité disponible.'**
  String get unitNoneAvailable;

  /// No description provided for @resourceProduction.
  ///
  /// In fr, this message translates to:
  /// **'Production'**
  String get resourceProduction;

  /// No description provided for @resourceMainBuilding.
  ///
  /// In fr, this message translates to:
  /// **'Bâtiment principal'**
  String get resourceMainBuilding;

  /// No description provided for @turnTransition.
  ///
  /// In fr, this message translates to:
  /// **'Tour {from} → Tour {to}'**
  String turnTransition(int from, int to);

  /// No description provided for @turnNoProduction.
  ///
  /// In fr, this message translates to:
  /// **'Aucune production ce tour.'**
  String get turnNoProduction;

  /// No description provided for @turnNoChange.
  ///
  /// In fr, this message translates to:
  /// **'Aucun changement ce tour.'**
  String get turnNoChange;

  /// No description provided for @turnStorageFull.
  ///
  /// In fr, this message translates to:
  /// **'(max atteint)'**
  String get turnStorageFull;

  /// No description provided for @turnRecruitAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Recrutement disponible'**
  String get turnRecruitAvailable;

  /// No description provided for @turnPendingExplorations.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} exploration en attente} other{{count} explorations en attente}}'**
  String turnPendingExplorations(int count);

  /// No description provided for @turnBuildingsDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Bâtiments désactivés'**
  String get turnBuildingsDeactivated;

  /// No description provided for @turnUnitsLost.
  ///
  /// In fr, this message translates to:
  /// **'Unités perdues'**
  String get turnUnitsLost;

  /// No description provided for @turnPredatorsLooted.
  ///
  /// In fr, this message translates to:
  /// **'Le banc de prédateurs a pillé la base'**
  String get turnPredatorsLooted;

  /// No description provided for @turnEventDefaulted.
  ///
  /// In fr, this message translates to:
  /// **'{event} : option prudente appliquée'**
  String turnEventDefaulted(String event);

  /// No description provided for @turnEventDrawn.
  ///
  /// In fr, this message translates to:
  /// **'Événement : {event}'**
  String turnEventDrawn(String event);

  /// No description provided for @turnExplorationTotal.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Exploration : {count} nouvelle cellule} other{Exploration : {count} nouvelles cellules}}'**
  String turnExplorationTotal(int count);

  /// No description provided for @turnExplorationCells.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} cellule} other{{count} cellules}}'**
  String turnExplorationCells(int count);

  /// No description provided for @historyFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get historyFilterAll;

  /// No description provided for @historyFilterCombat.
  ///
  /// In fr, this message translates to:
  /// **'Combats'**
  String get historyFilterCombat;

  /// No description provided for @historyFilterBuilding.
  ///
  /// In fr, this message translates to:
  /// **'Construction'**
  String get historyFilterBuilding;

  /// No description provided for @historyFilterResearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get historyFilterResearch;

  /// No description provided for @historyFilterEvent.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get historyFilterEvent;

  /// No description provided for @historyFilterOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get historyFilterOther;

  /// No description provided for @historyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune action enregistrée pour l\'instant.'**
  String get historyEmpty;

  /// No description provided for @historyEmptyFilter.
  ///
  /// In fr, this message translates to:
  /// **'Aucune action pour ce filtre.'**
  String get historyEmptyFilter;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageAutomatic.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get settingsLanguageAutomatic;

  /// No description provided for @settingsLanguageAutomaticHint.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'appareil'**
  String get settingsLanguageAutomaticHint;

  /// No description provided for @screenViewRanking.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get screenViewRanking;

  /// No description provided for @factionRankingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Classement des factions'**
  String get factionRankingTitle;

  /// No description provided for @factionRankingYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get factionRankingYou;

  /// No description provided for @factionRankingHeadquarters.
  ///
  /// In fr, this message translates to:
  /// **'QG niveau {level}'**
  String factionRankingHeadquarters(int level);

  /// No description provided for @factionRankingDepth.
  ///
  /// In fr, this message translates to:
  /// **'Profondeur : niveau {level}'**
  String factionRankingDepth(int level);

  /// No description provided for @factionRankingKernel.
  ///
  /// In fr, this message translates to:
  /// **'Tient le Noyau du Volcan'**
  String get factionRankingKernel;

  /// No description provided for @factionRankingFallen.
  ///
  /// In fr, this message translates to:
  /// **'Tombée'**
  String get factionRankingFallen;

  /// No description provided for @buildingDegraded.
  ///
  /// In fr, this message translates to:
  /// **'Dégradé'**
  String get buildingDegraded;

  /// No description provided for @buildingDegradedReason.
  ///
  /// In fr, this message translates to:
  /// **'Dégradé : le QG doit être au niveau {level}'**
  String buildingDegradedReason(int level);

  /// No description provided for @buildingDegradedProduction.
  ///
  /// In fr, this message translates to:
  /// **'Produit 50 % de ses ressources'**
  String get buildingDegradedProduction;

  /// No description provided for @buildingDegradedLaboratory.
  ///
  /// In fr, this message translates to:
  /// **'Les recherches ont la moitié de leur effet'**
  String get buildingDegradedLaboratory;

  /// No description provided for @buildingDegradedBarracks.
  ///
  /// In fr, this message translates to:
  /// **'Les unités coûtent deux fois plus cher'**
  String get buildingDegradedBarracks;

  /// No description provided for @buildingDegradedSolar.
  ///
  /// In fr, this message translates to:
  /// **'Produit 50 % de son énergie'**
  String get buildingDegradedSolar;

  /// No description provided for @buildingDegradedCitadel.
  ///
  /// In fr, this message translates to:
  /// **'Le rempart a la moitié de sa force'**
  String get buildingDegradedCitadel;

  /// No description provided for @buildingDegradedUnusable.
  ///
  /// In fr, this message translates to:
  /// **'Inutilisable : ni descente, ni garnison, ni victoire'**
  String get buildingDegradedUnusable;

  /// No description provided for @factionBaseHeadquarters.
  ///
  /// In fr, this message translates to:
  /// **'Quartier général'**
  String get factionBaseHeadquarters;

  /// No description provided for @factionBaseAttack.
  ///
  /// In fr, this message translates to:
  /// **'Attaquer'**
  String get factionBaseAttack;

  /// No description provided for @assaultYouAttacked.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez attaqué {name}'**
  String assaultYouAttacked(String name);

  /// No description provided for @assaultAttackedYou.
  ///
  /// In fr, this message translates to:
  /// **'{name} vous a attaqué'**
  String assaultAttackedYou(String name);

  /// No description provided for @assaultDefendersDown.
  ///
  /// In fr, this message translates to:
  /// **'Défenseurs mis hors de combat : {killed}/{total}'**
  String assaultDefendersDown(int killed, int total);

  /// No description provided for @assaultRampart.
  ///
  /// In fr, this message translates to:
  /// **'Rempart : niveau {before} → {after}'**
  String assaultRampart(int before, int after);

  /// No description provided for @assaultHeadquarters.
  ///
  /// In fr, this message translates to:
  /// **'QG : niveau {before} → {after}'**
  String assaultHeadquarters(int before, int after);

  /// No description provided for @assaultBaseIntact.
  ///
  /// In fr, this message translates to:
  /// **'La base tient bon'**
  String get assaultBaseIntact;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

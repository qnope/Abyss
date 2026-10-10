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

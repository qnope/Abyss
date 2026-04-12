import 'package:flutter/material.dart';
import '../../domain/building/building_type.dart';
import '../theme/abyss_colors.dart';

extension BuildingTypeColor on BuildingType {
  Color get color => switch (this) {
    BuildingType.headquarters => AbyssColors.biolumPurple,
    BuildingType.algaeFarm => AbyssColors.algaeGreen,
    BuildingType.coralMine => AbyssColors.coralPink,
    BuildingType.coralCitadel => AbyssColors.coralPink,
    BuildingType.oreExtractor => AbyssColors.oreBlue,
    BuildingType.solarPanel => AbyssColors.energyYellow,
    BuildingType.laboratory => AbyssColors.biolumTeal,
    BuildingType.barracks => AbyssColors.biolumPink,
    BuildingType.descentModule => AbyssColors.biolumBlue,
    BuildingType.pressureCapsule => AbyssColors.biolumCyan,
    BuildingType.volcanicKernel => AbyssColors.warning,
  };
}

extension BuildingTypeInfo on BuildingType {
  String get displayName => switch (this) {
    BuildingType.headquarters => 'Quartier Général',
    BuildingType.algaeFarm => 'Ferme d\'algues',
    BuildingType.coralMine => 'Mine de corail',
    BuildingType.coralCitadel => 'Citadelle corallienne',
    BuildingType.oreExtractor => 'Extracteur de minerai',
    BuildingType.solarPanel => 'Panneau solaire',
    BuildingType.laboratory => 'Laboratoire',
    BuildingType.barracks => 'Caserne',
    BuildingType.descentModule => 'Module de Descente',
    BuildingType.pressureCapsule => 'Capsule Pressurisee',
    BuildingType.volcanicKernel => 'Noyau Volcanique',
  };

  String get description => switch (this) {
    BuildingType.headquarters =>
      'Centre de commandement de votre base sous-marine. '
      'Son niveau détermine les capacités de votre colonie.',
    BuildingType.algaeFarm =>
      'Cultive des algues pour nourrir votre colonie sous-marine.',
    BuildingType.coralMine =>
      'Extrait du corail des récifs pour la construction.',
    BuildingType.coralCitadel =>
      'Forteresse corallienne massive qui renforce la défense des unités '
      'stationnées dans votre base. Son bouclier s\'activera avec l\'arrivée '
      'des menaces abyssales.',
    BuildingType.oreExtractor =>
      'Fore les profondeurs pour extraire du minerai océanique.',
    BuildingType.solarPanel =>
      'Capte l\'énergie solaire pour alimenter vos installations.',
    BuildingType.laboratory =>
      'Centre de recherche sous-marin pour développer de nouvelles technologies.',
    BuildingType.barracks =>
      'Forme et entraîne vos unités militaires sous-marines.',
    BuildingType.descentModule =>
      'Module spécialisé permettant l\'assaut des failles abyssales.',
    BuildingType.pressureCapsule =>
      'Capsule haute pression permettant l\'assaut des cheminées hydrothermales.',
    BuildingType.volcanicKernel =>
      'Le coeur brulant des abysses. '
      'Construisez-le au niveau 10 pour remporter la victoire.',
  };

  String get iconPath => switch (this) {
    BuildingType.headquarters => 'assets/icons/buildings/headquarters.svg',
    BuildingType.algaeFarm => 'assets/icons/buildings/algae_farm.svg',
    BuildingType.coralMine => 'assets/icons/buildings/coral_mine.svg',
    BuildingType.coralCitadel => 'assets/icons/buildings/coral_citadel.svg',
    BuildingType.oreExtractor => 'assets/icons/buildings/ore_extractor.svg',
    BuildingType.solarPanel => 'assets/icons/buildings/solar_panel.svg',
    BuildingType.laboratory => 'assets/icons/buildings/laboratory.svg',
    BuildingType.barracks => 'assets/icons/buildings/barracks.svg',
    BuildingType.descentModule => 'assets/icons/buildings/descent_module.svg',
    BuildingType.pressureCapsule => 'assets/icons/buildings/pressure_capsule.svg',
    BuildingType.volcanicKernel => 'assets/icons/terrain/volcanic_kernel.svg',
  };
}

import 'package:flutter/material.dart';
import '../../domain/building/building_type.dart';
import '../theme/abyss_colors.dart';

extension BuildingTypeColor on BuildingType {
  Color get color => switch (this) {
    BuildingType.headquarters => AbyssColors.biolumPurple,
    BuildingType.algaeFarm => AbyssColors.algaeGreen,
    BuildingType.coralMine => AbyssColors.coralPink,
    BuildingType.oreExtractor => AbyssColors.oreBlue,
    BuildingType.solarPanel => AbyssColors.energyYellow,
    BuildingType.laboratory => AbyssColors.biolumTeal,
    BuildingType.barracks => AbyssColors.biolumPink,
  };
}

extension BuildingTypeInfo on BuildingType {
  String get displayName => switch (this) {
    BuildingType.headquarters => 'Quartier Général',
    BuildingType.algaeFarm => 'Ferme d\'algues',
    BuildingType.coralMine => 'Mine de corail',
    BuildingType.oreExtractor => 'Extracteur de minerai',
    BuildingType.solarPanel => 'Panneau solaire',
    BuildingType.laboratory => 'Laboratoire',
    BuildingType.barracks => 'Caserne',
  };

  String get description => switch (this) {
    BuildingType.headquarters =>
      'Centre de commandement de votre base sous-marine. '
      'Son niveau détermine les capacités de votre colonie.',
    BuildingType.algaeFarm =>
      'Cultive des algues pour nourrir votre colonie sous-marine.',
    BuildingType.coralMine =>
      'Extrait du corail des récifs pour la construction.',
    BuildingType.oreExtractor =>
      'Fore les profondeurs pour extraire du minerai océanique.',
    BuildingType.solarPanel =>
      'Capte l\'énergie solaire pour alimenter vos installations.',
    BuildingType.laboratory =>
      'Centre de recherche sous-marin pour développer de nouvelles technologies.',
    BuildingType.barracks =>
      'Forme et entraîne vos unités militaires sous-marines.',
  };

  String get iconPath => switch (this) {
    BuildingType.headquarters => 'assets/icons/buildings/headquarters.svg',
    BuildingType.algaeFarm => 'assets/icons/buildings/algae_farm.svg',
    BuildingType.coralMine => 'assets/icons/buildings/coral_mine.svg',
    BuildingType.oreExtractor => 'assets/icons/buildings/ore_extractor.svg',
    BuildingType.solarPanel => 'assets/icons/buildings/solar_panel.svg',
    BuildingType.laboratory => 'assets/icons/buildings/laboratory.svg',
    BuildingType.barracks => 'assets/icons/buildings/barracks.svg',
  };
}

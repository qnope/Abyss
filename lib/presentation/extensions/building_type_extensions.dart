import 'package:flutter/material.dart';
import '../../domain/building/building_type.dart';
import '../../domain/resource/production_calculator.dart';
import '../../domain/resource/resource_type.dart';
import '../l10n/app_localizations.dart';
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
  String displayName(AppLocalizations l10n) => switch (this) {
    BuildingType.headquarters => l10n.buildingHeadquartersName,
    BuildingType.algaeFarm => l10n.buildingAlgaeFarmName,
    BuildingType.coralMine => l10n.buildingCoralMineName,
    BuildingType.coralCitadel => l10n.buildingCoralCitadelName,
    BuildingType.oreExtractor => l10n.buildingOreExtractorName,
    BuildingType.solarPanel => l10n.buildingSolarPanelName,
    BuildingType.laboratory => l10n.buildingLaboratoryName,
    BuildingType.barracks => l10n.buildingBarracksName,
    BuildingType.descentModule => l10n.buildingDescentModuleName,
    BuildingType.pressureCapsule => l10n.buildingPressureCapsuleName,
    BuildingType.volcanicKernel => l10n.buildingVolcanicKernelName,
  };

  String description(AppLocalizations l10n) => switch (this) {
    BuildingType.headquarters => l10n.buildingHeadquartersDescription(
      _hqIncome(ResourceType.coral),
      _hqIncome(ResourceType.ore),
    ),
    BuildingType.algaeFarm => l10n.buildingAlgaeFarmDescription,
    BuildingType.coralMine => l10n.buildingCoralMineDescription,
    BuildingType.coralCitadel => l10n.buildingCoralCitadelDescription,
    BuildingType.oreExtractor => l10n.buildingOreExtractorDescription,
    BuildingType.solarPanel => l10n.buildingSolarPanelDescription,
    BuildingType.laboratory => l10n.buildingLaboratoryDescription,
    BuildingType.barracks => l10n.buildingBarracksDescription,
    BuildingType.descentModule => l10n.buildingDescentModuleDescription,
    BuildingType.pressureCapsule => l10n.buildingPressureCapsuleDescription,
    BuildingType.volcanicKernel => l10n.buildingVolcanicKernelDescription,
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

int _hqIncome(ResourceType type) =>
    ProductionCalculator.headquartersIncome[type] ?? 0;

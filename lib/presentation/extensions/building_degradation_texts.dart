import '../../domain/building/building_type.dart';
import '../l10n/app_localizations.dart';

extension BuildingDegradationTexts on BuildingType {
  /// What a degraded building suffers, in words.
  String degradedEffect(AppLocalizations l10n) => switch (this) {
    BuildingType.headquarters ||
    BuildingType.algaeFarm ||
    BuildingType.coralMine ||
    BuildingType.oreExtractor => l10n.buildingDegradedProduction,
    BuildingType.solarPanel => l10n.buildingDegradedSolar,
    BuildingType.laboratory => l10n.buildingDegradedLaboratory,
    BuildingType.barracks => l10n.buildingDegradedBarracks,
    BuildingType.coralCitadel => l10n.buildingDegradedCitadel,
    BuildingType.descentModule ||
    BuildingType.pressureCapsule ||
    BuildingType.volcanicKernel => l10n.buildingDegradedUnusable,
  };
}

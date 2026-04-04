import 'building_type.dart';
import 'production_formula.dart';
import 'resource_type.dart';

const Map<BuildingType, ProductionFormula> productionFormulas = {
  BuildingType.algaeFarm: ProductionFormula(
    resourceType: ResourceType.algae,
    compute: _algaeFarmProduction,
  ),
  BuildingType.coralMine: ProductionFormula(
    resourceType: ResourceType.coral,
    compute: _coralMineProduction,
  ),
  BuildingType.oreExtractor: ProductionFormula(
    resourceType: ResourceType.ore,
    compute: _oreExtractorProduction,
  ),
  BuildingType.solarPanel: ProductionFormula(
    resourceType: ResourceType.energy,
    compute: _solarPanelProduction,
  ),
};

int _algaeFarmProduction(int level) => 3 * level * level + 2;
int _coralMineProduction(int level) => 2 * level * level + 2;
int _oreExtractorProduction(int level) => 2 * level * level + 1;
int _solarPanelProduction(int level) => 2 * level * level + 1;

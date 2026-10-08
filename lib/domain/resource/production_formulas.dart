import '../building/building_type.dart';
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

// Linear production: every level adds the same amount, so the
// exponential upgrade costs take longer and longer to pay back.
int _algaeFarmProduction(int level) => 90 * level - 40;
int _coralMineProduction(int level) => 60 * level - 20;
int _oreExtractorProduction(int level) => 60 * level - 30;
int _solarPanelProduction(int level) => 36 * level - 18;

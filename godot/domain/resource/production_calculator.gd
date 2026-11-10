class_name ProductionCalculator
extends RefCounted
## lib/domain/resource/production_calculator.dart: what the buildings of a
## base make each turn.

## Flat income of a built HQ, whatever its level. Coral pays for the Ore
## Extractor and ore for the Coral Mine, so without it a base that spent its
## stock on anything else could never build either again.
const HEADQUARTERS_INCOME: Dictionary[ResourceType.Value, int] = {
	ResourceType.Value.CORAL: 15,
	ResourceType.Value.ORE: 10,
}


## What `buildings` make, in the order they first make each resource, raised
## by the research of `tech_branches`. Dart takes a map or null and applies
## no research to null: the empty map that stands for null here gives the
## same amounts in Dart too (no tier, no perk, +0 %).
static func from_buildings(
	buildings: Dictionary[BuildingType.Value, Building],
	tech_branches: Dictionary[TechBranch.Value, TechBranchState] = {},
) -> Dictionary[ResourceType.Value, int]:
	var result: Dictionary[ResourceType.Value, int] = {}
	var formulas := ProductionFormulas.production_formulas()
	for building: Building in buildings.values():
		var formula: ProductionFormula = formulas.get(building.type)
		if formula != null and building.level > 0:
			var amount := BuildingDegradation.half(
				formula.compute(building.level),
				BuildingDegradation.is_degraded(buildings, building.type),
			)
			var made: int = result.get(formula.resource_type, 0)
			result[formula.resource_type] = made + amount
	if Building.level_in(buildings, BuildingType.Value.HEADQUARTERS) > 0:
		for type: ResourceType.Value in HEADQUARTERS_INCOME:
			var made: int = result.get(type, 0)
			result[type] = made + HEADQUARTERS_INCOME[type]
	if tech_branches.is_empty():
		return result
	var tech := TechEffects.new(
		tech_branches, BuildingDegradation.is_degraded(buildings, BuildingType.Value.LABORATORY)
	)
	for type: ResourceType.Value in result.keys():
		result[type] = DartMath.trunc_div(result[type] * (100 + tech.production_percent(type)), 100)
	return result

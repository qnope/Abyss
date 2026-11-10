class_name ProductionFormulas
extends RefCounted
## lib/domain/resource/production_formulas.dart: what each production
## building makes.


## `productionFormulas`, a const map in Dart. It holds objects and functions,
## which no GDScript constant can: it is built at each call, in the order
## Dart wrote it.
static func production_formulas() -> Dictionary[BuildingType.Value, ProductionFormula]:
	return {
		BuildingType.Value.ALGAE_FARM: ProductionFormula.new(
			ResourceType.Value.ALGAE, _algae_farm_production
		),
		BuildingType.Value.CORAL_MINE: ProductionFormula.new(
			ResourceType.Value.CORAL, _coral_mine_production
		),
		BuildingType.Value.ORE_EXTRACTOR: ProductionFormula.new(
			ResourceType.Value.ORE, _ore_extractor_production
		),
		BuildingType.Value.SOLAR_PANEL: ProductionFormula.new(
			ResourceType.Value.ENERGY, _solar_panel_production
		),
	}


# Linear production: every level adds the same amount, so the exponential
# upgrade costs take longer and longer to pay back.
static func _algae_farm_production(level: int) -> int:
	return 90 * level - 40


static func _coral_mine_production(level: int) -> int:
	return 60 * level - 20


static func _ore_extractor_production(level: int) -> int:
	return 60 * level - 30


static func _solar_panel_production(level: int) -> int:
	return DartMath.trunc_div((36 * level - 18) * 11, 10)

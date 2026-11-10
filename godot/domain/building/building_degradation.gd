class_name BuildingDegradation
extends RefCounted
## lib/domain/building/building_degradation.dart: a building keeps its level
## when the headquarters falls below the level it asked for, but works badly
## until the headquarters is raised again.
##
## Nothing is stored: the state is read from the headquarters level and the
## prerequisites, so raising the headquarters restores everything.


## Headquarters level `type` needs at its current level (an int); null when
## it is unbuilt, is the headquarters, or needs none.
static func required_headquarters(
	buildings: Dictionary[BuildingType.Value, Building], type: BuildingType.Value
) -> Variant:
	var level := Building.level_in(buildings, type)
	if level <= 0:
		return null
	var prerequisites := BuildingCostCalculator.new().prerequisites(type, level)
	return prerequisites.get(BuildingType.Value.HEADQUARTERS)


## Headquarters level `type` is missing (an int), null when it is not
## degraded. A QG at 0 (a bare fixture; a real one never goes below 1)
## degrades nothing.
static func missing_headquarters(
	buildings: Dictionary[BuildingType.Value, Building], type: BuildingType.Value
) -> Variant:
	var hq := Building.level_in(buildings, BuildingType.Value.HEADQUARTERS)
	var required: Variant = required_headquarters(buildings, type)
	if hq <= 0 or required == null:
		return null
	var needed: int = required
	return needed if hq < needed else null


static func is_degraded(
	buildings: Dictionary[BuildingType.Value, Building], type: BuildingType.Value
) -> bool:
	return missing_headquarters(buildings, type) != null


## `amount` halved when `degraded`, the rule of the production, the energy
## and the research.
static func half(amount: int, degraded: bool) -> int:
	return DartMath.trunc_div(amount, 2) if degraded else amount

class_name UnitLossCalculator
extends RefCounted
## lib/domain/unit/unit_loss_calculator.dart: the units lost when the algae
## run short. `units_per_level` holds a `Dictionary[UnitType.Value, Unit]`
## per level.


## Returns map of unit losses per type when algae is insufficient. Losses
## are proportional: each type loses the same percentage, rounded UP (ceil).
static func calculate_losses(
	units: Dictionary[UnitType.Value, Unit], algae_production: int, algae_stock: int
) -> Dictionary[UnitType.Value, int]:
	var total_consumption := ConsumptionCalculator.total_unit_consumption(units)
	var available := algae_production + algae_stock

	if available >= total_consumption:
		return {}

	var deficit := total_consumption - available
	var loss_ratio := DartMath.quotient(deficit, total_consumption)

	var losses: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in units:
		if units[type].count <= 0:
			continue
		losses[type] = _lost(units[type].count, loss_ratio)

	return losses


## Calculates losses across all levels (read-only, for preview).
static func calculate_losses_all_levels(
	units_per_level: Dictionary[int, Dictionary], algae_production: int, algae_stock: int
) -> Dictionary[UnitType.Value, int]:
	return _losses_all_levels(units_per_level, algae_production, algae_stock, false)


## Applies losses across all levels and returns aggregated totals.
static func apply_losses_all_levels(
	units_per_level: Dictionary[int, Dictionary], algae_production: int, algae_stock: int
) -> Dictionary[UnitType.Value, int]:
	return _losses_all_levels(units_per_level, algae_production, algae_stock, true)


## The losses of every level, summed by type in the order the units are
## met; taken from the units when `applied`. Dart writes the loop twice.
static func _losses_all_levels(
	units_per_level: Dictionary[int, Dictionary],
	algae_production: int,
	algae_stock: int,
	applied: bool,
) -> Dictionary[UnitType.Value, int]:
	var total := ConsumptionCalculator.total_unit_consumption_all_levels(units_per_level)
	var available := algae_production + algae_stock
	if available >= total or total == 0:
		return {}
	var loss_ratio := DartMath.quotient(total - available, total)
	var losses: Dictionary[UnitType.Value, int] = {}
	for level: int in units_per_level:
		var units: Dictionary[UnitType.Value, Unit] = units_per_level[level]
		for type: UnitType.Value in units:
			var unit := units[type]
			if unit.count <= 0:
				continue
			var lost := _lost(unit.count, loss_ratio)
			if applied:
				unit.count -= lost
			var so_far: int = losses.get(type, 0)
			losses[type] = so_far + lost
	return losses


## `(count * lossRatio).ceil()`, never more than `count`.
static func _lost(count: int, loss_ratio: float) -> int:
	return mini(DartMath.ceil(count * loss_ratio), count)

class_name PlayerTurnResolver
extends RefCounted
## lib/domain/turn/player_turn_resolver.dart: the end of a turn on one
## player's base: what the buildings make, the buildings shut down for want
## of energy, the units lost for want of algae, the stocks changed; then the
## recruitments and the worksite of the turn are freed.


## `extra_production` comes on top of the buildings' (the pearl income); a
## faction (`is_faction`) produces by the difficulty's faction percent. The
## result's `new_turn` is `previous_turn`: TurnResolver gives the next one.
static func resolve(
	player: Player,
	previous_turn: int,
	extra_production: Dictionary[ResourceType.Value, int] = {},
	difficulty := Difficulty.Value.NORMAL,
	is_faction := false,
) -> TurnResult:
	var had_recruited_units := not player.recruited_unit_types.is_empty()

	# Step 1: Calculate initial production
	var production := _with_extra(
		TurnProduction.of(player, previous_turn, difficulty, [], is_faction), extra_production
	)

	# Steps 2-4: Energy consumption & building deactivation
	var deactivated := TurnProduction.deactivated(player, production, previous_turn)

	# Step 5: Recalculate production if buildings were deactivated
	if not deactivated.is_empty():
		production = _with_extra(
			TurnProduction.of(player, previous_turn, difficulty, deactivated, is_faction),
			extra_production,
		)

	# Steps 6-9: Algae consumption & unit losses (all levels)
	var algae_prod: int = production.get(ResourceType.Value.ALGAE, 0)
	var algae_stock := GameResource.amount_in(player.resources, ResourceType.Value.ALGAE)
	var lost_units := UnitLossCalculator.apply_losses_all_levels(
		player.units_per_level, algae_prod, algae_stock
	)

	# Step 10: Recalculate consumption after losses
	var energy_consumption := TurnProduction.energy_consumption(player, previous_turn, deactivated)
	var algae_consumption := ConsumptionCalculator.total_unit_consumption_all_levels(
		player.units_per_level
	)

	# Step 11: Apply resource changes
	var changes := _apply_resource_changes(
		player, production, energy_consumption, algae_consumption
	)

	player.recruited_unit_types.clear()
	player.worksite.clear()

	return TurnResult.new(
		changes, previous_turn, previous_turn, had_recruited_units, deactivated, lost_units
	)


static func _with_extra(
	production: Dictionary[ResourceType.Value, int], extra: Dictionary[ResourceType.Value, int]
) -> Dictionary[ResourceType.Value, int]:
	for type: ResourceType.Value in extra:
		production[type] = production.get(type, 0) + extra[type]
	return production


static func _apply_resource_changes(
	player: Player,
	production: Dictionary[ResourceType.Value, int],
	energy_consumption: int,
	algae_consumption: int,
) -> Array[TurnResourceChange]:
	var resource_types: Dictionary[ResourceType.Value, bool] = {}
	for type: ResourceType.Value in production:
		resource_types[type] = true
	if energy_consumption > 0:
		resource_types[ResourceType.Value.ENERGY] = true
	if algae_consumption > 0:
		resource_types[ResourceType.Value.ALGAE] = true

	var changes: Array[TurnResourceChange] = []
	for type: ResourceType.Value in resource_types:
		var resource: GameResource = player.resources.get(type)
		if resource == null:
			continue
		var produced: int = production.get(type, 0)
		var consumed := _consumed(type, energy_consumption, algae_consumption)
		var net_change := produced - consumed
		var before_amount := resource.amount
		var new_amount := resource.amount + net_change
		var capped := new_amount > resource.max_storage
		if new_amount < 0:
			new_amount = 0
		if capped:
			new_amount = resource.max_storage
		resource.amount = new_amount
		changes.append(
			TurnResourceChange.new(type, produced, capped, before_amount, resource.amount, consumed)
		)
	return changes


## The `switch` of Dart: the energy and the algae spent, nothing else.
static func _consumed(type: ResourceType.Value, energy_consumption: int, algae_consumption: int) -> int:
	match type:
		ResourceType.Value.ENERGY:
			return energy_consumption
		ResourceType.Value.ALGAE:
			return algae_consumption
	return 0

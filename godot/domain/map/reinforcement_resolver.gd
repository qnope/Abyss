class_name ReinforcementResolver
extends RefCounted
## lib/domain/map/reinforcement_resolver.dart: the units sent from a level
## to another join the units there once their turn has passed.


## The orders that arrived, player after player, each in its order.
static func resolve(game: Game) -> Array[ReinforcementOrder]:
	var arrived: Array[ReinforcementOrder] = []
	for player: Player in game.players.values():
		if player.pending_reinforcements.is_empty():
			continue
		var ready: Array[ReinforcementOrder] = []
		for order: ReinforcementOrder in player.pending_reinforcements:
			if not order.is_ready_to_arrive(game.turn):
				continue
			if not player.units_per_level.has(order.to_level):
				player.units_per_level[order.to_level] = {} as Dictionary[UnitType.Value, Unit]
			var target_units: Dictionary[UnitType.Value, Unit] = player.units_per_level[order.to_level]
			for type: UnitType.Value in order.units:
				if target_units.has(type):
					target_units[type].count += order.units[type]
				else:
					target_units[type] = Unit.new(type, order.units[type])
			ready.append(order)
		# `removeWhere(ready.contains)`, in the same list: an order is itself.
		var kept := player.pending_reinforcements.filter(
			func(order: ReinforcementOrder) -> bool: return not ready.has(order)
		)
		player.pending_reinforcements.assign(kept)
		arrived.append_array(ready)
	return arrived

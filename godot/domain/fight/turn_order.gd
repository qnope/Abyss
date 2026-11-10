class_name TurnOrder
extends RefCounted
## lib/domain/fight/turn_order.dart: order in which the combatants act
## during one fight turn.


## The alive combatants of both sides, shuffled with `random`: one pass
## gathers the alive players then the alive monsters, in side order.
static func shuffle(
	player_side: Array[Combatant], monster_side: Array[Combatant], random: DartRandom
) -> Array[Combatant]:
	var order: Array[Combatant] = []
	_add_alive(order, player_side)
	_add_alive(order, monster_side)
	DartRandom.shuffle(order, random)
	return order


static func _add_alive(order: Array[Combatant], side: Array[Combatant]) -> void:
	for c: Combatant in side:
		if c.current_hp > 0:
			order.append(c)

class_name TreasureLoot
extends RefCounted
## lib/domain/action/treasure_loot.dart: what a treasure, ruins or a wreck
## hold, before the tech loot bonus and the storage cap.

## Treasures and ruins are rarer, so each one is worth more.
const REWARD_MULTIPLIER := 3

const _ALGAE := ResourceType.Value.ALGAE
const _CORAL := ResourceType.Value.CORAL
const _ORE := ResourceType.Value.ORE
const _PEARL := ResourceType.Value.PEARL


## Loot of `content` on `level`, rolled with `random` in a fixed order;
## nothing for a cell that holds no loot.
static func of(content: CellContentType.Value, random: DartRandom, level: int) -> Dictionary[ResourceType.Value, int]:
	match content:
		CellContentType.Value.RESOURCE_BONUS:
			var algae := 50 + random.next_int(51)
			var coral := 30 + random.next_int(21)
			var ore := 30 + random.next_int(21)
			return _multiplied({_ALGAE: algae, _CORAL: coral, _ORE: ore})
		CellContentType.Value.RUINS:
			var algae := random.next_int(101)
			var coral := random.next_int(26)
			var ore := random.next_int(26)
			# Deeper ruins hold more pearls: 0-2 on level 1, 0-3 on 2, 0-4 on 3.
			var pearl := random.next_int(level + 2)
			return _multiplied({_ALGAE: algae, _CORAL: coral, _ORE: ore, _PEARL: pearl})
		CellContentType.Value.WRECK:
			# A wreck holds a fixed loot, never multiplied.
			return {_CORAL: EventRules.WRECK_CORAL, _ORE: EventRules.WRECK_ORE, _PEARL: EventRules.WRECK_PEARLS}
	# `_ => const {}`.
	return {}


static func _multiplied(base: Dictionary[ResourceType.Value, int]) -> Dictionary[ResourceType.Value, int]:
	var loot: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in base:
		loot[type] = base[type] * REWARD_MULTIPLIER
	return loot

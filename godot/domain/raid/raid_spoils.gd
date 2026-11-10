class_name RaidSpoils
extends RefCounted
## lib/domain/raid/raid_spoils.dart: resources won or lost at the end of a
## raid.

## Share of each stock (pearls aside) the monsters carry away.
const PILLAGE_RATE := 0.3
## Turns of production a repelled raid brings back, at most.
const LOOT_TURNS_CAP := 2


## Half the loot of a lair of the same `difficulty`, or `percent` % of that
## half for a lesser fight; drawn with `random`, a die of its own when null.
static func loot(
	difficulty: MonsterDifficulty.Value, random: DartRandom = null, percent := 100
) -> Dictionary[ResourceType.Value, int]:
	var full := LootCalculator.new(random).compute(difficulty)
	var halved: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in full:
		halved[type] = DartMath.trunc_div(full[type] * percent, 200)
	return halved


## `loot` with algae, coral and ore cut to LOOT_TURNS_CAP turns of
## `production`; pearls are left as they are.
static func cap_to_production(
	loot_: Dictionary[ResourceType.Value, int], production: Dictionary[ResourceType.Value, int]
) -> Dictionary[ResourceType.Value, int]:
	var capped: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in loot_:
		var amount := loot_[type]
		if type != ResourceType.Value.PEARL:
			var produced: int = production.get(type, 0)
			amount = mini(amount, LOOT_TURNS_CAP * produced)
		capped[type] = amount
	return capped


## Removes `rate` of every stock but pearls and returns what was taken.
static func pillage(
	resources: Dictionary[ResourceType.Value, GameResource], rate := PILLAGE_RATE
) -> Dictionary[ResourceType.Value, int]:
	var taken: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in resources:
		if type == ResourceType.Value.PEARL:
			continue
		var amount := floori(resources[type].amount * rate)
		if amount <= 0:
			continue
		resources[type].amount -= amount
		taken[type] = amount
	return taken

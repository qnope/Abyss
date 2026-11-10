class_name Difficulty
extends RefCounted
## lib/domain/game/difficulty.dart: how hard the depths are, picked when a
## new game starts. Two levers: the production of the buildings and the
## size of the monster waves (raids on the base and krakens on the volcanic
## kernel). The Dart file tells how they were calibrated with the
## simulator.

enum Value {
	EASY,
	NORMAL,
	HARD,
}

## Share of monster_percent the monsters keep against a faction: they are
## drawn to the human first, so the factions can run their race.
const FACTION_MONSTER_SHARE := 75
## The resources scaled by the difficulty, a set; energy and pearls are not.
const SCALED_RESOURCES: Dictionary[ResourceType.Value, bool] = {
	ResourceType.Value.ALGAE: true,
	ResourceType.Value.CORAL: true,
	ResourceType.Value.ORE: true,
}
const _RESOURCE_PERCENT: Dictionary[Value, int] = {
	Value.EASY: 110, Value.NORMAL: 100, Value.HARD: 95,
}
const _MONSTER_PERCENT: Dictionary[Value, int] = {
	Value.EASY: 86, Value.NORMAL: 94, Value.HARD: 102,
}
const _FACTION_PERCENT: Dictionary[Value, int] = {
	Value.EASY: 90, Value.NORMAL: 100, Value.HARD: 110,
}
const _ATTACK_GAP: Dictionary[Value, int] = {Value.EASY: 16, Value.NORMAL: 10, Value.HARD: 6}


## Production of algae, coral and ore, in percent of the buildings' own.
static func resource_percent(difficulty: Value) -> int:
	return _RESOURCE_PERCENT[difficulty]


## Power of a raid and krakens of a volcano wave, in percent of the base
## waves (RaidWaveFactory, VolcanoWaveFactory).
static func monster_percent(difficulty: Value) -> int:
	return _MONSTER_PERCENT[difficulty]


## Same production for a faction, the other way round: the easier the game,
## the slower the factions grow.
static func faction_percent(difficulty: Value) -> int:
	return _FACTION_PERCENT[difficulty]


## Turns the human is left in peace between two attacks of factions on its
## base: the harder the game, the closer they come.
static func attack_gap(difficulty: Value) -> int:
	return _ATTACK_GAP[difficulty]


## Power of the raids and waves that hit a faction when `faction`, the
## human otherwise. The human's waves are eased by world_relief_percent in
## a world of `factions` factions.
static func monster_percent_for(difficulty: Value, faction: bool, factions := 0) -> int:
	var share := FACTION_MONSTER_SHARE if faction else world_relief_percent(factions)
	return DartMath.trunc_div(monster_percent(difficulty) * share, 100)


## Share of its monsters the human keeps in a world of `factions` factions:
## the map grows with the players, so the road to the volcano is longer and
## the same noise would be paid for longer.
static func world_relief_percent(factions: int) -> int:
	return DartMath.trunc_div(200 - 5 * factions, 2)


## `production` of the buildings, scaled in place and handed back; by
## faction_percent for a `faction`, by resource_percent otherwise.
static func scale_production(
	difficulty: Value, production: Dictionary[ResourceType.Value, int], faction := false
) -> Dictionary[ResourceType.Value, int]:
	var percent := faction_percent(difficulty) if faction else resource_percent(difficulty)
	for type: ResourceType.Value in SCALED_RESOURCES:
		if production.has(type) and production[type] > 0:
			production[type] = DartMath.trunc_div(production[type] * percent, 100)
	return production

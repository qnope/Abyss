class_name DefenceStrength
extends RefCounted
## lib/domain/raid/defence_strength.dart: how strong the units standing on
## a base are, counted in level 1 monsters: each unit weighs its HP times its
## ATK against theirs.
##
## Techs, the rampart and the admiral's command are left out: they stay an
## edge the raids do not answer.


## Strength of the units on `player`'s base level.
static func of(player: Player) -> int:
	var weight := 0
	var units := player.units_on_level(RaidBattle.BASE_LEVEL)
	for type: UnitType.Value in units:
		var stats := UnitStats.for_type(type)
		weight += units[type].count * stats.hp * stats.atk
	return DartMath.trunc_div(weight, _monster_weight())


## `_monsterWeight`, a static final of Dart: HP times ATK of a level 1
## monster.
static func _monster_weight() -> int:
	var monster := MonsterUnitStats.for_level(1)
	return monster.hp * monster.atk

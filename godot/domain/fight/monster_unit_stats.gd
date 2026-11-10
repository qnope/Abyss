class_name MonsterUnitStats
extends RefCounted
## lib/domain/fight/monster_unit_stats.dart: the stats of one monster, by
## family and level.

const _SWARM := MonsterFamily.Value.SWARM
const _ARMOURED := MonsterFamily.Value.ARMOURED
const _HUNTER := MonsterFamily.Value.HUNTER
const _COLOSSUS := MonsterFamily.Value.COLOSSUS
const _KRAKEN := MonsterFamily.Value.KRAKEN

## HP, ATK and DEF (x, y, z) at levels 1, 2 and 3, by family; null is the
## generic monster of older games.
const _TABLE: Dictionary[Variant, Array] = {
	null: [Vector3i(10, 3, 1), Vector3i(20, 5, 2), Vector3i(35, 8, 3)],
	_SWARM: [Vector3i(3, 2, 0), Vector3i(6, 3, 1), Vector3i(11, 5, 2)],
	_ARMOURED: [Vector3i(15, 3, 20), Vector3i(30, 5, 25), Vector3i(53, 8, 30)],
	_HUNTER: [Vector3i(8, 6, 1), Vector3i(16, 10, 2), Vector3i(28, 16, 3)],
	_COLOSSUS: [Vector3i(70, 10, 5), Vector3i(140, 17, 6), Vector3i(245, 27, 7)],
	_KRAKEN: [Vector3i(40, 5, 3), Vector3i(80, 8, 4), Vector3i(140, 12, 5)],
}
const _COUNT_PERCENT: Dictionary[Variant, int] = {
	null: 100, _SWARM: 300, _ARMOURED: 70, _HUNTER: 80, _COLOSSUS: 17, _KRAKEN: 10,
}
const _LEVELS: Dictionary[MonsterDifficulty.Value, int] = {
	MonsterDifficulty.Value.EASY: 1,
	MonsterDifficulty.Value.MEDIUM: 2,
	MonsterDifficulty.Value.HARD: 3,
}

var hp: int
var atk: int
var def: int


func _init(hp_: int, atk_: int, def_: int) -> void:
	hp = hp_
	atk = atk_
	def = def_


## `MonsterUnitStats.forLevel`: stats of the generic monsters (Rôdeurs) of
## older games.
static func for_level(level: int) -> MonsterUnitStats:
	return of(null, level)


## Stats of a monster of `family` (a MonsterFamily.Value) at `level` (1 to
## 3); a null family is the generic monster of older games. Dart throws for
## any other level: this logs an error and returns null.
static func of(family: Variant, level: int) -> MonsterUnitStats:
	if level < 1 or level > 3:
		push_error("MonsterUnitStats.of: the level %d is not 1, 2 or 3" % level)
		return null
	var levels: Array = _TABLE[family]
	var stats: Vector3i = levels[level - 1]
	return MonsterUnitStats.new(stats.x, stats.y, stats.z)


## Monsters of `family` (a MonsterFamily.Value, or null) that stand for 100
## generic ones of the same level: three fragile fish for one, one giant
## for six.
static func count_percent(family: Variant) -> int:
	return _COUNT_PERCENT[family]


## `generic_count` generic monsters turned into monsters of `family`, at
## least one.
static func count_for(family: Variant, generic_count: int) -> int:
	var count := DartMath.trunc_div(generic_count * count_percent(family), 100)
	return 1 if count < 1 else count


static func level_for(difficulty: MonsterDifficulty.Value) -> int:
	return _LEVELS[difficulty]

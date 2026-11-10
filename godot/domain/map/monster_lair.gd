class_name MonsterLair
extends RefCounted
## lib/domain/map/monster_lair.dart: a group of monsters of one level. A
## lair on the map holds one family, a raid wave mixes two.

## The level of the monsters of each difficulty.
const _LEVELS: Dictionary[MonsterDifficulty.Value, int] = {
	MonsterDifficulty.Value.EASY: 1,
	MonsterDifficulty.Value.MEDIUM: 2,
	MonsterDifficulty.Value.HARD: 3,
}

var difficulty: MonsterDifficulty.Value
## Monsters of `family`.
var unit_count: int
## Family of the monsters (a MonsterFamily.Value), null for the generic
## monsters (Rôdeurs) of games started before the families.
var family: Variant
## Second family of a raid wave (a MonsterFamily.Value), null for a lair.
var second_family: Variant
## Monsters of `second_family`.
var second_count: int


func _init(
	difficulty_: MonsterDifficulty.Value,
	unit_count_: int,
	family_: Variant = null,
	second_family_: Variant = null,
	second_count_ := 0,
) -> void:
	difficulty = difficulty_
	unit_count = unit_count_
	family = family_
	second_family = second_family_
	second_count = second_count_


func level() -> int:
	return _LEVELS[difficulty]


## Each family of the group (null for Rôdeurs) with its monster count, empty
## ones left out.
func groups() -> Dictionary[Variant, int]:
	var found: Dictionary[Variant, int] = {}
	if unit_count > 0:
		found[family] = unit_count
	if second_family != null and second_count > 0:
		found[second_family] = second_count
	return found


func total_count() -> int:
	var total := 0
	for count: int in groups().values():
		total += count
	return total

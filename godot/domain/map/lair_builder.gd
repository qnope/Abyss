class_name LairBuilder
extends RefCounted
## lib/domain/map/lair_builder.dart: builds the monster lair of a map cell.

## The fewest monsters of a lair of each difficulty (x), and how many
## counts above it the die can give (y): 20 to 50, 60 to 100, 120 to 200.
const _UNIT_COUNTS: Dictionary[MonsterDifficulty.Value, Vector2i] = {
	MonsterDifficulty.Value.EASY: Vector2i(20, 31),
	MonsterDifficulty.Value.MEDIUM: Vector2i(60, 41),
	MonsterDifficulty.Value.HARD: Vector2i(120, 81),
}


## A lair of `difficulty` on cell `cell_index`. Its size is rolled with the
## map's `random`; its family comes from `family_seed` and the cell through
## a generator of its own, so placing families never consumes the map's
## dice: a seed still makes the same map, and replays of older games still
## find their lairs and treasures where they were.
static func build(
	difficulty: MonsterDifficulty.Value, random: DartRandom, family_seed: int, cell_index: int
) -> MonsterLair:
	var rolled := _roll_unit_count(difficulty, random)
	var family := family_for(family_seed, cell_index, MonsterUnitStats.level_for(difficulty))
	return MonsterLair.new(difficulty, MonsterUnitStats.count_for(family, rolled), family)


## The product wraps to 64 bits before the mask, as in Dart.
static func family_for(seed_: int, cell_index: int, level: int) -> MonsterFamily.Value:
	var random := DartRandom.new((seed_ * 7919 + cell_index) & 0x7FFFFFFF)
	var families := MonsterFamily.available_at(level)
	return families[random.next_int(families.size())]


static func _roll_unit_count(difficulty: MonsterDifficulty.Value, random: DartRandom) -> int:
	var counts := _UNIT_COUNTS[difficulty]
	return counts.x + random.next_int(counts.y)

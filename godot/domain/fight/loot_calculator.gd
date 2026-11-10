class_name LootCalculator
extends RefCounted
## lib/domain/fight/loot_calculator.dart: what a lair yields once its
## monsters are beaten.

## The range of each of algae, coral and ore (x to y), by difficulty.
const _RANGES: Dictionary[MonsterDifficulty.Value, Vector2i] = {
	MonsterDifficulty.Value.EASY: Vector2i(300, 500),
	MonsterDifficulty.Value.MEDIUM: Vector2i(500, 1000),
	MonsterDifficulty.Value.HARD: Vector2i(1000, 2000),
}
const _PEARLS: Dictionary[MonsterDifficulty.Value, int] = {
	MonsterDifficulty.Value.EASY: 0,
	MonsterDifficulty.Value.MEDIUM: 2,
	MonsterDifficulty.Value.HARD: 10,
}

var _random: DartRandom


## Without `random_`, a die of its own that no seed replays.
func _init(random_: DartRandom = null) -> void:
	_random = random_ if random_ != null else DartRandom.unseeded()


## Algae, coral then ore, each drawn in that order, then the pearls.
func compute(difficulty: MonsterDifficulty.Value) -> Dictionary[ResourceType.Value, int]:
	var range_ := _RANGES[difficulty]
	var loot: Dictionary[ResourceType.Value, int] = {}
	loot[ResourceType.Value.ALGAE] = _roll(range_.x, range_.y)
	loot[ResourceType.Value.CORAL] = _roll(range_.x, range_.y)
	loot[ResourceType.Value.ORE] = _roll(range_.x, range_.y)
	loot[ResourceType.Value.PEARL] = _PEARLS[difficulty]
	return loot


func _roll(low: int, high: int) -> int:
	return low + _random.next_int(high - low + 1)

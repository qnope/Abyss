extends TestCase
## test/domain/fight/loot_calculator_test.dart: what a lair yields. The
## three tests Dart generates by difficulty are one test that loops.

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const PEARL := ResourceType.Value.PEARL
const RANGES: Dictionary[MonsterDifficulty.Value, Vector2i] = {
	MonsterDifficulty.Value.EASY: Vector2i(300, 500),
	MonsterDifficulty.Value.MEDIUM: Vector2i(500, 1000),
	MonsterDifficulty.Value.HARD: Vector2i(1000, 2000),
}
const PEARLS: Dictionary[MonsterDifficulty.Value, int] = {
	MonsterDifficulty.Value.EASY: 0,
	MonsterDifficulty.Value.MEDIUM: 2,
	MonsterDifficulty.Value.HARD: 10,
}


func _loot(seed_: int, difficulty: MonsterDifficulty.Value) -> Dictionary[ResourceType.Value, int]:
	return LootCalculator.new(DartRandom.new(seed_)).compute(difficulty)


func test_compute_returns_all_resources_in_range_across_50_seeds() -> void:
	for difficulty: MonsterDifficulty.Value in MonsterDifficulty.Value.values():
		var range_ := RANGES[difficulty]
		for seed_: int in 50:
			var loot := _loot(seed_, difficulty)
			for type: ResourceType.Value in [ALGAE, CORAL, ORE, PEARL]:
				assert_has(loot, type)
			for type: ResourceType.Value in [ALGAE, CORAL, ORE]:
				var amount := loot[type]
				assert_true(amount >= range_.x and amount <= range_.y,
					"%d=%d for %d (seed %d)" % [type, amount, difficulty, seed_])
			assert_eq(loot[PEARL], PEARLS[difficulty])


func test_compute_easy_with_random_42_returns_deterministic_tuple() -> void:
	var loot := _loot(42, MonsterDifficulty.Value.EASY)
	assert_eq([loot[ALGAE], loot[CORAL], loot[ORE], loot[PEARL]], [475, 459, 420, 0])


func test_compute_medium_with_random_42_returns_deterministic_tuple() -> void:
	var loot := _loot(42, MonsterDifficulty.Value.MEDIUM)
	assert_eq([loot[ALGAE], loot[CORAL], loot[ORE], loot[PEARL]], [528, 620, 830, 2])


func test_compute_hard_with_random_42_returns_deterministic_tuple() -> void:
	var loot := _loot(42, MonsterDifficulty.Value.HARD)
	assert_eq([loot[ALGAE], loot[CORAL], loot[ORE], loot[PEARL]], [1671, 1918, 1292, 10])


func test_compute_default_constructor_uses_a_fresh_random() -> void:
	var loot := LootCalculator.new().compute(MonsterDifficulty.Value.MEDIUM)
	assert_eq(loot.size(), 4)
	assert_eq(loot[PEARL], 2)


## Not in the Dart file: the entries come in the order of the Dart map.
func test_gives_the_loot_in_the_order_of_dart() -> void:
	assert_eq(_loot(1, MonsterDifficulty.Value.EASY).keys(), [ALGAE, CORAL, ORE, PEARL])

extends VectorTestCase
## test/domain/game/difficulty_test.dart: the levers of a difficulty. Its
## tests of the raid and kraken waves ('a scaled kraken wave keeps at least
## one kraken', 'raid waves grow...', 'kraken waves grow...') go with the
## raid and volcano modules, 'a new game starts in the difficulty picked'
## with the game module. Then the monsterPercent section of raids.json.

const EASY := Difficulty.Value.EASY
const NORMAL := Difficulty.Value.NORMAL
const HARD := Difficulty.Value.HARD
const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func test_normal_is_the_calibrated_game_same_resources_smaller_waves() -> void:
	var production: Dictionary[ResourceType.Value, int] = {CORAL: 120}
	assert_eq(Difficulty.scale_production(NORMAL, production)[CORAL], 120)
	assert_eq(Difficulty.monster_percent(NORMAL), 94)


func test_easy_gives_more_resources_and_fewer_monsters_than_hard() -> void:
	assert_true(Difficulty.resource_percent(EASY) > Difficulty.resource_percent(NORMAL))
	assert_true(Difficulty.resource_percent(HARD) < Difficulty.resource_percent(NORMAL))
	assert_true(Difficulty.monster_percent(EASY) < Difficulty.monster_percent(NORMAL))
	assert_true(Difficulty.monster_percent(HARD) > Difficulty.monster_percent(NORMAL))


func test_only_algae_coral_and_ore_are_scaled() -> void:
	var production := Difficulty.scale_production(
		EASY, {ALGAE: 100, CORAL: 100, ORE: 100, ENERGY: 100, PEARL: 5}
	)
	var scaled := Difficulty.resource_percent(EASY)
	assert_eq(production, {ALGAE: scaled, CORAL: scaled, ORE: scaled, ENERGY: 100, PEARL: 5})


## Not in the Dart file: the names and the order the snapshots write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(Difficulty.Value), PackedStringArray(["easy", "normal", "hard"]))
	assert_eq(Difficulty.SCALED_RESOURCES.keys(), [ALGAE, CORAL, ORE])
	assert_eq(Difficulty.FACTION_MONSTER_SHARE, 75)


## Not in the Dart file: the map given is scaled in place and handed back,
## its order kept; an amount of zero or less, or missing, is left alone.
func test_scales_the_production_in_place() -> void:
	var production: Dictionary[ResourceType.Value, int] = {ORE: 19, ENERGY: 7, ALGAE: 0, CORAL: -10}
	var scaled := Difficulty.scale_production(HARD, production)
	scaled[PEARL] = 1
	assert_eq(production, {ORE: 18, ENERGY: 7, ALGAE: 0, CORAL: -10, PEARL: 1})
	assert_eq(production.keys(), [ORE, ENERGY, ALGAE, CORAL, PEARL])
	assert_eq(Difficulty.scale_production(EASY, {}), {})


func test_monster_percent_vectors() -> void:
	var cases := VectorFile.new("raids").cases("monsterPercent")
	assert_eq(cases.size(), 3)
	for case: Dictionary in cases:
		var difficulty := VectorInputs.value(Difficulty.Value, case["difficulty"]) as Difficulty.Value
		var human: Array[int] = []
		var relief: Array[int] = []
		for factions: int in range(0, 11):
			human.append(Difficulty.monster_percent_for(difficulty, false, factions))
			relief.append(Difficulty.world_relief_percent(factions))
		var out := {
			"attackGap": Difficulty.attack_gap(difficulty),
			"faction": Difficulty.monster_percent_for(difficulty, true),
			"factionPercent": Difficulty.faction_percent(difficulty),
			"human": human,
			"relief": relief,
			"resourcePercent": Difficulty.resource_percent(difficulty),
		}
		assert_same(out, case["out"], str(case))

extends TestCase
## test/domain/raid/defence_strength_test.dart: the strength of the units on
## a base, counted in level 1 monsters.

const HARPOONIST := UnitType.Value.HARPOONIST


func test_an_empty_base_has_no_strength() -> void:
	assert_eq(DefenceStrength.of(RaidSamples.raid_player()), 0)


func test_a_unit_weighs_its_hp_times_its_atk_against_a_level_1_monster() -> void:
	# Harpoonist 15 × 5 = 75, a generic monster 10 × 3 = 30.
	var player := RaidSamples.raid_player({HARPOONIST: 4})
	assert_eq(DefenceStrength.of(player), 10)


func test_every_type_on_the_base_adds_up_the_admiral_weighs_nothing() -> void:
	var player := RaidSamples.raid_player({
		HARPOONIST: 4, # 300
		UnitType.Value.GUARDIAN: 3, # 25 × 2 × 3 = 150
		UnitType.Value.ABYSS_ADMIRAL: 1, # 0
	})
	assert_eq(DefenceStrength.of(player), 15)


func test_units_on_deeper_levels_do_not_count() -> void:
	var player := RaidSamples.raid_player()
	var deeper: Dictionary[UnitType.Value, Unit] = {HARPOONIST: Unit.new(HARPOONIST, 4)}
	player.units_per_level[2] = deeper
	assert_eq(DefenceStrength.of(player), 0)

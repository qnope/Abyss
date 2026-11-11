extends TestCase
## The squads and the barracks of the parade, read from the game.

const Type := UnitType.Value


func _roster(barracks_level: int, counts: Dictionary[UnitType.Value, int] = {},
		recruitable: Dictionary[UnitType.Value, bool] = {}) -> ArmyRoster:
	return ArmyRoster.new(barracks_level, counts, recruitable)


func test_gives_a_state_for_each_unit_in_order() -> void:
	var states := ParadeStates.squads(_roster(1))
	var types: Array[UnitType.Value] = []
	for state in states:
		types.append(state.type)
	assert_eq(types, Type.values() as Array[UnitType.Value])


func test_counts_what_serves_and_names_it_in_the_plural() -> void:
	var states := ParadeStates.squads(_roster(1, {Type.SCOUT: 3, Type.HARPOONIST: 1}))
	assert_eq(states[Type.SCOUT].count, 3)
	assert_eq(states[Type.SCOUT].caption, UnitArmyTexts.plaque_name(Type.SCOUT, 3))
	assert_eq(states[Type.HARPOONIST].caption, "Harponneur")
	assert_eq(states[Type.GUARDIAN].count, 0)


func test_locks_the_units_the_barracks_is_too_low_for_and_says_the_level() -> void:
	var states := ParadeStates.squads(_roster(1, {}, {Type.SCOUT: true, Type.ABYSS_ADMIRAL: true}))
	assert_false(states[Type.SCOUT].locked)
	assert_true(states[Type.SCOUT].recruitable)
	assert_true(states[Type.ABYSS_ADMIRAL].locked)
	assert_false(states[Type.ABYSS_ADMIRAL].recruitable, "locked, whatever the stock")
	assert_eq(states[Type.ABYSS_ADMIRAL].caption, UnitArmyTexts.lock_pill(Type.ABYSS_ADMIRAL))


func test_gives_the_barracks_of_the_base_with_its_signs() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	var built := ParadeStates.barracks(game)
	assert_eq(built.type, BuildingType.Value.BARRACKS)
	assert_eq(built.level, 0)
	game.human_player().buildings[BuildingType.Value.BARRACKS].level = 2
	assert_eq(ParadeStates.barracks(game).level, 2)

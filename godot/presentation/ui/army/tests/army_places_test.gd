extends TestCase
## test/presentation/widgets/army/army_places_test.dart and the armyPlacesOf
## test of game_screen_army_tab_test.dart.

const Scout := UnitType.Value.SCOUT
const Harpoonist := UnitType.Value.HARPOONIST
const KERNEL := KernelGarrison.STOCK_KEY
const ALL := ArmyPlaces.ALL

var _places: ArmyPlaces


func before_each() -> void:
	_places = ArmyPlaces.new({
		1: {Scout: 10, Harpoonist: 0},
		2: {Scout: 4, Harpoonist: 2},
		3: {Harpoonist: 0},
		KERNEL: {Harpoonist: 5},
	})


func test_holds_the_places_with_at_least_one_unit_levels_then_kernel() -> void:
	assert_eq(_places.held(), [1, 2, KERNEL] as Array[int])


func test_counts_the_units_of_each_place_every_place_for_all() -> void:
	assert_eq(_places.counts_at(2), {Scout: 4, Harpoonist: 2})
	assert_eq(_places.counts_at(KERNEL), {Harpoonist: 5})
	assert_eq(_places.counts_at(3), {})
	assert_eq(_places.counts_at(ALL), {Scout: 14, Harpoonist: 7})


func test_counts_a_type_at_a_place_none_where_it_does_not_serve() -> void:
	assert_eq(_places.count_of(Harpoonist, 2), 2)
	assert_eq(_places.count_of(Scout, KERNEL), 0)
	assert_eq(_places.count_of(Harpoonist, ALL), 7)


func test_totals_the_units_of_a_place_and_of_the_whole_army() -> void:
	assert_eq(_places.total_at(1), 10)
	assert_eq(_places.total_at(KERNEL), 5)
	assert_eq(_places.total_at(ALL), 21)


func test_is_split_once_two_places_hold_units() -> void:
	assert_true(_places.is_split())
	assert_false(ArmyPlaces.new({1: {Scout: 3}, 2: {Scout: 0}}).is_split())
	assert_false(ArmyPlaces.new().is_split())


func test_counts_every_place_of_a_player_the_kernel_garrison_included() -> void:
	var player := GameSamples.player("Nemo")
	player.units_per_level = {
		1: {Scout: Unit.new(Scout, 10)},
		2: {Scout: Unit.new(Scout, 4), Harpoonist: Unit.new(Harpoonist, 2)},
		KERNEL: {Harpoonist: Unit.new(Harpoonist, 5)},
	}
	var places := ArmyPlaces.of(player)
	assert_eq(places.units[1], {Scout: 10})
	assert_eq(places.units[2], {Scout: 4, Harpoonist: 2})
	assert_eq(places.units[KERNEL], {Harpoonist: 5})
	assert_eq(places.held(), [1, 2, KERNEL] as Array[int])

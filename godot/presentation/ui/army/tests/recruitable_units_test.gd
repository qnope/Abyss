extends TestCase
## test/presentation/screens/game/game_screen_army_tab_test.dart:
## recruitableUnitsOf.

const Type := UnitType.Value
const Res := ResourceType.Value


## A player with a barracks at [param barracks], the headquarters at 10 and
## [param each] of every resource.
func _rich(barracks := 3, each := 1000) -> Player:
	var player := GameSamples.player_with("Nemo", {
		BuildingType.Value.BARRACKS: barracks, BuildingType.Value.HEADQUARTERS: 10,
	})
	for type: ResourceType.Value in player.resources:
		player.resources[type].amount = each
	return player


func _keys(set: Dictionary[UnitType.Value, bool]) -> Array:
	return set.keys()


func test_the_unlocked_units_one_can_pay_at_least_one_of() -> void:
	assert_eq(_keys(RecruitableUnits.of(_rich(2))), [Type.SCOUT, Type.HARPOONIST, Type.ABYSS_ADMIRAL])


func test_none_before_the_barracks_is_built() -> void:
	assert_eq(RecruitableUnits.of(_rich(0)).size(), 0)


func test_a_type_already_recruited_this_turn_is_not_recruitable_again() -> void:
	var player := _rich()
	player.recruited_unit_types.append(Type.SCOUT)
	var found := RecruitableUnits.of(player)
	assert_false(found.has(Type.SCOUT))
	assert_true(found.has(Type.HARPOONIST))


func test_a_type_one_cannot_pay_is_not_recruitable() -> void:
	var player := _rich(3, 0)
	player.resources[Res.ALGAE].amount = 10
	player.resources[Res.CORAL].amount = 5
	assert_eq(_keys(RecruitableUnits.of(player)), [Type.SCOUT])


func test_a_degraded_barracks_costs_twice_as_much() -> void:
	var player := _rich(3, 0)
	player.buildings[BuildingType.Value.HEADQUARTERS].level = 1
	player.resources[Res.ALGAE].amount = 10
	player.resources[Res.CORAL].amount = 5
	assert_true(player.is_degraded(BuildingType.Value.BARRACKS))
	assert_eq(RecruitableUnits.of(player).size(), 0)
	player.resources[Res.ALGAE].amount = 20
	player.resources[Res.CORAL].amount = 10
	assert_eq(_keys(RecruitableUnits.of(player)), [Type.SCOUT])

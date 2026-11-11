extends TestCase
## What the sheet of a unit reads of the game.

const Type := UnitType.Value
const Barracks := BuildingType.Value.BARRACKS

var _game: Game
var _human: Player


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_human = _game.human_player()


func test_reads_the_unit_and_its_count_where_the_player_looks() -> void:
	var view := UnitView.of(_game, Type.HARPOONIST, 7)
	assert_eq([view.type, view.count], [Type.HARPOONIST, 7])
	assert_eq(view.barracks_level, 0)
	assert_eq(view.resources, _human.resources)


func test_a_unit_is_unlocked_by_the_barracks_level() -> void:
	_human.buildings[Barracks].level = 2
	assert_true(UnitView.of(_game, Type.ABYSS_ADMIRAL, 0).is_unlocked())
	var guardian := UnitView.of(_game, Type.GUARDIAN, 0)
	assert_false(guardian.is_unlocked())
	assert_eq(guardian.unlock_level(), 3)


func test_the_stock_pays_for_a_number_of_units() -> void:
	_human.buildings[Barracks].level = 1
	for resource: GameResource in _human.resources.values():
		resource.amount = 100
	assert_eq(UnitView.of(_game, Type.SCOUT, 0).max_recruitable(), 10)
	assert_eq(UnitView.of(_game, Type.SCOUT, 0).unit_cost(), UnitCostCalculator.new().recruitment_cost(Type.SCOUT))


func test_a_unit_recruited_this_turn_is_marked() -> void:
	assert_false(UnitView.of(_game, Type.SCOUT, 0).recruited_this_turn)
	_human.recruited_unit_types.append(Type.SCOUT)
	assert_true(UnitView.of(_game, Type.SCOUT, 0).recruited_this_turn)
	assert_false(UnitView.of(_game, Type.HARPOONIST, 0).recruited_this_turn)


func test_a_degraded_barracks_doubles_the_cost() -> void:
	_human.buildings[Barracks].level = 1
	_human.buildings[BuildingType.Value.HEADQUARTERS].level = 1
	var view := UnitView.of(_game, Type.SCOUT, 0)
	assert_true(view.cost_doubled)
	assert_eq(view.unit_cost()[ResourceType.Value.ALGAE], 20)

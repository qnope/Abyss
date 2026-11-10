extends TestCase
## test/domain/objective/tip/tip_map_triggers_test.dart: the situations of
## the tips of the map, monster families included. Each tip is read from its
## list (ObjectiveSamples.applies), TipCatalog waiting for `action`.

const Id := TipId.Value
const Content := CellContentType.Value

var game: Game


func before_each() -> void:
	game = ObjectiveSamples.objective_game()


func test_map_tips_monster_families_a_lair_of_a_family_revealed() -> void:
	_hide_then_reveal(Id.MONSTER_FAMILIES, _lair(MonsterFamily.Value.ARMOURED))


func test_map_tips_monster_families_not_for_the_generic_monsters() -> void:
	game.levels[1].set_cell(9, 9, _lair())
	game.human_player().add_revealed_cell(1, GridPosition.new(9, 9))
	assert_false(_applies(Id.MONSTER_FAMILIES))


func test_map_tips_lair_a_lair_revealed() -> void:
	_hide_then_reveal(Id.LAIR, _lair())


func test_map_tips_lair_on_a_deeper_level_too() -> void:
	_hide_then_reveal(Id.LAIR, _lair(), 2)


func test_map_tips_chest_and_ruins_a_chest_revealed() -> void:
	_hide_then_reveal(Id.CHEST_AND_RUINS, _content(Content.RESOURCE_BONUS))


func test_map_tips_chest_and_ruins_ruins_revealed() -> void:
	_hide_then_reveal(Id.CHEST_AND_RUINS, _content(Content.RUINS))


func test_map_tips_transition_base_a_transition_base_revealed() -> void:
	var base := TransitionBase.new(TransitionBaseType.Value.FAILLE, "Faille")
	_hide_then_reveal(
		Id.TRANSITION_BASE, MapCell.new(TerrainType.Value.PLAIN, Content.TRANSITION_BASE, null, null, base)
	)


func test_map_tips_descent_once_the_descent_module_is_built() -> void:
	assert_false(_applies(Id.DESCENT))
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.DESCENT_MODULE, 1)
	assert_true(_applies(Id.DESCENT))


func test_map_tips_descent_not_for_a_save_older_than_the_descent_module() -> void:
	game.human_player().buildings.erase(BuildingType.Value.DESCENT_MODULE)
	assert_false(_applies(Id.DESCENT))


## Not in the Dart file: a revealed cell of a level the game has no map
## for is skipped.
func test_a_revealed_cell_of_a_level_without_map_is_skipped() -> void:
	game.human_player().add_revealed_cell(2, GridPosition.new(9, 9))
	assert_false(_applies(Id.LAIR))


## `hideThenReveal`: `cell` out of sight at (9, 9) of `level`, then revealed.
func _hide_then_reveal(id: Id, cell: MapCell, level := 1) -> void:
	if not game.levels.has(level):
		game.levels[level] = ObjectiveSamples.plain_map()
	game.levels[level].set_cell(9, 9, cell)
	var name := DartEnum.name_of(Id, id)
	assert_false(_applies(id), name + " hidden")
	game.human_player().add_revealed_cell(level, GridPosition.new(9, 9))
	assert_true(_applies(id), name + " revealed")


func _lair(family: Variant = null) -> MapCell:
	var lair := MonsterLair.new(MonsterDifficulty.Value.EASY, 3, family)
	return MapCell.new(TerrainType.Value.PLAIN, Content.MONSTER_LAIR, lair)


func _content(type: Content) -> MapCell:
	return MapCell.new(TerrainType.Value.PLAIN, type)


func _applies(id: Id) -> bool:
	return ObjectiveSamples.applies(game, id)

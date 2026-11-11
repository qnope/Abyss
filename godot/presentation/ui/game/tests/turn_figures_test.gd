extends TestCase
## The figures the resource bar shows are the ones the end of the turn
## really applies (game_screen_turn_helpers_test.dart,
## game_screen_consumption_test.dart).

const Type := ResourceType.Value


func test_the_preview_matches_the_end_of_turn_without_an_event() -> void:
	_expect_preview_matches([], false)


func test_the_preview_matches_the_end_of_turn_of_a_warm_current() -> void:
	_expect_preview_matches([RandomEventType.Value.WARM_CURRENT], false)


func test_the_preview_matches_the_end_of_turn_of_a_cold_current() -> void:
	_expect_preview_matches([RandomEventType.Value.COLD_CURRENT], false)


func test_the_preview_matches_the_end_of_turn_of_heated_farms() -> void:
	_expect_preview_matches([RandomEventType.Value.COLD_CURRENT], true)


func test_the_energy_of_the_buildings_is_spent() -> void:
	var game := _game_of({
		BuildingType.Value.HEADQUARTERS: 1, BuildingType.Value.SOLAR_PANEL: 1})
	assert_eq(TurnFigures.consumption(game, game.human_player()), {Type.ENERGY: 4})


func test_the_algae_of_the_units_are_eaten_on_every_level() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	game.human_player().units_per_level[1][UnitType.Value.SCOUT].count = 10
	assert_eq(TurnFigures.consumption(game, game.human_player()), {Type.ALGAE: 10})


func test_nothing_spent_is_left_out() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	var player := game.human_player()
	for type: BuildingType.Value in player.buildings:
		player.buildings[type].level = 0
	assert_eq(TurnFigures.consumption(game, player), {})


func test_the_pearls_of_the_posts_come_on_top() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	var player := game.human_player()
	assert_eq(TurnFigures.production(game, player).get(Type.PEARL, 0), 0)
	var base := TransitionBase.new(TransitionBaseType.Value.FAILLE, "Faille", player.id)
	var cell: MapCell = game.levels[1].cells[0]
	cell.transition_base = base
	var pearls := base.pearls_per_turn()
	assert_true(pearls > 0)
	assert_eq(TurnFigures.production(game, player)[Type.PEARL], pearls)


## A producing player of turn 12 under the [param event] (none, or one), with
## the heating of the farms [param heating].
func _expect_preview_matches(event: Array[RandomEventType.Value], heating: bool) -> void:
	var preview := _event_game(event, heating)
	var player := preview.human_player()
	var production := TurnFigures.production(preview, player)
	var consumption := TurnFigures.consumption(preview, player)
	var played := _event_game(event, heating)
	var result := PlayerTurnResolver.resolve(played.human_player(), played.turn, {}, played.difficulty())
	if not result.deactivated_buildings.is_empty():
		return
	for change in result.changes:
		assert_eq(production.get(change.type, 0), change.produced, str(change.type))
		if change.type == Type.ENERGY:
			assert_eq(consumption.get(Type.ENERGY, 0), change.consumed)


func _event_game(event: Array[RandomEventType.Value], heating: bool) -> Game:
	var player := EventSamples.producing_player()
	if not event.is_empty():
		player.event_state.activate(event[0], 14)
		player.event_state.heating = heating
	var game := Game.single_player(player)
	game.turn = 12
	return game


func _game_of(levels: Dictionary[BuildingType.Value, int]) -> Game:
	return GameSamples.game([GameSamples.player_with("Nemo", levels)])

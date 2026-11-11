extends UiTestCase
## What the confirmation announces
## (test/presentation/screens/game/game_screen_turn_helpers_test.dart,
## undefended_post_warning_test.dart): the forecast of the turn's end against
## the domain, and the warning of the posts nobody defends.

const Type := BuildingType.Value
const FAILLE_LINE := "Ta Faille n'a aucun défenseur au niveau 2"
const CHEMINEE_LINE := "Ta Cheminée n'a aucun défenseur au niveau 3"


## A game whose base holds [param levels] only, with the stock of energy
## and algae given.
func _game(levels: Dictionary[BuildingType.Value, int], energy := 0, algae := 0) -> Game:
	var game := GameSamples.game([GameSamples.player_with("Nemo", levels)])
	game.human_player().resources[ResourceType.Value.ENERGY].amount = energy
	game.human_player().resources[ResourceType.Value.ALGAE].amount = algae
	return game


func test_announces_what_the_base_will_make() -> void:
	var game := _game({Type.HEADQUARTERS: 1, Type.ALGAE_FARM: 2, Type.SOLAR_PANEL: 2})
	var forecast := TurnForecast.of(game)
	assert_eq(forecast.turn, 1)
	assert_eq(forecast.production, TurnFigures.production(game, game.human_player()))
	assert_true(forecast.production[ResourceType.Value.ALGAE] > 0)
	assert_eq(forecast.buildings_to_deactivate, [] as Array[BuildingType.Value])
	assert_eq(forecast.units_to_lose, {} as Dictionary[UnitType.Value, int])
	assert_eq(forecast.pending_explorations, 0)


func test_announces_the_buildings_the_lack_of_energy_shuts_down() -> void:
	var game := _game({Type.HEADQUARTERS: 1, Type.ORE_EXTRACTOR: 3, Type.CORAL_MINE: 3})
	var human := game.human_player()
	var forecast := TurnForecast.of(game)
	assert_eq(forecast.buildings_to_deactivate,
		TurnProduction.deactivated(human, TurnFigures.production(game, human), game.turn))
	assert_true(Type.ORE_EXTRACTOR in forecast.buildings_to_deactivate, "the first to go")


func test_announces_the_units_the_lack_of_algae_takes() -> void:
	var game := _game({Type.HEADQUARTERS: 1})
	KernelGarrison.stock_at(game.human_player(), 1)[UnitType.Value.SCOUT].count = 10
	var forecast := TurnForecast.of(game)
	assert_eq(forecast.units_to_lose, {UnitType.Value.SCOUT: 10} as Dictionary[UnitType.Value, int])
	game.human_player().resources[ResourceType.Value.ALGAE].amount = 10
	assert_eq(TurnForecast.of(game).units_to_lose, {} as Dictionary[UnitType.Value, int])


func test_counts_the_scouts_out() -> void:
	var game := _game({Type.HEADQUARTERS: 1})
	game.human_player().pending_explorations.append(ExplorationOrder.new(GridPosition.new(1, 2)))
	assert_eq(TurnForecast.of(game).pending_explorations, 1)


func test_warns_of_a_faille_nobody_defends() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	var warnings := TurnWarnings.of(war.game, war.human())
	assert_eq(warnings.size(), 1)
	mount(warnings[0])
	assert_eq(texts(warnings[0]), PackedStringArray([FAILLE_LINE]))


func test_warns_of_a_cheminee_nobody_defends() -> void:
	var war := PostWar.new(TransitionBaseType.Value.CHEMINEE, 7, true)
	var warning := UndefendedPostWarning.new(UndefendedPosts.of(war.game, war.human()))
	assert_eq(texts(mount(warning)), PackedStringArray([CHEMINEE_LINE]))


func test_no_warning_once_a_unit_defends_the_post() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	war.put(war.human(), 2, {UnitType.Value.GUARDIAN: 1})
	assert_eq(TurnWarnings.of(war.game, war.human()).size(), 0)


func test_no_warning_while_the_passage_is_not_built() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	war.human().buildings[war.passage()].level = 0
	assert_eq(TurnWarnings.of(war.game, war.human()).size(), 0)


func test_the_warning_is_worded_in_every_language() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	var warning := UndefendedPostWarning.new(UndefendedPosts.of(war.game, war.human()))
	mount(warning)
	use_language("en")
	assert_eq(texts(warning), PackedStringArray(["Your Rift has no defender on level 2"]))
	use_language("es")
	assert_eq(texts(warning), PackedStringArray(["Tu Falla no tiene defensores en el nivel 2"]))


func test_the_confirmation_shows_the_warning() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	modals().open(TurnConfirmation.new(TurnForecast.of(war.game), TurnWarnings.of(war.game, war.human())))
	assert_not_null(find_text(FAILLE_LINE))
	press("Confirmer")

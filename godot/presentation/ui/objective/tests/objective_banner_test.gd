extends ObjectiveCase
## test/presentation/widgets/objective/objective_banner_test.dart: the strip
## under the status bars.


func _banner(game: Game) -> ObjectiveBanner:
	return mount(ObjectiveBanner.new(GameActions.new(game), modals())) as ObjectiveBanner


func test_shows_the_first_objective_of_a_new_game() -> void:
	_banner(game_with_completed(0))
	assert_not_null(find_text("Installation"))
	assert_not_null(find_text("Monte le QG au niveau 1 : 0/1"))


func test_shows_the_live_progress_of_the_current_objective() -> void:
	var game := game_on(ObjectiveId.Value.BARRACKS_AND_SCOUTS)
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.BARRACKS, 1)
	var scouts: Unit = game.human_player().units_per_level[1][UnitType.Value.SCOUT]
	scouts.count = 1
	_banner(game)
	assert_not_null(find_text("Construis la Caserne et recrute 2 Éclaireurs : 2/3"))


func test_names_the_chapter_and_the_post_to_take() -> void:
	var game := game_on(ObjectiveId.Value.TAKE_FAILLE)
	var banner := _banner(game)
	assert_not_null(find_text("La Faille"))
	assert_not_null(find_text("Prends la Faille : 0/1"))
	assert_true(banner.lead.get_child(0) is Portrait, "the post, still guarded")
	assert_true(_banner(game_with_completed(0)).lead.get_child(0) is UiIcon, "the flag")
	assert_true(_banner(game_on(ObjectiveId.Value.TAKE_CHEMINEE)).lead.get_child(0) is Portrait, "the other post")


func test_speaks_english_and_spanish() -> void:
	var game := game_on(ObjectiveId.Value.TAKE_FAILLE)
	var banner := _banner(game)
	use_language("en")
	assert_eq(banner.chapter_label.text, "The Rift")
	assert_eq(banner.progress_label.text, "Take the Rift: 0/1")
	use_language("es")
	assert_eq(banner.chapter_label.text, "La Falla")
	assert_eq(banner.progress_label.text, "Toma la Falla: 0/1")
	assert_no_raw_keys(banner)


func test_is_hidden_once_every_objective_is_completed() -> void:
	assert_false(_banner(game_with_completed(ObjectiveId.Value.size())).visible)


func test_names_the_active_temporary_objectives() -> void:
	var game := game_with_completed(0)
	game.turn = 12
	lay_wreck(game)
	var banner := _banner(game)
	assert_true(banner.temporary_label.visible)
	assert_not_null(find_text("+ Épave"))


func test_shows_no_temporary_objective_when_none_is_active() -> void:
	assert_false(_banner(game_with_completed(0)).temporary_label.visible)


func test_a_touch_opens_the_sheet() -> void:
	var banner := _banner(game_with_completed(0))
	press(banner.tap_button)
	assert_true(current_modal() is ObjectivesSheet)


func test_follows_the_game_it_is_refreshed_with() -> void:
	var game := game_with_completed(0)
	var banner := _banner(game)
	game.human_player().saved_objective_state.completed.append(ObjectiveId.Value.HQ_LEVEL_1)
	banner.refresh()
	assert_not_null(find_text("Construis la Ferme d'algues : 0/1"))

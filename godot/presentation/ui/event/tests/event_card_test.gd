extends UiTestCase
## test/presentation/widgets/event/event_card_test.dart and
## screens/game/game_screen_event_actions_test.dart: the card of an event, its
## options, and the choice that goes through the actions.

const Type := RandomEventType.Value

var _game: Game
var _actions: GameActions
var _answers: Array = []
var _acted := 0


func before_each() -> void:
	_answers = []
	_acted = 0


## A game at turn 3 whose player must choose for [param type].
func _open(type: Type, player: Player = null, turn := 3) -> EventCard:
	var human := Player.new("Nemo", "p1") if player == null else player
	human.event_state.schedule(100)
	human.event_state.set_pending(type, 3)
	human.event_state.survivors = 4
	_game = Game.single_player(human)
	_game.turn = turn
	_actions = GameActions.new(_game)
	_actions.acted.connect(_count_acted)
	var card := EventCard.new(_actions, type)
	card.closed.connect(_answers.append)
	return mount(card) as EventCard


## A method, not a lambda: the actions are the test's, and a lambda that
## captured the test would hold it in a cycle for ever.
func _count_acted(_result: Variant) -> void:
	_acted += 1


func _harpoonists() -> int:
	return _game.human_player().units_on_level(1)[UnitType.Value.HARPOONIST].count


func test_shows_the_illustration_the_name_and_the_two_lines() -> void:
	var card := _open(Type.CARAVAN)
	var picture := find_type("TextureRect", card)[0] as UiIcon
	assert_eq(picture.icon_path, RandomEventTexts.illustration(Type.CARAVAN))
	assert_eq(card.card_body.title_label.text, "Caravane de tortues")
	assert_eq(card.card_body.line_labels[0].text, Texts.t(&"eventCardCaravanLine1"))
	assert_eq(card.card_body.line_labels[1].text, Texts.t(&"eventCardCaravanLine2"))
	assert_no_raw_keys(card)


func test_the_first_option_is_filled_and_the_prudent_one_outlined() -> void:
	var card := _open(Type.SURVIVORS)
	assert_eq(card.choice_buttons.size(), 2)
	assert_eq(card.choice_buttons[0].text, "Accueillir 4 harponneurs")
	assert_eq(card.choice_buttons[0].theme_type_variation, &"")
	assert_eq(card.choice_buttons[1].text, "Refuser")
	assert_eq(card.choice_buttons[1].theme_type_variation, &"OutlinedButton")
	assert_not_null(find_text("Plus tard", card))


func test_the_first_option_settles_the_event_and_the_game_is_told() -> void:
	var card := _open(Type.SURVIVORS)
	var before := _harpoonists()
	press("Accueillir 4 harponneurs")
	assert_eq(_answers, [true])
	assert_eq(_harpoonists(), before + 4)
	assert_false(_game.human_player().event_state.has_pending())
	assert_eq(_acted, 1, "acted, so the game is saved and redrawn")
	assert_true(card.is_closed())


func test_the_prudent_option_ends_the_card_with_false() -> void:
	var before := _open(Type.SURVIVORS)
	var harpoonists := _harpoonists()
	press("Refuser")
	assert_eq(_answers, [false])
	assert_eq(_harpoonists(), harpoonists)
	assert_false(_game.human_player().event_state.has_pending())
	assert_true(before.is_closed())


func test_later_closes_the_card_and_leaves_the_event_pending() -> void:
	_open(Type.SURVIVORS)
	press("Plus tard")
	assert_eq(_answers, [null])
	assert_true(_game.human_player().event_state.has_pending())
	assert_eq(_acted, 0)


func test_a_refused_option_is_disabled_and_says_why() -> void:
	var player := RaidSamples.raid_player()
	player.event_state.trade_from = ResourceType.Value.ALGAE
	player.event_state.trade_to = ResourceType.Value.ORE
	player.resources[ResourceType.Value.ALGAE].amount = 40
	var card := _open(Type.CARAVAN, player)
	assert_true(card.choice_buttons[0].disabled)
	assert_false(card.choice_buttons[1].disabled)
	assert_not_null(find_text("Stock insuffisant pour échanger", card))


func test_an_event_without_choice_only_offers_got_it() -> void:
	var card := _open(Type.STORM)
	assert_eq(card.card_body.title_label.text, "Tempête")
	assert_true(card.choice_buttons.is_empty())
	assert_null(find_text("Plus tard", card))
	press("Compris")
	assert_eq(_answers, [null])


func test_a_choice_made_after_its_turn_is_refused_and_tells_why() -> void:
	use_language("en")
	var card := _open(Type.SURVIVORS, null, 4)
	assert_false(card.failure_label.visible)
	press(Texts.t(&"eventCardRefuse"))
	assert_true(card.failure_label.visible)
	assert_eq(card.failure_label.text, Texts.t(&"actionFailureNotThisChoiceTurn"))
	assert_eq(_answers, [] as Array)
	assert_false(card.is_closed(), "the card stays open")
	assert_true(_game.human_player().event_state.has_pending())
	assert_eq(_acted, 0, "nothing changed, nothing to save")


func test_every_card_is_written_in_every_language() -> void:
	for locale: String in ["fr", "en", "es"]:
		use_language(locale)
		for type: Type in Type.values():
			var card := _open(type)
			assert_no_raw_keys(card)
			assert_false(card.card_body.title_label.text.is_empty())

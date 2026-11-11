extends TextsTestCase
## test/presentation/extensions/event_state_extensions_test.dart.

const Type := RandomEventType.Value


func test_counts_the_current_turn_among_the_turns_left() -> void:
	assert_eq(EventStateTexts.turns_left(13, 10), 4)
	assert_eq(EventStateTexts.turns_left(13, 13), 1)


func test_a_countdown_reads_in_the_singular_on_its_last_turn() -> void:
	assert_eq(EventStateTexts.countdown_text("Tempête", 2), "Tempête : encore 2 tours")
	assert_eq(EventStateTexts.countdown_text("Tempête", 1), "Tempête : encore 1 tour")


func test_a_countdown_reads_in_english_and_spanish() -> void:
	TranslationServer.set_locale("en")
	assert_eq(EventStateTexts.countdown_text("Storm", 2), "Storm: 2 turns left")
	assert_eq(EventStateTexts.countdown_text("Storm", 1), "Storm: 1 turn left")
	TranslationServer.set_locale("es")
	assert_eq(EventStateTexts.countdown_text("Tormenta", 2), "Tormenta: quedan 2 turnos")
	assert_eq(EventStateTexts.countdown_text("Tormenta", 1), "Tormenta: queda 1 turno")


func _wreck_state() -> EventState:
	return EventState.new(null, null, null, null, null, null, false, 0, null, null, null, null, null,
		GridPosition.new(2, 3), 13)


func test_the_wreck_counts_down_on_its_cell_of_level_one() -> void:
	var state := _wreck_state()
	assert_eq(EventStateTexts.wreck_countdown_at(state, 2, 3, 1, 11), "Épave : encore 3 tours")
	TranslationServer.set_locale("en")
	assert_eq(EventStateTexts.wreck_countdown_at(state, 2, 3, 1, 11), "Wreck: 3 turns left")


func test_the_wreck_says_nothing_elsewhere_or_without_a_wreck() -> void:
	var state := _wreck_state()
	assert_null(EventStateTexts.wreck_countdown_at(state, 3, 2, 1, 11))
	assert_null(EventStateTexts.wreck_countdown_at(state, 2, 3, 2, 11))
	assert_null(EventStateTexts.wreck_countdown_at(EventState.new(), 2, 3, 1, 11))
	assert_null(EventStateTexts.wreck_countdown(EventState.new(), 11))
	var searched := EventState.new()
	searched.wreck_until_turn = 13
	assert_null(EventStateTexts.wreck_countdown(searched, 11), "a wreck searched is no longer on the map")


func test_the_effect_counts_down_while_it_lasts() -> void:
	var state := EventState.new()
	state.activate(Type.STORM, 10)
	assert_eq(EventStateTexts.effect_countdown(state, 10), "Tempête : encore 1 tour")
	assert_null(EventStateTexts.effect_countdown(state, 11), "an effect that is over is forgotten")
	assert_null(EventStateTexts.effect_countdown(EventState.new(), 10))


func test_says_the_greenhouses_are_heated_during_a_cold_current() -> void:
	var state := EventState.new(null, null, null, null, Type.COLD_CURRENT, 12, true)
	assert_eq(EventStateTexts.effect_countdown(state, 11), "Courant froid (serres chauffées) : encore 2 tours")
	TranslationServer.set_locale("en")
	assert_eq(EventStateTexts.effect_countdown(state, 11), "Cold Current (heated greenhouses): 2 turns left")
	state.heating = false
	assert_eq(EventStateTexts.effect_countdown(state, 11), "Cold Current: 2 turns left")

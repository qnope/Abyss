extends TextsTestCase
## test/presentation/widgets/event/event_card_data_test.dart: what each card
## says and offers, in figures.

const Type := RandomEventType.Value


## The game of [param player] during turn 12.
func _game(player: Player) -> Game:
	var game := Game.single_player(player)
	game.turn = 12
	return game


## The card of [param type] waiting for [param player]'s choice during turn 12.
func _card(type: Type, player: Player = null) -> EventCardData:
	var p := RaidSamples.raid_player() if player == null else player
	if p.event_state.pending == null:
		p.event_state.set_pending(type, 12)
	return EventCardData.of(_game(p), type)


func _labels(card: EventCardData) -> PackedStringArray:
	var labels := PackedStringArray()
	for choice in card.choices:
		labels.append(choice.label)
	return labels


func test_a_warm_current_shows_its_boost_and_its_noise() -> void:
	var card := _card(Type.WARM_CURRENT)
	assert_eq(card.lines.size(), 2)
	assert_eq(_labels(card), PackedStringArray([
		"Exploiter (+30 % algues, corail, minerai pendant 3 tours, +3 bruit/tour)", "Laisser passer"]))
	assert_eq([card.choices[0].accept, card.choices[1].accept], [true, false])


func test_a_cold_current_weighs_the_energy_against_the_algae() -> void:
	assert_eq(_labels(_card(Type.COLD_CURRENT)), PackedStringArray([
		"Chauffer les serres (−20 énergie/tour pendant 3 tours)", "Subir (−30 % d'algues pendant 3 tours)"]))


func test_the_predators_show_their_wave_the_defenders_and_the_bait() -> void:
	var player := EventSamples.threatened_player({UnitType.Value.HARPOONIST: 3})
	player.resources[ResourceType.Value.ALGAE].amount = 250
	var card := _card(Type.PREDATORS, player)
	var wave := MonsterLairTexts.wave_label(EventSamples.predator_test_wave())
	assert_eq(card.lines[1], "%s contre 3 défenseurs du niveau 1." % wave)
	assert_eq(_labels(card), PackedStringArray(["L'affronter (5 monstres, fin du tour)", "L'appâter (−75 algues)"]))


func test_predators_with_no_wave_drawn_yet_only_watch_the_base() -> void:
	var card := _card(Type.PREDATORS, RaidSamples.raid_player())
	assert_eq(card.lines[1], Texts.t(&"eventCardPredatorsWatching"))
	assert_eq(card.choices[0].label, Texts.t(&"eventCardPredatorsAccept", {"count": 0}))


func test_the_survivors_count_the_harpoonists_who_join() -> void:
	var player := RaidSamples.raid_player()
	player.event_state.set_pending(Type.SURVIVORS, 12)
	player.event_state.survivors = 4
	assert_eq(_labels(_card(Type.SURVIVORS, player)), PackedStringArray(["Accueillir 4 harponneurs", "Refuser"]))


func test_the_survivors_not_counted_yet_are_none() -> void:
	var player := RaidSamples.raid_player()
	player.event_state.set_pending(Type.SURVIVORS, 12)
	assert_eq(_card(Type.SURVIVORS, player).choices[0].label, "Accueillir 0 harponneur")


func _caravan(algae: int) -> Player:
	var player := RaidSamples.raid_player()
	player.event_state.set_pending(Type.CARAVAN, 12)
	player.event_state.trade_from = ResourceType.Value.ALGAE
	player.event_state.trade_to = ResourceType.Value.ORE
	player.resources[ResourceType.Value.ALGAE].amount = algae
	return player


func test_the_caravan_names_both_resources_of_its_trade() -> void:
	var card := _card(Type.CARAVAN, _caravan(1000))
	assert_eq(_labels(card), PackedStringArray(["Échanger 100 Algues contre 70 Minerai", "Refuser"]))
	assert_null(card.choices[0].refusal)


func test_a_caravan_with_no_trade_drawn_names_nothing() -> void:
	var player := RaidSamples.raid_player()
	player.event_state.set_pending(Type.CARAVAN, 12)
	assert_eq(_card(Type.CARAVAN, player).choices[0].label, "Échanger 100 ? contre 70 ?")


func test_the_caravan_is_refused_once_the_stock_cannot_pay() -> void:
	var player := _caravan(40)
	var card := _card(Type.CARAVAN, player)
	assert_eq(card.choices[0].refusal, "Stock insuffisant pour échanger")
	assert_null(card.choices[1].refusal)
	TranslationServer.set_locale("en")
	assert_eq(EventCardData.of(_game(player), Type.CARAVAN).choices[0].refusal, "Not enough stock to trade")


func test_the_storm_only_explains_its_effect() -> void:
	var card := EventCardData.of(_game(RaidSamples.raid_player()), Type.STORM)
	assert_true(card.choices.is_empty())
	assert_eq(card.lines, PackedStringArray([
		"Exploration impossible pendant 2 tours.", "La tempête couvre le bruit : jauge −10."]))


func test_the_wreck_counts_the_turns_left_to_search_it() -> void:
	var player := RaidSamples.raid_player()
	player.event_state.wreck_until_turn = 16
	var card := EventCardData.of(_game(player), Type.WRECK)
	assert_true(card.choices.is_empty())
	assert_eq(card.lines, PackedStringArray([
		"Une épave a coulé au bord de la zone explorée.",
		"Explore-la avec un Éclaireur puis fouille-la avant 5 tours (+20 bruit)."]))


func test_a_wreck_not_drawn_yet_gets_all_its_turns() -> void:
	var card := EventCardData.of(_game(RaidSamples.raid_player()), Type.WRECK)
	assert_eq(card.lines[1], Texts.t(&"eventCardWreckLine2", {"turns": EventRules.WRECK_TURNS, "noise": 20}))


func test_every_card_is_written_in_every_language() -> void:
	for locale in LANGUAGES:
		TranslationServer.set_locale(locale)
		for type: Type in Type.values():
			var card := _card(type, _caravan(1000) if type == Type.CARAVAN else null)
			for line in card.lines:
				assert_false(line.is_empty())
			for choice in card.choices:
				assert_false(choice.label.is_empty())

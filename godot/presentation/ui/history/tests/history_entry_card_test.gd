extends UiTestCase
## test/presentation/widgets/history/history_entry_card_test.dart and the card
## part of history_event_card_test.dart: the look of each kind of entry.

var _taps := 0


func before_each() -> void:
	_taps = 0


func _card(entry: HistoryEntry) -> HistoryEntryCard:
	var card := HistoryEntryCard.new(entry)
	card.tapped.connect(_count)
	return mount(card) as HistoryEntryCard


func _count() -> void:
	_taps += 1


func _picture(card: HistoryEntryCard) -> UiIcon:
	return find_type("TextureRect", card)[0] as UiIcon


func test_a_building_shows_its_glyph_its_title_and_the_turn() -> void:
	var card := _card(BuildingEntry.new(3, BuildingType.Value.ALGAE_FARM, 2))
	assert_eq(card.title_label.text, "Ferme d'algues niv. 2")
	assert_eq(card.turn_label.text, "Tour 3")
	assert_true(card.turn_label.visible)
	assert_false(card.subtitle_label.visible, "no detail, no subtitle")
	assert_null(card.tap_button)
	assert_eq(_picture(card).icon_path, UiIcon.glyph_path(&"build"))
	assert_eq(_picture(card).self_modulate, HistoryColors.of(HistoryEntryCategory.Value.BUILDING))
	assert_no_raw_keys(card)


func test_a_card_is_tinted_with_the_colour_of_its_entry() -> void:
	var card := _card(HistorySamples.combat_entry(true))
	var box := card.panel.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.bg_color, Color(AbyssColors.SUCCESS, HistoryEntryCard.FILL_SHARE))
	var lost := _card(HistorySamples.combat_entry(false)).panel.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(lost.bg_color, Color(AbyssColors.ERROR, HistoryEntryCard.FILL_SHARE))


func test_a_static_card_does_nothing_when_touched() -> void:
	var card := _card(BuildingEntry.new(3, BuildingType.Value.ALGAE_FARM, 2))
	assert_null(card.tap_button)
	assert_false(card.tappable)
	assert_eq(_taps, 0)


func test_a_combat_is_tappable_with_a_chevron_and_the_turn_in_its_subtitle() -> void:
	var card := _card(HistorySamples.combat_entry(true))
	assert_true(card.tappable)
	assert_eq(card.title_label.text, "Victoire vs Repaire niv. 2")
	assert_eq(card.subtitle_label.text, "Tour 5")
	assert_true(card.subtitle_label.visible)
	assert_false(card.turn_label.visible, "the chevron has the room")
	assert_eq(find_type("TextureRect", card).size(), 2, "its glyph and the chevron")
	press(card.tap_button)
	assert_eq(_taps, 1)


func test_a_tappable_card_with_a_detail_puts_the_turn_before_it() -> void:
	var card := _card(HistorySamples.capture_entry("faille:0"))
	assert_eq(card.subtitle_label.text, "Tour 6 · Victoire en 2 tours")
	assert_eq(card.title_label.text, "Capture : Faille Alpha")


func test_a_static_card_with_a_detail_keeps_it_as_its_subtitle() -> void:
	var card := _card(DescentEntry.new(4, 2, 5))
	assert_eq(card.subtitle_label.text, "5 unités envoyées")
	assert_eq(card.turn_label.text, "Tour 4")


func test_an_event_shows_its_art_its_name_and_its_choice() -> void:
	var card := _card(EventEntry.new(6, RandomEventType.Value.CARAVAN, false, true))
	assert_eq(card.title_label.text, "Caravane de tortues")
	assert_eq(card.subtitle_label.text, "Option prudente, sans choix")
	assert_eq(card.turn_label.text, "Tour 6")
	assert_eq(_picture(card).icon_path, RandomEventTexts.illustration(RandomEventType.Value.CARAVAN))
	assert_eq(_picture(card).custom_minimum_size, Vector2.ONE * HistoryEntryCard.ILLUSTRATION_SIZE)


func test_a_school_of_predators_shows_the_predators_art() -> void:
	var card := _card(HistorySamples.raid_entry(true, true))
	assert_eq(card.title_label.text, "Banc de prédateurs repoussé")
	assert_eq(_picture(card).icon_path, RandomEventTexts.illustration(RandomEventType.Value.PREDATORS))


func test_a_plain_raid_keeps_its_category_glyph() -> void:
	var card := _card(HistorySamples.raid_entry(false))
	assert_eq(_picture(card).icon_path, UiIcon.glyph_path(&"warning"))


func test_an_entry_reads_in_the_language_on() -> void:
	var card := _card(HistorySamples.combat_entry(true))
	use_language("en")
	assert_eq(card.title_label.text, "Victory vs Lair lv. 2")
	assert_eq(card.subtitle_label.text, "Turn 5")
	use_language("es")
	assert_no_raw_keys(card)

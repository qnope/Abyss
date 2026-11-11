extends UiTestCase
## test/presentation/screens/game/raid/raid_pillage_card_test.dart.

const Kind := ResourceType.Value


func test_lists_what_a_lost_raid_carried_away_in_red() -> void:
	var taken: Dictionary[ResourceType.Value, int] = {Kind.CORAL: 40, Kind.ORE: 0}
	var card := mount(RaidPillageCard.new(taken)) as RaidPillageCard
	assert_eq(card.title_label.text, "Pillage")
	assert_eq(card.title_label.get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_eq(card.rows.keys(), [Kind.CORAL])
	assert_eq(card.rows[Kind.CORAL].text, "Corail -40")
	assert_false(card.empty_label.visible)
	assert_no_raw_keys()


func test_says_there_was_nothing_to_loot() -> void:
	var taken: Dictionary[ResourceType.Value, int] = {Kind.CORAL: 0}
	var card := mount(RaidPillageCard.new(taken)) as RaidPillageCard
	assert_true(card.empty_label.visible)
	assert_eq(card.empty_label.text, "Rien à piller")
	assert_eq(find_type("ResourceIcon", card).size(), 0)
	use_language("en")
	assert_eq(card.empty_label.text, text(&"raidNothingToLoot"))
	assert_eq(card.title_label.text, text(&"raidPillage"))

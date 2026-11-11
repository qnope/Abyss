extends UiTestCase
## The cards of a fight report (test/presentation/widgets/fight/): the banner,
## the kill count, the loot and the pillage, the accounting of the units.

const Kind := ResourceType.Value
const Troop := UnitType.Value


func test_the_banner_tells_a_victory_with_the_turns_of_the_fight() -> void:
	var banner := mount(FightResultBanner.new(true, 2)) as FightResultBanner
	assert_eq(banner.title_label.text, "VICTOIRE")
	assert_eq(banner.title_label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_CYAN)
	assert_eq(banner.turns_label.text, "Combat en 2 tours")
	assert_true(banner.turns_label.visible)
	assert_no_raw_keys()


func test_the_banner_tells_a_defeat_in_warning_with_one_turn() -> void:
	var banner := mount(FightResultBanner.new(false, 1)) as FightResultBanner
	assert_eq(banner.title_label.text, "DÉFAITE")
	assert_eq(banner.title_label.get_theme_color(&"font_color"), AbyssColors.WARNING)
	assert_eq(banner.turns_label.text, "Combat en 1 tour")


func test_the_banner_takes_a_text_of_its_own_and_says_nothing_of_the_turns() -> void:
	var banner := mount(FightResultBanner.new(true, -1, &"fightKernelCaptured")) as FightResultBanner
	assert_eq(banner.title_label.text, "NOYAU CAPTURÉ")
	assert_false(banner.turns_label.visible)


func test_the_banner_follows_the_language() -> void:
	var banner := mount(FightResultBanner.new(true, 2)) as FightResultBanner
	use_language("en")
	assert_eq(banner.title_label.text, text(&"fightVictory"))
	assert_eq(banner.turns_label.text, "Fight over 2 turns")


func test_the_kill_count_tells_the_enemies_killed() -> void:
	var count := mount(FightKillCount.new(HistorySamples.fight(true, 5, 2))) as FightKillCount
	assert_eq(count.label.text, "Ennemis tués : 3/5")
	assert_no_raw_keys()


func test_the_kill_count_calls_them_guardians_of_a_guarded_place() -> void:
	var count := mount(FightKillCount.new(HistorySamples.fight(true, 5, 0), true)) as FightKillCount
	assert_eq(count.label.text, "Gardiens éliminés : 5/5")


func test_the_kill_count_can_say_it_in_other_words() -> void:
	var count := mount(FightKillCount.new(HistorySamples.fight(true, 5, 1), false, &"assaultDefendersDown")) as FightKillCount
	assert_eq(count.label.text, "Défenseurs mis hors de combat : 4/5")


func test_the_loot_lists_each_resource_won_and_skips_the_zeros() -> void:
	var loot: Dictionary[ResourceType.Value, int] = {Kind.CORAL: 40, Kind.ORE: 0}
	var card := mount(FightLootCard.new(loot)) as FightLootCard
	assert_eq(card.title_label.text, "Butin")
	assert_eq(card.rows.keys(), [Kind.CORAL])
	assert_eq(card.rows[Kind.CORAL].text, "Corail +40")
	assert_false(card.empty_label.visible)
	assert_eq(find_type("ResourceIcon", card).size(), 1)
	assert_no_raw_keys()


func test_the_loot_says_there_was_none() -> void:
	var loot: Dictionary[ResourceType.Value, int] = {Kind.CORAL: 0}
	var card := mount(FightLootCard.new(loot)) as FightLootCard
	assert_true(card.empty_label.visible)
	assert_eq(card.empty_label.text, "Aucun butin")
	assert_true(card.rows.is_empty())


func test_the_accounting_tells_each_type_sent_and_what_came_back() -> void:
	var sent: Dictionary[UnitType.Value, int] = {Troop.GUARDIAN: 2, Troop.HARPOONIST: 3}
	var intact: Dictionary[UnitType.Value, int] = {Troop.GUARDIAN: 1}
	var dead: Dictionary[UnitType.Value, int] = {Troop.GUARDIAN: 1, Troop.HARPOONIST: 1}
	var wounded: Dictionary[UnitType.Value, int] = {Troop.HARPOONIST: 2}
	var card := mount(FightUnitAccounting.new(sent, intact, wounded, dead)) as FightUnitAccounting
	assert_eq(card.title_label.text, "Vos unités")
	assert_eq(card.rows.size(), 2)
	assert_eq(card.rows[Troop.GUARDIAN].text, "Envoyés : 2 / Intactes : 1 / Blessés : 0 / Morts : 1")
	assert_eq(card.rows[Troop.HARPOONIST].text, "Envoyés : 3 / Intactes : 0 / Blessés : 2 / Morts : 1")
	assert_eq(find_type("Portrait", card).size(), 2)
	assert_no_raw_keys()

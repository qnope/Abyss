extends UiTestCase
## test/presentation/screens/game/fight/fight_summary_screen_test.dart and
## history_fight_launcher: the report of a fight against a lair.

const Scout := UnitType.Value.SCOUT
const Harpoonist := UnitType.Value.HARPOONIST

var _closed: Array[Variant] = []


func _result(victory: bool) -> FightMonsterResult:
	var loot: Dictionary[ResourceType.Value, int] = {}
	if victory:
		loot = {ResourceType.Value.ALGAE: 10, ResourceType.Value.ORE: 0}
	return FightMonsterResult.success(victory, HistorySamples.fight(victory, 3), loot,
		_counts(3, 2), _counts(2, 1), _counts(1, 0), _counts(0, 1))


func _counts(scouts: int, harpoonists: int) -> Dictionary[UnitType.Value, int]:
	return {Scout: scouts, Harpoonist: harpoonists}


func _open(page: FightSummaryPage) -> FightSummaryPage:
	page.closed.connect(_closed.append)
	modals().open(page)
	return page


## The class of each card of [param page], top to bottom; a plain button has none.
func _kinds(page: FightSummaryPage) -> Array[StringName]:
	var found: Array[StringName] = []
	for card in page.body.get_children():
		var script: Script = card.get_script()
		found.append(&"" if script == null else script.get_global_name())
	return found


func _lair() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 3)


func test_a_victory_tells_the_loot() -> void:
	var page := _open(FightSummaryPage.new(_result(true), _lair(), 4, 5))
	assert_eq(page.title(), "Combat (4, 5)")
	assert_eq(_kinds(page), [&"FightResultBanner", &"MonsterPreview", &"FightUnitAccounting",
		&"FightKillCount", &"FightLootCard", &"FightTurnList", &""] as Array[StringName])
	assert_not_null(find_text("VICTOIRE", page))
	assert_not_null(find_text("Combat en 2 tours", page))
	assert_not_null(find_text("Butin", page))
	assert_not_null(find_text("Algues +10", page))
	assert_no_raw_keys(page)


func test_a_defeat_has_no_loot() -> void:
	var page := _open(FightSummaryPage.new(_result(false), _lair(), 1, 2))
	assert_not_null(find_text("DÉFAITE", page))
	assert_null(find_text("Butin", page))
	assert_false(_kinds(page).has(&"FightLootCard"))


func test_the_units_and_the_enemies_are_counted() -> void:
	var page := _open(FightSummaryPage.new(_result(true), _lair(), 0, 0))
	assert_not_null(find_text("Envoyés : 3 / Intactes : 2 / Blessés : 1 / Morts : 0", page))
	assert_not_null(find_text("Envoyés : 2 / Intactes : 1 / Blessés : 0 / Morts : 1", page))
	assert_not_null(find_text("Ennemis tués : 3/3", page))


func test_the_monsters_are_the_lair_s() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.HARD, 5, MonsterFamily.Value.SWARM)
	var page := _open(FightSummaryPage.new(_result(true), lair, 0, 0))
	assert_eq((find_type("MonsterPreview", page)[0] as MonsterPreview).lair, lair)


func test_back_to_the_map_ends_the_page() -> void:
	var page := _open(FightSummaryPage.new(_result(true), _lair(), 0, 0))
	press("Retour à la carte")
	assert_true(page.is_closed())
	assert_eq(_closed, [null] as Array[Variant])


func test_the_page_follows_the_language() -> void:
	var page := _open(FightSummaryPage.new(_result(true), _lair(), 2, 3))
	use_language("en")
	assert_eq(page.title(), "Fight (2, 3)")
	assert_not_null(find_text("VICTORY", page))
	assert_not_null(find_text("Back to the map", page))
	assert_no_raw_keys(page)


func test_the_history_reopens_the_report_of_an_entry() -> void:
	var entry := HistorySamples.combat_entry(true)
	var loot: Dictionary[ResourceType.Value, int] = {ResourceType.Value.CORAL: 4}
	entry.loot = loot
	entry.sent = _counts(3, 0)
	var page := _open(HistoryReports.fight_summary(entry))
	assert_eq(page.title(), "Combat (3, 4)")
	assert_not_null(find_text("Corail +4", page))
	assert_eq((find_type("MonsterPreview", page)[0] as MonsterPreview).lair, entry.lair)
	assert_eq((find_type("FightUnitAccounting", page)[0] as FightUnitAccounting).sent, entry.sent)
	var lost := _open(HistoryReports.fight_summary(HistorySamples.combat_entry(false)))
	assert_not_null(find_text("DÉFAITE", lost))

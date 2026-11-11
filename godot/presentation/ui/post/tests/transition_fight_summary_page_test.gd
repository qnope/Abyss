extends UiTestCase
## test/presentation/screens/game/fight/transition_fight_summary_screen_test.dart:
## the report of the assault on a Faille or a Cheminée.

const Admiral := UnitType.Value.ABYSS_ADMIRAL
const Harpoonist := UnitType.Value.HARPOONIST

var _closed: Array[Variant] = []


func _page(result: AttackTransitionBaseResult) -> TransitionFightSummaryPage:
	var page := TransitionFightSummaryPage.new(result, 4, 9)
	page.closed.connect(_closed.append)
	modals().open(page)
	return page


func test_the_title_has_the_coordinates() -> void:
	assert_eq(_page(AssaultResults.transition(AssaultResults.STRONG)).title(), "Assaut (4, 9)")


func test_a_capture_says_so_and_lists_the_units_the_guardians_and_the_turns() -> void:
	var result := AssaultResults.transition(AssaultResults.STRONG)
	var page := _page(result)
	assert_not_null(find_text("BASE CAPTURÉE", page))
	assert_null(find_text("VICTOIRE", page))
	assert_not_null(find_text("Gardiens éliminés : %d/%d" % [
		result.fight.initial_monster_count - result.fight.final_monster_count, result.fight.initial_monster_count], page))
	assert_eq(find_type("FightTurnTile", page).size(), result.fight.turn_summaries.size())
	assert_eq(find_type("FightUnitAccounting", page).size(), 1)
	assert_no_raw_keys(page)


func test_a_defeat_says_so_and_has_no_capture() -> void:
	var page := _page(AssaultResults.transition(AssaultResults.WEAK))
	assert_not_null(find_text("DÉFAITE", page))
	assert_null(find_text("BASE CAPTURÉE", page))


func test_a_victory_without_a_capture_reads_victory() -> void:
	var result := AssaultResults.transition(AssaultResults.STRONG)
	result.captured = false
	assert_not_null(find_text("VICTOIRE", _page(result)))


func test_without_a_fight_only_the_result_and_the_units_show() -> void:
	var result := AttackTransitionBaseResult.success(false, false, null, {Harpoonist: 2}, {}, {}, {Harpoonist: 2})
	var page := _page(result)
	assert_eq(find_type("FightKillCount", page).size(), 0)
	assert_eq(find_type("FightTurnList", page).size(), 0)
	assert_not_null(find_text("DÉFAITE", page))


func test_back_to_the_map_ends_the_page() -> void:
	var page := _page(AssaultResults.transition(AssaultResults.STRONG))
	press("Retour à la carte")
	assert_true(page.is_closed())
	assert_eq(_closed, [null] as Array[Variant])


func test_the_page_speaks_english_and_spanish() -> void:
	var page := _page(AssaultResults.transition(AssaultResults.STRONG))
	use_language("en")
	assert_eq(page.title(), "Assault (4, 9)")
	assert_not_null(find_text("Back to the map", page))
	assert_no_raw_keys(page)
	use_language("es")
	assert_no_raw_keys(page)

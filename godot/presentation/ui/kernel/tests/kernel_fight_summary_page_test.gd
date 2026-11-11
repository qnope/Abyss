extends UiTestCase
## test/presentation/screens/game/fight/kernel_fight_summary_screen_test.dart:
## the report of the assault on the volcano the kraken guards.

var _closed: Array[Variant] = []


func _page(result: AttackVolcanicKernelResult) -> KernelFightSummaryPage:
	var page := KernelFightSummaryPage.new(result, 7, 8)
	page.closed.connect(_closed.append)
	modals().open(page)
	return page


func test_the_title_names_the_kernel() -> void:
	assert_eq(_page(AssaultResults.kernel(AssaultResults.STRONG)).title(), "Assaut : Noyau Volcanique")


func test_a_capture_says_the_kernel_is_captured() -> void:
	var result := AssaultResults.kernel(AssaultResults.STRONG)
	var page := _page(result)
	assert_not_null(find_text("NOYAU CAPTURÉ", page))
	assert_null(find_text("BASE CAPTURÉE", page))
	assert_not_null(find_text("Gardiens éliminés : %d/%d" % [
		result.fight.initial_monster_count - result.fight.final_monster_count, result.fight.initial_monster_count], page))
	assert_no_raw_keys(page)


func test_a_defeat_says_so() -> void:
	var page := _page(AssaultResults.kernel(AssaultResults.WEAK))
	assert_not_null(find_text("DÉFAITE", page))
	assert_null(find_text("NOYAU CAPTURÉ", page))


func test_the_units_are_accounted_for() -> void:
	var result := AssaultResults.kernel(AssaultResults.STRONG)
	var page := _page(result)
	var accounting := find_type("FightUnitAccounting", page)[0] as FightUnitAccounting
	assert_eq(accounting.sent, result.sent)
	assert_eq(accounting.dead, result.dead)


func test_back_to_the_map_ends_the_page() -> void:
	var page := _page(AssaultResults.kernel(AssaultResults.STRONG))
	press("Retour à la carte")
	assert_true(page.is_closed())


func test_the_page_speaks_english() -> void:
	var page := _page(AssaultResults.kernel(AssaultResults.STRONG))
	use_language("en")
	assert_eq(page.title(), "Assault: Volcanic Core")
	assert_no_raw_keys(page)

extends UiTestCase
## test/presentation/screens/game/fight/base_assault_summary_screen_test.dart,
## widgets/history/history_assault_entry_test.dart, history_post_assault_test.dart
## and history_kernel_assault_test.dart: the report of an assault on a base, a
## post or the kernel, read from either side.

const Harpoonist := UnitType.Value.HARPOONIST
const Coral := ResourceType.Value.CORAL


## The assault of "Nacre", seen from the side [param defending] says.
func _entry(victory: bool, defending: bool, post: Variant = null, rampart := Vector2i(3, 1)) -> BaseAssaultEntry:
	return BaseAssaultEntry.new(14, victory, defending, "Nacre", HistorySamples.fight(victory),
		{Harpoonist: 6}, {Harpoonist: 4}, {Harpoonist: 1}, {Harpoonist: 1}, rampart.x, rampart.y, 5, 5,
		{Coral: 21}, {Coral: 15}, post)


## Whether the page shows a line that contains [param part].
func _says(page: BaseAssaultSummaryPage, part: String) -> bool:
	for shown in texts(page):
		if shown.contains(part):
			return true
	return false


func _page(entry: BaseAssaultEntry) -> BaseAssaultSummaryPage:
	var page := BaseAssaultSummaryPage.new(entry)
	modals().open(page)
	return page


func test_a_won_attack_tells_the_damage_the_loot_and_the_casualties() -> void:
	var page := _page(_entry(true, false))
	assert_eq(page.title(), "Assaut : Nacre")
	assert_not_null(find_text("VICTOIRE", page))
	assert_not_null(find_text("Vous avez attaqué Nacre", page))
	assert_not_null(find_text("Rempart : niveau 3 → 1", page))
	assert_null(find_text("QG : niveau 5 → 5", page))
	assert_not_null(find_text("Défenseurs mis hors de combat : 4/4", page))
	assert_eq(find_type("FightLootCard", page).size(), 1)
	assert_eq(find_type("RaidPillageCard", page).size(), 0)
	assert_eq(find_type("FightUnitAccounting", page).size(), 1)
	assert_eq(find_type("FightTurnTile", page).size(), page.fight.turn_summaries.size())
	assert_no_raw_keys(page)


func test_a_lost_attack_shows_no_damage_and_no_loot() -> void:
	var page := _page(_entry(false, false))
	assert_not_null(find_text("DÉFAITE", page))
	assert_null(find_text("Rempart : niveau 3 → 1", page))
	assert_eq(find_type("FightLootCard", page).size(), 0)


func test_the_defender_reads_the_same_fight_from_its_side() -> void:
	var page := _page(_entry(true, true))
	assert_not_null(find_text("DÉFAITE", page))
	assert_not_null(find_text("Nacre vous a attaqué", page))
	assert_not_null(find_text("Rempart : niveau 3 → 1", page))
	assert_eq(find_type("RaidPillageCard", page).size(), 1)
	assert_eq(find_type("FightLootCard", page).size(), 0)


func test_a_repelled_attack_is_a_victory_for_the_defender() -> void:
	assert_not_null(find_text("VICTOIRE", _page(_entry(false, true))))


func test_a_won_attack_that_broke_nothing_says_the_base_held() -> void:
	var page := _page(_entry(true, false, null, Vector2i(0, 0)))
	assert_not_null(find_text("La base tient bon", page))


func test_the_headquarters_are_told_when_they_were_razed() -> void:
	var entry := _entry(true, false, null, Vector2i(0, 0))
	entry.headquarters_after = 4
	assert_not_null(find_text("QG : niveau 5 → 4", _page(entry)))


func test_each_side_reads_the_fate_of_a_post_in_its_own_words() -> void:
	var taken := _page(_entry(true, false, "faille:1"))
	assert_true(_says(taken, "est à vous"))
	assert_null(find_text("Rempart : niveau 3 → 1", taken))
	assert_eq(find_type("FightLootCard", taken).size(), 0)
	taken.close()
	var lost := _page(_entry(true, true, "faille:1"))
	assert_true(_says(lost, "est perdue"))
	assert_no_raw_keys(lost)


func test_a_post_that_held_says_nothing_of_it() -> void:
	var page := _page(_entry(false, false, "faille:1"))
	assert_eq(find_type("AssaultLineCard", page).size(), 1, "only who attacked")


func test_a_kernel_that_only_lost_a_level_says_which() -> void:
	var page := _page(_entry(true, false, AttackHeldKernelAction.KERNEL_CODE, Vector2i(2, 1)))
	assert_not_null(find_text("Noyau : niveau 2 → 1", page))
	assert_false(_says(page, "Le Noyau est"))


func test_the_attacker_who_takes_the_kernel_is_told_to_build_it() -> void:
	var page := _page(_entry(true, false, AttackHeldKernelAction.KERNEL_CODE, Vector2i(2, 0)))
	assert_true(_says(page, "Le Noyau est à vous"))


func test_the_defender_who_loses_the_kernel_loses_its_garrison() -> void:
	var page := _page(_entry(true, true, AttackHeldKernelAction.KERNEL_CODE, Vector2i(2, 0)))
	assert_true(_says(page, "Le Noyau est perdu"))


func test_the_guardians_of_a_faille_are_named_in_the_language_on() -> void:
	var entry := _entry(true, true)
	entry.opponent_name = LeviathanForce.ATTACKER_NAME
	var page := _page(entry)
	assert_eq(page.title(), "Assaut : %s" % Texts.t(&"leviathanAttackerName"))
	use_language("en")
	assert_eq(page.title(), "Assault: %s" % Texts.t(&"leviathanAttackerName"))
	assert_not_null(find_text("Back to the map", page))
	use_language("es")
	assert_no_raw_keys(page)


func test_back_to_the_map_ends_the_page() -> void:
	var closed := []
	var page := _page(_entry(true, false))
	page.closed.connect(closed.append)
	press("Retour à la carte")
	assert_eq(closed, [null])

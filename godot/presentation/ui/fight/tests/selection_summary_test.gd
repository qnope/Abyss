extends UiTestCase
## The totals of an army before a fight and the buttons under it
## (test/presentation/widgets/fight/selection_summary_card_test.dart and
## the totals of army_selection_screen_test.dart).

const Harpoonist := UnitType.Value.HARPOONIST
const Scout := UnitType.Value.SCOUT


func _boost(military_level: int) -> UnitBoost:
	return ArmySelectionSummary.boost_of(ActionSamples.fight_player({}, military_level))


func test_the_totals_are_the_stats_of_the_units_picked() -> void:
	var picked: Dictionary[UnitType.Value, int] = {Scout: 2, Harpoonist: 1}
	assert_eq(ArmySelectionSummary.total_atk(picked, UnitBoost.none()), 2 * 2 + 5)
	assert_eq(ArmySelectionSummary.total_def(picked, UnitBoost.none()), 2 * 1 + 2)


func test_a_type_picked_zero_times_counts_for_nothing() -> void:
	var picked: Dictionary[UnitType.Value, int] = {Scout: 0, Harpoonist: -1}
	assert_eq(ArmySelectionSummary.total_atk(picked, UnitBoost.none()), 0)


func test_the_military_research_boosts_the_totals_as_the_fight_does() -> void:
	var boost := _boost(5)
	assert_eq(boost.atk_percent, 95)
	var picked: Dictionary[UnitType.Value, int] = {Harpoonist: 1}
	# 5 * 1.95 = 9.75, rounded.
	assert_eq(ArmySelectionSummary.total_atk(picked, boost), 10)
	assert_eq(ArmySelectionSummary.total_def(picked, boost), boost.def(2))


func test_the_card_shows_the_totals_and_no_bonus_without_research() -> void:
	var card := mount(SelectionSummaryCard.new(UnitBoost.none())) as SelectionSummaryCard
	assert_eq(card.atk_value.text, "0")
	card.show_totals(12, 7)
	assert_eq(card.atk_value.text, "12")
	assert_eq(card.def_value.text, "7")
	assert_eq(card.atk_title.text, "ATK")
	assert_eq(card.def_title.text, "DEF")
	assert_eq(card.bonus_label.text, "Bonus militaire : aucun")
	assert_no_raw_keys()


func test_the_card_lists_every_boost_that_is_not_zero() -> void:
	var card := mount(SelectionSummaryCard.new(UnitBoost.new(30, 10, 20))) as SelectionSummaryCard
	assert_eq(card.bonus_label.text, "Bonus militaire : +30% ATK, +10% DEF, +20% PV")
	card = mount(SelectionSummaryCard.new(UnitBoost.new(0, 30, 0))) as SelectionSummaryCard
	assert_eq(card.bonus_label.text, "Bonus militaire : +30% DEF")
	card = mount(SelectionSummaryCard.new(_boost(3))) as SelectionSummaryCard
	assert_eq(card.bonus_label.text, "Bonus militaire : +75% ATK, +40% DEF")


func test_the_card_follows_the_language() -> void:
	var card := mount(SelectionSummaryCard.new(UnitBoost.new(30, 0, 0))) as SelectionSummaryCard
	use_language("en")
	assert_eq(card.bonus_label.text, "Military bonus: +30% ATK")
	assert_eq(card.atk_title.text, text(&"statAttack"))


func test_the_buttons_launch_or_cancel_and_launching_waits_for_units() -> void:
	var bar := mount(ArmySelectionActions.new(&"fightLaunch")) as ArmySelectionActions
	var told: Array[String] = []
	bar.launch_requested.connect(func() -> void: told.append("launch"))
	bar.cancel_requested.connect(func() -> void: told.append("cancel"))
	assert_true(bar.launch_button.disabled)
	assert_eq(bar.launch_button.text, "Lancer le combat")
	assert_eq(bar.cancel_button.text, "Annuler")
	bar.set_ready(true)
	press("Lancer le combat")
	press("Annuler")
	assert_eq(told, ["launch", "cancel"] as Array[String])
	assert_no_raw_keys()


func test_the_warning_of_a_missing_admiral_shows_when_told() -> void:
	var bar := mount(ArmySelectionActions.new(&"fightLaunchAssault")) as ArmySelectionActions
	assert_false(bar.admiral_label.visible)
	bar.set_admiral_missing(true)
	assert_eq(bar.admiral_label.text, "Un Amiral des Abysses est requis pour lancer l'assaut")
	bar.set_admiral_missing(false)
	assert_false(bar.admiral_label.visible)

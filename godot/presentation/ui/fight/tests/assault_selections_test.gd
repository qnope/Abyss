extends UiTestCase
## test/presentation/screens/game/fight/transition_army_selection_screen_test.dart
## and kernel_army_selection_screen_test.dart: the pages where the army of an
## assault is picked.

const Scout := UnitType.Value.SCOUT
const Admiral := UnitType.Value.ABYSS_ADMIRAL

var _asked: Array[Dictionary] = []


func _confirm(picks: Dictionary[UnitType.Value, int]) -> ActionResult:
	_asked.append(picks)
	return ActionResult.success()


func _player() -> Player:
	var player := ActionSamples.fight_player({Scout: 3, Admiral: 1})
	player.units_per_level[3] = DomainSamples.units({UnitType.Value.HARPOONIST: 2, Admiral: 1})
	return player


func test_the_transition_page_is_titled_with_the_post_and_lists_its_levels_units() -> void:
	var base := TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille_beta")
	var page := AssaultSelections.transition(_player(), 1, base, _confirm)
	modals().open(page)
	assert_eq(page.title(), "Assaut : %s" % TransitionBaseNameTexts.label("faille_beta"))
	assert_eq(page.rows.keys(), [Scout, Admiral])
	assert_eq(page.actions_bar.launch_button.text, "Lancer l'assaut")
	assert_true(page.actions_bar.admiral_label.visible)
	assert_no_raw_keys(page)


func test_the_kernel_page_picks_among_the_units_of_the_volcano_level() -> void:
	var page := AssaultSelections.kernel(_player(), 3, _confirm)
	modals().open(page)
	assert_eq(page.title(), "Assaut : Noyau Volcanique")
	assert_eq(page.rows.keys(), [UnitType.Value.HARPOONIST, Admiral])


func test_launching_needs_the_admiral_and_asks_with_the_picks() -> void:
	var page := AssaultSelections.kernel(_player(), 3, _confirm)
	modals().open(page)
	page.rows[UnitType.Value.HARPOONIST].set_value(2)
	assert_true(page.actions_bar.launch_button.disabled)
	page.rows[Admiral].set_value(1)
	press("Lancer l'assaut")
	assert_eq(_asked, [{UnitType.Value.HARPOONIST: 2, Admiral: 1}] as Array[Dictionary])
	assert_true(page.is_closed())


func test_a_plan_is_shown_before_the_rows() -> void:
	var plan := Label.new()
	var base := TransitionBase.new(TransitionBaseType.Value.CHEMINEE, "cheminee_primary")
	var page := AssaultSelections.transition(_player(), 1, base, _confirm, plan)
	modals().open(page)
	assert_eq(page.body.get_child(0), plan)


func test_the_title_follows_the_language() -> void:
	var page := AssaultSelections.kernel(_player(), 3, _confirm)
	modals().open(page)
	use_language("en")
	assert_eq(page.title(), "Assault: Volcanic Core")

extends UiTestCase
## test/presentation/widgets/map/rival_post_sheet_test.dart (and
## map_visuals_posts_test.dart): a post another player holds, and the attack
## button, off with the reason while the attack is refused.

var _attacks := 0


func _sheet(base: TransitionBase, refusal: Variant = null) -> RivalPostSheet:
	var sheet := RivalPostSheet.new(base, "Horde", refusal)
	sheet.attack_requested.connect(func() -> void: _attacks += 1)
	modals().open(sheet)
	return sheet


func _faille() -> TransitionBase:
	return TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille_alpha", "faction-x")


func test_the_sheet_names_the_post_and_who_holds_it() -> void:
	var sheet := _sheet(_faille())
	assert_eq(sheet.title_label.text, TransitionBaseNameTexts.label("faille_alpha"))
	assert_eq(sheet.held_label.text, "Tenue par Horde")
	assert_false(sheet.failure_label.visible)
	var portrait := find_type("Portrait", sheet)[0] as Portrait
	assert_eq(portrait.initials_label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_PINK, "lit as a rival's")
	assert_no_raw_keys(sheet)


func test_the_attack_closes_the_sheet_and_tells_it_once() -> void:
	var sheet := _sheet(_faille())
	press("Attaquer")
	assert_eq(_attacks, 1)
	assert_true(sheet.is_closed())


func test_a_refusal_is_told_and_switches_the_attack_off() -> void:
	var sheet := _sheet(_faille(), ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_true(sheet.failure_label.visible)
	assert_eq(sheet.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.NOT_ENOUGH_UNITS))
	assert_true(sheet.attack_button.disabled)
	assert_eq(_attacks, 0)
	assert_no_raw_keys(sheet)


func test_without_a_post_it_is_the_kernel_that_is_held() -> void:
	var sheet := _sheet(null)
	assert_eq(sheet.title_label.text, "Noyau Volcanique")
	assert_eq(sheet.held_label.text, "Tenue par Horde")


func test_cancelling_attacks_nothing() -> void:
	var sheet := _sheet(_faille())
	press("Annuler")
	assert_true(sheet.is_closed())
	assert_eq(_attacks, 0)


func test_the_sheet_follows_the_language() -> void:
	var sheet := _sheet(_faille(), ActionFailure.Value.NOT_ENOUGH_UNITS)
	use_language("en")
	assert_eq(sheet.held_label.text, "Held by Horde")
	assert_eq(sheet.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.NOT_ENOUGH_UNITS))
	assert_no_raw_keys(sheet)

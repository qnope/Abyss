extends UiTestCase
## The top of a target's panel (tech_target_panel_test.dart).

const Branch := TechBranch.Value

var _acts := 0


func _header(target: TechTarget, with_button := true, can_act := true) -> TechTargetHeader:
	var header := TechTargetHeader.new(target, with_button, can_act)
	header.act_pressed.connect(func() -> void: _acts += 1)
	return mount(header) as TechTargetHeader


func test_a_branch_shows_its_emblem_name_and_description() -> void:
	var header := _header(TechTarget.new(Branch.MILITARY))
	assert_eq(header.title_label.text, "Militaire")
	assert_eq(header.subtitle_label.text, TechBranchTexts.description(Branch.MILITARY))
	assert_eq(header.title_label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_PINK)
	assert_eq(header.icon.icon_path, UiIcon.glyph_path(&"shield"))
	assert_eq(header.act_button.text, "Débloquer")


func test_a_tier_shows_its_icon_name_and_effect() -> void:
	var header := _header(TechTarget.new(Branch.RESOURCES, 3))
	assert_eq(header.title_label.text, TechNodeTexts.node_name(Branch.RESOURCES, 3))
	assert_eq(header.subtitle_label.text,
		"Ressources · Niveau 3 · %s" % TechNodeTexts.node_effect(Branch.RESOURCES, 3))
	assert_eq(header.icon.icon_path, "res://assets/icons/tech/resources_3.svg")
	assert_eq(header.act_button.text, "Rechercher")


func test_a_choice_has_a_title_and_the_warning_and_no_icon() -> void:
	var header := _header(TechTarget.new(Branch.MILITARY, 2), false)
	assert_eq(header.title_label.text, "Militaire · Niveau 2 · Choix")
	assert_eq(header.subtitle_label.text, "Une seule option par partie, l'autre sera perdue.")
	assert_null(header.icon)
	assert_null(header.act_button)


func test_the_button_is_pressed_or_dark() -> void:
	var header := _header(TechTarget.new(Branch.EXPLORER, 1))
	press("Rechercher")
	assert_eq(_acts, 1)
	var dark := _header(TechTarget.new(Branch.EXPLORER, 1), true, false)
	assert_true(dark.act_button.disabled)


func test_a_target_done_has_no_button() -> void:
	assert_null(_header(TechTarget.new(Branch.EXPLORER, 1), false).act_button)


func test_follows_the_language() -> void:
	use_language("en")
	var header := _header(TechTarget.new(Branch.MILITARY, 2), false)
	assert_eq(header.title_label.text, "Military · Level 2 · Choice")
	assert_eq(header.subtitle_label.text, "Only one option per game, the other will be lost.")
	assert_no_raw_keys(header)

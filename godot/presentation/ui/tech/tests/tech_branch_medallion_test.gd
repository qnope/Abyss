extends UiTestCase
## The emblem of a branch (tech_branch_medallion_test.dart).

const Branch := TechBranch.Value

var _taps := 0


func _medallion(branch: TechBranch.Value, unlocked: bool, level := 0) -> TechBranchMedallion:
	var medallion := TechBranchMedallion.new(branch, unlocked, level)
	medallion.tapped.connect(func() -> void: _taps += 1)
	return mount(medallion) as TechBranchMedallion


func test_an_unlocked_branch_shows_its_emblem_in_colour_with_its_level() -> void:
	var medallion := _medallion(Branch.MILITARY, true, 3)
	assert_null(medallion.icon.material)
	assert_eq(medallion.icon.self_modulate, AbyssColors.BIOLUM_PINK)
	assert_null(medallion.lock_icon)
	assert_eq(medallion.name_label.text, "Militaire")
	assert_eq(medallion.name_label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_PINK)
	assert_eq(medallion.level_label.text, "Niv. 3")


func test_a_locked_branch_is_grey_with_a_padlock_and_no_level() -> void:
	var medallion := _medallion(Branch.EXPLORER, false)
	assert_not_null(medallion.icon.material)
	assert_not_null(medallion.lock_icon)
	assert_eq(medallion.lock_icon.icon_path, UiIcon.glyph_path(&"lock"))
	assert_eq(medallion.name_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	assert_eq(medallion.level_label.text, "", "no level, but the room of one")
	assert_null(find_text("Niv. 0"))


func test_each_branch_has_its_name_and_emblem() -> void:
	assert_eq(_medallion(Branch.RESOURCES, true).name_label.text, "Ressources")
	assert_eq(_medallion(Branch.RESOURCES, true).icon.icon_path, ResourceIcon.path_for(ResourceType.Value.ALGAE))
	assert_eq(_medallion(Branch.EXPLORER, true).name_label.text, "Explorateur")


func test_a_touch_tells_it() -> void:
	press(_medallion(Branch.MILITARY, false).tap_button)
	assert_eq(_taps, 1)


func test_follows_the_language_when_built_again() -> void:
	use_language("en")
	assert_eq(_medallion(Branch.MILITARY, true, 1).level_label.text, "Lv. 1")
	assert_no_raw_keys()

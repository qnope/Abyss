extends TestCase
## The chips of the level selector: small buttons, the lit one filled with cyan.

const CYAN := AbyssColors.BIOLUM_CYAN

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssButtonTheme.apply(_theme)
	AbyssChipTheme.apply(_theme)


func _box(state: String, type: StringName) -> StyleBoxFlat:
	return _theme.get_stylebox(state, type) as StyleBoxFlat


func test_chips_are_variations_of_the_button() -> void:
	assert_eq(_theme.get_type_variation_base(AbyssChipTheme.CHIP), &"Button")
	assert_eq(_theme.get_type_variation_base(AbyssChipTheme.ACTIVE), &"Button")


func test_a_chip_lies_on_the_dim_surface_in_cyan_ink() -> void:
	var normal := _box("normal", AbyssChipTheme.CHIP)
	assert_eq(normal.bg_color, AbyssColors.SURFACE_DIM)
	assert_eq(normal.corner_radius_top_left, 8)
	assert_eq(normal.content_margin_left, 8.0)
	assert_eq(normal.content_margin_top, 8.0)
	assert_eq(_theme.get_color("font_color", AbyssChipTheme.CHIP), CYAN)


func test_the_chip_on_show_is_filled_with_cyan() -> void:
	assert_eq(_box("normal", AbyssChipTheme.ACTIVE).bg_color, CYAN)
	assert_eq(_theme.get_color("font_color", AbyssChipTheme.ACTIVE), AbyssColors.ABYSS_BLACK)


func test_a_chip_that_cannot_be_chosen_is_darker_with_its_ink_off() -> void:
	assert_eq(_box("disabled", AbyssChipTheme.CHIP).bg_color, AbyssColors.TRENCH)
	assert_eq(_theme.get_color("font_disabled_color", AbyssChipTheme.CHIP), AbyssColors.DISABLED)
	assert_eq(_theme.get_color("icon_disabled_color", AbyssChipTheme.CHIP), AbyssColors.DISABLED)


func test_sets_the_label_at_13() -> void:
	assert_eq(_theme.get_font_size("font_size", AbyssChipTheme.CHIP), 13)
	assert_eq(_theme.get_font_size("font_size", AbyssChipTheme.ACTIVE), 13)


func test_is_part_of_the_game_theme() -> void:
	assert_eq(AbyssTheme.build().get_type_variation_base(AbyssChipTheme.CHIP), &"Button")

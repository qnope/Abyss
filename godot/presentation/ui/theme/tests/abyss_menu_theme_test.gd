extends TestCase
## The full-screen menus of abyss_menu_theme.dart: the glowing title, the
## large menu buttons and the footnote.

const CYAN := AbyssColors.BIOLUM_CYAN

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssMenuTheme.apply(_theme)


func test_the_hero_title_glows_in_widely_spaced_capitals() -> void:
	_check_text("HeroTitle", AbyssFonts.BOLD, 60, CYAN, 10)
	# Flutter's tight shadow (80 %, blur 16) as the outline, its wide one
	# (45 %, blur 40) as the shadow: half as wide, a third as opaque.
	_check_halo("HeroTitle", Color(CYAN, 0.15), 20)
	_assert_near(_theme.get_color("font_outline_color", "HeroTitle"), Color(CYAN, 0.8 / 3))
	assert_eq(_theme.get_constant("outline_size", "HeroTitle"), 8)


func test_the_hero_subtitle_is_misty_over_a_dark_halo() -> void:
	_check_text("HeroSubtitle", AbyssFonts.MEDIUM, 15, AbyssColors.ABYSS_MIST, 3)
	_check_halo("HeroSubtitle", Color(AbyssColors.ABYSS_BLACK, 0.8 / 3), 3)


func test_a_primary_menu_button_glows_cyan() -> void:
	var normal := _box("normal", "MenuPrimaryButton")
	assert_eq(normal.bg_color, AbyssMenuTheme.PRIMARY_FILL)
	assert_eq(normal.corner_radius_top_left, 12)
	assert_eq(normal.shadow_color, Color(CYAN, 0.5))
	assert_eq(normal.shadow_size, 24)
	assert_eq(normal.content_margin_left, 16.0)
	assert_eq(normal.content_margin_top, 10.0)
	assert_eq(_theme.get_color("font_color", "MenuPrimaryButton"), AbyssColors.DEEP_NAVY)
	var middle := AbyssColors.BIOLUM_CYAN_LIGHT.lerp(AbyssColors.BIOLUM_CYAN_DEEP, 0.5)
	assert_true(AbyssMenuTheme.PRIMARY_FILL.is_equal_approx(middle))


func test_an_outlined_menu_button_is_dark_glass_rimmed_with_cyan() -> void:
	var normal := _box("normal", "MenuOutlinedButton")
	assert_eq(normal.bg_color, Color(AbyssColors.ABYSS_BLACK, 0.6))
	assert_eq(normal.border_color, Color(CYAN, 0.9))
	assert_eq(normal.border_width_top, 2)
	assert_eq(_theme.get_color("font_color", "MenuOutlinedButton"), CYAN)


func test_the_label_drawn_over_a_menu_button_is_written_as_the_button_s() -> void:
	for pair: Array in [["MenuButtonLabel", CYAN], ["MenuPrimaryLabel", AbyssColors.DEEP_NAVY]]:
		var type: String = pair[0]
		assert_eq(_theme.get_type_variation_base(type), &"Label", type)
		var font := _theme.get_font("font", type) as FontVariation
		assert_eq(font.base_font, AbyssFonts.BOLD, type)
		assert_eq(font.spacing_glyph, 3, type)
		assert_eq(_theme.get_font_size("font_size", type), 20, type)
		assert_eq(_theme.get_color("font_color", type), pair[1], type)


func test_a_menu_button_label_is_large_spaced_capitals() -> void:
	for type: String in ["MenuPrimaryButton", "MenuOutlinedButton"]:
		assert_eq(_theme.get_type_variation_base(type), &"Button", type)
		var font := _theme.get_font("font", type) as FontVariation
		assert_eq(font.base_font, AbyssFonts.BOLD, type)
		assert_eq(font.spacing_glyph, 3, type)
		assert_eq(_theme.get_font_size("font_size", type), 20, type)
	assert_eq(AbyssMenuTheme.BUTTON_MIN_HEIGHT, 56.0)
	assert_eq(AbyssMenuTheme.BUTTON_GAP, 12.0)


func test_the_small_print_of_the_menus() -> void:
	_check_text("MenuButtonSubtitle", ThemeDB.fallback_font, 13, AbyssColors.ON_SURFACE_DIM)
	_check_text(
		"MenuPrimarySubtitle", ThemeDB.fallback_font, 13, Color(AbyssColors.DEEP_NAVY, 0.75)
	)
	_check_text("Footnote", ThemeDB.fallback_font, 13, AbyssColors.ON_SURFACE_DIM)
	_check_halo("Footnote", Color(AbyssColors.ABYSS_BLACK, 0.3), 2)
	assert_eq(_theme.get_font("font", "BadgeLabel"), AbyssFonts.BOLD)
	assert_eq(_theme.get_font_size("font_size", "BadgeLabel"), 14)
	# Its colour is the ink of the button it sits on.
	assert_false(_theme.has_color("font_color", "BadgeLabel"))
	assert_eq(AbyssMenuTheme.CORNER_ICON, AbyssColors.ABYSS_MIST)


func _box(state: StringName, type: StringName) -> StyleBoxFlat:
	return _theme.get_stylebox(state, type) as StyleBoxFlat


func _check_halo(type: StringName, color: Color, size: int) -> void:
	_assert_near(_theme.get_color("font_shadow_color", type), color)
	assert_eq(_theme.get_constant("shadow_offset_x", type), 0, type)
	assert_eq(_theme.get_constant("shadow_offset_y", type), 0, type)
	assert_eq(_theme.get_constant("shadow_outline_size", type), size, type)


func _assert_near(actual: Color, expected: Color) -> void:
	assert_true(actual.is_equal_approx(expected), "expected %s, got %s" % [expected, actual])


func _check_text(type: StringName, base: Font, size: int, color: Color, spacing := 0) -> void:
	assert_eq(_theme.get_type_variation_base(type), &"Label", type)
	var font := _theme.get_font("font", type)
	var variation := font as FontVariation
	assert_eq(variation.base_font if variation else font, base, type)
	assert_eq(variation.spacing_glyph if variation else 0, spacing, type)
	assert_eq(_theme.get_font_size("font_size", type), size, type)
	assert_eq(_theme.get_color("font_color", type), color, type)

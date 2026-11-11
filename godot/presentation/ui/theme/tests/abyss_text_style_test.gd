extends TestCase
## A text style picks its Rajdhani weight, spaces its letters and sets
## its size and colour on a theme type.

const RAJDHANI := "res://assets/fonts/rajdhani/Rajdhani-%s.ttf"


func test_picks_the_rajdhani_file_of_each_weight() -> void:
	assert_eq(AbyssFonts.of(AbyssFonts.Weight.MEDIUM).resource_path, RAJDHANI % "Medium")
	assert_eq(AbyssFonts.of(AbyssFonts.Weight.SEMI_BOLD).resource_path, RAJDHANI % "SemiBold")
	assert_eq(AbyssFonts.of(AbyssFonts.Weight.BOLD).resource_path, RAJDHANI % "Bold")


func test_leaves_the_regular_weight_to_the_default_font() -> void:
	assert_eq(AbyssFonts.of(AbyssFonts.Weight.DEFAULT), ThemeDB.fallback_font)


func test_spaces_the_letters_by_whole_pixels() -> void:
	var font := AbyssFonts.of(AbyssFonts.Weight.BOLD, 1.5) as FontVariation
	assert_eq(font.base_font, AbyssFonts.BOLD)
	assert_eq(font.spacing_glyph, 2)
	var tight := AbyssFonts.of(AbyssFonts.Weight.DEFAULT, 1.2) as FontVariation
	assert_eq(tight.base_font, ThemeDB.fallback_font)
	assert_eq(tight.spacing_glyph, 1)


func test_keeps_its_values() -> void:
	var style := AbyssTextStyle.new(18, AbyssFonts.Weight.SEMI_BOLD, Color.RED, 1.5)
	assert_eq(style.size, 18)
	assert_eq(style.weight, AbyssFonts.Weight.SEMI_BOLD)
	assert_eq(style.color, Color.RED)
	assert_eq(style.letter_spacing, 1.5)
	assert_eq(AbyssTextStyle.new(12, AbyssFonts.Weight.BOLD, Color.RED).letter_spacing, 0.0)


func test_leans_a_font_as_flutters_italic() -> void:
	var style := AbyssTextStyle.new(14, AbyssFonts.Weight.DEFAULT, Color.RED)
	assert_eq(style.slant, 0.0)
	assert_eq(style.font(), ThemeDB.fallback_font, "upright by default")
	style.slant = 0.2
	var leaning := style.font() as FontVariation
	assert_eq(leaning.base_font, ThemeDB.fallback_font)
	assert_eq(leaning.variation_transform.y, Vector2(0.2, 1.0))
	assert_eq(leaning.variation_transform.x, Vector2(1.0, 0.0))


func test_sets_its_font_size_and_colour_on_a_theme_type() -> void:
	var theme := Theme.new()
	AbyssTextStyle.new(18, AbyssFonts.Weight.BOLD, Color.RED).apply_to(theme, "Label")
	assert_eq(theme.get_font("font", "Label"), AbyssFonts.BOLD)
	assert_eq(theme.get_font_size("font_size", "Label"), 18)
	assert_eq(theme.get_color("font_color", "Label"), Color.RED)

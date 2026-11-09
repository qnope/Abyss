extends TestCase
## The roles of abyss_text_theme.dart, as Label variations: font weight,
## size, colour and letter spacing.

const D := AbyssFonts.Weight.DEFAULT
const M := AbyssFonts.Weight.MEDIUM
const S := AbyssFonts.Weight.SEMI_BOLD
const B := AbyssFonts.Weight.BOLD

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssTextTheme.apply(_theme)


func test_ports_the_material_roles() -> void:
	_check("DisplayLarge", B, 40, AbyssColors.BIOLUM_CYAN, 2)
	_check("DisplayMedium", S, 32, AbyssColors.BIOLUM_CYAN)
	_check("DisplaySmall", S, 24, AbyssColors.BIOLUM_TEAL)
	_check("HeadlineLarge", B, 22, AbyssColors.ON_SURFACE)
	_check("HeadlineMedium", S, 20, AbyssColors.ON_SURFACE)
	_check("HeadlineSmall", M, 18, AbyssColors.ON_SURFACE)
	_check("TitleLarge", S, 18, AbyssColors.BIOLUM_CYAN)
	_check("TitleMedium", M, 16, AbyssColors.ON_SURFACE)
	_check("TitleSmall", M, 14, AbyssColors.ON_SURFACE_DIM)
	_check("BodyLarge", D, 16, AbyssColors.ON_SURFACE)
	_check("BodyMedium", D, 14, AbyssColors.ON_SURFACE)
	_check("BodySmall", D, 12, AbyssColors.ON_SURFACE_DIM)
	_check("LabelLarge", S, 14, AbyssColors.ABYSS_BLACK, 1)
	_check("LabelMedium", M, 12, AbyssColors.ON_SURFACE)
	_check("LabelSmall", M, 10, AbyssColors.ON_SURFACE_DIM, 1)


func test_ports_the_named_styles() -> void:
	_check("SectionLabel", B, 13, AbyssColors.ON_SURFACE_DIM, 3)
	_check("PillLabel", B, 11, AbyssColors.ON_SURFACE, 1)


func test_a_plain_label_reads_as_body_medium() -> void:
	assert_eq(_theme.default_font_size, 14)
	assert_false(_theme.has_font("font", "Label"))
	assert_eq(_theme.get_font_size("font_size", "Label"), 14)
	assert_eq(_theme.get_color("font_color", "Label"), AbyssColors.ON_SURFACE)


func test_a_label_takes_a_role_by_its_variation() -> void:
	var label := Label.new()
	label.theme = _theme
	label.theme_type_variation = &"TitleLarge"
	(Engine.get_main_loop() as SceneTree).root.add_child(label)
	assert_eq(label.get_theme_font_size("font_size"), 18)
	assert_eq(label.get_theme_color("font_color"), AbyssColors.BIOLUM_CYAN)
	assert_eq(label.get_theme_font("font"), AbyssFonts.SEMI_BOLD)
	label.free()


func _check(
	role: StringName, weight: AbyssFonts.Weight, size: int, color: Color, spacing := 0
) -> void:
	assert_eq(_theme.get_type_variation_base(role), &"Label", role)
	assert_eq(_theme.get_font_size("font_size", role), size, role)
	assert_eq(_theme.get_color("font_color", role), color, role)
	var font := _theme.get_font("font", role)
	var variation := font as FontVariation
	assert_eq(variation.base_font if variation else font, AbyssFonts.of(weight), role)
	assert_eq(variation.spacing_glyph if variation else 0, spacing, role)

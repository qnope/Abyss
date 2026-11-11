extends TestCase
## The panels of abyss_card_theme.dart: the card as the plain
## PanelContainer, the dialog, the bottom sheet, the app bar and the save
## panels as its variations.

const CYAN := AbyssColors.BIOLUM_CYAN

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssCardTheme.apply(_theme)


func test_a_plain_panel_is_a_card() -> void:
	var card := _panel("PanelContainer")
	assert_eq(card.bg_color, AbyssColors.SURFACE_LIGHT)
	assert_eq(card.corner_radius_top_left, 16)
	assert_eq(card.border_color, Color(CYAN, 0.15))
	assert_eq(card.border_width_left, 1)
	assert_eq(card.shadow_color, Color(CYAN, 0.15 * 0.25))
	assert_eq(card.shadow_size, 4)
	assert_eq(card.content_margin_left, 16.0)


func test_a_dialog_is_a_rimmed_deep_navy_panel() -> void:
	var dialog := _panel("DialogPanel")
	assert_eq(dialog.bg_color, AbyssColors.DEEP_NAVY)
	assert_eq(dialog.corner_radius_bottom_left, 20)
	assert_eq(dialog.border_color, Color(CYAN, 0.2))
	assert_eq(dialog.content_margin_top, 24.0)
	assert_eq(_theme.get_type_variation_base("DialogTitle"), &"Label")
	assert_eq(_theme.get_font_size("font_size", "DialogTitle"), 20)
	assert_eq(_theme.get_color("font_color", "DialogTitle"), CYAN)


func test_a_bottom_sheet_rounds_its_top() -> void:
	var sheet := _panel("BottomSheetPanel")
	assert_eq(sheet.bg_color, AbyssColors.DEEP_NAVY)
	assert_eq(sheet.corner_radius_top_right, 24)
	assert_eq(sheet.corner_radius_bottom_right, 0)
	assert_eq(AbyssCardTheme.DRAG_HANDLE, Color(CYAN, 0.5))
	assert_eq(AbyssCardTheme.SHEET_HANDLE, Color(AbyssColors.ON_SURFACE, 0.3))
	assert_eq(AbyssCardTheme.HANDLE_SIZE, Vector2i(40, 4))
	assert_eq(AbyssCardTheme.HANDLE_PADDING, Vector2i(8, 4))


func test_an_app_bar_is_a_dark_veil_with_a_spaced_title() -> void:
	var bar := _panel("AppBarPanel")
	assert_eq(bar.bg_color, Color(AbyssColors.ABYSS_BLACK, 0.9))
	assert_eq(bar.corner_radius_top_left, 0)
	var font := _theme.get_font("font", "AppBarTitle") as FontVariation
	assert_eq(font.base_font, AbyssFonts.BOLD)
	assert_eq(font.spacing_glyph, 2)
	assert_eq(_theme.get_font_size("font_size", "AppBarTitle"), 20)
	assert_eq(_theme.get_color("font_color", "AppBarTitle"), CYAN)


func test_a_save_panel_glows_when_highlighted_and_dims_when_faded() -> void:
	var fill := Color(AbyssColors.SURFACE_LIGHT, 0.78)
	var plain := _panel("SavePanel")
	assert_eq(plain.bg_color, fill)
	assert_eq(plain.corner_radius_top_left, AbyssCardTheme.SAVE_PANEL_RADIUS)
	assert_eq(plain.border_color, Color(CYAN, 0.18))
	assert_eq(plain.border_width_top, 1)
	var lit := _panel("SavePanelHighlighted")
	assert_eq(lit.border_color, Color(CYAN, 0.75))
	assert_eq(lit.border_width_top, 2)
	assert_eq(lit.shadow_color, Color(CYAN, 0.22))
	assert_eq(lit.shadow_size, 18)
	var faded := _panel("SavePanelFaded")
	assert_eq(faded.bg_color, AbyssColors.dimmed(fill))
	assert_eq(faded.border_color, Color(CYAN, 0.08))


func _panel(type: StringName) -> StyleBoxFlat:
	if type != &"PanelContainer":
		assert_eq(_theme.get_type_variation_base(type), &"PanelContainer", type)
	return _theme.get_stylebox("panel", type) as StyleBoxFlat

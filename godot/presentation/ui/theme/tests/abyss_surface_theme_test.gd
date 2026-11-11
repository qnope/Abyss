extends TestCase
## The surfaces under and between components: the scrim behind a modal,
## the panel that draws nothing, the button that is only a touch area, the
## divider of Flutter's dividerColor and the scrollbars.

const CYAN := AbyssColors.BIOLUM_CYAN

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssSurfaceTheme.apply(_theme)


func test_the_scrim_dims_what_a_modal_covers() -> void:
	assert_eq(_theme.get_type_variation_base("ModalScrim"), &"Panel")
	var scrim := _theme.get_stylebox("panel", "ModalScrim") as StyleBoxFlat
	assert_eq(scrim.bg_color, Color(0, 0, 0, 0.54))
	assert_eq(scrim.corner_radius_top_left, 0)


func test_a_bare_panel_only_lays_out_its_content() -> void:
	assert_eq(_theme.get_type_variation_base("BarePanel"), &"PanelContainer")
	assert_true(_theme.get_stylebox("panel", "BarePanel") is StyleBoxEmpty)


func test_a_page_is_abyss_black_all_over() -> void:
	assert_eq(_theme.get_type_variation_base("PagePanel"), &"PanelContainer")
	var page := _theme.get_stylebox("panel", "PagePanel") as StyleBoxFlat
	assert_eq(page.bg_color, AbyssColors.ABYSS_BLACK)
	assert_eq(page.content_margin_left, 0.0, "it pads nothing")


func test_a_tap_surface_draws_only_its_feedback() -> void:
	assert_eq(_theme.get_type_variation_base("TapSurface"), &"Button")
	for state: String in ["normal", "disabled", "focus"]:
		assert_true(_theme.get_stylebox(state, "TapSurface") is StyleBoxEmpty, state)
	var hover := _theme.get_stylebox("hover", "TapSurface") as StyleBoxFlat
	assert_eq(hover.bg_color, Color(AbyssColors.ON_SURFACE, 0.08))
	var pressed := _theme.get_stylebox("pressed", "TapSurface") as StyleBoxFlat
	assert_eq(pressed.bg_color, Color(AbyssColors.ON_SURFACE, 0.1))


func test_a_divider_is_a_faint_cyan_line() -> void:
	for type: String in ["HSeparator", "VSeparator"]:
		var line := _theme.get_stylebox("separator", type) as StyleBoxLine
		assert_eq(line.color, Color(CYAN, 0.1), type)
		assert_eq(line.thickness, 1, type)
		assert_eq(line.vertical, type == "VSeparator", type)


func test_a_scrollbar_is_a_thin_cyan_grabber_on_nothing() -> void:
	for type: String in ["VScrollBar", "HScrollBar"]:
		assert_true(_theme.get_stylebox("scroll", type) is StyleBoxEmpty, type)
		var grabber := _theme.get_stylebox("grabber", type) as StyleBoxFlat
		assert_eq(grabber.bg_color, Color(CYAN, 0.3), type)
		assert_eq(grabber.corner_radius_top_left, 3, type)
		assert_eq(grabber.get_minimum_size(), Vector2(6, 6), type)
		var held := _theme.get_stylebox("grabber_pressed", type) as StyleBoxFlat
		assert_eq(held.bg_color, Color(CYAN, 0.6), type)

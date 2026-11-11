extends TestCase
## The fields, progress bars and sliders of abyss_input_theme.dart.

const CYAN := AbyssColors.BIOLUM_CYAN

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssInputTheme.apply(_theme)


func test_a_field_is_filled_and_faintly_rimmed() -> void:
	for type: String in ["LineEdit", "TextEdit"]:
		var normal := _box("normal", type)
		assert_eq(normal.bg_color, AbyssColors.SURFACE_DIM, type)
		assert_eq(normal.corner_radius_top_left, 12, type)
		assert_eq(normal.border_color, Color(CYAN, 0.2), type)
		assert_eq(normal.border_width_left, 1, type)
		assert_eq(normal.content_margin_left, 16.0, type)
		assert_eq(normal.content_margin_top, 14.0, type)


func test_a_focused_field_is_rimmed_with_cyan() -> void:
	for type: String in ["LineEdit", "TextEdit"]:
		var focus := _box("focus", type)
		assert_false(focus.draw_center, type)
		assert_eq(focus.border_color, CYAN, type)
		assert_eq(focus.border_width_top, 2, type)
		assert_eq(focus.corner_radius_top_left, 12, type)


func test_a_read_only_field_has_no_rim() -> void:
	var read_only := _box("read_only", "LineEdit")
	assert_eq(read_only.bg_color, AbyssColors.SURFACE_DIM)
	assert_eq(read_only.border_width_top, 0)


func test_writes_body_large_with_a_cyan_caret() -> void:
	for type: String in ["LineEdit", "TextEdit"]:
		assert_eq(_theme.get_font_size("font_size", type), 16, type)
		assert_eq(_theme.get_color("font_color", type), AbyssColors.ON_SURFACE, type)
		assert_eq(
			_theme.get_color("font_placeholder_color", type),
			Color(AbyssColors.ON_SURFACE_DIM, 0.6), type
		)
		assert_eq(_theme.get_color("caret_color", type), CYAN, type)
		assert_eq(_theme.get_color("selection_color", type), Color(CYAN, 0.4), type)
	assert_eq(
		_theme.get_color("font_uneditable_color", "LineEdit"),
		Color(AbyssColors.ON_SURFACE, 0.38)
	)


func test_a_field_in_error_is_rimmed_in_red() -> void:
	assert_eq(_theme.get_type_variation_base("ErrorLineEdit"), &"LineEdit")
	assert_eq(_box("normal", "ErrorLineEdit").border_color, AbyssColors.ERROR)
	assert_eq(_box("normal", "ErrorLineEdit").border_width_top, 1)
	assert_eq(_box("focus", "ErrorLineEdit").border_color, AbyssColors.ERROR)
	assert_eq(_box("focus", "ErrorLineEdit").border_width_top, 2)


func test_a_progress_bar_fills_a_bright_track_with_cyan() -> void:
	var track := _box("background", "ProgressBar")
	assert_eq(track.bg_color, AbyssColors.SURFACE_BRIGHT)
	assert_eq(track.content_margin_top + track.content_margin_bottom, 4.0)
	assert_eq(_box("fill", "ProgressBar").bg_color, CYAN)


func test_the_noise_gauge_fills_a_trench_track_with_warning() -> void:
	assert_eq(_theme.get_type_variation_base(AbyssInputTheme.NOISE_GAUGE), &"ProgressBar")
	assert_eq(_box("background", AbyssInputTheme.NOISE_GAUGE).bg_color, AbyssColors.TRENCH)
	assert_eq(_box("fill", AbyssInputTheme.NOISE_GAUGE).bg_color, AbyssColors.WARNING)


func test_a_slider_lights_its_track_up_to_a_cyan_thumb() -> void:
	assert_eq(_box("slider", "HSlider").bg_color, AbyssColors.SURFACE_BRIGHT)
	assert_eq(_box("grabber_area", "HSlider").bg_color, CYAN)
	assert_eq(_box("grabber_area_highlight", "HSlider").bg_color, CYAN)
	var thumb := _theme.get_icon("grabber", "HSlider")
	assert_eq(thumb.get_width(), 20)
	assert_eq(_theme.get_icon("grabber_highlight", "HSlider"), thumb)


func _box(state: StringName, type: StringName) -> StyleBoxFlat:
	return _theme.get_stylebox(state, type) as StyleBoxFlat

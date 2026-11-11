extends UiTestCase
## The notice at the top of a dialog and the threat strip under the resource
## bar.

const WARNING := AbyssColors.WARNING


func test_a_notice_tints_a_box_and_its_text_with_one_colour() -> void:
	var banner := mount(NoticeBanner.new(UiIcon.glyph_path(&"warning"), WARNING, "Prudence")) as NoticeBanner
	var box := banner.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.bg_color, Color(WARNING, 0.15))
	assert_eq(box.border_color, Color(WARNING, 0.5))
	assert_eq(box.corner_radius_top_left, 8)
	assert_eq(box.content_margin_left, 12.0)
	assert_eq(banner.label.text, "Prudence")
	assert_eq(banner.label.theme_type_variation, &"BodySmall")
	assert_eq(banner.label.get_theme_color(&"font_color"), WARNING)
	assert_eq(banner.icon.self_modulate, WARNING)
	assert_eq(banner.icon.icon_path, "res://assets/icons/ui/warning.svg")
	assert_eq(find_text("Prudence"), banner.label)


func test_a_notice_wraps_a_long_text() -> void:
	var banner := mount(NoticeBanner.new(UiIcon.glyph_path(&"info"), WARNING, "Long")) as NoticeBanner
	assert_eq(banner.label.autowrap_mode, TextServer.AUTOWRAP_WORD_SMART)
	assert_eq(banner.label.size_flags_horizontal, Control.SIZE_EXPAND_FILL)


func test_a_threat_shows_its_title_in_its_colour_and_its_detail_under() -> void:
	var banner := mount(_threat(false)) as ThreatBanner
	assert_eq(banner.title_label.text, "Raid imminent")
	assert_eq(banner.title_label.get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_eq(banner.detail_label.text, "Dans 2 tours")
	assert_eq(banner.detail_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE, "plain body text")
	assert_eq(texts(banner), PackedStringArray(["Raid imminent", "Dans 2 tours"]))


func test_a_threat_is_edged_on_surface_dim_in_its_colour() -> void:
	var banner := mount(_threat(false)) as ThreatBanner
	var box := banner.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.bg_color, AbyssColors.SURFACE_DIM)
	assert_eq(box.border_color, AbyssColors.ERROR)
	assert_eq(box.border_width_left, 4)
	assert_eq(box.border_width_top, 0)
	assert_eq(box.content_margin_left, 16.0, "past the edge")
	assert_eq(box.content_margin_top, 6.0)


func test_a_threat_that_opens_nothing_has_no_chevron_and_no_touch() -> void:
	var banner := mount(_threat(false)) as ThreatBanner
	assert_null(banner.tap)
	assert_eq(find_type("TextureRect", banner).size(), 1, "only its icon")
	assert_eq(find_type("Button", banner).size(), 0)


func test_a_tappable_threat_has_a_chevron_and_tells_the_touch() -> void:
	var banner := mount(_threat(true)) as ThreatBanner
	var taps := []
	banner.tapped.connect(func() -> void: taps.append("tapped"))
	var icons := find_type("TextureRect", banner)
	assert_eq((icons[1] as UiIcon).icon_path, "res://assets/icons/ui/chevron_right.svg")
	assert_eq((icons[1] as UiIcon).self_modulate, AbyssColors.ON_SURFACE_DIM)
	assert_eq(banner.tap.theme_type_variation, &"TapSurface")
	assert_eq(banner.tap.accessibility_name, "Raid imminent")
	press(banner.tap)
	assert_eq(taps, ["tapped"])


func _threat(tappable: bool) -> ThreatBanner:
	return ThreatBanner.new(UiIcon.glyph_path(&"warning"), "Raid imminent", "Dans 2 tours",
		AbyssColors.ERROR, tappable)

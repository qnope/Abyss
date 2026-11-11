extends UiTestCase
## test/presentation/widgets/menu/beta_notice_test.dart.


func test_warns_that_the_game_is_a_beta_in_the_language_on() -> void:
	var notice := mount(BetaNotice.new()) as BetaNotice
	assert_eq(notice.version_label.text, "Version bêta %s" % AppVersion.current())
	assert_eq(notice.warning_label.text, "· les sauvegardes peuvent être effacées")
	assert_eq(notice.version_label.get_theme_color(&"font_color"), AbyssColors.WARNING)
	use_language("en")
	assert_eq(notice.version_label.text, "Beta version %s" % AppVersion.current())
	assert_true(notice.warning_label.text.begins_with("· "))
	assert_no_raw_keys()


func test_shows_a_warning_sign_before_the_version() -> void:
	var notice := mount(BetaNotice.new()) as BetaNotice
	var sign_icon := find_type("TextureRect", notice)[0] as UiIcon
	assert_eq(sign_icon.icon_path, UiIcon.glyph_path(&"warning"))
	assert_eq(sign_icon.self_modulate, AbyssColors.WARNING)
	var flow := find_type("HFlowContainer", notice)[0] as HFlowContainer
	assert_eq(flow.alignment, FlowContainer.ALIGNMENT_CENTER)

extends UiTestCase
## test/presentation/widgets/menu/glow_title_test.dart.


func test_shows_the_title_and_the_subtitle_in_capitals() -> void:
	var title := mount(GlowTitle.new("ABYSSES", "Les profondeurs vous attendent")) as GlowTitle
	assert_eq(texts(title), PackedStringArray(["ABYSSES", "LES PROFONDEURS VOUS ATTENDENT"]))
	assert_eq(title.title_label.theme_type_variation, &"HeroTitle")
	assert_eq(title.subtitle_label.theme_type_variation, &"HeroSubtitle")
	assert_eq(title.title_label.horizontal_alignment, HORIZONTAL_ALIGNMENT_CENTER)


func test_has_no_second_line_without_a_subtitle() -> void:
	var title := mount(GlowTitle.new("ABYSSES")) as GlowTitle
	assert_eq(texts(title), PackedStringArray(["ABYSSES"]))
	title.set_subtitle("Plus bas")
	assert_eq(title.subtitle_label.text, "PLUS BAS")
	assert_true(title.subtitle_label.visible)

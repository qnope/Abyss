extends UiTestCase
## test/presentation/widgets/common/lore_text_test.dart: a line of lore in
## dimmed italics.


func test_tells_the_lore_in_dimmed_italics() -> void:
	var lore := mount(LoreText.new("Les abysses écoutent.")) as LoreText
	assert_eq(lore.text, "Les abysses écoutent.")
	assert_eq(lore.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	var font := lore.get_theme_font(&"font") as FontVariation
	assert_almost_eq(font.variation_transform.y.x, 0.2, 1e-6, "leaning")
	assert_eq(lore.horizontal_alignment, HORIZONTAL_ALIGNMENT_LEFT)
	assert_eq(lore.get_theme_font_size(&"font_size"), 14)


func test_can_be_centered() -> void:
	var lore := mount(LoreText.new("Le Volcan dort.", HORIZONTAL_ALIGNMENT_CENTER)) as LoreText
	assert_eq(lore.horizontal_alignment, HORIZONTAL_ALIGNMENT_CENTER)


func test_dims_and_slants_the_body_size_it_is_given() -> void:
	var small := mount(LoreText.new("La Fosse.", HORIZONTAL_ALIGNMENT_LEFT, LoreText.SMALL)) as LoreText
	var large := mount(LoreText.new("Le Récif.", HORIZONTAL_ALIGNMENT_LEFT, LoreText.LARGE)) as LoreText
	assert_eq(small.get_theme_font_size(&"font_size"), 12)
	assert_eq(large.get_theme_font_size(&"font_size"), 16)
	for lore: LoreText in [small, large]:
		assert_eq(lore.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
		assert_true(lore.get_theme_font(&"font") is FontVariation)


func test_wraps_over_several_lines() -> void:
	var lore := mount(LoreText.new("Long")) as LoreText
	assert_eq(lore.autowrap_mode, TextServer.AUTOWRAP_WORD_SMART)

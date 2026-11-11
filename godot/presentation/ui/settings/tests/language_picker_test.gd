extends UiTestCase
## test/presentation/widgets/common/language_picker_test.dart: automatic and the
## three languages, each named in itself, the current choice checked.

var _chosen: Array[LanguageChoice.Value] = []


func test_offers_automatic_and_the_three_languages() -> void:
	var picker := _picker(LanguageChoice.Value.AUTOMATIC)
	assert_eq(texts(picker), PackedStringArray(
		["Langue", "Automatique", "Langue de l'appareil", "Français", "English", "Español"]))
	assert_no_raw_keys()


func test_names_each_language_in_itself_whatever_the_language_on() -> void:
	var picker := _picker(LanguageChoice.Value.AUTOMATIC)
	use_language("en")
	assert_eq(texts(picker), PackedStringArray(
		["Language", "Automatic", "Device language", "Français", "English", "Español"]))
	use_language("es")
	assert_eq(picker.title_label.text, "Idioma")
	assert_eq(picker.row(LanguageChoice.Value.AUTOMATIC).name_label.text, "Automático")
	assert_eq(picker.row(LanguageChoice.Value.SPANISH).name_label.text, "Español")


func test_marks_the_current_choice_only() -> void:
	var picker := _picker(LanguageChoice.Value.ENGLISH)
	for choice: LanguageChoice.Value in LanguageChoice.Value.values():
		var row := picker.row(choice)
		assert_eq(row.check.visible, choice == LanguageChoice.Value.ENGLISH)
		assert_eq(row.name_label.has_theme_color_override(&"font_color"),
			choice == LanguageChoice.Value.ENGLISH)
	assert_eq(picker.row(LanguageChoice.Value.ENGLISH).name_label.get_theme_color(&"font_color"),
		AbyssColors.BIOLUM_CYAN)


func test_only_automatic_has_a_hint_and_a_taller_row() -> void:
	var picker := _picker(LanguageChoice.Value.AUTOMATIC)
	assert_true(picker.row(LanguageChoice.Value.AUTOMATIC).hint_label.visible)
	assert_false(picker.row(LanguageChoice.Value.FRENCH).hint_label.visible)
	assert_eq(picker.row(LanguageChoice.Value.AUTOMATIC).custom_minimum_size.y, LanguageRow.HINT_HEIGHT)
	assert_eq(picker.row(LanguageChoice.Value.FRENCH).custom_minimum_size.y, LanguageRow.HEIGHT)


func test_a_touch_on_a_language_picks_it_and_checks_it() -> void:
	var picker := _picker(LanguageChoice.Value.AUTOMATIC)
	press("English")
	assert_eq(_chosen, [LanguageChoice.Value.ENGLISH] as Array[LanguageChoice.Value])
	assert_true(picker.row(LanguageChoice.Value.ENGLISH).check.visible)
	assert_false(picker.row(LanguageChoice.Value.AUTOMATIC).check.visible)
	press("English")
	assert_eq(_chosen.size(), 2, "the choice already on is told too")


func test_follows_a_choice_made_elsewhere_without_telling_it() -> void:
	var picker := _picker(LanguageChoice.Value.AUTOMATIC)
	picker.select(LanguageChoice.Value.SPANISH)
	assert_true(picker.row(LanguageChoice.Value.SPANISH).check.visible)
	assert_false(picker.row(LanguageChoice.Value.AUTOMATIC).check.visible)
	assert_eq(_chosen, [] as Array[LanguageChoice.Value])


func test_names_each_row_for_screen_readers() -> void:
	var picker := _picker(LanguageChoice.Value.AUTOMATIC)
	assert_eq(picker.row(LanguageChoice.Value.FRENCH).accessibility_name, "Français")
	assert_eq(picker.row(LanguageChoice.Value.AUTOMATIC).accessibility_name, "Automatique")


func _picker(current: LanguageChoice.Value) -> LanguagePicker:
	var picker := mount(LanguagePicker.new(current)) as LanguagePicker
	picker.language_chosen.connect(func(choice: LanguageChoice.Value) -> void: _chosen.append(choice))
	return picker

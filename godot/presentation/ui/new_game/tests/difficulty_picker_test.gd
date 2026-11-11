extends UiTestCase
## test/presentation/widgets/common/difficulty_picker_test.dart: one segment per
## difficulty, normal first lit, the description of the selected one.

var _changes: Array[Difficulty.Value] = []


func test_offers_the_three_difficulties_with_the_current_one_lit() -> void:
	var picker := _picker(Difficulty.Value.NORMAL)
	assert_eq(texts(picker.bar), PackedStringArray(["Facile", "Normal", "Difficile"]))
	assert_eq(picker.bar.selected(), Difficulty.Value.NORMAL)
	assert_eq(picker.title_label.text, "Difficulté")
	assert_eq(picker.description_label.text, "L'équilibre prévu pour les abysses.")
	assert_no_raw_keys()


func test_a_touch_on_another_level_picks_it_and_describes_it() -> void:
	var picker := _picker(Difficulty.Value.NORMAL)
	press("Difficile")
	assert_eq(_changes, [Difficulty.Value.HARD] as Array[Difficulty.Value])
	assert_eq(picker.current, Difficulty.Value.HARD)
	assert_eq(picker.description_label.text, "Moins de ressources, des monstres plus nombreux.")
	press("Difficile")
	assert_eq(_changes.size(), 1, "the lit level tells nothing")


func test_starts_on_the_difficulty_given() -> void:
	var picker := _picker(Difficulty.Value.EASY)
	assert_eq(picker.bar.selected(), Difficulty.Value.EASY)
	assert_eq(picker.description_label.text, "Plus de ressources, des monstres moins nombreux.")


func test_follows_the_language() -> void:
	var picker := _picker(Difficulty.Value.HARD)
	use_language("en")
	assert_eq(texts(picker.bar), PackedStringArray(["Easy", "Normal", "Hard"]))
	assert_eq(picker.bar.button(Difficulty.Value.EASY).accessibility_name, "Easy")
	assert_eq(picker.title_label.text, "Difficulty")
	assert_eq(picker.description_label.text, DifficultyTexts.description(Difficulty.Value.HARD))


func _picker(current: Difficulty.Value) -> DifficultyPicker:
	var picker := mount(DifficultyPicker.new(current)) as DifficultyPicker
	picker.changed.connect(func(difficulty: Difficulty.Value) -> void: _changes.append(difficulty))
	return picker

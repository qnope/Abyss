extends UiTestCase
## test/presentation/widgets/common/faction_count_picker_test.dart: from 0 to
## 10 factions, one touch at a time.

var _changes: Array[int] = []


func test_shows_the_count_and_what_it_means() -> void:
	var picker := _picker(3)
	assert_eq(picker.title_label.text, "Factions rivales")
	assert_eq(picker.count_label.text, "3")
	assert_eq(picker.description_label.text, "3 factions courent avec toi vers le Volcan")
	assert_no_raw_keys()


func test_one_faction_is_told_in_the_singular() -> void:
	assert_eq(_picker(1).description_label.text, "1 faction court avec toi vers le Volcan")


func test_none_means_playing_alone_against_the_monsters() -> void:
	var picker := _picker(0)
	assert_eq(picker.description_label.text, "Aucune : tu joues seul face aux monstres")


func test_the_buttons_add_and_remove_one() -> void:
	var picker := _picker(3)
	press(picker.plus)
	press(picker.plus)
	press(picker.minus)
	assert_eq(_changes, [4, 5, 4] as Array[int])
	assert_eq(picker.count, 4)
	assert_eq(picker.count_label.text, "4")


func test_cannot_go_below_none_or_above_ten() -> void:
	var picker := _picker(0)
	assert_true(picker.minus.disabled)
	assert_false(picker.plus.disabled)
	assert_eq(picker._minus_icon.self_modulate, AbyssColors.DISABLED)
	picker = _picker(10)
	assert_true(picker.plus.disabled)
	assert_false(picker.minus.disabled)
	assert_eq(picker._plus_icon.self_modulate, AbyssColors.DISABLED)
	assert_eq(picker._minus_icon.self_modulate, AbyssColors.ON_SURFACE)
	assert_eq(_picker(25).count, FactionCountPicker.MAX)


func test_follows_the_language() -> void:
	var picker := _picker(2)
	use_language("en")
	assert_eq(picker.title_label.text, "Rival factions")
	assert_eq(picker.description_label.text, "2 factions race you to the volcano")


func _picker(count: int) -> FactionCountPicker:
	var picker := mount(FactionCountPicker.new(count)) as FactionCountPicker
	picker.changed.connect(func(changed_to: int) -> void: _changes.append(changed_to))
	return picker

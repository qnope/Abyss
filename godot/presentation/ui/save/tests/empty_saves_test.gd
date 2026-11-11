extends UiTestCase
## test/presentation/widgets/save/empty_saves_test.dart: no colony detected, and
## a way to found a first one.

var _requests := 0


func test_tells_that_no_colony_was_detected() -> void:
	var empty := _empty()
	assert_eq(empty.title_label.text, "Aucune colonie détectée")
	assert_eq(empty.message_label.text, "Fondez votre première base dans les abysses.")
	assert_eq(empty.title_label.theme_type_variation, &"HeadlineLarge")
	assert_no_raw_keys()


func test_offers_a_new_game() -> void:
	var empty := _empty()
	assert_eq(empty.new_game_entry.label.text, "NOUVELLE PARTIE")
	press("NOUVELLE PARTIE")
	assert_eq(_requests, 1)


func test_follows_the_language() -> void:
	var empty := _empty()
	use_language("en")
	assert_eq(empty.new_game_entry.label.text, "NEW GAME")
	assert_eq(empty.title_label.text, text(&"saveEmptyTitle"))


func test_stays_within_its_width_in_the_middle() -> void:
	var empty := _empty()
	var column := empty.get_child(0) as Control
	assert_eq(column.custom_minimum_size.x, EmptySaves.MAX_WIDTH)
	assert_eq(column.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	assert_eq(column.size_flags_vertical, Control.SIZE_SHRINK_CENTER)


func _empty() -> EmptySaves:
	var empty := mount(EmptySaves.new()) as EmptySaves
	empty.new_game_requested.connect(func() -> void: _requests += 1)
	return empty

extends UnitTestCase
## test/presentation/widgets/unit/unit_card_test.dart.

const KERNEL := KernelGarrison.STOCK_KEY

var _taps := 0


func _show(counts: Dictionary[int, int] = {1: 0}, unlocked := true, type := Type.SCOUT) -> UnitCard:
	var card := UnitCard.new(type, counts, unlocked)
	mount(card)
	card.tapped.connect(func() -> void: _taps += 1)
	return card


func test_an_unlocked_card_shows_the_name_in_the_colour_of_the_unit() -> void:
	var card := _show()
	assert_not_null(find_text("Éclaireur", card))
	assert_eq(card.name_label.get_theme_color(&"font_color"), UnitColors.of(Type.SCOUT))
	assert_no_raw_keys()


func test_an_unlocked_card_shows_the_count() -> void:
	assert_not_null(find_text("5 unités", _show({1: 5})))


func test_a_locked_card_says_it_is_locked_with_a_padlock() -> void:
	var card := _show({1: 0}, false)
	assert_not_null(find_text("Verrouillé", card))
	assert_not_null(card.lock_icon)
	assert_eq(card.lock_icon.icon_path, UiIcon.glyph_path(&"lock"))
	assert_null(find_text("0 unité", card))


func test_a_locked_card_is_dimmed_and_its_picture_grey() -> void:
	var card := _show({1: 0}, false)
	assert_eq(card.name_label.get_theme_color(&"font_color"), AbyssColors.dimmed(AbyssColors.ON_SURFACE))
	assert_almost_eq(portrait_in(card).modulate.a, AbyssColors.UNAVAILABLE_OPACITY, 1e-5)


func test_an_unlocked_card_has_no_padlock() -> void:
	assert_null(_show().lock_icon)


func test_shows_the_count_at_each_place_when_there_are_several() -> void:
	assert_not_null(find_text("Niv. 1: 5 · Niv. 2: 3", _show({1: 5, 2: 3})))
	assert_not_null(find_text("Niv. 1: 5 · Noyau: 2", _show({1: 5, KERNEL: 2})))


func test_shows_the_simple_count_when_only_one_place_has_units() -> void:
	assert_not_null(find_text("7 unités", _show({1: 7})))
	assert_not_null(find_text("4 unités", _show({1: 4, 2: 0})))


func test_a_touch_tells_it() -> void:
	_show()
	press(UiButtons.under(find_type("Button", host())[0]))
	assert_eq(_taps, 1)


func test_the_card_is_named_for_a_screen_reader() -> void:
	assert_eq(_show().tap_button.accessibility_name, "Éclaireur")


func test_follows_the_language() -> void:
	var card := _show({1: 1})
	use_language("en")
	assert_not_null(find_text("Scout", card))
	assert_not_null(find_text("1 unit", card))
	assert_no_raw_keys()

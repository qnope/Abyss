extends UiTestCase
## test/presentation/widgets/history/history_filter_chips_test.dart.

const Filter := HistoryFilter.Value

var _told: Array[HistoryFilter.Value] = []


func before_each() -> void:
	_told = []


func _chips(current := Filter.ALL) -> HistoryFilterChips:
	var chips := HistoryFilterChips.new(current)
	chips.changed.connect(_told.append)
	return mount(chips) as HistoryFilterChips


func test_one_chip_per_filter_with_french_labels() -> void:
	var chips := _chips()
	assert_eq(texts(chips), PackedStringArray(["Tous", "Combats", "Construction", "Recherche", "Événements", "Autres"]))
	assert_no_raw_keys(chips)


func test_marks_the_current_filter() -> void:
	var chips := _chips(Filter.RESEARCH)
	assert_eq(chips.chips.selected(), Filter.RESEARCH)
	assert_eq(chips.chips.button(Filter.RESEARCH).theme_type_variation, &"")
	assert_eq(chips.chips.button(Filter.ALL).theme_type_variation, &"OutlinedButton")


func test_a_touch_on_a_chip_tells_the_filter() -> void:
	var chips := _chips()
	press("Combats")
	press("Construction")
	assert_eq(_told, [Filter.COMBAT, Filter.BUILDING] as Array[HistoryFilter.Value])
	assert_eq(chips.current, Filter.BUILDING)


func test_a_touch_on_the_current_chip_tells_nothing() -> void:
	_chips(Filter.COMBAT)
	press("Combats")
	assert_eq(_told, [] as Array[HistoryFilter.Value])


func test_select_changes_the_current_filter_without_telling_it() -> void:
	var chips := _chips()
	chips.select(Filter.OTHER)
	assert_eq(chips.current, Filter.OTHER)
	assert_eq(chips.chips.selected(), Filter.OTHER)
	assert_eq(_told, [] as Array[HistoryFilter.Value])


func test_follows_the_language() -> void:
	var chips := _chips()
	use_language("en")
	assert_eq(texts(chips), PackedStringArray(["All", "Combat", "Construction", "Research", "Events", "Other"]))
	assert_eq(chips.chips.button(Filter.EVENT).accessibility_name, "Events")
	use_language("es")
	assert_no_raw_keys(chips)

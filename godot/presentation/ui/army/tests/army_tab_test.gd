extends UiTestCase
## The army tab's 2D part (army_places_view_test.dart, game_screen_army_test.dart):
## the places, what the ground shows at each, the plus of the recruitable.

const Scout := UnitType.Value.SCOUT
const Harpoonist := UnitType.Value.HARPOONIST
const KERNEL := KernelGarrison.STOCK_KEY
const ALL := ArmyPlaces.ALL

var _game: Game
var _rosters: Array[ArmyRoster] = []


## A game of a barracks at level 1 and 500 of every resource, the scouts at
## [param at] (a place and its count each).
func _tab(at: Dictionary[int, int] = {}) -> ArmyTab:
	_game = GameFactory.new_single_player("Nemo", 1)
	var human := _game.human_player()
	human.buildings[BuildingType.Value.BARRACKS].level = 1
	for resource: GameResource in human.resources.values():
		resource.amount = 500
	for place: int in at:
		human.units_per_level[place] = {Scout: Unit.new(Scout, at[place])}
	var tab := ArmyTab.new(_game)
	mount(tab)
	tab.changed.connect(_rosters.append)
	return tab


func _split() -> ArmyTab:
	var tab := _tab({1: 10, 2: 4, KERNEL: 5})
	_game.human_player().units_per_level[2][Harpoonist] = Unit.new(Harpoonist, 2)
	tab.refresh()
	_rosters.clear()
	return tab


func test_shows_the_places_once_the_army_serves_in_two_of_them() -> void:
	var tab := _split()
	assert_true(tab.place_bar.visible)
	assert_eq(tab.roster.counts, {Scout: 19, Harpoonist: 2})
	assert_not_null(find_text("Niv. 2", tab))
	assert_no_raw_keys()


func test_hides_the_places_of_an_army_in_one_place_or_none() -> void:
	assert_false(_tab({1: 10, 2: 0}).place_bar.visible)
	assert_false(_tab().place_bar.visible)


func test_a_place_leaves_on_the_ground_only_the_units_it_holds() -> void:
	var tab := _split()
	press("Niv. 2")
	assert_eq(tab.place, 2)
	assert_eq(tab.roster.counts, {Scout: 4, Harpoonist: 2})
	press("Niv. 1")
	assert_eq(tab.roster.counts, {Scout: 10})
	assert_eq(_rosters.size(), 2, "told each time")


func test_the_plus_shows_under_all_and_where_recruits_arrive() -> void:
	var tab := _split()
	assert_true(tab.roster.recruitable.has(Scout))
	press("Niv. 2")
	assert_eq(tab.roster.recruitable.size(), 0)
	press("Niv. 1")
	assert_true(tab.roster.recruitable.has(Scout))
	press("Toutes")
	assert_true(tab.roster.recruitable.has(Scout))


func test_the_roster_knows_the_barracks_level() -> void:
	assert_eq(_tab().roster.barracks_level, 1)


func test_a_squad_opens_with_the_count_of_the_place_shown() -> void:
	var tab := _split()
	assert_eq(tab.count_of(Harpoonist), 2)
	press("Noyau")
	assert_eq(tab.count_of(Harpoonist), 0)
	assert_eq(tab.count_of(Scout), 5)


func test_back_to_all_once_the_place_shown_is_left_empty() -> void:
	var tab := _split()
	press("Noyau")
	_game.human_player().units_per_level[KERNEL][Scout].count = 0
	tab.refresh()
	assert_eq(tab.place, ALL)
	assert_eq(tab.place_bar.bar.selected(), ALL)
	assert_eq(tab.roster.counts, {Scout: 14, Harpoonist: 2})


func test_back_to_all_when_the_army_is_in_one_place_again() -> void:
	var tab := _split()
	press("Niv. 2")
	var human := _game.human_player()
	human.units_per_level[KERNEL][Scout].count = 0
	human.units_per_level[1][Scout].count = 0
	tab.refresh()
	assert_eq(tab.place, ALL)
	assert_false(tab.place_bar.visible)


func test_tells_the_army_on_each_refresh() -> void:
	var tab := _tab({1: 3})
	_game.human_player().units_per_level[1][Scout].count = 7
	tab.refresh()
	assert_eq(_rosters.size(), 1)
	assert_eq(_rosters[0].count_of(Scout), 7)
	assert_true(_rosters[0] == tab.roster)


func test_the_marks_of_a_recruit_already_made_this_turn_are_gone() -> void:
	var tab := _tab({1: 3})
	_game.human_player().recruited_unit_types.append(Scout)
	tab.refresh()
	assert_false(tab.roster.recruitable.has(Scout))


func test_shows_the_rampart_the_citadel_raises() -> void:
	var tab := _tab()
	assert_false(tab.shield.visible)
	_game.human_player().buildings[BuildingType.Value.CORAL_CITADEL].level = 2
	tab.refresh()
	assert_true(tab.shield.visible)
	assert_not_null(find_text(tab.shield.badge.label.text, tab))


func test_lets_the_touches_through_to_the_world_but_on_the_bar() -> void:
	var tab := _split()
	assert_eq(tab.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	for control: Node in tab.find_children("*", "Control", true, false):
		var filter := (control as Control).mouse_filter
		if filter == Control.MOUSE_FILTER_STOP:
			assert_true(tab.place_bar.is_ancestor_of(control), str(control))


func test_follows_the_language_without_a_rebuild() -> void:
	var tab := _split()
	use_language("en")
	assert_not_null(find_text("All", tab))
	assert_not_null(find_text("Core", tab))

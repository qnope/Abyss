extends TestCase
## test/domain/event/event_drawer_test.dart: when the next random event is
## drawn, and which one.

const Type := RandomEventType.Value
const _SEEDS := 300


func _picks(ended_turn: int, last_drawn: Variant = null, excluded: Array[Type] = []) -> Dictionary:
	var picks := {}
	for seed_value: int in _SEEDS:
		picks[EventDrawer.pick(DartRandom.new(seed_value), ended_turn, last_drawn, _set_of(excluded))] = true
	return picks


func _set_of(types: Array[Type]) -> Dictionary[Type, bool]:
	var members: Dictionary[Type, bool] = {}
	for type: Type in types:
		members[type] = true
	return members


func _turns(draw: Callable) -> Array:
	var turns := {}
	for seed_value: int in _SEEDS:
		turns[draw.call(DartRandom.new(seed_value))] = true
	var sorted := turns.keys()
	sorted.sort()
	return sorted


func test_first_draw_turn_a_new_game_draws_between_turns_5_and_8_all_reachable() -> void:
	assert_eq(_turns(func(random: DartRandom) -> int: return EventDrawer.first_draw_turn(1, random)), [5, 6, 7, 8])
	assert_eq(EventRules.FIRST_DRAW_MIN, 5)
	assert_eq(EventRules.FIRST_DRAW_MAX, 8)


func test_first_draw_turn_a_legacy_save_draws_5_to_8_turns_after_loading() -> void:
	assert_eq(_turns(func(random: DartRandom) -> int: return EventDrawer.first_draw_turn(40, random)), [45, 46, 47, 48])


func test_next_draw_turn_waits_5_to_8_turns_all_reachable() -> void:
	assert_eq(_turns(func(random: DartRandom) -> int: return EventDrawer.next_draw_turn(12, random)), [17, 18, 19, 20])


func test_pick_every_type_can_be_drawn_once_predators_are_allowed() -> void:
	assert_eq(_sorted(_picks(20)), Type.values())


func test_pick_never_draws_the_same_event_twice_in_a_row() -> void:
	for last: Type in Type.values():
		var picks := _picks(20, last)
		assert_false(picks.has(last), DartEnum.name_of(Type, last))
		assert_eq(picks.size(), Type.size() - 1)


func test_pick_honours_the_exclusions() -> void:
	var picks := _picks(20, null, [Type.CARAVAN, Type.WRECK])
	assert_false(picks.has(Type.CARAVAN))
	assert_false(picks.has(Type.WRECK))
	assert_eq(picks.size(), Type.size() - 2)


func test_pick_no_predators_for_an_event_before_turn_10() -> void:
	var early := EventRules.PREDATORS_FIRST_TURN - 2
	assert_false(_picks(early).has(Type.PREDATORS))
	assert_true(_picks(early + 1).has(Type.PREDATORS))


func test_pick_the_same_seed_gives_the_same_event() -> void:
	for seed_value: int in 20:
		var draw := func() -> Variant:
			return EventDrawer.pick(DartRandom.new(seed_value), 15, Type.STORM, _set_of([Type.WRECK]))
		assert_eq(draw.call(), draw.call())


func test_pick_returns_null_when_every_type_is_excluded() -> void:
	var all: Array[Type] = []
	all.assign(Type.values())
	assert_eq(_picks(20, null, all), {null: true})


func test_pick_returns_null_when_only_the_last_draw_is_left() -> void:
	var excluded: Array[Type] = []
	excluded.assign(Type.values())
	excluded.erase(Type.STORM)
	assert_eq(_picks(20, Type.STORM, excluded), {null: true})


## Not in the Dart file: a pick without candidates leaves the dice alone.
func test_pick_without_candidates_does_not_roll() -> void:
	var random := DartRandom.new(5)
	assert_null(EventDrawer.pick(random, 20, Type.STORM, _set_of([
		Type.WARM_CURRENT, Type.WRECK, Type.PREDATORS, Type.SURVIVORS, Type.CARAVAN, Type.COLD_CURRENT,
	])))
	assert_eq(random.next_int(1000), DartRandom.new(5).next_int(1000))


func _sorted(picks: Dictionary) -> Array:
	var keys := picks.keys()
	keys.sort()
	return keys

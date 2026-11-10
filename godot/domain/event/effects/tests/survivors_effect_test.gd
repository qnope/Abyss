extends VectorTestCase
## test/domain/event/effects/survivors_effect_test.dart: survivors who may
## join the base as free harpoonists.

var _survivors := SurvivorsEffect.new()


func _harpoonists(player: Player) -> int:
	return player.units_on_level(1)[UnitType.Value.HARPOONIST].count


func _stocks(player: Player) -> Dictionary[ResourceType.Value, int]:
	var stocks: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in player.resources:
		stocks[type] = player.resources[type].amount
	return stocks


## Player whose survivors, drawn at the end of turn 11, wait on turn 12.
func _met(count: int) -> Player:
	var player := EventSamples.event_player()
	player.event_state.schedule(100)
	player.event_state.set_pending(RandomEventType.Value.SURVIVORS, 12)
	player.event_state.survivors = count
	return player


func test_3_survivors_early_on_one_more_every_20_turns_8_at_most() -> void:
	var counts: Array[int] = []
	for turn: int in [5, 19, 20, 45, 100, 400]:
		counts.append(SurvivorsEffect.count_at(turn))
	assert_eq(counts, [3, 3, 4, 5, 8, 8])


func test_the_draw_remembers_how_many_survivors_are_met() -> void:
	var player := EventSamples.event_player()
	_survivors.on_draw(EventSamples.event_game(player, 20), player, 20, DartRandom.new(1))
	assert_eq(player.event_state.survivors, 4)


func test_welcoming_them_adds_free_harpoonists_on_level_1_silently() -> void:
	var player := _met(4)
	var before := _stocks(player)
	var result := ActionExecutor.new().execute(ChooseEventAction.new(true), EventSamples.event_game(player, 12), player)
	assert_true(result.is_success)
	assert_eq(_harpoonists(player), 4)
	assert_eq(_stocks(player), before)
	assert_eq(player.raid_state.total_noise, 0)
	assert_true(player.recruited_unit_types.is_empty())
	assert_null(player.event_state.survivors)


func test_turning_them_away_adds_nobody() -> void:
	var player := _met(4)
	ActionExecutor.new().execute(ChooseEventAction.new(false), EventSamples.event_game(player, 12), player)
	assert_eq(_harpoonists(player), 0)
	assert_null(player.event_state.survivors)


func test_left_without_a_choice_nobody_joins() -> void:
	var player := _met(4)
	EventResolver.resolve(EventSamples.event_game(player, 12), player, 12, DartRandom.new(1))
	assert_eq(_harpoonists(player), 0)
	assert_null(player.event_state.survivors)


## Not in the Dart file: the section survivors of
## reference/vectors/events.json, every case.
func test_counts_the_survivors_as_dart_does() -> void:
	var cases := VectorFile.new("events").cases("survivors")
	assert_eq(cases.size(), 10)
	for case: Dictionary in cases:
		var turn: int = case["turn"]
		assert_same(SurvivorsEffect.count_at(turn), case["out"], str(case))


## Not in the Dart file: welcomed through the effect itself, as the choice
## does, they join the harpoonists of level 1; none join when none were met.
func test_welcomed_through_the_effect_they_join_the_harpoonists() -> void:
	var player := _met(4)
	var game := EventSamples.event_game(player, 12)
	_survivors.apply(game, player, true, 12)
	assert_eq(_harpoonists(player), 4)
	_survivors.apply(game, player, false, 12)
	player.event_state.survivors = null
	_survivors.apply(game, player, true, 12)
	assert_eq(_harpoonists(player), 4)

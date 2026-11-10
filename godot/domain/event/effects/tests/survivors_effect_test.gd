extends VectorTestCase
## test/domain/event/effects/survivors_effect_test.dart: survivors who may
## join the base as free harpoonists. 'welcoming them adds free harpoonists
## on level 1, silently' and 'turning them away adds nobody' wait for the
## action module (ChooseEventAction, ActionExecutor); 'left without a
## choice, nobody joins' for the event resolver, ported next.

var _survivors := SurvivorsEffect.new()


func _harpoonists(player: Player) -> int:
	return player.units_on_level(1)[UnitType.Value.HARPOONIST].count


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

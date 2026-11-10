extends TestCase
## test/domain/event/event_effects_test.dart: each step of a random event
## handed to the effect of its type.

const PREDATORS := RandomEventType.Value.PREDATORS

var _wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 3)


func test_excluded_at_excludes_nothing_on_a_quiet_turn() -> void:
	var player := EventSamples.wreck_player()
	assert_eq(EventEffects.excluded_at(EventSamples.wreck_game(player), player, 20), {})


func test_excluded_at_excludes_predators_when_a_raid_hits_at_the_end_of_next_turn() -> void:
	var player := EventSamples.wreck_player()
	player.raid_state.announce(_wave, 21)
	assert_eq(EventEffects.excluded_at(EventSamples.wreck_game(player), player, 20), {PREDATORS: true})


func test_excluded_at_keeps_predators_when_the_raid_comes_later() -> void:
	var player := EventSamples.wreck_player()
	player.raid_state.announce(_wave, 22)
	assert_eq(EventEffects.excluded_at(EventSamples.wreck_game(player), player, 20), {})


func test_excluded_at_excludes_the_wreck_when_there_is_no_map_to_sink_it_on() -> void:
	var player := EventSamples.event_player()
	assert_eq(
		EventEffects.excluded_at(EventSamples.event_game(player), player, 20),
		{RandomEventType.Value.WRECK: true},
	)


func test_the_hooks_of_every_event_but_the_predators_leave_the_dice_alone() -> void:
	for type: RandomEventType.Value in RandomEventType.Value.values():
		var player := EventSamples.event_player()
		var game := EventSamples.event_game(player, 12)
		var random := DartRandom.new(5)
		if type != PREDATORS:
			EventEffects.on_draw(game, player, type, 12, random)
		for accept: bool in [true, false]:
			EventEffects.apply(game, player, type, accept, 13, random)
		var name := DartEnum.name_of(RandomEventType.Value, type)
		assert_eq(random.next_int(1000), DartRandom.new(5).next_int(1000), name)


func test_the_predators_draw_their_wave_with_the_dice_of_the_draw() -> void:
	var player := EventSamples.event_player()
	player.raid_state.add_noise(200)
	var random := DartRandom.new(5)
	EventEffects.on_draw(EventSamples.event_game(player, 12), player, PREDATORS, 12, random)
	assert_not_null(player.event_state.predator_wave)
	assert_ne(random.next_int(1000), DartRandom.new(5).next_int(1000))


## Not in the Dart file: the effect of each type, the currents told apart.
func test_hands_each_type_to_its_effect() -> void:
	var classes: Array[String] = []
	for type: RandomEventType.Value in RandomEventType.Value.values():
		var script: Script = EventEffects.of(type).get_script()
		classes.append(script.get_global_name())
	assert_eq(classes, [
		"CurrentEffect", "WreckEffect", "PredatorsEffect", "StormEffect", "SurvivorsEffect",
		"CaravanEffect", "CurrentEffect",
	])
	var warm: CurrentEffect = EventEffects.of(RandomEventType.Value.WARM_CURRENT)
	var cold: CurrentEffect = EventEffects.of(RandomEventType.Value.COLD_CURRENT)
	assert_eq([warm.type, cold.type], [RandomEventType.Value.WARM_CURRENT, RandomEventType.Value.COLD_CURRENT])


## Not in the Dart file: the end of a turn reaches every effect, and none
## of them leaves anything on the map at the end of a turn today.
func test_the_end_of_a_turn_reaches_every_effect_and_leaves_the_wreck() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player)
	var random := DartRandom.new(5)
	WreckEffect.new().on_draw(game, player, 12, random)
	var at := player.event_state.wreck_position
	EventEffects.end_turn(game, player, 17)
	assert_eq(game.current_map().cell_at(at.x, at.y).content, CellContentType.Value.WRECK)
	assert_eq(player.event_state.wreck_until_turn, 17)

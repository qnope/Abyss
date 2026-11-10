extends TestCase
## test/domain/event/effects/predators_effect_test.dart: the shoal of
## predators. 'facing them marks the fight for the end of the turn' and
## 'baiting them gives up 30 % of the algae, without a fight' wait for the
## action module (ChooseEventAction).

const ALGAE := ResourceType.Value.ALGAE
const HARPOONIST := UnitType.Value.HARPOONIST

var _predators := PredatorsEffect.new()


func _algae(player: Player) -> int:
	return player.resources[ALGAE].amount


## `_expectBaited`: 30 % of `algae_before` lost, nobody fought, the wave
## forgotten.
func _expect_baited(player: Player, algae_before: int) -> void:
	var lost := DartMath.trunc_div(algae_before * EventRules.BAIT_ALGAE_PERCENT, 100)
	assert_eq(_algae(player), algae_before - lost)
	assert_eq(player.resources[ResourceType.Value.CORAL].amount, 1000)
	assert_eq(RaidSamples.units_on_base(player), 10)
	assert_false(player.history_entries.any(func(e: HistoryEntry) -> bool: return e is RaidEntry))
	assert_null(player.event_state.predator_wave)
	assert_null(player.event_state.predators_turn)


func test_the_draw_builds_a_wave_of_half_a_raid_scaled_by_the_difficulty() -> void:
	for difficulty: Difficulty.Value in Difficulty.Value.values():
		for noise: int in [60, 400, 900]:
			var player := EventSamples.event_player()
			player.raid_state.add_noise(noise)
			var game := Game.single_player(player, difficulty)
			_predators.on_draw(game, player, 20, DartRandom.new(3))
			var expected := RaidWaveFactory.from_total_noise(
				noise, DartRandom.new(3), DartMath.trunc_div(Difficulty.monster_percent(difficulty) * 50, 100)
			)
			assert_eq(
				RaidSamples.wave_fields(player.event_state.predator_wave),
				RaidSamples.wave_fields(expected),
				"%s, noise %d" % [DartEnum.name_of(Difficulty.Value, difficulty), noise],
			)


func test_half_the_power_of_a_raid_at_the_same_noise() -> void:
	var player := EventSamples.event_player()
	player.raid_state.add_noise(150)
	_predators.on_draw(EventSamples.event_game(player), player, 20, DartRandom.new(1))
	var raid := RaidWaveFactory.from_total_noise(
		150, DartRandom.new(1), Difficulty.monster_percent(Difficulty.Value.NORMAL)
	)
	assert_true(player.event_state.predator_wave.level() < raid.level())


func test_left_without_a_choice_they_are_baited_at_the_end_of_the_turn() -> void:
	var player := EventSamples.threatened_player({HARPOONIST: 10})
	var game := EventSamples.event_game(player, 12)
	var outcome := EventResolver.resolve(game, player, 12, DartRandom.new(1))
	assert_null(outcome.predators)
	assert_not_null(outcome.defaulted)
	_expect_baited(player, 1000)


## Not in the Dart file: the choices through the effect itself, as
## ChooseEventAction makes them: faced, the fight is marked for the turn;
## baited, 30 % of the algae go.
func test_the_choices_through_the_effect_itself() -> void:
	var faced := EventSamples.threatened_player({HARPOONIST: 10})
	_predators.apply(EventSamples.event_game(faced, 12), faced, true, 12)
	assert_eq(faced.event_state.predators_turn, 12)
	assert_not_null(faced.event_state.predator_wave)
	assert_eq([_algae(faced), RaidSamples.units_on_base(faced)], [1000, 10])
	var baited := EventSamples.threatened_player({HARPOONIST: 10})
	baited.resources[ALGAE].amount = 333
	_predators.apply(EventSamples.event_game(baited, 12), baited, false, 12)
	_expect_baited(baited, 333)
	baited.resources.erase(ALGAE)
	_predators.apply(EventSamples.event_game(baited, 12), baited, false, 12)
	assert_false(baited.resources.has(ALGAE))


## Not in the Dart file: never on top of a raid due at the end of the next
## turn, which event_effects_test.dart checks through EventEffects.
func test_allowed_unless_a_raid_hits_at_the_end_of_the_next_turn() -> void:
	var player := EventSamples.event_player()
	var game := EventSamples.event_game(player, 20)
	assert_true(_predators.allowed_at(game, player, 20))
	player.raid_state.announce(EventSamples.predator_test_wave(), 21)
	assert_false(_predators.allowed_at(game, player, 20))
	assert_true(_predators.allowed_at(game, player, 19))

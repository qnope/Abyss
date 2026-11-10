extends TestCase
## Not in the Dart tests, which read a VolcanoState through the waves of the
## krakens (test/domain/volcano/first_wave_test.dart, volcano_resolver_test
## .dart: the volcano module): the bookkeeping itself, as lib/domain/volcano/
## volcano_state.dart answers.


func test_a_new_state_fought_no_wave_and_expects_none() -> void:
	var state := VolcanoState.new()
	assert_eq([state.incoming, state.arrival_turn], [null, null])
	assert_eq([state.waves_repelled, state.levels_lost, state.waves_fought()], [0, 0, 0])
	assert_false(state.is_incoming())


func test_takes_its_fields_in_the_dart_order() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.HARD, 6)
	var state := VolcanoState.new(wave, 20, 2, 1)
	assert_eq([state.incoming, state.arrival_turn], [wave, 20])
	assert_eq([state.waves_repelled, state.levels_lost, state.waves_fought()], [2, 1, 3])


func test_announce_keeps_the_wave_until_it_is_cleared() -> void:
	var state := VolcanoState.new()
	var wave := MonsterLair.new(MonsterDifficulty.Value.HARD, 6)
	state.announce(wave, 20)
	assert_true(state.is_incoming())
	assert_eq([state.incoming, state.arrival_turn], [wave, 20])
	state.clear_incoming()
	assert_false(state.is_incoming())
	assert_eq([state.incoming, state.arrival_turn], [null, null])


func test_a_wave_without_its_turn_is_not_incoming() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.HARD, 6)
	assert_false(VolcanoState.new(wave).is_incoming())
	assert_false(VolcanoState.new(null, 20).is_incoming())


func test_counts_the_waves_repelled_and_the_levels_lost() -> void:
	var state := VolcanoState.new()
	state.record_outcome(true)
	state.record_outcome(false)
	state.record_outcome(true)
	assert_eq([state.waves_repelled, state.levels_lost, state.waves_fought()], [2, 1, 3])

extends TestCase
## test/domain/objective/objective_state_test.dart: the objectives a player
## completed and the tips they saw. 'a new player carries an empty state'
## waits for the game module (a Player).

const Id := ObjectiveId.Value


func test_objective_state_starts_with_nothing_completed_the_tutorial_and_tips_off() -> void:
	var state := ObjectiveState.new()
	assert_eq(state.completed, [] as Array[Id])
	assert_false(state.tutorial_enabled)
	assert_false(state.tips_enabled)
	assert_false(state.is_completed(Id.HQ_LEVEL_1))
	assert_eq(state.seen_tips, [] as Array[TipId.Value])


func test_objective_state_keeps_the_tips_seen_in_their_order_each_once() -> void:
	var state := ObjectiveState.new()
	state.mark_seen(TipId.Value.LAIR)
	state.mark_seen(TipId.Value.NOISE_GAUGE)
	state.mark_seen(TipId.Value.LAIR)
	assert_eq(state.seen_tips, [TipId.Value.LAIR, TipId.Value.NOISE_GAUGE] as Array[TipId.Value])
	assert_true(state.has_seen(TipId.Value.NOISE_GAUGE))
	assert_false(state.has_seen(TipId.Value.DESCENT))


func test_objective_state_keeps_the_completions_in_their_order_each_once() -> void:
	var state := ObjectiveState.new([], true)
	state.complete(Id.MINES)
	state.complete(Id.HQ_LEVEL_1)
	state.complete(Id.MINES)
	assert_eq(state.completed, [Id.MINES, Id.HQ_LEVEL_1] as Array[Id])
	assert_true(state.is_completed(Id.HQ_LEVEL_1))
	assert_true(state.tutorial_enabled)


## Not in the Dart file: two states never share the lists of their defaults.
func test_two_states_keep_their_own_lists() -> void:
	var first := ObjectiveState.new()
	first.complete(Id.MINES)
	first.mark_seen(TipId.Value.LAIR)
	var second := ObjectiveState.new([], false, true)
	assert_eq(second.completed, [] as Array[Id])
	assert_eq(second.seen_tips, [] as Array[TipId.Value])
	assert_true(second.tips_enabled)

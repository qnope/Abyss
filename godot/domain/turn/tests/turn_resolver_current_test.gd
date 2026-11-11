extends TestCase
## test/domain/turn/turn_resolver_current_test.dart: the warm and the cold
## currents through the ends of turns. A turn of `_play` is the record
## `(made, energyUsed, noise)` as `[made, energy_used, noise]`.

const Event := RandomEventType.Value
const R := ResourceType.Value
const UP := 100 + EventRules.CURRENT_PERCENT
const DOWN := 100 - EventRules.CURRENT_PERCENT

var calm: Array[Array] = []


func before_each() -> void:
	super()
	calm = _play()


## Plays turns 12 to 17 of a producing player. `choice` (a bool) is taken
## during turn 12 on the `pending` event (a RandomEventType.Value); null
## leaves it without a choice.
static func _play(pending: Variant = null, choice: Variant = null) -> Array[Array]:
	var player := EventSamples.producing_player()
	player.event_state.schedule(100)
	if pending != null:
		var type: RandomEventType.Value = pending
		player.event_state.set_pending(type, 12)
	var game := Game.single_player(player)
	game.turn = 12
	if choice != null:
		var accept: bool = choice
		ChooseEventAction.new(accept).execute(game, player)
	var random := DartRandom.new(7)
	var turns: Array[Array] = []
	for _turn: int in range(12, 18):
		var before := player.raid_state.total_noise
		var result := TurnResolver.new().resolve(game, random)
		var made: Dictionary[ResourceType.Value, int] = {}
		var energy_used := 0
		for c: TurnResourceChange in result.changes:
			made[c.type] = c.produced
			if c.type == R.ENERGY:
				energy_used = c.consumed
		turns.append([made, energy_used, player.raid_state.total_noise - before])
	return turns


## What `turn` made of `type`, null when nothing.
static func _of(turn: Array, type: ResourceType.Value) -> Variant:
	var made: Dictionary = turn[0]
	return made.get(type)


static func _percent(amount: int, percent: int) -> int:
	return DartMath.trunc_div(amount * percent, 100)


func test_exploiting_a_warm_current_lifts_3_productions_and_makes_noise() -> void:
	var warm := _play(Event.WARM_CURRENT, true)
	for i: int in calm.size():
		var lifted := i < EventRules.EFFECT_TURNS
		for type: ResourceType.Value in [R.ALGAE, R.CORAL, R.ORE]:
			var normal: int = _of(calm[i], type)
			assert_eq(_of(warm[i], type), _percent(normal, UP) if lifted else normal, "%d, turn %d" % [type, 12 + i])
		assert_eq(_of(warm[i], R.ENERGY), _of(calm[i], R.ENERGY))
		assert_eq(_of(warm[i], R.PEARL), _of(calm[i], R.PEARL))
		assert_eq(warm[i][2] - calm[i][2], EventRules.WARM_NOISE_PER_TURN if lifted else 0)


func test_letting_a_warm_current_pass_changes_nothing() -> void:
	assert_eq(_play(Event.WARM_CURRENT, false), calm)
	assert_eq(_play(Event.WARM_CURRENT), calm)


func test_enduring_a_cold_current_takes_algae_on_3_productions() -> void:
	_expect_algae(_play(Event.COLD_CURRENT, false), 0, DOWN)


func test_a_cold_current_left_without_a_choice_hits_the_3_next_ones() -> void:
	_expect_algae(_play(Event.COLD_CURRENT), 1, DOWN)


func test_heating_the_farms_keeps_the_algae_for_20_energy_a_turn() -> void:
	var heated := _play(Event.COLD_CURRENT, true)
	for i: int in calm.size():
		assert_eq(heated[i][0], calm[i][0])
		var extra := EventRules.HEATING_ENERGY_PER_TURN if i < EventRules.EFFECT_TURNS else 0
		assert_eq(heated[i][1], calm[i][1] + extra)


## `played` makes `percent` % of the calm algae on the 3 productions from
## index `from`, and the same as calm otherwise.
func _expect_algae(played: Array[Array], from: int, percent: int) -> void:
	for i: int in calm.size():
		var hit := i >= from and i < from + EventRules.EFFECT_TURNS
		var normal: int = _of(calm[i], R.ALGAE)
		assert_eq(_of(played[i], R.ALGAE), _percent(normal, percent) if hit else normal, "turn %d" % (12 + i))
		assert_eq(_of(played[i], R.CORAL), _of(calm[i], R.CORAL))
		assert_eq(played[i][2], calm[i][2])

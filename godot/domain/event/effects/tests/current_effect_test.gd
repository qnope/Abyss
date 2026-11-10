extends TestCase
## test/domain/event/effects/current_effect_test.dart: the warm and the cold
## currents.

const Type := RandomEventType.Value

var _warm := CurrentEffect.new(Type.WARM_CURRENT)
var _cold := CurrentEffect.new(Type.COLD_CURRENT)


func _game(player: Player) -> Game:
	return EventSamples.event_game(player, 12)


func test_exploiting_a_warm_current_lasts_through_the_3_turns_from_now() -> void:
	var player := EventSamples.event_player()
	_warm.apply(_game(player), player, true, 12)
	var state := player.event_state
	assert_eq(state.active, Type.WARM_CURRENT)
	assert_eq(state.active_until_turn, 12 + EventRules.EFFECT_TURNS - 1)
	assert_false(state.heating)


func test_letting_a_warm_current_pass_changes_nothing() -> void:
	var player := EventSamples.event_player()
	_warm.apply(_game(player), player, false, 12)
	assert_null(player.event_state.active)


func test_heating_the_farms_lasts_3_turns_and_spends_energy() -> void:
	var player := EventSamples.event_player()
	_cold.apply(_game(player), player, true, 12)
	var state := player.event_state
	assert_eq(state.active, Type.COLD_CURRENT)
	assert_eq(state.active_until_turn, 14)
	assert_true(state.heating)


func test_enduring_a_cold_current_lasts_3_turns_without_heating() -> void:
	var player := EventSamples.event_player()
	_cold.apply(_game(player), player, false, 12)
	var state := player.event_state
	assert_eq(state.active, Type.COLD_CURRENT)
	assert_eq(state.active_until_turn, 14)
	assert_false(state.heating)


func test_a_warm_current_makes_noise_at_the_end_of_each_of_its_turns() -> void:
	var player := EventSamples.event_player()
	_warm.on_turn_end(_game(player), player, 12)
	assert_eq(player.raid_state.total_noise, EventRules.WARM_NOISE_PER_TURN)


func test_a_cold_current_makes_no_noise() -> void:
	var player := EventSamples.event_player()
	_cold.on_turn_end(_game(player), player, 12)
	assert_eq(player.raid_state.total_noise, 0)


## Not in the Dart file: a current is an event effect, and keeps its type.
func test_is_an_event_effect_of_its_type() -> void:
	var effect: EventEffect = _cold
	assert_eq(_cold.type, Type.COLD_CURRENT)
	assert_true(effect.allowed_at(_game(EventSamples.event_player()), EventSamples.event_player(), 12))

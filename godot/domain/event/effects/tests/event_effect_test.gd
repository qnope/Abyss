extends TestCase
## Not in the Dart files: lib/domain/event/effects/event_effect.dart has no
## test of its own. Every hook of an event does nothing until the event
## overrides it, and none of them rolls.


func test_every_hook_does_nothing_by_default() -> void:
	var effect := EventEffect.new()
	var player := EventSamples.event_player()
	var game := EventSamples.event_game(player, 12)
	var random := DartRandom.new(5)
	assert_true(effect.allowed_at(game, player, 12))
	effect.on_draw(game, player, 12, random)
	assert_null(effect.refusal(game, player))
	effect.apply(game, player, true, 13, random)
	effect.apply(game, player, false, 13)
	effect.on_turn_end(game, player, 13)
	effect.on_any_turn_end(game, player, 13)
	assert_eq(random.next_int(1000), DartRandom.new(5).next_int(1000))
	assert_null(player.event_state.active)
	assert_eq(player.raid_state.total_noise, 0)

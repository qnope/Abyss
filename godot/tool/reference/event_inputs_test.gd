extends TestCase
## What EventInputs reads from a case of events.json.

const Type := RandomEventType.Value


func test_reads_an_event_or_none() -> void:
	assert_eq(EventInputs.event_or_null("coldCurrent"), Type.COLD_CURRENT)
	assert_null(EventInputs.event_or_null(null))


func test_reads_a_set_of_events_in_the_order_written() -> void:
	var events := EventInputs.events(["storm", "wreck"])
	assert_eq(events.keys(), [Type.STORM, Type.WRECK])
	assert_true(EventInputs.events([]).is_empty())


func test_reads_the_lasting_effect_of_a_state() -> void:
	var state := EventInputs.state({"active": "coldCurrent", "until": 10, "heating": true})
	assert_eq(state.active, Type.COLD_CURRENT)
	assert_eq(state.active_until_turn, 10)
	assert_true(state.heating)
	var quiet := EventInputs.state({"active": null, "until": null, "heating": false})
	assert_null(quiet.active)
	assert_null(quiet.active_until_turn)
	assert_false(quiet.heating)

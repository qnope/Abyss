extends VectorTestCase
## test/domain/event/event_production_test.dart: how the currents change the
## production of a turn. Then every case of the production section of
## events.json.

const Type := RandomEventType.Value
const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func _production() -> Dictionary[ResourceType.Value, int]:
	return {ALGAE: 100, CORAL: 50, ORE: 7, ENERGY: 40, PEARL: 2}


func _active(type: Type, heating := false) -> EventState:
	var state := EventState.new()
	state.activate(type, 14)
	state.heating = heating
	return state


func test_no_lasting_event_leaves_the_production_as_it_is() -> void:
	assert_eq(EventProduction.adjust(_production(), EventState.new(), 12), _production())
	assert_eq(EventProduction.heating_energy(EventState.new(), 12), 0)


func test_a_warm_current_adds_30_percent_of_algae_coral_and_ore_only() -> void:
	assert_eq(EventRules.CURRENT_PERCENT, 30)
	var adjusted := EventProduction.adjust(_production(), _active(Type.WARM_CURRENT), 14)
	assert_eq(adjusted, {ALGAE: 130, CORAL: 65, ORE: 9, ENERGY: 40, PEARL: 2})


func test_a_cold_current_takes_30_percent_of_the_algae_only() -> void:
	var adjusted := EventProduction.adjust(_production(), _active(Type.COLD_CURRENT), 12)
	var expected := _production()
	expected[ALGAE] = 70
	assert_eq(adjusted, expected)
	assert_eq(EventProduction.heating_energy(_active(Type.COLD_CURRENT), 12), 0)


func test_heated_farms_keep_their_algae_for_energy_each_turn() -> void:
	var state := _active(Type.COLD_CURRENT, true)
	assert_eq(EventProduction.adjust(_production(), state, 12), _production())
	assert_eq(EventProduction.heating_energy(state, 12), EventRules.HEATING_ENERGY_PER_TURN)


func test_an_effect_past_its_last_turn_changes_nothing() -> void:
	for type: Type in [Type.WARM_CURRENT, Type.COLD_CURRENT]:
		var state := _active(type, true)
		assert_eq(EventProduction.adjust(_production(), state, 15), _production())
		assert_eq(EventProduction.heating_energy(state, 15), 0)


func test_the_other_lasting_events_leave_the_production_as_it_is() -> void:
	var state := _active(Type.STORM)
	assert_eq(EventProduction.adjust(_production(), state, 12), _production())


## Not in the Dart file: the map given is changed in place and handed back,
## its order kept; an amount of zero or less is left alone.
func test_adjusts_the_production_in_place() -> void:
	var production: Dictionary[ResourceType.Value, int] = {ORE: 10, ALGAE: 0, CORAL: -10}
	var adjusted := EventProduction.adjust(production, _active(Type.WARM_CURRENT), 14)
	assert_true(adjusted == production)
	assert_eq(production, {ORE: 13, ALGAE: 0, CORAL: -10})
	assert_eq(production.keys(), [ORE, ALGAE, CORAL])


func test_production_vectors() -> void:
	var cases := VectorFile.new("events").cases("production")
	assert_eq(cases.size(), 15)
	for case: Dictionary in cases:
		var state := EventInputs.state(case)
		var turn: int = case["turn"]
		var percents: Dictionary[ResourceType.Value, int] = {}
		for type: ResourceType.Value in ResourceType.Value.values():
			percents[type] = EventProduction.percent_of(state, turn, type)
		var production: Dictionary[ResourceType.Value, int] = {}
		production.assign(VectorInputs.amounts(ResourceType.Value, case["production"]))
		var out := {
			"percents": VectorInputs.named(ResourceType.Value, percents),
			"adjusted": VectorInputs.named(
				ResourceType.Value, EventProduction.adjust(production, state, turn)
			),
			"heatingEnergy": EventProduction.heating_energy(state, turn),
		}
		assert_same(out, case["out"], str(case))

extends TestCase
## What the base reads of each pad.

const Type := BuildingType.Value


func test_reads_every_building_of_the_base_in_order() -> void:
	var player := GameFactory.new_single_player("Nemo", 1).human_player()
	player.buildings[Type.SOLAR_PANEL].level = 3
	var states := PadState.of_base(player.buildings)
	assert_eq(states.size(), 11)
	var types: Array[BuildingType.Value] = []
	for state in states:
		types.append(state.type)
	assert_eq(types, player.buildings.keys() as Array[BuildingType.Value])
	assert_eq(_state(states, Type.SOLAR_PANEL).level, 3)
	assert_eq(_state(states, Type.SOLAR_PANEL).pad(), &"SolarPanel")
	assert_true(_state(states, Type.SOLAR_PANEL).is_built())
	assert_false(_state(states, Type.BARRACKS).is_built())


func test_a_building_the_headquarters_is_too_low_for_is_degraded() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 1, Type.LABORATORY: 3})
	var states := PadState.of_base(player.buildings)
	assert_true(_state(states, Type.LABORATORY).degraded)
	assert_false(_state(states, Type.HEADQUARTERS).degraded)
	player.buildings[Type.HEADQUARTERS].level = 10
	assert_false(_state(PadState.of_base(player.buildings), Type.LABORATORY).degraded)


func test_tells_the_buildings_that_can_rise() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 1, Type.ALGAE_FARM: 0})
	var states := PadState.of_base(player.buildings, {Type.ALGAE_FARM: true})
	assert_true(_state(states, Type.ALGAE_FARM).upgradable)
	assert_false(_state(states, Type.HEADQUARTERS).upgradable)


func test_locks_a_plot_but_never_a_building_that_stands() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 1, Type.BARRACKS: 0, Type.ALGAE_FARM: 1})
	var locked: Dictionary[BuildingType.Value, bool] = {Type.BARRACKS: true, Type.ALGAE_FARM: true}
	var states := PadState.of_base(player.buildings, {}, locked)
	assert_true(_state(states, Type.BARRACKS).locked)
	assert_false(_state(states, Type.ALGAE_FARM).locked)


func test_stands_the_pads_named_at_level_one() -> void:
	var states := PadState.standing([&"Headquarters", &"CoralCitadel"] as Array[StringName])
	assert_eq(states.size(), 2)
	assert_eq([states[1].type, states[1].level], [Type.CORAL_CITADEL, 1])
	assert_false(states[1].degraded or states[1].upgradable or states[1].locked)


func test_the_signature_tells_everything_a_state_shows() -> void:
	var base := PadState.new(Type.BARRACKS, 2)
	var seen: Dictionary[String, bool] = {base.signature(): true}
	var others: Array[PadState] = [
		PadState.new(Type.LABORATORY, 2), PadState.new(Type.BARRACKS, 3),
		PadState.new(Type.BARRACKS, 2, true), PadState.new(Type.BARRACKS, 2, false, true),
		PadState.new(Type.BARRACKS, 2, false, false, true),
	]
	for other in others:
		seen[other.signature()] = true
	assert_eq(seen.size(), 6)
	assert_eq(PadState.new(Type.BARRACKS, 2).signature(), base.signature())


func test_the_signature_of_a_base_follows_its_pads() -> void:
	var one: Array[PadState] = [PadState.new(Type.BARRACKS, 2), PadState.new(Type.LABORATORY)]
	var other: Array[PadState] = [PadState.new(Type.BARRACKS, 2), PadState.new(Type.LABORATORY, 1)]
	assert_ne(PadState.signature_of(one), PadState.signature_of(other))
	assert_eq(PadState.signature_of(one), PadState.signature_of(one.duplicate()))


func _state(states: Array[PadState], type: BuildingType.Value) -> PadState:
	for state in states:
		if state.type == type:
			return state
	return null

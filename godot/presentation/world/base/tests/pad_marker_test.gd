extends TestCase
## The look of an empty pad: its slab shaded into the deck, its rim a faint
## glow that breathes.

const ISLAND := preload("res://assets/models/base_island.glb")


func test_shades_the_pad_into_the_deck_without_touching_the_deck() -> void:
	var island := ISLAND.instantiate() as Node3D
	var pad := (island.get_node("Pads/Barracks") as MeshInstance3D).mesh
	var stone := pad.surface_get_material(0) as StandardMaterial3D
	var marker := PadMarker.new(pad)
	assert_ne(marker.stone, stone)
	assert_true(marker.stone.vertex_color_use_as_albedo)
	assert_eq(marker.stone.albedo_color, PadMarker.STONE_SHADE)
	assert_eq(stone.albedo_color, Color.WHITE, "the deck keeps its own")
	assert_true(marker.glow.emission_enabled)
	assert_almost_eq(marker.glow.emission_energy_multiplier, PadMarker.GLOW_ENERGY, 1e-6)
	island.free()


func test_breathes_its_glow_over_a_pulse_cycle() -> void:
	var marker := PadMarker.new(_mesh())
	marker.breathe(0.0)
	var start := marker.glow.emission_energy_multiplier
	marker.breathe(PadMarker.PULSE_CYCLE / 4.0)
	assert_true(marker.glow.emission_energy_multiplier > start)
	marker.breathe(PadMarker.PULSE_CYCLE * 3.0 / 4.0)
	assert_true(marker.glow.emission_energy_multiplier < start)
	marker.breathe(PadMarker.PULSE_CYCLE)
	assert_almost_eq(marker.glow.emission_energy_multiplier, start, 1e-5)


func _mesh() -> Mesh:
	var island := ISLAND.instantiate() as Node3D
	var mesh := (island.get_node("Pads/Barracks") as MeshInstance3D).mesh
	island.free()
	return mesh


func test_stays_a_hint_beside_the_buildings_lights() -> void:
	var marker := PadMarker.new(_mesh())
	for seconds: float in [0.0, PadMarker.PULSE_CYCLE / 4.0, PadMarker.PULSE_CYCLE / 2.0]:
		marker.breathe(seconds)
		assert_true(marker.glow.emission_energy_multiplier <= 0.3, "dimmer than any lamp")
	assert_true(marker.glow.albedo_color.get_luminance() < 0.2, "its paint barely lit")

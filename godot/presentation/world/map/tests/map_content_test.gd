extends MapTestCase
## The stand-ins of the map: each kind of content is a solid of its own in a
## colour of its own, the posts and the passage taking the colour of who holds
## them.


func test_every_kind_is_a_different_solid_in_a_different_colour() -> void:
	var seen: Dictionary[String, bool] = {}
	for kind: Kind in Kind.values():
		var shape := MapContent.shape_of(kind)
		seen["%s %s %s" % [shape.kind, shape.size, shape.taper]] = true
	assert_eq(seen.size(), Kind.size(), "no two kinds share a solid")
	var colours: Dictionary[Color, bool] = {}
	for kind: Kind in Kind.values():
		colours[MapContent.colour_of(kind)] = true
	# The posts and the passage start from the guardians' grey.
	assert_eq(colours.size(), Kind.size() - 2)


func test_the_lairs_grow_taller_and_redder_with_their_difficulty() -> void:
	var lairs: Array[Kind] = [Kind.LAIR_EASY, Kind.LAIR_MEDIUM, Kind.LAIR_HARD]
	var tops: Array[float] = []
	for kind in lairs:
		tops.append(MapContent.shape_of(kind).size.y)
	assert_true(tops[0] < tops[1] and tops[1] < tops[2], str(tops))
	assert_true(MapPalette.LAIRS[MonsterDifficulty.Value.HARD].v < MapPalette.LAIRS[MonsterDifficulty.Value.EASY].v)
	for difficulty: MonsterDifficulty.Value in MonsterDifficulty.Value.values():
		assert_eq(MapContent.colour_of(MapContent.lair_of(difficulty)), MapPalette.LAIRS[difficulty])


func test_a_stand_in_stands_on_the_floor_in_its_colour() -> void:
	for kind: Kind in Kind.values():
		var stand_in := MapStandIn.new(kind)
		var box := stand_in.body.mesh.get_aabb()
		assert_almost_eq(stand_in.body.position.y + box.position.y, 0.0, 1e-4, str(kind))
		var material := stand_in.body.material_override as StandardMaterial3D
		assert_eq(material.albedo_color, MapContent.colour_of(kind), str(kind))
		assert_true(material.emission_enabled)
		assert_null(stand_in.seal)
		stand_in.free()


func test_a_tint_takes_the_place_of_the_colour() -> void:
	var stand_in := MapStandIn.new(Kind.FAILLE, Color.GOLD)
	assert_eq((stand_in.body.material_override as StandardMaterial3D).albedo_color, Color.GOLD)
	stand_in.free()


func test_an_emptied_content_is_the_degraded_grey_and_does_not_glow() -> void:
	var stand_in := MapStandIn.new(Kind.TREASURE, null, true)
	var material := stand_in.body.material_override as StandardMaterial3D
	assert_eq(material.albedo_color, WorldPalette.DEGRADED)
	assert_false(material.emission_enabled)
	assert_true(stand_in.dimmed)
	stand_in.free()


func test_a_held_volcano_wears_a_seal_in_its_owners_colour() -> void:
	var stand_in := MapStandIn.new(Kind.KERNEL, Color.CYAN)
	assert_eq((stand_in.body.material_override as StandardMaterial3D).albedo_color, MapPalette.KERNEL)
	assert_eq((stand_in.seal.material_override as StandardMaterial3D).albedo_color, Color.CYAN)
	assert_eq(stand_in.get_child_count(), 2)
	stand_in.free()


func test_the_seam_gives_a_stand_in_until_step_7_and_a_model_when_there_is_one() -> void:
	assert_true(WorldModels.MAP_MODELS.is_empty())
	for kind: Kind in Kind.values():
		var node := WorldModels.map_content(kind)
		assert_true(node is MapStandIn, str(kind))
		assert_eq((node as MapStandIn).kind, kind)
		node.free()
	var models: Dictionary[Kind, PackedScene] = {
		Kind.RUINS: WorldModels.MODELS[BuildingType.Value.HEADQUARTERS],
	}
	var model := mounted(WorldModels.map_content(Kind.RUINS, null, false, models))
	assert_false(model is MapStandIn)
	for mesh: Node in model.find_children("*", "GeometryInstance3D", true, false):
		assert_null((mesh as GeometryInstance3D).material_overlay)
	var dull := mounted(WorldModels.map_content(Kind.RUINS, null, true, models))
	for mesh: Node in dull.find_children("*", "GeometryInstance3D", true, false):
		assert_not_null((mesh as GeometryInstance3D).material_overlay)
	var other := mounted(WorldModels.map_content(Kind.TREASURE, null, false, models))
	assert_true(other is MapStandIn, "the others stay stand-ins")

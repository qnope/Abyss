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


func test_every_content_has_a_model_and_a_stand_in_when_there_is_none() -> void:
	var none: Dictionary[Kind, PackedScene] = {}
	for kind: Kind in Kind.values():
		assert_true(WorldModels.MAP_MODELS.has(kind), str(kind))
		var node := WorldModels.map_content(kind)
		assert_false(node is MapStandIn, str(kind))
		node.free()
		var stand_in := WorldModels.map_content(kind, null, false, none)
		assert_eq((stand_in as MapStandIn).kind, kind)
		stand_in.free()


func test_a_dull_content_is_veiled_and_a_whole_one_is_not() -> void:
	var model := mounted(WorldModels.map_content(Kind.RUINS))
	for mesh: Node in model.find_children("*", "GeometryInstance3D", true, false):
		assert_null((mesh as GeometryInstance3D).material_overlay)
	var dull := mounted(WorldModels.map_content(Kind.RUINS, null, true))
	for mesh: Node in dull.find_children("*", "GeometryInstance3D", true, false):
		assert_not_null((mesh as GeometryInstance3D).material_overlay)


func test_a_held_post_takes_the_colour_of_its_holder_on_its_tint() -> void:
	for kind: Kind in [Kind.FAILLE, Kind.CHEMINEE, Kind.PASSAGE, Kind.KERNEL, Kind.FACTION_BASE]:
		var model := mounted(WorldModels.map_content(kind, Color.CYAN))
		var lamp := model.find_child("Tint", true, false) as MeshInstance3D
		assert_not_null(lamp, str(kind))
		var material := lamp.get_surface_override_material(0) as StandardMaterial3D
		assert_eq(material.albedo_color, Color.CYAN, str(kind))
		if material.emission_enabled:
			assert_eq(material.emission, Color.CYAN, str(kind))
	var home := mounted(WorldModels.map_content(Kind.HOME, Color.CYAN))
	assert_null(home.find_child("Tint", true, false), "the home takes no colour")

extends TestCase
## The map's models of assets/models/ as the game will instantiate them: a
## level's floor tiles inside one cell, the fog blended and shadowless, the
## backdrop's straight pieces two long, and the creatures with the two loops
## every moving model has.

const FOLDER := "res://assets/models/"
const LEVELS: Array[int] = [1, 2, 3]
const CREATURES: Array[String] = ["map_turtle", "map_jelly", "map_ray"]


func test_every_floor_tile_stays_in_its_cell_and_the_fog_lies_under_the_lit() -> void:
	for level in LEVELS:
		var scene := _instantiate("map_terrain_%d" % level)
		var lit_top := INF
		var fog_top := -INF
		for node in scene.get_children():
			var box := (node as MeshInstance3D).mesh.get_aabb()
			assert_true(box.size.x <= 1.001 and box.size.z <= 1.001, "%d/%s" % [level, node.name])
			assert_almost_eq(box.position.y, -0.6, 0.001, "%d/%s" % [level, node.name])
			if String(node.name).begins_with("Lit"):
				lit_top = minf(lit_top, box.end.y)
			else:
				fog_top = maxf(fog_top, box.end.y)
		assert_true(fog_top < lit_top - 0.15, "level %d: the fog is lower" % level)
		scene.free()


func test_a_floor_has_three_lit_variants_and_two_under_the_fog() -> void:
	for level in LEVELS:
		var scene := _instantiate("map_terrain_%d" % level)
		var lit := scene.find_children("Lit*", "MeshInstance3D", false, false)
		var fog := scene.find_children("Fog*", "MeshInstance3D", false, false)
		assert_eq([lit.size(), fog.size()], [3, 2], "level %d" % level)
		scene.free()


func test_the_fog_is_blended_and_takes_no_shadow() -> void:
	var scene := _instantiate("map_fog")
	for node in scene.get_children():
		var mesh := (node as MeshInstance3D).mesh
		for surface in mesh.get_surface_count():
			var material := mesh.surface_get_material(surface) as BaseMaterial3D
			assert_ne(material.transparency, BaseMaterial3D.TRANSPARENCY_DISABLED, node.name)
			assert_true(material.disable_receive_shadows, node.name)
			assert_eq(material.cull_mode, BaseMaterial3D.CULL_DISABLED, node.name)
	scene.free()


func test_a_backdrops_straight_pieces_are_two_long_falling_away_to_the_front() -> void:
	for level in LEVELS:
		var scene := _instantiate("map_backdrop_%d" % level)
		for piece_name: String in ["Edge1", "Edge2"]:
			var box := (scene.get_node(NodePath(piece_name)) as MeshInstance3D).mesh.get_aabb()
			assert_true(box.size.x > 1.99 and box.size.x < 2.5, "%d/%s" % [level, piece_name])
			assert_true(box.end.z > 4.0, "%d/%s runs out to the front" % [level, piece_name])
			assert_true(box.position.y < -5.0, "%d/%s falls away" % [level, piece_name])
		scene.free()


func test_every_creature_loops_idle_and_swim_and_nothing_else() -> void:
	for model in CREATURES:
		var scene := _instantiate(model)
		var player := scene.find_child("AnimationPlayer", true, false) as AnimationPlayer
		var names := Array(player.get_animation_list())
		names.sort()
		assert_eq(names, ["idle", "swim"], model)
		for action: String in names:
			var animation := player.get_animation(action)
			assert_eq(animation.loop_mode, Animation.LOOP_LINEAR, "%s/%s" % [model, action])
			assert_true(animation.length > 0.5, "%s/%s" % [model, action])
		scene.free()


func test_every_creature_is_part_of_a_cell_across() -> void:
	for model in CREATURES:
		var scene := _instantiate(model)
		var skeleton := scene.find_child("Skeleton3D", true, false) as Skeleton3D
		assert_not_null(skeleton, model)
		for node in scene.find_children("*", "MeshInstance3D", true, false):
			var box := (node as MeshInstance3D).mesh.get_aabb()
			assert_true(maxf(box.size.x, box.size.z) < 1.0, model)
		scene.free()


func _instantiate(model: String) -> Node3D:
	var scene := load(FOLDER + model + ".glb") as PackedScene
	return null if scene == null else scene.instantiate() as Node3D

extends TestCase
## The six units' models (tool/models/catalog): rigged, skinned, with the four
## actions the game plays by name, the loops looping.

const FOLDER := "res://assets/models/"
const UNITS: Array[String] = ["scout", "harpoonist", "guardian", "dome_breaker", "abyss_admiral", "saboteur"]
const ACTIONS: Array[String] = ["attack", "hit", "idle", "swim"]


func test_every_unit_plays_the_four_actions_by_name_the_loops_looping() -> void:
	for unit in UNITS:
		var scene := _instantiate(unit)
		var player := scene.get_node("AnimationPlayer") as AnimationPlayer
		var names: Array[String] = []
		for animation in player.get_animation_list():
			names.append(String(animation))
		names.sort()
		assert_eq(names, ACTIONS, unit)
		for action: StringName in [&"idle", &"swim"]:
			assert_eq(player.get_animation(action).loop_mode, Animation.LOOP_LINEAR, "%s %s" % [unit, action])
		for action: StringName in [&"attack", &"hit"]:
			assert_eq(player.get_animation(action).loop_mode, Animation.LOOP_NONE, "%s %s" % [unit, action])
		scene.free()


func test_every_unit_has_a_skeleton_and_skinned_meshes() -> void:
	for unit in UNITS:
		var scene := _instantiate(unit)
		var skeletons := scene.find_children("*", "Skeleton3D", true, false)
		assert_eq(skeletons.size(), 1, unit)
		assert_true((skeletons[0] as Skeleton3D).get_bone_count() <= 24, unit)
		for node in scene.find_children("*", "MeshInstance3D", true, false):
			assert_true((node as MeshInstance3D).skin != null, "%s/%s" % [unit, node.name])
		scene.free()


func test_a_unit_stands_on_the_floor_under_its_origin() -> void:
	for unit in UNITS:
		var scene := _instantiate(unit)
		var lowest := INF
		for node in scene.find_children("*", "MeshInstance3D", true, false):
			lowest = minf(lowest, (node as MeshInstance3D).get_aabb().position.y)
		assert_almost_eq(lowest, 0.0, 0.06, unit)
		scene.free()


func _instantiate(model: String) -> Node3D:
	return (load(FOLDER + model + ".glb") as PackedScene).instantiate() as Node3D

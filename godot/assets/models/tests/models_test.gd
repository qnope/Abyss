extends TestCase
## Each glb of assets/models/, built by tool/models/build.py, imports and
## instantiates with the nodes the game relies on, its vertex colours used
## as albedo (tool/models/model_import.gd).

const FOLDER := "res://assets/models/"

## The root nodes of each model, under the scene's own root.
const ROOTS := {
	"material_swatches": ["Swatches", "Unit"],
}


func test_every_model_has_its_root_nodes() -> void:
	for model: String in ROOTS:
		var scene := _instantiate(model)
		assert_not_null(scene, model)
		if scene == null:
			continue
		var names: Array[String] = []
		for child in scene.get_children():
			names.append(String(child.name))
		assert_eq(names, ROOTS[model], model)
		scene.free()


func test_every_committed_model_is_expected() -> void:
	for file in DirAccess.get_files_at(FOLDER):
		if file.ends_with(".glb"):
			assert_has(ROOTS, file.get_basename(), "%s has no expected roots here" % file)


func test_every_surface_takes_its_albedo_from_the_vertex_colours() -> void:
	for model: String in ROOTS:
		var scene := _instantiate(model)
		if scene == null:
			continue
		for node in scene.find_children("*", "MeshInstance3D", true, false):
			var mesh := (node as MeshInstance3D).mesh
			for surface in mesh.get_surface_count():
				var material := mesh.surface_get_material(surface) as BaseMaterial3D
				assert_true(material.vertex_color_use_as_albedo, "%s/%s" % [model, node.name])
		scene.free()


func _instantiate(model: String) -> Node3D:
	var scene := load(FOLDER + model + ".glb") as PackedScene
	return null if scene == null else scene.instantiate() as Node3D

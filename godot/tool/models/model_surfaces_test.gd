extends TestCase
## The import of a model turns the vertex colours of a surface into its
## albedo, and leaves a surface without any as it is.

const ModelSurfaces := preload("res://tool/models/model_surfaces.gd")

var _scene: Node3D


func after_each() -> void:
	_scene.free()


func test_uses_the_vertex_colours_of_a_surface_as_albedo() -> void:
	_scene = _scene_with([true, false])
	ModelSurfaces.use_vertex_colours(_scene)
	var mesh := (_scene.get_child(0) as MeshInstance3D).mesh
	assert_true((mesh.surface_get_material(0) as BaseMaterial3D).vertex_color_use_as_albedo)
	assert_false((mesh.surface_get_material(1) as BaseMaterial3D).vertex_color_use_as_albedo)


func test_skips_a_surface_without_material() -> void:
	_scene = _scene_with([true])
	((_scene.get_child(0) as MeshInstance3D).mesh as ArrayMesh).surface_set_material(0, null)
	ModelSurfaces.use_vertex_colours(_scene)
	assert_null((_scene.get_child(0) as MeshInstance3D).mesh.surface_get_material(0))


func _scene_with(coloured: Array[bool]) -> Node3D:
	var mesh := ArrayMesh.new()
	for with_colours in coloured:
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3.ZERO, Vector3.RIGHT, Vector3.UP])
		if with_colours:
			arrays[Mesh.ARRAY_COLOR] = PackedColorArray([Color.RED, Color.RED, Color.RED])
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, StandardMaterial3D.new())
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var scene := Node3D.new()
	scene.add_child(instance)
	return scene

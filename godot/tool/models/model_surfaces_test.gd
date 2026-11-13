extends TestCase
## The import of a model turns the vertex colours of a surface into its
## albedo, and leaves a surface without any as it is; it samples a model's
## atlas anisotropically, and leaves a surface without texture as it is; it
## blends plainly a material whose depth pre-pass would keep no fragment.

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


func test_a_blended_surface_takes_no_shadows() -> void:
	_scene = _scene_with([true, true])
	var mesh := (_scene.get_child(0) as MeshInstance3D).mesh
	(mesh.surface_get_material(0) as BaseMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ModelSurfaces.use_vertex_colours(_scene)
	assert_true((mesh.surface_get_material(0) as BaseMaterial3D).disable_receive_shadows)
	assert_false((mesh.surface_get_material(1) as BaseMaterial3D).disable_receive_shadows)


func test_skips_a_surface_without_material() -> void:
	_scene = _scene_with([true])
	((_scene.get_child(0) as MeshInstance3D).mesh as ArrayMesh).surface_set_material(0, null)
	ModelSurfaces.use_vertex_colours(_scene)
	assert_null((_scene.get_child(0) as MeshInstance3D).mesh.surface_get_material(0))


func test_samples_the_atlas_of_a_surface_anisotropically() -> void:
	_scene = _scene_with([true, true])
	var mesh := (_scene.get_child(0) as MeshInstance3D).mesh
	var textured := mesh.surface_get_material(0) as BaseMaterial3D
	textured.albedo_texture = PlaceholderTexture2D.new()
	textured.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	ModelSurfaces.sample_atlas(_scene)
	assert_eq(textured.texture_filter, BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC)
	var plain := mesh.surface_get_material(1) as BaseMaterial3D
	assert_eq(plain.texture_filter, BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)


func test_samples_no_atlas_on_a_surface_without_material() -> void:
	_scene = _scene_with([true])
	((_scene.get_child(0) as MeshInstance3D).mesh as ArrayMesh).surface_set_material(0, null)
	ModelSurfaces.sample_atlas(_scene)
	assert_null((_scene.get_child(0) as MeshInstance3D).mesh.surface_get_material(0))


func test_blends_plainly_a_surface_whose_colours_are_never_opaque() -> void:
	_scene = _scene_with([true], 0.9)
	var murk := _pre_passed(0)
	ModelSurfaces.blend_plainly(_scene)
	assert_eq(murk.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA)


func test_a_surface_with_an_opaque_vertex_keeps_its_pre_pass() -> void:
	_scene = _scene_with([true], 1.0)
	var bell := _pre_passed(0)
	ModelSurfaces.blend_plainly(_scene)
	assert_eq(bell.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS)


func test_blends_plainly_a_surface_whose_albedo_is_never_opaque() -> void:
	_scene = _scene_with([true], 1.0)
	var veil := _pre_passed(0)
	veil.albedo_color.a = 0.5
	ModelSurfaces.blend_plainly(_scene)
	assert_eq(veil.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA)


func test_a_surface_without_colours_keeps_its_pre_pass() -> void:
	_scene = _scene_with([false])
	var glass := _pre_passed(0)
	ModelSurfaces.blend_plainly(_scene)
	assert_eq(glass.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS)


func test_a_material_keeps_its_pre_pass_for_its_one_opaque_surface() -> void:
	_scene = _scene_with([true, false], 0.9)
	var shared := _pre_passed(0)
	_mesh().surface_set_material(1, shared)
	ModelSurfaces.blend_plainly(_scene)
	assert_eq(shared.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS)


func test_leaves_an_opaque_surface_and_one_without_material_alone() -> void:
	_scene = _scene_with([true, true], 0.9)
	_mesh().surface_set_material(1, null)
	ModelSurfaces.blend_plainly(_scene)
	var opaque := _mesh().surface_get_material(0) as BaseMaterial3D
	assert_eq(opaque.transparency, BaseMaterial3D.TRANSPARENCY_DISABLED)
	assert_null(_mesh().surface_get_material(1))


func _mesh() -> ArrayMesh:
	return (_scene.get_child(0) as MeshInstance3D).mesh as ArrayMesh


## The material of [param surface], blended as Godot imports a glTF BLEND one.
func _pre_passed(surface: int) -> BaseMaterial3D:
	var material := _mesh().surface_get_material(surface) as BaseMaterial3D
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	return material


## A mesh of one surface per entry of [param coloured], with vertex colours
## where it is true: their alpha tops at [param alpha], on one vertex only.
func _scene_with(coloured: Array[bool], alpha := 1.0) -> Node3D:
	var faint := Color(Color.RED, alpha * 0.5)
	var mesh := ArrayMesh.new()
	for with_colours in coloured:
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3.ZERO, Vector3.RIGHT, Vector3.UP])
		if with_colours:
			arrays[Mesh.ARRAY_COLOR] = PackedColorArray([faint, Color(Color.RED, alpha), faint])
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, StandardMaterial3D.new())
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var scene := Node3D.new()
	scene.add_child(instance)
	return scene

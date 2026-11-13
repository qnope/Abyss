extends TestCase
## The shadowless twin of a model's mesh: the same geometry drawn by copies of
## its materials that take no shadow, the model's own left as they are.

var _parts: Dictionary[StringName, Mesh]
var _mesh: Mesh
var _twin: Mesh


func before_each() -> void:
	_parts = MapScenery.parts(MapScenery.BACKDROPS[0])
	_mesh = _parts[&"Edge1"]
	_twin = ShadowlessMesh.of(_mesh)


func test_the_twin_is_another_mesh_of_the_same_geometry() -> void:
	assert_ne(_twin, _mesh)
	assert_eq(_twin.get_surface_count(), _mesh.get_surface_count())
	assert_eq(_mesh.get_surface_count(), 3)
	for surface in _mesh.get_surface_count():
		assert_eq(_twin.surface_get_arrays(surface), _mesh.surface_get_arrays(surface))


func test_the_twin_keeps_the_levels_of_detail() -> void:
	var mine: Array = _mesh.get("_surfaces")
	var its: Array = _twin.get("_surfaces")
	assert_eq(its.size(), mine.size())
	for surface in mine.size():
		var model: Dictionary = mine[surface]
		var copy: Dictionary = its[surface]
		var lods: Array = model["lods"]
		assert_false(lods.is_empty())
		assert_eq(copy["lods"], lods)


func test_its_materials_are_copies_that_take_no_shadow() -> void:
	for surface in _mesh.get_surface_count():
		var own := _mesh.surface_get_material(surface) as BaseMaterial3D
		var copy := _twin.surface_get_material(surface) as BaseMaterial3D
		assert_ne(copy, own)
		assert_true(copy.disable_receive_shadows)
		assert_false(own.disable_receive_shadows, "the model's own is left as it is")
		assert_eq(_settings(copy), _settings(own))
		assert_eq(copy.albedo_texture, own.albedo_texture)
		assert_eq(copy.vertex_color_use_as_albedo, own.vertex_color_use_as_albedo)


func test_asking_twice_gives_the_same_twin() -> void:
	assert_eq(ShadowlessMesh.of(_mesh), _twin)


func test_the_meshes_of_one_material_share_its_copy() -> void:
	var corner := _parts[&"Corner"]
	assert_eq(corner.surface_get_material(0), _mesh.surface_get_material(0))
	assert_eq(ShadowlessMesh.of(corner).surface_get_material(0), _twin.surface_get_material(0))


func test_a_surface_with_no_material_of_its_own_keeps_none() -> void:
	var bare := BoxMesh.new()
	var twin := ShadowlessMesh.of(bare)
	assert_ne(twin, bare)
	assert_null(twin.surface_get_material(0))


func test_a_reset_forgets_the_twins() -> void:
	ShadowlessMesh.debug_reset()
	var next := ShadowlessMesh.of(_mesh)
	assert_ne(next, _twin)
	assert_ne(next.surface_get_material(0), _twin.surface_get_material(0))
	assert_has(ProcessResets.all(), ShadowlessMesh.debug_reset)


## What [param material] stores, but for whether it takes shadows and what
## names the resource.
func _settings(material: Material) -> Dictionary[String, Variant]:
	var found: Dictionary[String, Variant] = {}
	for property in material.get_property_list():
		var title: String = property["name"]
		var usage: int = property["usage"]
		if usage & PROPERTY_USAGE_STORAGE != 0 and title != "disable_receive_shadows" and not title.begins_with("resource_"):
			found[title] = material.get(title)
	return found

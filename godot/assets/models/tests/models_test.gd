extends TestCase
## Each glb of assets/models/, built by tool/models/build.py, imports and
## instantiates with the nodes the game relies on, its vertex colours used
## as albedo (tool/models/model_import.gd), and its atlas, if it has one,
## compressed for the GPU, with mipmaps, sampled anisotropically, and the
## light of its glowing surfaces.

const FOLDER := "res://assets/models/"

## The root nodes of each model, under the scene's own root.
const ROOTS := {
	"barracks": ["Barracks"],
	"base_island": ["Island", "Pads"],
	"base_rampart": ["Tier1", "Tier2", "Tier3"],
	"coral_citadel": ["CoralCitadel"],
	"descent_module": ["Tier1", "Tier2", "Tier3"],
	"headquarters": ["Headquarters"],
	"laboratory": ["Laboratory"],
	"material_swatches": ["Swatches", "Unit"],
	"pressure_capsule": ["Tier1", "Tier2", "Tier3"],
	"probe_fish": ["Rig", "AnimationPlayer"],
	"solar_panel": ["SolarPanel"],
	"algae_farm": ["AlgaeFarm"],
	"coral_mine": ["CoralMine"],
	"ore_extractor": ["OreExtractor"],
	"volcanic_kernel": ["Tier1", "Tier2", "Tier3"],
}

## The models that paint an atlas (<model>_atlas.png beside the glb).
const TEXTURED: Array[String] = [
	"algae_farm", "barracks", "base_rampart", "coral_citadel", "coral_mine", "descent_module",
	"headquarters", "laboratory", "ore_extractor", "pressure_capsule", "solar_panel", "volcanic_kernel",
]

## The island's pads, one per building, where the buildings stand.
const PADS: Array[String] = [
	"AlgaeFarm", "Barracks", "CoralCitadel", "CoralMine", "DescentModule", "Headquarters",
	"Laboratory", "OreExtractor", "PressureCapsule", "SolarPanel", "VolcanicKernel",
]


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


func test_the_island_has_a_pad_per_building_on_the_deck() -> void:
	var island := _instantiate("base_island")
	var names: Array[String] = []
	for pad in island.get_node("Pads").get_children():
		names.append(String(pad.name))
		var top := (pad as Node3D).position
		assert_almost_eq(top.y, 0.12, 0.001, String(pad.name))
		assert_true(maxf(absf(top.x), absf(top.z)) < 6.0, String(pad.name))
	names.sort()
	assert_eq(names, PADS)
	var headquarters := island.get_node("Pads/Headquarters") as Node3D
	assert_true(headquarters.position.is_equal_approx(Vector3(0.4, 0.12, 0.4)))
	island.free()


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


func test_every_atlas_is_compressed_with_mipmaps_and_sampled_anisotropically() -> void:
	for model in TEXTURED:
		var scene := _instantiate(model)
		var textured := 0
		for node in scene.find_children("*", "MeshInstance3D", true, false):
			var mesh := (node as MeshInstance3D).mesh
			for surface in mesh.get_surface_count():
				var material := mesh.surface_get_material(surface) as BaseMaterial3D
				if material.albedo_texture == null:
					continue
				textured += 1
				assert_eq(material.albedo_texture.resource_path, FOLDER + model + "_atlas.png", model)
				var image := material.albedo_texture.get_image()
				assert_true(image.has_mipmaps(), "%s: its atlas has no mipmaps" % model)
				assert_true(image.is_compressed(), "%s: its atlas is not VRAM-compressed" % model)
				assert_eq(material.texture_filter,
					BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC, model)
				if material.emission_enabled:
					assert_eq(material.emission_texture, material.albedo_texture, model)
		assert_true(textured > 0, "%s has no textured surface" % model)
		scene.free()


func _instantiate(model: String) -> Node3D:
	var scene := load(FOLDER + model + ".glb") as PackedScene
	return null if scene == null else scene.instantiate() as Node3D

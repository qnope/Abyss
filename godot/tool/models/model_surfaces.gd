extends RefCounted
## What model_import.gd does to an imported model, apart from the editor
## class it must extend, so that a test can run it.


## Turns the vertex colours (glTF COLOR_0) of each surface under [param scene]
## into a factor of its albedo, as glTF means them; Godot's importer leaves
## them out.
static func use_vertex_colours(scene: Node) -> void:
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var mesh := (node as MeshInstance3D).mesh as ArrayMesh
		for surface in mesh.get_surface_count():
			var material := mesh.surface_get_material(surface) as BaseMaterial3D
			if material != null and mesh.surface_get_format(surface) & Mesh.ARRAY_FORMAT_COLOR:
				material.vertex_color_use_as_albedo = true


## Samples the atlas of each textured surface under [param scene] (the PNG
## a model of tool/models paints) anisotropically: the game's camera sees the
## walls at a grazing angle, where plain mipmaps blur its panel lines.
static func sample_atlas(scene: Node) -> void:
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var mesh := (node as MeshInstance3D).mesh
		for surface in mesh.get_surface_count():
			var material := mesh.surface_get_material(surface) as BaseMaterial3D
			if material != null and material.albedo_texture != null:
				material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC

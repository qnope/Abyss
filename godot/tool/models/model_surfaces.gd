extends RefCounted
## What model_import.gd does to an imported model, apart from the editor
## class it must extend, so that a test can run it.

## The alpha under which the depth pre-pass of a blended material discards a
## fragment: Godot's opaque_prepass_threshold, which its renderers set to 0.99
## and a material cannot change.
const PREPASS_THRESHOLD := 0.99


## Turns the vertex colours (glTF COLOR_0) of each surface under [param scene]
## into a factor of its albedo, as glTF means them; Godot's importer leaves
## them out. A blended surface (the fog's murk, whose alpha is its colours')
## takes no shadows: the light's shadow map would stripe a veil this thin.
static func use_vertex_colours(scene: Node) -> void:
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var mesh := (node as MeshInstance3D).mesh as ArrayMesh
		for surface in mesh.get_surface_count():
			var material := mesh.surface_get_material(surface) as BaseMaterial3D
			if material != null and mesh.surface_get_format(surface) & Mesh.ARRAY_FORMAT_COLOR:
				material.vertex_color_use_as_albedo = true
				if material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
					material.disable_receive_shadows = true


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


## Blends plainly each material under [param scene] that Godot's importer
## gave a depth pre-pass (every glTF BLEND one) and whose pre-pass would keep
## no fragment: the fog's murk tops at 0.9, so a phone would shade each of its
## stacked sheets once more to discard it whole, for the same image. A
## material that is opaque somewhere on any of its surfaces keeps its
## pre-pass, which sorts those parts. Its opacity is its albedo's alpha times
## its vertex colours', as use_vertex_colours, called first, makes it.
static func blend_plainly(scene: Node) -> void:
	var opacities: Dictionary[BaseMaterial3D, float] = {}
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var mesh := (node as MeshInstance3D).mesh as ArrayMesh
		for surface in mesh.get_surface_count():
			var material := mesh.surface_get_material(surface) as BaseMaterial3D
			if material != null and material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS:
				var known: float = opacities.get(material, 0.0)
				opacities[material] = maxf(known, material.albedo_color.a * _top_alpha(mesh, surface))
	for material in opacities:
		if opacities[material] < PREPASS_THRESHOLD:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA


## The largest alpha of the vertex colours of a [param surface] of
## [param mesh], 1 when it has none: they then leave its albedo as it is.
static func _top_alpha(mesh: ArrayMesh, surface: int) -> float:
	if not mesh.surface_get_format(surface) & Mesh.ARRAY_FORMAT_COLOR:
		return 1.0
	var colours: PackedColorArray = mesh.surface_get_arrays(surface)[Mesh.ARRAY_COLOR]
	var top := 0.0
	for colour in colours:
		top = maxf(top, colour.a)
	return top

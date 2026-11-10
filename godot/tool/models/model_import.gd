@tool
extends EditorScenePostImport
## The import script of every scene (project.godot, [importer_defaults]): gives
## the glb of tool/models their glTF meaning, which Godot's importer leaves
## out. A mesh's vertex colours carry the models' albedo and baked occlusion,
## times its atlas when it has one.

const ModelSurfaces := preload("res://tool/models/model_surfaces.gd")


func _post_import(scene: Node) -> Object:
	ModelSurfaces.use_vertex_colours(scene)
	ModelSurfaces.sample_atlas(scene)
	return scene

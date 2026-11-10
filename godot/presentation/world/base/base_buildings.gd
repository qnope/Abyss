class_name BaseBuildings
extends Node3D
## The buildings of the base, each standing on the island's pad named after
## it: a model of assets/models/, its origin at the centre of its pad.

## The model of each building, by its pad's name.
const MODELS: Dictionary[StringName, PackedScene] = {
	&"Headquarters": preload("res://assets/models/headquarters.glb"),
	&"SolarPanel": preload("res://assets/models/solar_panel.glb"),
	&"CoralCitadel": preload("res://assets/models/coral_citadel.glb"),
}


## Stands the buildings [param names] on their [param pads], in place of
## the ones standing before.
func build(names: Array[StringName], pads: BasePads) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	for name in names:
		var model := MODELS[name].instantiate() as Node3D
		model.name = name
		model.position = pads.origin_of(name)
		add_child(model)


## The names of the buildings standing, in the order they were built.
func names() -> Array[StringName]:
	var built: Array[StringName] = []
	for child: Node in get_children():
		built.append(child.name)
	return built


## The model of the building [param name], or null if it is not built.
func building(name: StringName) -> Node3D:
	return get_node_or_null(NodePath(name)) as Node3D

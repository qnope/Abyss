class_name BaseBuildings
extends Node3D
## The buildings of the base, each standing on the island's pad named after
## it: whatever [WorldModels] gives (a model of assets/models/ or a stand-in),
## its origin at the centre of its pad.

## Whether the buildings that have a model use it; off, every building is
## its stand-in (a review of the shapes).
var use_models := true
var _degraded: Dictionary[StringName, bool] = {}


## Stands the buildings of [param states] that are built (level 1 or more) on
## their [param pads], in place of the ones standing before.
func build(states: Array[PadState], pads: BasePads) -> void:
	for child: Node in get_children():
		# Freed in the tree: a node with its own materials, freed outside it,
		# makes the renderer complain.
		child.free()
	_degraded.clear()
	for state in states:
		if not state.is_built():
			continue
		var model := WorldModels.building(state.type, state.level, state.degraded, use_models)
		model.name = state.pad()
		model.position = pads.origin_of(state.pad())
		_degraded[state.pad()] = state.degraded
		add_child(model)


## The pad of the building [param type]: its Dart name, capitalised
## (`solarPanel` stands on `SolarPanel`).
static func pad_of(type: BuildingType.Value) -> StringName:
	var named := DartEnum.name_of(BuildingType.Value, type)
	return StringName(named.substr(0, 1).to_upper() + named.substr(1))


## The building whose pad is [param pad], the inverse of [method pad_of].
static func type_of(pad: StringName) -> BuildingType.Value:
	for type: BuildingType.Value in BuildingType.Value.values():
		if pad_of(type) == pad:
			return type
	push_error("BaseBuildings: no building has a pad called %s" % pad)
	return BuildingType.Value.HEADQUARTERS


## The names of the buildings standing, in the order they were built.
func names() -> Array[StringName]:
	var built: Array[StringName] = []
	for child: Node in get_children():
		built.append(child.name)
	return built


## Whether the building [param name] stands degraded: greyed, and still.
func is_degraded(name: StringName) -> bool:
	return _degraded.get(name, false)


## The building [param name] (a model or a stand-in), or null if it is not
## built.
func building(name: StringName) -> Node3D:
	return get_node_or_null(NodePath(name)) as Node3D

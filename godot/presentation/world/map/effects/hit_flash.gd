class_name HitFlash
extends RefCounted
## A flash of colour over a model: a blow lands, a place is taken (the white and
## the cyan flashes of MapStrikeRun). One translucent unshaded material laid over
## every mesh of the node as an overlay, its alpha the strength of the flash; what
## a mesh wore as an overlay before (the grey veil of a content already emptied)
## is put back when the flash is over, so that it is never lost.

## The strength under which there is no flash to see.
const FAINT := 0.01

var _material := StandardMaterial3D.new()
var _meshes: Array[GeometryInstance3D] = []
var _worn: Array[Material] = []


## A flash over the meshes under [param node].
func _init(node: Node3D) -> void:
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for found: Node in node.find_children("*", "GeometryInstance3D", true, false):
		var mesh := found as GeometryInstance3D
		_meshes.append(mesh)
		_worn.append(mesh.material_overlay)


## Flashes [param colour] at [param strength] (0 to 1): next to none puts the
## meshes back.
func show(colour: Color, strength: float) -> void:
	if strength < FAINT:
		clear()
		return
	_material.albedo_color = Color(colour, minf(strength, 1.0))
	for mesh in _meshes:
		if is_instance_valid(mesh):
			mesh.material_overlay = _material


## Puts back what the meshes wore.
func clear() -> void:
	for index in _meshes.size():
		if is_instance_valid(_meshes[index]):
			_meshes[index].material_overlay = _worn[index]

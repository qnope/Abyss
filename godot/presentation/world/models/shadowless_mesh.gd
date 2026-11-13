class_name ShadowlessMesh
extends RefCounted
## The twin of a model's mesh that takes no shadow: the same surfaces, with
## their levels of detail, drawn by copies of its materials that receive none.
## With the Compatibility renderer (the web's) a lit surface that receives
## shadows is drawn a second time, so what fills the screen is worth drawing
## with the twin while no shadow falls on it.
##
## The mesh and its materials are the model's own, shared by every scene made of
## it: they are never changed. The twins are made once and kept, so that the two
## shaders, with and without shadows, stay alive and a switch from a mesh to its
## twin compiles nothing: a material that changed its flag back and forth would
## free its shader each time and compile the other.

static var _twins: Dictionary[Mesh, Mesh] = {}
static var _materials: Dictionary[Material, Material] = {}


## The twin of [param mesh], the same one each time it is asked.
static func of(mesh: Mesh) -> Mesh:
	if not _twins.has(mesh):
		var twin: Mesh = mesh.duplicate()
		for surface in twin.get_surface_count():
			twin.surface_set_material(surface, _shadowless(mesh.surface_get_material(surface)))
		_twins[mesh] = twin
	return _twins[mesh]


## Forgets the twins made.
static func debug_reset() -> void:
	_twins.clear()
	_materials.clear()


## The copy of [param material] that receives no shadow, one for all the meshes
## it draws. What is not a [BaseMaterial3D] (a shader of its own, or nothing) is
## given back as it is.
static func _shadowless(material: Material) -> Material:
	if not material is BaseMaterial3D:
		return material
	if not _materials.has(material):
		var copy: BaseMaterial3D = material.duplicate()
		copy.disable_receive_shadows = true
		_materials[material] = copy
	return _materials[material]

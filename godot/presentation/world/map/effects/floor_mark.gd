class_name FloorMark
extends MeshInstance3D
## A ring or a disc of light lying on the floor, centred on what it marks (the
## alert around a place besieged, its shield, the flashes: SiegeFloor of the Dart
## map). One unshaded translucent material and a mesh of radius 1, both shared
## by all its shows: [method show_mark] scales the mesh to a radius and sets the
## colour and the opacity. Hidden until it is shown.

## How high over the floor it lies, so that it does not flicker with the tiles.
const HEIGHT := 0.04
## How thick a ring is, as a share of its radius.
const RING_WIDTH := 0.04

var _material := StandardMaterial3D.new()


## A ring, or a disc when [param ring] is false.
func _init(ring := true) -> void:
	name = &"Ring" if ring else &"Disc"
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if ring:
		var torus := TorusMesh.new()
		torus.inner_radius = 1.0 - RING_WIDTH
		torus.outer_radius = 1.0
		torus.rings = 24
		torus.ring_segments = 3
		mesh = torus
	else:
		var disc := CylinderMesh.new()
		disc.top_radius = 1.0
		disc.bottom_radius = 1.0
		disc.height = 0.002
		disc.radial_segments = 24
		disc.rings = 1
		mesh = disc
	material_override = _material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	position.y = HEIGHT
	visible = false


## Shows the mark [param radius] metres across from its middle, in [param colour]
## at [param opacity]; nothing shows at no opacity.
func show_mark(radius: float, colour: Color, opacity: float) -> void:
	visible = opacity > 0.0 and radius > 0.0
	_material.albedo_color = Color(colour, clampf(opacity, 0.0, 1.0))
	scale = Vector3(radius, 1.0, radius)

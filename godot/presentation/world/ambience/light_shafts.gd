class_name LightShafts
extends MultiMeshInstance3D
## Rays of light falling from the surface through the water, along the key
## light: ribbons that turn about their axis to face the camera, drawn
## additively by light_shaft.gdshader, all in one draw call of a few
## triangles. Volumetric fog would draw them for real, but only on the
## Forward+ renderer, which neither the web nor the phones use.

const SHADER := preload("res://presentation/world/ambience/light_shaft.gdshader")
const COUNT := 18
## Where the rays cross the deck's height: spread evenly over a disc around
## the island (a golden-angle spiral), so that every view of the orbit shows
## some over the base and some in the water behind it.
const SPREAD := 32.0
const GOLDEN_ANGLE := 2.39996
## Each ray's phase of wavering and width, from a fixed seed: every run
## shows the same.
const SEED := 20261110
## A ray's length, from above the camera to the abyss.
const LENGTH := 64.0
## The box the rays are drawn in, for culling: the shader widens them.
const BOUNDS := AABB(Vector3(-60.0, -30.0, -60.0), Vector3(120.0, 90.0, 120.0))


## Lays the rays along [param direction], the way the light travels.
func _init(direction: Vector3) -> void:
	cast_shadow = SHADOW_CASTING_SETTING_OFF
	custom_aabb = BOUNDS
	var material := ShaderMaterial.new()
	material.shader = SHADER
	material_override = material
	var rays := MultiMesh.new()
	rays.transform_format = MultiMesh.TRANSFORM_3D
	rays.use_custom_data = true
	rays.mesh = QuadMesh.new()
	rays.instance_count = COUNT
	var places := placements(direction)
	var random := RandomNumberGenerator.new()
	random.seed = SEED
	for index in COUNT:
		rays.set_instance_transform(index, places[index])
		# Its phase of wavering, and its width.
		rays.set_instance_custom_data(index, Color(random.randf(), random.randf_range(0.5, 1.2), 0.0))
	multimesh = rays


## Where each ray stands: its y axis along [param direction], as long as
## the ray, crossing the deck's height around the island.
static func placements(direction: Vector3) -> Array[Transform3D]:
	var axis := -direction.normalized()
	var side := axis.cross(Vector3.FORWARD if absf(axis.z) < 0.9 else Vector3.RIGHT).normalized()
	var basis := Basis(side, axis * LENGTH, side.cross(axis))
	var places: Array[Transform3D] = []
	for index in COUNT:
		var angle := index * GOLDEN_ANGLE
		var reach := sqrt((index + 0.5) / COUNT)
		var crossing := Vector3(cos(angle), 0.0, sin(angle)) * reach * SPREAD
		places.append(Transform3D(basis, crossing + axis * LENGTH * 0.2))
	return places

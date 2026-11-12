class_name FishSchool
extends MultiMeshInstance3D
## A school of small fish drifting round a place: a loose cloud that swims a
## lap every [constant LAP] seconds along a circle, each fish keeping its own
## place in it and wavering a little, turned along the school's way. All in
## one draw call of a few dozen triangles (one ellipsoid, [constant COUNT]
## times), moved by the processor: no particle shader, no model.

const COUNT := 14
const LAP := 70.0
## The circle the school swims along, and how high above its middle.
const RADIUS := 15.0
const HEIGHT := 1.0
## A fish's size: width, height and length in metres.
const BODY := Vector3(0.07, 0.11, 0.3)
## How far from the school's middle a fish keeps: ahead, aside, up.
const CLOUD := Vector3(1.4, 1.0, 0.6)
## How far a fish wavers aside, and how fast (radians per second).
const WAVER := 0.18
const WAVER_RATE := 1.7
const SEED := 20261112
const BOUNDS := AABB(Vector3(-20.0, -4.0, -20.0), Vector3(40.0, 10.0, 40.0))

var _time := 0.0
var _places: Array[Vector3] = []
var _phases: PackedFloat32Array = []


func _init() -> void:
	name = &"Fish"
	cast_shadow = SHADOW_CASTING_SETTING_OFF
	custom_aabb = BOUNDS
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = WorldPalette.FISH
	var body := SphereMesh.new()
	body.radius = 0.5
	body.height = 1.0
	body.radial_segments = 6
	body.rings = 3
	body.material = material
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = body
	multimesh.instance_count = COUNT
	var random := RandomNumberGenerator.new()
	random.seed = SEED
	for index in COUNT:
		_places.append(Vector3(random.randf_range(-1.0, 1.0), random.randf_range(-1.0, 1.0),
			random.randf_range(-1.0, 1.0)) * CLOUD)
		_phases.append(random.randf() * TAU)
	advance(0.0)


func _process(delta: float) -> void:
	advance(delta)


## Lets [param seconds] pass: the school swims on.
func advance(seconds: float) -> void:
	_time = fmod(_time + seconds, LAP * 10.0)
	for index in COUNT:
		multimesh.set_instance_transform(index, placement(index, _time))


## Where fish [param index] is [param t] seconds in, turned along the way.
func placement(index: int, t: float) -> Transform3D:
	var angle := TAU * t / LAP
	var ahead := Vector3(-sin(angle), 0.0, cos(angle))
	var aside := Vector3(cos(angle), 0.0, sin(angle))
	var place := _places[index]
	var waver := WAVER * sin(WAVER_RATE * t + _phases[index])
	var at := aside * (RADIUS + place.y + waver) + ahead * place.x
	at += Vector3(0.0, HEIGHT + place.z, 0.0)
	# The fish is long on z, its nose (-z) pointing the way the school goes.
	var tail := -ahead
	var basis := Basis(Vector3.UP.cross(tail), Vector3.UP, tail)
	return Transform3D(basis * Basis.from_scale(BODY), at)

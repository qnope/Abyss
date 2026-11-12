class_name BasePartsMotion
extends RefCounted
## The moving parts of the buildings other than the headquarters, the solar
## panel and the citadel, each named by the pad and the node of its model
## (`CoralMine/Wheel`): what turns (the drill, the winch wheels, the drone,
## the laboratory's atom), what bobs (the drone), what swells (the kernel's
## flame) and the lamps that pulse (the beacons, the flame). A degraded
## building stays still.

## What turns: degrees per second around each axis.
const SPINS: Dictionary[String, Vector3] = {
	"OreExtractor/Drill": Vector3(0.0, 240.0, 0.0),
	"CoralMine/Wheel": Vector3(0.0, 0.0, 70.0),
	"CoralMine/CrownWheel": Vector3(0.0, 0.0, 70.0),
	"AlgaeFarm/Drone": Vector3(0.0, 40.0, 0.0),
	"Laboratory/Atom": Vector3(0.0, 50.0, 0.0),
}
## What bobs: the height it goes up and down each way.
const BOBS: Dictionary[String, float] = {"AlgaeFarm/Drone": 0.03}
## What swells: how much its size grows at the most.
const SWELLS: Dictionary[String, float] = {"VolcanicKernel/Flame": 0.08}
## The lamps that pulse: the surface of the part, then its dimmest and
## brightest emission.
const LAMPS: Dictionary[String, Vector3] = {
	"DescentModule/Beacon": Vector3(1.0, 0.4, 4.0),
	"PressureCapsule/Beacon": Vector3(1.0, 0.4, 4.0),
	"VolcanicKernel/Flame": Vector3(0.0, 1.2, 3.4),
}
## How long a bob and a pulse take, in seconds.
const BOB_CYCLE := 4.0
const PULSE_CYCLE := 2.5

var _parts: Dictionary[String, Node3D] = {}
var _rest: Dictionary[String, Vector3] = {}
var _lamps: Dictionary[String, StandardMaterial3D] = {}


## Finds the moving parts of the buildings standing in [param buildings]:
## after each build.
func track(buildings: BaseBuildings) -> void:
	_parts.clear()
	_rest.clear()
	_lamps.clear()
	for key: String in _keys():
		var pad := StringName(key.get_slice("/", 0))
		var model := buildings.building(pad)
		if model == null or buildings.is_degraded(pad):
			continue
		var node := model.find_child(key.get_slice("/", 1), true, false) as Node3D
		if node == null:
			continue
		_parts[key] = node
		_rest[key] = node.position
		_light(key, node as MeshInstance3D)


## Moves everything to [param t] seconds in.
func advance(t: float) -> void:
	for key: String in _parts:
		var part := _parts[key]
		var bob := BOBS[key] if BOBS.has(key) else 0.0
		var swell := SWELLS[key] if SWELLS.has(key) else 0.0
		var spin := SPINS[key] if SPINS.has(key) else Vector3.ZERO
		part.position = _rest[key] + Vector3.UP * bob * sin(TAU * t / BOB_CYCLE)
		part.rotation = spin * t * PI / 180.0
		part.scale = Vector3.ONE * (1.0 + swell * _beat(t))
	for key: String in _lamps:
		var range_: Vector3 = LAMPS[key]
		_lamps[key].emission_energy_multiplier = lerpf(range_.y, range_.z, _beat(t))


## The pulse, from 0 to 1 and back each cycle.
static func _beat(t: float) -> float:
	return 0.5 + 0.5 * sin(TAU * t / PULSE_CYCLE)


func _keys() -> Array[String]:
	var keys: Array[String] = []
	for source: Dictionary[String, Vector3] in [SPINS, LAMPS]:
		keys.append_array(source.keys())
	for source: Dictionary[String, float] in [BOBS, SWELLS]:
		keys.append_array(source.keys())
	var unique: Array[String] = []
	for key in keys:
		if not unique.has(key):
			unique.append(key)
	return unique


func _light(key: String, mesh: MeshInstance3D) -> void:
	if not LAMPS.has(key):
		return
	var surface := int((LAMPS[key] as Vector3).x)
	var lamp := mesh.mesh.surface_get_material(surface).duplicate() as StandardMaterial3D
	mesh.set_surface_override_material(surface, lamp)
	_lamps[key] = lamp

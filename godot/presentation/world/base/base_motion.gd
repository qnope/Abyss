class_name BaseMotion
extends Node
## The base's slow life, the moving parts the models leave as nodes: the
## headquarters' Beacon spins and flashes and its Dish sweeps the water,
## the solar panel's Array tracks the light, the citadel's Heart beats, and
## the empty pads breathe; [BasePartsMotion] moves the other buildings' parts.
## A few transforms and two lamps a frame.

## A flash of the beacon, a beat of the heart, in seconds.
const FLASH_CYCLE := 2.0
const BEAT_CYCLE := 3.0
## The dish's and the array's sweeps: their half-angles and periods.
const DISH_SWEEP := 50.0
const DISH_CYCLE := 14.0
const ARRAY_SWEEP := 22.0
const ARRAY_CYCLE := 30.0
## The beacon's and the heart's turns, in degrees per second.
const BEACON_SPIN := 90.0
const HEART_SPIN := 18.0
## The lamps' light, between rest and their brightest.
const BEACON_LIGHT := Vector2(0.3, 4.0)
const HEART_LIGHT := Vector2(1.6, 3.2)
const HEART_SWELL := 0.07

var _buildings: BaseBuildings
var _marker: PadMarker
var _time := 0.0
var _parts: Dictionary[StringName, Node3D] = {}
var _lamps: Dictionary[StringName, StandardMaterial3D] = {}
var _others := BasePartsMotion.new()


func _init(buildings: BaseBuildings, marker: PadMarker) -> void:
	_buildings = buildings
	_marker = marker


## Finds the moving parts of the buildings standing: after each build.
func track() -> void:
	_parts.clear()
	_lamps.clear()
	_track(&"Headquarters", &"Beacon", true)
	_track(&"Headquarters", &"Dish", false)
	_track(&"SolarPanel", &"Array", false)
	_track(&"CoralCitadel", &"Heart", true)
	_others.track(_buildings)


func _process(delta: float) -> void:
	advance(delta)


## Moves everything [param seconds] on.
func advance(seconds: float) -> void:
	_time = fmod(_time + seconds, 600.0)
	var t := _time
	_turn(&"Beacon", deg_to_rad(BEACON_SPIN * t))
	_turn(&"Dish", sweep(t, DISH_SWEEP, DISH_CYCLE))
	_turn(&"Array", sweep(t, ARRAY_SWEEP, ARRAY_CYCLE))
	_turn(&"Heart", deg_to_rad(HEART_SPIN * t))
	var beat := 0.5 + 0.5 * sin(TAU * t / BEAT_CYCLE)
	if _parts.has(&"Heart"):
		_parts[&"Heart"].scale = Vector3.ONE * (1.0 + HEART_SWELL * beat)
	_light(&"Beacon", lerpf(BEACON_LIGHT.x, BEACON_LIGHT.y, flash(t)))
	_light(&"Heart", lerpf(HEART_LIGHT.x, HEART_LIGHT.y, beat))
	_others.advance(t)
	_marker.breathe(t)


## A swing of [param degrees] each way over [param cycle] seconds, in
## radians, [param t] seconds in.
static func sweep(t: float, degrees: float, cycle: float) -> float:
	return deg_to_rad(degrees) * sin(TAU * t / cycle)


## The beacon's flash, from 0 to 1: short, once a cycle.
static func flash(t: float) -> float:
	return pow(maxf(sin(TAU * t / FLASH_CYCLE), 0.0), 12.0)


func _track(building: StringName, part: StringName, lit: bool) -> void:
	var model := _buildings.building(building)
	# A degraded building is greyed and still.
	if model == null or _buildings.is_degraded(building):
		return
	# A stand-in has no moving part.
	var node := model.get_node_or_null("%s/%s" % [building, part]) as Node3D
	if node == null:
		return
	_parts[part] = node
	if lit:
		var mesh := node as MeshInstance3D
		var lamp := mesh.mesh.surface_get_material(1).duplicate() as StandardMaterial3D
		mesh.set_surface_override_material(1, lamp)
		_lamps[part] = lamp


func _turn(part: StringName, angle: float) -> void:
	if _parts.has(part):
		_parts[part].rotation.y = angle


func _light(part: StringName, energy: float) -> void:
	if _lamps.has(part):
		_lamps[part].emission_energy_multiplier = energy

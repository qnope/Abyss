class_name BaseScene
extends Node3D
## The player's base in 3D: the island and its rampart, the buildings on
## their pads and the empty pads marked on the deck, lit from the surface
## and seen by the orbit camera. A tap on a pad, or on its building, is
## told by pad_tapped.

## The player tapped the pad [param pad], or the building on it.
signal pad_tapped(pad: StringName)

const ISLAND := preload("res://assets/models/base_island.glb")
const RAMPART := preload("res://assets/models/base_rampart.glb")
## The buildings of the 3D prototype.
const BUILT: Array[StringName] = [&"Headquarters", &"SolarPanel", &"CoralCitadel"]
## The meshes whose shadows are not worth their triangles in each of the
## two shadow passes: glowing trims and algae, too thin to see; the deck,
## which only shadows itself; the island's rocks, mostly under the deck,
## and its coral, small on the rims. The buildings and the rampart keep
## theirs: 124k triangles drawn, 88k more for the shadows, not 211k.
const NO_SHADOW: Array[String] = [
	"*_glow", "*_glow_pink", "*_algae", "Island_stone", "Island_rock", "Island_coral",
]

## How far the rampart has grown with the coral citadel, from 1 to 3.
@export_range(1, 3) var rampart_tier := 1:
	set = set_rampart_tier

var camera := OrbitCamera.new()
var key_light := KeyLight.new()
var buildings := BaseBuildings.new()
var pads: BasePads
var _rampart := RAMPART.instantiate() as Node3D


func _init() -> void:
	var island := ISLAND.instantiate() as Node3D
	island.name = &"Island"
	add_child(island)
	pads = BasePads.new(island.get_node("Pads") as Node3D)
	_rampart.name = &"Rampart"
	add_child(_rampart)
	add_child(buildings)
	add_child(key_light)
	add_child(camera)
	build(BUILT)
	set_rampart_tier(rampart_tier)
	_quiet_shadows(island)
	_quiet_shadows(_rampart)
	camera.tapped.connect(_on_tapped)


## Stands the buildings [param names] on their pads, the others empty.
func build(names: Array[StringName]) -> void:
	buildings.build(names, pads)
	pads.mark(names)
	for name in names:
		_quiet_shadows(buildings.building(name))


## Turns the key light's shadows on or off.
func set_shadows(enabled: bool) -> void:
	key_light.set_shadows(enabled)


func set_rampart_tier(tier: int) -> void:
	rampart_tier = clampi(tier, 1, 3)
	for index in _rampart.get_child_count():
		(_rampart.get_child(index) as Node3D).visible = index < rampart_tier


func _on_tapped(position: Vector2) -> void:
	# The pads are in the base's space.
	var to_base := global_transform.affine_inverse()
	var origin := to_base * camera.project_ray_origin(position)
	var picked := pads.pick(origin, to_base.basis * camera.project_ray_normal(position))
	if picked != &"":
		pad_tapped.emit(picked)


static func _quiet_shadows(model: Node) -> void:
	for node: Node in model.find_children("*", "GeometryInstance3D", true, false):
		for pattern in NO_SHADOW:
			if String(node.name).match(pattern):
				(node as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

class_name BaseScene
extends Node3D
## The player's base in 3D: the island and its rampart, the buildings on
## their pads and the empty pads marked on the deck, lit from the surface
## and seen by the orbit camera. Each pad shows its building, a model or a
## stand-in ([WorldModels]), its level and the signs that tell what it needs
## ([PadMarks], and the glow of [PadHalos] behind a building that can rise); a
## tap on a pad, built or not, or on its building, is told by building_tapped.

## The player tapped the pad, or the building on it, of [param type].
signal building_tapped(type: BuildingType.Value)

const ISLAND := preload("res://assets/models/base_island.glb")
const RAMPART := preload("res://assets/models/base_rampart.glb")
## The buildings of the 3D prototype.
const BUILT: Array[StringName] = [&"Headquarters", &"SolarPanel", &"CoralCitadel"]
## The way the rays of light fall: nearly straight down, steeper than the
## key light, so that they cross every view of the orbit instead of
## running along it.
const RAYS := Vector3(-0.12, -1.0, -0.22)

## The island's outline the default view fits to the screen: its rims along
## the axes and the diagonals, from the coral on its top to the strata under
## its deck, and the headquarters' beacon.
const OUTLINE: PackedVector3Array = [
	Vector3(8.1, 1.0, 0.0), Vector3(-8.1, 1.0, 0.0), Vector3(0.0, 1.0, 8.1), Vector3(0.0, 1.0, -8.1),
	Vector3(7.4, 1.0, 7.4), Vector3(-7.4, 1.0, 7.4), Vector3(7.4, 1.0, -7.4), Vector3(-7.4, 1.0, -7.4),
	Vector3(8.1, -1.5, 0.0), Vector3(-8.1, -1.5, 0.0), Vector3(0.0, -1.5, 8.1), Vector3(0.0, -1.5, -8.1),
	Vector3(7.4, -1.5, 7.4), Vector3(-7.4, -1.5, 7.4), Vector3(7.4, -1.5, -7.4),
	Vector3(-7.4, -1.5, -7.4), Vector3(0.4, 3.2, 0.4),
]

## How far the rampart has grown with the coral citadel, from 0 (none) to 3.
@export_range(0, 3) var rampart_tier := 1:
	set = set_rampart_tier

var camera := OrbitCamera.new()
var key_light := KeyLight.new()
var water := UnderwaterEnvironment.new()
var buildings := BaseBuildings.new()
var marks := PadMarks.new()
## The glow of the buildings that can rise.
var halos := PadHalos.new()
## The ring the tutorial's guide puts around the pad it points at.
var guide := GuideRing.new()
var pads: BasePads
var motion: BaseMotion
var snow := MarineSnow.new()
var bubbles := RisingBubbles.new()
var _shown := ""
var _rampart := RAMPART.instantiate() as Node3D


func _init() -> void:
	var island := ISLAND.instantiate() as Node3D
	island.name = &"Island"
	add_child(island)
	pads = BasePads.new(island.get_node("Pads") as Node3D)
	_rampart.name = &"Rampart"
	add_child(_rampart)
	motion = BaseMotion.new(buildings, pads.marker)
	for part: Node in [buildings, marks, halos, guide, key_light, water, LightShafts.new(RAYS),
			motion, snow, bubbles, camera]:
		add_child(part)
	build(BUILT)
	BaseShadows.quiet(island)
	BaseShadows.quiet(_rampart)
	camera.tapped.connect(_on_tapped)


## Stands the buildings [param names] on their pads at level 1, the others
## empty, and the rampart at its first tier if the citadel is among them: the
## prototype's and the menus' base.
func build(names: Array[StringName]) -> void:
	_show(PadState.standing(names))
	set_rampart_tier(BuildingTier.rampart_of(1 if names.has(&"CoralCitadel") else 0))


## Shows the base of a game: each building of [param held] on its pad at its
## level (greyed when degraded), the rampart at the tier of the citadel's
## level, and the signs: [param upgradable], the buildings that can rise now
## (and the plots that can be built on), and [param locked], the plots held
## back by a prerequisite. The same base again changes nothing.
func show_base(
	held: Dictionary[BuildingType.Value, Building],
	upgradable: Dictionary[BuildingType.Value, bool] = {},
	locked: Dictionary[BuildingType.Value, bool] = {},
) -> void:
	_show(PadState.of_base(held, upgradable, locked))
	set_rampart_tier(BuildingTier.rampart_of(
		Building.level_in(held, BuildingType.Value.CORAL_CITADEL)))


## Fits the default view to the screen, the island centred between the top
## [param hud] share of it and its bottom [param foot] share.
func frame(hud: float, foot := 0.0) -> void:
	camera.fit(OUTLINE, hud, foot)


## Turns the key light's shadows on or off.
func set_shadows(enabled: bool) -> void:
	key_light.set_shadows(enabled)


## Turns the glow of the lights on or off.
func set_glow(enabled: bool) -> void:
	water.set_glow(enabled)


## Runs the marine snow and the bubbles, or stops and hides them.
func set_particles(enabled: bool) -> void:
	snow.set_running(enabled)
	bubbles.set_running(enabled)


func set_rampart_tier(tier: int) -> void:
	rampart_tier = clampi(tier, 0, 3)
	for index in _rampart.get_child_count():
		(_rampart.get_child(index) as Node3D).visible = index < rampart_tier


func _show(states: Array[PadState]) -> void:
	var signature := PadState.signature_of(states)
	if signature == _shown:
		return
	_shown = signature
	buildings.build(states, pads)
	pads.mark(buildings.names())
	pads.fit_reach(buildings)
	motion.track()
	marks.show_marks(states, pads, buildings)
	halos.show_halos(states, pads, buildings)
	BaseShadows.quiet(buildings)
	bubbles.rise_from(pads.origins_of(buildings.names()))


func _on_tapped(position: Vector2) -> void:
	# The pads are in the base's space.
	var to_base := global_transform.affine_inverse()
	var origin := to_base * camera.project_ray_origin(position)
	var picked := pads.pick(origin, to_base.basis * camera.project_ray_normal(position))
	if picked != &"":
		building_tapped.emit(BaseBuildings.type_of(picked))

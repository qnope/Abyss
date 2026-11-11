class_name ParadeScene
extends Node3D
## The army's parade ground in 3D, shown on the army tab as the base is on the
## base tab: a deck with the barracks at the back and one drill pad for each
## of the six units, a squad of figures standing on it ([WorldModels.unit]: a
## stand-in until step 7) with its count and caption over it, a green plus on
## the squads that can recruit now and a ghost and a padlock on those the
## barracks is too low for. Lit from the surface and seen by an orbit camera;
## the ambience (the water, the sky) is the base's, which shares it.
##
## [method show_army] draws what `app/` gives it, read from the game; a tap on
## a squad or on the barracks is told by [signal squad_tapped] and
## [signal barracks_tapped].

## The player tapped the squad of [param type], locked or not.
signal squad_tapped(type: UnitType.Value)
## The player tapped the barracks, built or not.
signal barracks_tapped

## The share of the screen kept free at the bottom for the bar of the places,
## which floats there.
const PLACE_BAR_ROOM := 0.08

var camera := OrbitCamera.new()
var key_light := KeyLight.new()
var ground := ParadeGround.new()
var barracks := ParadeBarracks.new()
var squads: Dictionary[UnitType.Value, Squad] = {}
var _shown := ""


func _init() -> void:
	name = &"Parade"
	add_child(ground)
	add_child(barracks)
	for type: UnitType.Value in UnitType.Value.values():
		var squad := Squad.new(type)
		squads[type] = squad
		add_child(squad)
	add_child(key_light)
	add_child(camera)
	camera.tapped.connect(_on_tapped)
	show_army([], PadState.new(BuildingType.Value.BARRACKS))


## Shows the army: the squads of [param states], the ones not given left
## out, and the barracks as [param plot] says. The same army again changes
## nothing.
func show_army(states: Array[SquadState], plot: PadState) -> void:
	var signature := "%s|%s" % [SquadState.signature_of(states), plot.signature()]
	if signature == _shown:
		return
	_shown = signature
	var given: Dictionary[UnitType.Value, bool] = {}
	for state in states:
		given[state.type] = true
		squads[state.type].show_state(state)
	for type: UnitType.Value in squads:
		squads[type].visible = given.has(type)
	barracks.show_state(plot)


## Fits the default view to the screen, the deck centred between the top
## [param hud] share of it and its bottom [param foot] share (and the room of
## the bar of the places).
func frame(hud: float, foot := 0.0) -> void:
	camera.fit(ParadeLayout.OUTLINE, hud, foot + PLACE_BAR_ROOM)


## Turns the key light's shadows on or off.
func set_shadows(enabled: bool) -> void:
	key_light.set_shadows(enabled)


## The boxes a tap picks, by key: each squad's (its unit's value) and the
## barracks' ([constant ParadePick.BARRACKS]).
func boxes() -> Dictionary[int, AABB]:
	var found: Dictionary[int, AABB] = {ParadePick.BARRACKS: barracks.box()}
	for type: UnitType.Value in squads:
		if squads[type].visible:
			found[type] = squads[type].box()
	return found


func _on_tapped(position: Vector2) -> void:
	# The boxes are in the parade's space.
	var to_parade := global_transform.affine_inverse()
	var origin := to_parade * camera.project_ray_origin(position)
	var picked := ParadePick.pick(boxes(), origin, to_parade.basis * camera.project_ray_normal(position))
	if picked == ParadePick.BARRACKS:
		barracks_tapped.emit()
	elif picked != ParadePick.NONE:
		squad_tapped.emit(picked as UnitType.Value)

class_name MapScene
extends Node3D
## The map of a level in 3D, shown on the map tab as the base is on the base
## tab: a tile for each cell (dark and lower while it is not seen), what lies
## on the cells seen, the scouts on their way, and round and over the slab the
## scenery, the creature and the specks. Lit as its level is (the key light
## is its own, the water the base's, which shares it) and seen by a camera that
## pans and zooms. One level at a time: [method show_level] draws what `app/`
## reads from the game, and a tap on a cell is told by [signal cell_tapped].

## The player tapped the cell ([param x], [param y]) of [param level].
signal cell_tapped(level: int, x: int, y: int)
## A level was drawn: the water's light follows it.
signal level_shown(level: int)

## The share of the screen kept free at the top for the level selector, which
## floats there.
const LEVEL_BAR_ROOM := 0.08

var camera := MapCamera.new()
var key_light := KeyLight.new()
var tiles := MapTiles.new()
var fog := MapFog.new()
## The scenery, the creature and the specks round and over the slab.
var surroundings := MapSurroundings.new()
var contents := MapContents.new()
var scouts := MapScouts.new()
## What plays over the cells: the fog lifting, the strikes and sieges.
var effects := MapEffects.new()
## The ring the tutorial's guide puts around the cell it points at.
var guide := MapGuide.new()
## The level on show, 0 before the first.
var level := 0
var state: MapLevelState
## The shares of the screen the bars keep free, at the top and at the bottom.
var _bars := Vector2.ZERO
var _lifts := FogLifts.new()


func _init() -> void:
	name = &"Map"
	for part: Node in [surroundings, tiles, fog, contents, scouts, effects, guide, key_light, camera]:
		add_child(part)
	camera.tapped.connect(_on_tapped)
	camera.zoomed.connect(contents.cast_shadows)
	effects.jolted.connect(_on_jolted)


## Shows the level of [param next]: its floor, its contents and its scouts. A
## level not on show before is framed anew, the view back on the middle of the
## map; the same level again (a change of the game) keeps the view where the
## player left it.
func show_level(next: MapLevelState) -> void:
	effects.finish()
	var changed := next.level != level
	state = next
	level = next.level
	key_light.set_mood(LightMoods.of_level(level))
	var looks := MapLooks.of(next)
	tiles.show_looks(looks, next.map.width, next.map.height, level)
	fog.show_looks(looks, next.map.width, next.map.height)
	surroundings.show_level(level, next.map.width, next.map.height)
	contents.show_looks(looks, next.map.width, next.map.height)
	var left := scouts.show_scouts(next.pending, level, next.map.width, next.map.height)
	guide.shown_on(next)
	_lift_fog(looks, left)
	level_shown.emit(level)
	if changed:
		frame(_bars.x, _bars.y)
		camera.home()


## Plays [param attack], an army against what stands on a cell of the level shown
## (a lair's monsters, a post, a base, the volcano), calling [param then] once it
## is over: at once when no level is shown.
func strike(attack: MapStrike, then := Callable()) -> void:
	if state == null:
		if then.is_valid():
			then.call()
		return
	var origin := ScoutOrigin.of(attack.target, state.base, state.passage_holders, state.revealed)
	var geometry := StrikeGeometry.new(origin, attack.target, state.map.width, state.map.height, attack.span)
	var content: Node3D = contents.by_cell.get(attack.target)
	effects.play(StrikeEffect.new(attack, geometry, content), then)


## Plays [param attack], attackers besieging a place of the level shown, calling
## [param then] once it is over (at once when no level is shown).
func siege(attack: MapSiege, then := Callable()) -> void:
	if state == null:
		if then.is_valid():
			then.call()
		return
	var geometry := SiegeGeometry.new(attack.place, state.map.width, state.map.height, attack.span)
	var content: Node3D = contents.by_cell.get(attack.place)
	effects.play(SiegeEffect.new(attack, geometry, content), then)


## Forgets what the levels showed: the next one shown lifts no fog.
func forget() -> void:
	_lifts.forget()


## Fits the default view to the screen, the map centred between the top
## [param hud] share of it and its bottom [param foot] share (and the room of
## the level selector).
func frame(hud: float, foot := 0.0) -> void:
	_bars = Vector2(hud, foot)
	if state != null and is_inside_tree():
		camera.fit_map(state.map.width, state.map.height, hud + LEVEL_BAR_ROOM, foot)


## Turns the key light's shadows on or off.
func set_shadows(enabled: bool) -> void:
	key_light.set_shadows(enabled)


## Lets the specks of the water drift, or stops them (the quality panel's setting).
func set_particles(enabled: bool) -> void:
	surroundings.set_particles(enabled)


## Lifts the fog from the cells [param looks] sees for the first time, the scouts
## [param left] (their exploration over) leaving with it.
func _lift_fog(looks: Array[MapLook], left: Array[Vector2i]) -> void:
	var seen := _lifts.newly_seen(level, looks)
	if seen.is_empty():
		return
	var waited: Array[Vector2i] = []
	for target in left:
		if seen.has(target):
			waited.append(target)
	effects.play(FogLift.new(seen, state.map.width, state.map.height, FogLifts.hidden(looks), contents, waited))


func _on_jolted(offset: float) -> void:
	camera.jolt = offset


func _on_tapped(position: Vector2) -> void:
	if state == null:
		return
	# The cells are in the map's space.
	var to_map := global_transform.affine_inverse()
	var origin := to_map * camera.project_ray_origin(position)
	var picked: Variant = MapPick.cell(origin, to_map.basis * camera.project_ray_normal(position),
		state.map.width, state.map.height)
	if picked != null:
		var cell: Vector2i = picked
		cell_tapped.emit(level, cell.x, cell.y)

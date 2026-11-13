class_name FogLift
extends MapEffect
## The fog lifting from the cells a scout has just seen (lib/presentation/
## widgets/map/effects/story/map_fog_lift.dart): the map already shows those
## cells seen, so the lift covers them with the clouds as the shroud does, their
## contents hidden, holds a moment, then the clouds rise and fade away while the
## wisps puff out from the edge of what is still hidden, and the floor and its
## contents show. The scouts that waited on their cells shrink away with it.
##
## A cloud for each cell, three MultiMeshes in all (one for each of the three
## clouds), raised together: no node for a cell. The wisps are a few meshes along
## the edge only. Nothing casts a shadow, and each part fades through a copy of the
## murk material of its own, the original untouched.

## How long the fog holds before it lifts, and how long it takes to.
const HOLD := MapMotion.STORY_PAUSE
const LIFT := MapMotion.FADE
## How high the clouds rise, each at its own pace, and how far the wisps drift
## and swell.
const RISE: Array[float] = [0.9, 0.7, 1.1]
const DRIFT := 0.5
const SWELL := 0.7
## Where a wisp stands: out toward the cell still hidden, a little above the floor.
const EDGE := 0.4
const WISP_HEIGHT := 0.1
## The most wisps, so that a wide lift stays cheap: only every other hidden
## cell along the edge puffs.
const MAX_WISPS := 24

## The three layers of clouds, and the wisps.
var clouds: Array[MultiMeshInstance3D] = []
var wisps: Array[MeshInstance3D] = []
## The scouts leaving with the fog.
var scouts: Array[ScoutToken] = []
var _cells: Array[Vector2i]
var _contents: MapContents
var _cloud_fade: StandardMaterial3D
var _wisp_fade: StandardMaterial3D
var _wisp_homes: Array[Vector3] = []
var _wisp_dirs: Array[Vector3] = []


## The fog lifting from [param cells] (those seen) of a map [param width] by
## [param height], whose cells [param hidden] are still under the shroud, over
## [param contents] (the cells' standing contents), with the scouts that waited
## on [param waited].
func _init(
	cells: Array[Vector2i], width: int, height: int, hidden: Dictionary[Vector2i, bool],
	contents: MapContents, waited: Array[Vector2i] = [],
) -> void:
	name = &"FogLift"
	_cells = cells
	_contents = contents
	var parts := MapScenery.parts(MapScenery.FOG)
	_cloud_fade = _faded(parts[&"Cloud1"])
	_wisp_fade = _faded(parts[&"Wisp1"])
	var places: Dictionary[StringName, Array] = {}
	for cell in cells:
		var at := MapGrid.at(cell.x, cell.y, width, height)
		var chosen := StringName("Cloud%d" % (MapTiles.hash_of(cell.x, cell.y) % 3 + 1))
		if not places.has(chosen):
			places[chosen] = []
		places[chosen].append(Transform3D(MapTiles.turn_of(cell.x, cell.y), at))
		for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if hidden.has(cell + step) and _puffs(cell + step):
				_add_wisp(parts, at, Vector3(step.x, 0.0, step.y), cell)
	for cloud in MapScenery.named(parts, "Cloud"):
		if places.has(cloud):
			clouds.append(_layer(cloud, parts[cloud], places[cloud]))
	for target in waited:
		var scout := ScoutToken.new(MapGrid.at(target.x, target.y, width, height),
			MapGrid.at(target.x, target.y, width, height), false)
		scouts.append(scout)
		add_child(scout)
	_show(0.0)


func duration() -> float:
	return HOLD + LIFT


## How much of the fog is left [param t] seconds in: all of it, then none.
func opacity_at(t: float) -> float:
	return 1.0 - MapMotion.exit(MapMotion.share(t, HOLD, LIFT))


func _show(t: float) -> void:
	var lift := MapMotion.share(t, HOLD, LIFT)
	_cloud_fade.albedo_color.a = opacity_at(t)
	_wisp_fade.albedo_color.a = 1.0 - lift
	for index in clouds.size():
		clouds[index].position.y = RISE[index % RISE.size()] * MapMotion.enter(lift)
	for index in wisps.size():
		wisps[index].position = _wisp_homes[index] + _wisp_dirs[index] * DRIFT * MapMotion.enter(lift)
		wisps[index].scale = Vector3.ONE * (1.0 + SWELL * lift)
	for scout in scouts:
		scout.leave(MapMotion.enter(lift))
	var shown := t >= HOLD
	for cell in _cells:
		var content: Node3D = _contents.by_cell.get(cell)
		if content != null:
			content.visible = shown


func _layer(part_name: StringName, mesh: Mesh, places: Array) -> MultiMeshInstance3D:
	var layer := MapLayer.new(part_name, mesh, places)
	layer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	layer.material_override = _cloud_fade
	add_child(layer)
	return layer


## Whether the hidden cell [param cell] has a wisp coming off the edge of the lift.
func _puffs(cell: Vector2i) -> bool:
	return wisps.size() < MAX_WISPS and MapTiles.hash_of(cell.x, cell.y) % 2 == 0


func _add_wisp(parts: Dictionary[StringName, Mesh], at: Vector3, dir: Vector3, cell: Vector2i) -> void:
	var wisp := MeshInstance3D.new()
	wisp.name = &"Wisp"
	wisp.mesh = parts[StringName("Wisp%d" % (MapTiles.hash_of(cell.y, cell.x) % 3 + 1))]
	wisp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	wisp.material_override = _wisp_fade
	_wisp_homes.append(at + dir * EDGE + Vector3.UP * WISP_HEIGHT)
	_wisp_dirs.append(dir)
	wisps.append(wisp)
	add_child(wisp)


## A copy of the murk material of [param mesh], for a part to fade on its own.
static func _faded(mesh: Mesh) -> StandardMaterial3D:
	var murk := mesh.surface_get_material(0) as StandardMaterial3D
	return murk.duplicate() as StandardMaterial3D

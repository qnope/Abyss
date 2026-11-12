class_name MapFog
extends Node3D
## The shroud over the cells not seen: a stack of translucent sheets of murk
## ([code]Cloud1..3[/code] of map_fog.glb) on each, so that neighbours merge into
## one blanket over the dark tiles. One MultiMesh for each of the three clouds,
## drawn blended, never casting a shadow: a handful of draw calls for the whole
## level. A cloud is 384 triangles, so the shroud is thick only near what is
## seen, where it is lifted: [constant BAND] cells deep every cell has its cloud,
## beyond only every other cell, as the black squares of a chessboard (a cloud
## spreads over its neighbours, so the blanket holds), over the dark tiles. A
## wreck seen through the fog has none over it. Which cloud, and its quarter
## turn, come from the cell alone, as the tiles' do.

## How high the clouds' floor lies: level with the floor of a cell seen, over
## the fog tiles, which lie lower.
const FLOOR := 0.0
## How many cells deep from the cells seen the shroud is whole.
const BAND := 2

## How many clouds stand, by the name of the cloud ("Cloud2").
var counts: Dictionary[StringName, int] = {}


## Covers the cells of [param looks] not seen (a map [param width] by
## [param height]) with clouds, in place of the ones before.
func show_looks(looks: Array[MapLook], width: int, height: int) -> void:
	for child: Node in get_children():
		child.free()
	counts.clear()
	var parts := MapScenery.parts(MapScenery.FOG)
	var clouds := MapScenery.named(parts, "Cloud")
	var spots: Dictionary[StringName, Array] = {}
	for look in clouded(looks, width, height):
		var chosen := clouds[MapTiles.hash_of(look.x, look.y) % clouds.size()]
		if not spots.has(chosen):
			spots[chosen] = []
		spots[chosen].append(Transform3D(MapTiles.turn_of(look.x, look.y),
			MapGrid.at(look.x, look.y, width, height) + Vector3.UP * FLOOR))
	for cloud in spots:
		var places: Array = spots[cloud]
		counts[cloud] = places.size()
		var layer := MapLayer.of(cloud, parts[cloud], places)
		layer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(layer)


## The cells of [param looks] that stand under a cloud.
static func clouded(looks: Array[MapLook], width: int, height: int) -> Array[MapLook]:
	var near := _near_the_seen(looks, width, height)
	var found: Array[MapLook] = []
	for look in looks:
		if shrouded(look) and (near.has(look.key()) or (look.x + look.y) % 2 == 0):
			found.append(look)
	return found


## Whether the cell of [param look] lies under the shroud: not seen, and not a
## beacon (a wreck, which must show through the fog).
static func shrouded(look: MapLook) -> bool:
	return not look.revealed and not look.beacon


## The cells within [constant BAND] cells of a cell seen (the seen ones too).
static func _near_the_seen(looks: Array[MapLook], width: int, height: int) -> Dictionary[Vector2i, bool]:
	var near: Dictionary[Vector2i, bool] = {}
	for look in looks:
		if not look.revealed:
			continue
		for y in range(maxi(look.y - BAND, 0), mini(look.y + BAND + 1, height)):
			for x in range(maxi(look.x - BAND, 0), mini(look.x + BAND + 1, width)):
				near[Vector2i(x, y)] = true
	return near

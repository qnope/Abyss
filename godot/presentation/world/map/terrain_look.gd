class_name TerrainLook
extends RefCounted
## How the floor of a cell stands: a colour (of the stand-in floor, the model's
## tiles being drawn by [MapTiles]) and the height of its top, which is where
## what stands on the cell is put. A cell not seen is dark and lower, as under a
## cover of fog. [method WorldModels.terrain] is the one place that says it.

## How far below the sea floor a cell not seen lies.
const FOG_DROP := 0.2

var colour: Color
## The height of the tile's top, from the floor at 0.
var height: float


func _init(colour_: Color, height_: float) -> void:
	colour = colour_
	height = height_


## The floor of [param terrain], seen or not.
static func of(terrain: TerrainType.Value, revealed: bool) -> TerrainLook:
	if not revealed:
		return TerrainLook.new(MapPalette.FOG, -FOG_DROP)
	return TerrainLook.new(MapPalette.TERRAINS[terrain], 0.0)

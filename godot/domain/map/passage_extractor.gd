class_name PassageExtractor
extends RefCounted
## lib/domain/map/passage_extractor.dart: the transition bases of a level,
## which the level below holds as passages.


## The name of each post of the map by the key of its position
## (`GridPosition.key()`), row by row.
static func from(map: GameMap) -> Dictionary[Vector2i, String]:
	var result: Dictionary[Vector2i, String] = {}
	var index := 0
	for y: int in map.height:
		for x: int in map.width:
			var cell := map.cells[index]
			index += 1
			if (
				cell.content == CellContentType.Value.TRANSITION_BASE
				and cell.transition_base != null
			):
				result[Vector2i(x, y)] = cell.transition_base.name
	return result

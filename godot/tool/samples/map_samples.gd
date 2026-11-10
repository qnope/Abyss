class_name MapSamples
extends RefCounted
## Sample maps for the tests of godot/domain/map, and what the Dart tests
## read from a map through test/helpers/map_fingerprint.dart and
## transition_base_helpers.dart.


## As many bare cells: a plain terrain, nothing on it.
static func plain_cells(count: int) -> Array[MapCell]:
	var cells: Array[MapCell] = []
	for _index: int in count:
		cells.append(MapCell.new(TerrainType.Value.PLAIN))
	return cells


## A map of bare cells.
static func plain_map(width: int, height: int, seed_ := 1) -> GameMap:
	return GameMap.new(width, height, plain_cells(width * height), seed_)


## The indices of the cells that hold `content`.
static func indices_of(cells: Array[MapCell], content: CellContentType.Value) -> Array[int]:
	var found: Array[int] = []
	for index: int in cells.size():
		if cells[index].content == content:
			found.append(index)
	return found


## `transitionBaseIndices`: the indices of the cells that hold a post.
static func transition_base_indices(cells: Array[MapCell]) -> Array[int]:
	return indices_of(cells, CellContentType.Value.TRANSITION_BASE)


## The content of every cell, in the order of the grid.
static func contents(cells: Array[MapCell]) -> Array:
	return cells.map(func(cell: MapCell) -> CellContentType.Value: return cell.content)


## `chebyshev`: the distance between two cells, a diagonal step counting one.
static func chebyshev(x1: int, y1: int, x2: int, y2: int) -> int:
	return maxi(absi(x1 - x2), absi(y1 - y2))


## `passagesOf`: the posts of the map, as the passages of the level below.
static func passages_of(map: GameMap) -> Dictionary[Vector2i, String]:
	var passages: Dictionary[Vector2i, String] = {}
	for index: int in transition_base_indices(map.cells):
		var key := Vector2i(index % map.width, DartMath.trunc_div(index, map.width))
		passages[key] = map.cells[index].transition_base.name
	return passages


## `mapFingerprint`: the 32-bit FNV-1a hash the Dart tests pin a generated
## map with, of every field of every cell written as Dart writes them.
static func fingerprint(map: GameMap) -> int:
	var texts := PackedStringArray(["%dx%ds%d" % [map.width, map.height, map.map_seed]])
	for cell: MapCell in map.cells:
		var lair := cell.lair
		var base := cell.transition_base
		texts.append("|%s,%s,%s:%s:%s,%s:%s:%s,%s,%s" % [
			DartEnum.name_of(TerrainType.Value, cell.terrain),
			DartEnum.name_of(CellContentType.Value, cell.content),
			"null" if lair == null else DartEnum.name_of(MonsterDifficulty.Value, lair.difficulty),
			"null" if lair == null else str(lair.unit_count),
			_family(lair),
			"null" if base == null else DartEnum.name_of(TransitionBaseType.Value, base.type),
			"null" if base == null else base.name,
			_text(null if base == null else base.captured_by),
			_text(cell.passage_name),
			_text(cell.collected_by),
		])
	var fnv := 0x811c9dc5
	# Code units in Dart; the names of a map are ASCII, one unit a character.
	var text := "".join(texts)
	for index: int in text.length():
		fnv = ((fnv ^ text.unicode_at(index)) * 0x01000193) & 0xFFFFFFFF
	return fnv


## `lair?.family?.name` as Dart's string interpolation writes it.
static func _family(lair: MonsterLair) -> String:
	if lair == null:
		return "null"
	return _text(VectorInputs.name_or_null(MonsterFamily.Value, lair.family))


## A value as Dart's string interpolation writes it.
static func _text(value: Variant) -> String:
	return "null" if value == null else str(value)

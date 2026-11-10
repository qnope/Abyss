class_name WreckSites
extends RefCounted
## lib/domain/event/effects/wreck_sites.dart: the cells where a wreck may
## sink: hidden from the player, empty, and just at the edge of the explored
## area, so a scout can explore them.

## The wreck sinks on level 1 only.
const LEVEL := 1


## The sites of `map` for `player`, in row-major order. Walks the
## neighbours of the revealed cells only, so the search grows with the
## explored area, not with the map.
static func of(map: GameMap, player: Player) -> Array[GridPosition]:
	var revealed := player.revealed_cells_on_level(LEVEL)
	var known := PlayerHoldings.key_set(revealed)
	var visited: Dictionary[int, bool] = {}
	var sites: Array[int] = []
	for p: GridPosition in revealed:
		for dy: int in range(-1, 2):
			for dx: int in range(-1, 2):
				var x := p.x + dx
				var y := p.y + dy
				if x < 0 or x >= map.width or y < 0 or y >= map.height:
					continue
				var index := y * map.width + x
				if visited.has(index):
					continue
				visited[index] = true
				if _fits(map, player, known, x, y):
					sites.append(index)
	# Distinct whole numbers: Godot's sort without comparator orders them as
	# Dart's.
	sites.sort()
	var positions: Array[GridPosition] = []
	for i: int in sites:
		positions.append(GridPosition.new(i % map.width, DartMath.trunc_div(i, map.width)))
	return positions


static func _fits(
	map: GameMap, player: Player, known: Dictionary[Vector2i, bool], x: int, y: int
) -> bool:
	if known.has(Vector2i(x, y)):
		return false
	var cell := map.cell_at(x, y)
	return (
		cell.content == CellContentType.Value.EMPTY
		and not cell.is_collected()
		and CellEligibilityChecker.is_eligible_among(map, player, known, x, y)
	)

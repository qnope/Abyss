class_name MapLooks
extends RefCounted
## The look of every cell of a level, row by row (lib/presentation/widgets/map/
## map_visuals_builder.dart and `MapCellVisual.from`): a cell not seen shows
## nothing of what it holds, except a wreck not searched yet, which shows
## through the fog; a cell seen shows its content, dull once emptied, a post
## and its passage in the colour of who holds them, the volcano with the seal of
## its owner and whole as soon as one of its cells is seen.

const _KERNEL := CellContentType.Value.VOLCANIC_KERNEL
const Kind := MapContent.Kind


## The looks of the cells of [param state]'s map, in the order of the grid.
static func of(state: MapLevelState) -> Array[MapLook]:
	var seen := _with_whole_volcano(state.map, state.revealed)
	var looks: Array[MapLook] = []
	for y: int in state.map.height:
		for x: int in state.map.width:
			looks.append(_look(state, seen, x, y))
	return looks


static func _look(
	state: MapLevelState, seen: Dictionary[Vector2i, bool], x: int, y: int
) -> MapLook:
	var cell := state.map.cell_at(x, y)
	var look := MapLook.new(x, y, cell.terrain, seen.has(Vector2i(x, y)))
	if not look.revealed:
		# Content seen through the fog: a wreck not searched yet.
		if cell.content == CellContentType.Value.WRECK and not cell.is_collected():
			look.content = Kind.WRECK
			look.beacon = true
		return look
	look.content = _content_of(look, cell, state)
	look.dimmed = cell.is_collected() and cell.content != _KERNEL
	if cell.content == _KERNEL:
		look.span = VolcanicKernelPlacer.SIDE
		if cell.is_collected():
			look.tint = state.owner_colors.get(str(cell.collected_by))
	return look


## What stands on a cell seen, and its tint when it has one.
static func _content_of(look: MapLook, cell: MapCell, state: MapLevelState) -> Variant:
	var key := look.key()
	var base := cell.transition_base
	var holder: PostHolder.Value = PostHolder.of(base, state.human_id) if base != null \
		else state.passage_holders.get(key, PostHolder.Value.GUARDIANS)
	if cell.content == CellContentType.Value.TRANSITION_BASE and base != null:
		look.tint = MapPalette.HOLDERS[holder]
		return Kind.FAILLE if base.type == TransitionBaseType.Value.FAILLE else Kind.CHEMINEE
	if cell.content == CellContentType.Value.PASSAGE:
		look.tint = MapPalette.HOLDERS[holder]
		return Kind.PASSAGE
	if cell.content == CellContentType.Value.TRANSITION_BASE \
			or cell.content == CellContentType.Value.VOLCANIC_KERNEL_PART:
		return null
	if state.base == key:
		return Kind.HOME
	if state.faction_bases.has(key):
		look.tint = state.faction_bases[key]
		return Kind.FACTION_BASE
	match cell.content:
		CellContentType.Value.MONSTER_LAIR:
			return MapContent.lair_of(cell.lair.difficulty) if cell.lair != null else null
		CellContentType.Value.RESOURCE_BONUS:
			return Kind.TREASURE
		CellContentType.Value.RUINS:
			return Kind.RUINS
		CellContentType.Value.WRECK:
			return Kind.WRECK
		CellContentType.Value.VOLCANIC_KERNEL:
			return Kind.KERNEL
	return null


## The cells seen, the volcano whole as soon as one of its cells is.
static func _with_whole_volcano(
	map: GameMap, revealed: Dictionary[Vector2i, bool]
) -> Dictionary[Vector2i, bool]:
	var seen: Dictionary[Vector2i, bool] = {}
	for key: Vector2i in revealed:
		seen[key] = true
	for y: int in map.height:
		for x: int in map.width:
			if map.cell_at(x, y).content != _KERNEL:
				continue
			var footprint := VolcanicKernelPlacer.footprint(x, y)
			if footprint.any(func(cell: Vector2i) -> bool: return revealed.has(cell)):
				for cell: Vector2i in footprint:
					seen[cell] = true
	return seen

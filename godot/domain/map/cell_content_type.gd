class_name CellContentType
extends RefCounted
## lib/domain/map/cell_content_type.dart: what a cell of a map holds.

enum Value {
	EMPTY,
	RESOURCE_BONUS,
	RUINS,
	MONSTER_LAIR,
	TRANSITION_BASE,
	PASSAGE,
	VOLCANIC_KERNEL,
	## Sunk by a random event for a few turns, never by the map generator.
	WRECK,
	## One of the three non-anchor cells of the 2x2 volcano; the anchor
	## (`VOLCANIC_KERNEL`) carries all the state.
	VOLCANIC_KERNEL_PART,
}

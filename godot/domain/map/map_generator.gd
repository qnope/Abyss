class_name MapGenerator
extends RefCounted
## lib/domain/map/map_generator.dart: generates one level of a map. Every
## die comes from one generator seeded with the seed of the map, in this
## order: the base, the other bases, the contents, the posts.

const _OFFSET := 2


## `seed_` is an int, or null to draw one; `reserved_passages` gives the
## name of the post above each cell the level keeps as a passage, by the
## key of its position, in the order they are marked. A number of players
## Dart throws for (`MapLayout`) gives null.
static func generate(
	seed_: Variant = null,
	level := 1,
	reserved_passages: Dictionary[Vector2i, String] = {},
	player_count := 1,
) -> MapGenerationResult:
	var size := MapLayout.size_for(player_count)
	if size == MapLayout.REFUSED:
		return null
	var extra_posts := MapLayout.extra_posts_for(player_count)
	var actual_seed: int = (
		seed_ if seed_ != null else DartRandom.unseeded().next_int(0x7FFFFFFF)
	)
	var random := DartRandom.new(actual_seed)

	var center := DartMath.trunc_div(size, 2)
	var base_x := center + random.next_int(_OFFSET * 2 + 1) - _OFFSET
	var base_y := center + random.next_int(_OFFSET * 2 + 1) - _OFFSET
	# The volcano covers the centre cell and the three after it: the base
	# steps aside to the cell before the centre.
	if (
		level == 3
		and base_x >= center and base_x < center + VolcanicKernelPlacer.SIDE
		and base_y >= center and base_y < center + VolcanicKernelPlacer.SIDE
	):
		base_x = center - 1
	var bases: Array[GridPosition] = [GridPosition.new(base_x, base_y)]
	if level == 1:
		bases = StartingBasePlacer.place(size, bases[0], player_count, random)
	var other_bases: Array[GridPosition] = bases.slice(1)

	var reserved_indices: Dictionary[int, bool] = {}
	for pos: Vector2i in reserved_passages:
		reserved_indices[pos.y * size + pos.x] = true
	var lairs := MapLayout.lair_range_for(size)

	var cells := TerrainGenerator.generate(size, size, random, base_x, base_y)
	ContentPlacer.place(
		cells, size, size, base_x, base_y, random, reserved_indices,
		actual_seed + level, other_bases, lairs.x, lairs.y,
	)
	var kept_from_posts: Dictionary[int, bool] = reserved_indices.duplicate()
	for b: GridPosition in other_bases:
		kept_from_posts[b.y * size + b.x] = true
	TransitionBasePlacer.place(
		cells, size, size, base_x, base_y, level, random, kept_from_posts, extra_posts
	)

	for b: GridPosition in bases:
		_clear_base_content(cells, size, b.x, b.y)
	# Placed after the base is cleared, which may sit on the centre.
	if level == 3:
		VolcanicKernelPlacer.place(cells, size, size)
	_mark_passages(cells, size, base_x, base_y, reserved_passages)

	return MapGenerationResult.new(
		GameMap.new(size, size, cells, actual_seed), base_x, base_y, bases
	)


static func _clear_base_content(cells: Array[MapCell], size: int, base_x: int, base_y: int) -> void:
	var i := base_y * size + base_x
	cells[i] = cells[i].copy_with({"content": CellContentType.Value.EMPTY})


## Each reserved cell becomes a passage named after its post, but the base
## of the first player and the cells of the volcano.
static func _mark_passages(
	cells: Array[MapCell],
	size: int,
	base_x: int,
	base_y: int,
	reserved_passages: Dictionary[Vector2i, String],
) -> void:
	for pos: Vector2i in reserved_passages:
		if pos.x == base_x and pos.y == base_y:
			continue
		var i := pos.y * size + pos.x
		if (
			cells[i].content == CellContentType.Value.VOLCANIC_KERNEL
			or cells[i].content == CellContentType.Value.VOLCANIC_KERNEL_PART
		):
			continue
		cells[i] = cells[i].copy_with({
			"content": CellContentType.Value.PASSAGE,
			"passage_name": reserved_passages[pos],
		})

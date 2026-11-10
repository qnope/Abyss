class_name TransitionBasePlacer
extends RefCounted
## lib/domain/map/transition_base_placer.dart: places the Failles of level 1,
## one per quarter of the map, and the Cheminées of level 2, on its edges.


## `reserved_indices` is a set of cell indices no post may take.
static func place(
	cells: Array[MapCell],
	width: int,
	height: int,
	base_x: int,
	base_y: int,
	level: int,
	random: DartRandom,
	reserved_indices: Dictionary[int, bool] = {},
	extra_posts := 0,
) -> void:
	var candidate_sets: Array[Array] = []
	var type := TransitionBaseType.Value.FAILLE
	var min_center_dist := 8
	if level == 1:
		var quadrants := _build_quadrants(width, height)
		for i: int in 4 + extra_posts:
			candidate_sets.append(quadrants[i % 4])
	elif level == 2:
		var edge := _outer_edge_cells(width, height)
		for _i: int in 3 + extra_posts:
			candidate_sets.append(edge)
		type = TransitionBaseType.Value.CHEMINEE
		min_center_dist = 10
	else:
		return
	var center := Vector2i(DartMath.trunc_div(width, 2), DartMath.trunc_div(height, 2))
	var placed: Array[int] = []
	var names := TransitionBaseName.all_of(type, extra_posts)
	for i: int in names.size():
		var candidates: Array[int] = candidate_sets[i]
		var idx: Variant = _pick_cell(
			candidates, width, center, base_x, base_y, min_center_dist, 5, placed, random,
			reserved_indices,
		)
		if idx != null:
			var picked: int = idx
			cells[picked] = cells[picked].copy_with({
				"content": CellContentType.Value.TRANSITION_BASE,
				"transition_base": TransitionBase.new(type, names[i].code()),
			})
			placed.append(picked)


## A cell drawn among the candidates far enough from the centre and from the
## posts already placed (an int), the spacing asked going down to 0 until
## one fits; null when none ever does.
static func _pick_cell(
	candidates: Array[int],
	width: int,
	center: Vector2i,
	base_x: int,
	base_y: int,
	min_center_dist: int,
	min_spacing: int,
	placed: Array[int],
	random: DartRandom,
	reserved_indices: Dictionary[int, bool],
) -> Variant:
	for spacing: int in range(min_spacing, -1, -1):
		var valid: Array[int] = []
		for idx: int in candidates:
			if reserved_indices.has(idx):
				continue
			var x := idx % width
			var y := DartMath.trunc_div(idx, width)
			if x == base_x and y == base_y:
				continue
			if maxi(absi(x - center.x), absi(y - center.y)) < min_center_dist:
				continue
			if _spacing_ok(x, y, width, placed, spacing):
				valid.append(idx)
		if valid.is_empty():
			continue
		return valid[random.next_int(valid.size())]
	return null


## Whether (`x`, `y`) is `min_dist` cells or more away from every post.
static func _spacing_ok(x: int, y: int, width: int, placed: Array[int], min_dist: int) -> bool:
	for p: int in placed:
		var apart := maxi(absi(x - p % width), absi(y - DartMath.trunc_div(p, width)))
		if apart < min_dist:
			return false
	return true


## The cells of each quarter of the map, row by row: top left, top right,
## bottom left, bottom right. As in Dart, the rows too are split at half the
## width.
static func _build_quadrants(w: int, h: int) -> Array[Array]:
	var half := DartMath.trunc_div(w, 2)
	var lists: Array[Array] = []
	for _quadrant: int in 4:
		var cells: Array[int] = []
		lists.append(cells)
	for y: int in h:
		for x: int in w:
			lists[(0 if x < half else 1) + (0 if y < half else 2)].append(y * w + x)
	return lists


## The cells of the edges, each once, in the order Dart's set meets them:
## the top and bottom rows cell by cell, then the two sides row by row.
static func _outer_edge_cells(w: int, h: int) -> Array[int]:
	var met: Dictionary[int, bool] = {}
	for x: int in w:
		met[x] = true
		met[(h - 1) * w + x] = true
	for y: int in h:
		met[y * w] = true
		met[y * w + w - 1] = true
	var result: Array[int] = []
	result.assign(met.keys())
	return result

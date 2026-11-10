class_name VolcanicKernelPlacer
extends RefCounted
## lib/domain/map/volcanic_kernel_placer.dart: lays the volcano on a 2x2
## footprint. The top-left cell (the anchor) is the `VOLCANIC_KERNEL` and
## carries all the state; the three others are `VOLCANIC_KERNEL_PART`s.

const SIDE := 2


## The footprint cells for an anchor, anchor first. Dart's list of records
## `(int, int)`.
static func footprint(anchor_x: int, anchor_y: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dy: int in SIDE:
		for dx: int in SIDE:
			cells.append(Vector2i(anchor_x + dx, anchor_y + dy))
	return cells


static func place(cells: Array[MapCell], width: int, height: int) -> void:
	var anchor_x := DartMath.trunc_div(width, 2)
	var anchor_y := DartMath.trunc_div(height, 2)
	for cell: Vector2i in footprint(anchor_x, anchor_y):
		var is_anchor := cell.x == anchor_x and cell.y == anchor_y
		var index := cell.y * width + cell.x
		cells[index] = cells[index].copy_with({
			"content": (
				CellContentType.Value.VOLCANIC_KERNEL if is_anchor
				else CellContentType.Value.VOLCANIC_KERNEL_PART
			),
			"lair": null,
			"transition_base": null,
		})

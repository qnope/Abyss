class_name ParadeLayout
extends RefCounted
## Where everything stands on the parade ground, in metres from the middle of
## its deck (lib/presentation/widgets/army/army_layout.dart, in cells): a 9 x 9
## island split in 3 x 3 blocks, the barracks at the back, the army's crest in
## the middle and one block per unit, each holding the drill pad of its squad.
## The default view looks from the front corner, the largest x and z.

## Metres along each side of a cell, and cells along each side of the island,
## of a block and of a drill pad.
const CELL := 1.15
const ISLAND := 9.0
const BLOCK := 3.0
const PAD := 2.5
## The thickness of the deck, under y = 0, and how far it overhangs the island.
const DEPTH := 0.8
const RIM := 0.1
## Where the figures of a squad stand on their pad, in cells from its centre
## (Flutter's `SquadSlots.arrival`), in the order they arrive as it grows.
const SLOTS: Array[Vector2] = [
	Vector2(0.3, 0.3), Vector2(-0.42, 0.62), Vector2(0.62, -0.42),
	Vector2(-0.55, -0.05), Vector2(-0.05, -0.55), Vector2(-1.05, 0.45),
]
## The island's outline the default view fits to the screen: the deck's
## corners and what stands over them, with the plaques.
const OUTLINE: PackedVector3Array = [
	Vector3(5.2, 0.0, 5.2), Vector3(-5.2, 0.0, 5.2), Vector3(5.2, 0.0, -5.2),
	Vector3(-5.2, 0.0, -5.2), Vector3(5.2, -0.8, 5.2), Vector3(-5.2, -0.8, 5.2),
	Vector3(5.2, -0.8, -5.2), Vector3(-5.2, -0.8, -5.2),
	Vector3(4.2, 3.4, 4.2), Vector3(-4.2, 3.4, 4.2), Vector3(4.2, 3.4, -4.2),
	Vector3(-4.2, 3.4, -4.2),
]
## Where the barracks stands, in cells.
const BARRACKS := Vector2(1.5, 1.5)
const CREST := Vector2(4.5, 4.5)


## The centre of the drill pad of [param type], on the deck.
static func pad_of(type: UnitType.Value) -> Vector3:
	return at(_pad_cell(type))


## The deck's point under the cell [param cell].
static func at(cell: Vector2) -> Vector3:
	return Vector3((cell.x - ISLAND / 2.0) * CELL, 0.0, (cell.y - ISLAND / 2.0) * CELL)


## The metres from a pad's centre to the slot [param index] of its figures.
static func slot(index: int) -> Vector3:
	return Vector3(SLOTS[index].x * CELL, 0.0, SLOTS[index].y * CELL)


static func _pad_cell(type: UnitType.Value) -> Vector2:
	match type:
		UnitType.Value.SCOUT:
			return Vector2(1.5, 4.5)
		UnitType.Value.HARPOONIST:
			return Vector2(4.5, 1.5)
		UnitType.Value.GUARDIAN:
			return Vector2(1.5, 7.5)
		UnitType.Value.DOME_BREAKER:
			return Vector2(7.5, 1.5)
		UnitType.Value.ABYSS_ADMIRAL:
			return Vector2(4.5, 7.5)
	return Vector2(7.5, 4.5)

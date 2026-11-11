class_name SquadSize
extends RefCounted
## How many standing figures show a squad of a given number of units: the
## parade ground hints at the size of the army without one figure per unit
## (lib/presentation/widgets/army/squad_size.dart).

## The most figures a squad ever shows.
const MAX := 6
## Largest count shown by 1, 2, 3, 4 and 5 figures; above, [constant MAX].
const _TOPS: Array[int] = [1, 5, 15, 30, 60]


## Figures standing for [param count] units: none for an empty squad, then
## one more at 2, 6, 16, 31 and 61 units.
static func of(count: int) -> int:
	if count <= 0:
		return 0
	for tier in _TOPS.size():
		if count <= _TOPS[tier]:
			return tier + 1
	return MAX

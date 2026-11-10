class_name ContentPlacer
extends RefCounted
## lib/domain/map/content_placer.dart: scatters the treasures, the ruins and
## the monster lairs of a new map.

# A roll in [0.60, 0.80) used to place a treasure and one in [0.80, 0.90)
# ruins. Only the first third of each band still does, so a seed keeps a
# subset of the treasures it used to place and replays of older games still
# find them. Monster lairs keep [0.90, 1).
const _RESOURCE_FROM := 0.60
const _RUINS_FROM := 0.80
const _MONSTER_FROM := 0.90
const _KEPT_SHARE := 1.0 / 3.0

const _EMPTY := CellContentType.Value.EMPTY


## `reserved_indices` is a set of cell indices. A lair trimmed past
## `max_lairs` has already drawn its dice, and stays under the empty content
## of its cell (`MapCell.copy_with`).
static func place(
	cells: Array[MapCell],
	width: int,
	height: int,
	base_x: int,
	base_y: int,
	random: DartRandom,
	reserved_indices: Dictionary[int, bool] = {},
	family_seed := 0,
	other_bases: Array[GridPosition] = [],
	min_lairs := 5,
	max_lairs := 10,
) -> void:
	var eligible := _build_eligible_indices(
		width, height, base_x, base_y, reserved_indices, other_bases
	)
	DartRandom.shuffle(eligible, random)

	var monster_indices: Array[int] = []
	for i: int in eligible:
		var roll := random.next_double()
		if roll < _MONSTER_FROM:
			var treasure: Variant = _treasure_for(roll)
			if treasure != null:
				cells[i] = cells[i].copy_with({"content": treasure})
		else:
			_place_monster(cells, i, width, base_x, base_y, random, family_seed)
			monster_indices.append(i)

	var monster_count := monster_indices.size()
	while monster_count < min_lairs:
		var empty: Array[int] = []
		for i: int in eligible:
			if cells[i].content == _EMPTY:
				empty.append(i)
		if empty.is_empty():
			break
		var forced := empty[random.next_int(empty.size())]
		_place_monster(cells, forced, width, base_x, base_y, random, family_seed)
		monster_count += 1
	while monster_count > max_lairs:
		var trimmed: int = monster_indices.pop_back()
		cells[trimmed] = cells[trimmed].copy_with({"content": _EMPTY})
		monster_count -= 1


## The treasure a roll below the lairs' band places (a
## CellContentType.Value), or null.
static func _treasure_for(roll: float) -> Variant:
	if _keeps(roll, _RESOURCE_FROM, _RUINS_FROM):
		return CellContentType.Value.RESOURCE_BONUS
	if _keeps(roll, _RUINS_FROM, _MONSTER_FROM):
		return CellContentType.Value.RUINS
	return null


static func _keeps(roll: float, from: float, to: float) -> bool:
	return roll >= from and roll < from + (to - from) * _KEPT_SHARE


## The cells that may hold something, row by row: more than 2 cells away
## from every base and not reserved.
static func _build_eligible_indices(
	width: int,
	height: int,
	base_x: int,
	base_y: int,
	reserved_indices: Dictionary[int, bool],
	other_bases: Array[GridPosition],
) -> Array[int]:
	var result: Array[int] = []
	for y: int in height:
		for x: int in width:
			if maxi(absi(x - base_x), absi(y - base_y)) <= 2:
				continue
			if _near_a_base(x, y, other_bases) or reserved_indices.has(y * width + x):
				continue
			result.append(y * width + x)
	return result


static func _near_a_base(x: int, y: int, bases: Array[GridPosition]) -> bool:
	for b: GridPosition in bases:
		if maxi(absi(x - b.x), absi(y - b.y)) <= 2:
			return true
	return false


## A lair on the cell `i`: harder far from the base, its difficulty then its
## size drawn from the dice of the map.
static func _place_monster(
	cells: Array[MapCell],
	i: int,
	width: int,
	base_x: int,
	base_y: int,
	random: DartRandom,
	family_seed: int,
) -> void:
	var x := i % width
	var y := DartMath.trunc_div(i, width)
	var far_from_base := maxi(absi(x - base_x), absi(y - base_y)) > 7
	var roll := random.next_double()
	var difficulty := MonsterDifficulty.Value.HARD
	if roll < (0.15 if far_from_base else 0.50):
		difficulty = MonsterDifficulty.Value.EASY
	elif roll < (0.50 if far_from_base else 0.85):
		difficulty = MonsterDifficulty.Value.MEDIUM
	cells[i] = cells[i].copy_with({
		"content": CellContentType.Value.MONSTER_LAIR,
		"lair": LairBuilder.build(difficulty, random, family_seed, i),
	})

extends TestCase
## The ground plan of the parade: one block per unit, none shared.

const HALF := ParadeLayout.ISLAND * ParadeLayout.CELL / 2.0


func test_each_unit_has_a_pad_of_its_own_on_the_deck() -> void:
	var seen: Array[Vector3] = []
	for type: UnitType.Value in UnitType.Value.values():
		var centre := ParadeLayout.pad_of(type)
		assert_false(seen.has(centre), str(type))
		seen.append(centre)
		assert_true(absf(centre.x) < HALF and absf(centre.z) < HALF, str(type))
		assert_eq(centre.y, 0.0)


func test_the_pads_do_not_touch() -> void:
	var width := ParadeLayout.PAD * ParadeLayout.CELL
	for type: UnitType.Value in UnitType.Value.values():
		for other: UnitType.Value in UnitType.Value.values():
			if type != other:
				var apart := ParadeLayout.pad_of(type) - ParadeLayout.pad_of(other)
				assert_true(maxf(absf(apart.x), absf(apart.z)) > width, "%s %s" % [type, other])


func test_the_barracks_stands_at_the_back_and_the_crest_in_the_middle() -> void:
	var barracks := ParadeLayout.at(ParadeLayout.BARRACKS)
	assert_true(barracks.x < 0.0 and barracks.z < 0.0, "behind the middle, away from the view")
	assert_eq(ParadeLayout.at(ParadeLayout.CREST), Vector3.ZERO)


func test_the_figures_stand_inside_their_pad() -> void:
	var half := ParadeLayout.PAD * ParadeLayout.CELL / 2.0
	for index in ParadeLayout.SLOTS.size():
		var slot := ParadeLayout.slot(index)
		assert_true(absf(slot.x) < half and absf(slot.z) < half, str(index))


func test_the_outline_holds_the_deck() -> void:
	for corner in ParadeLayout.OUTLINE:
		assert_true(absf(corner.x) <= HALF + ParadeLayout.RIM and absf(corner.z) <= HALF + ParadeLayout.RIM)
		assert_true(corner.y >= -ParadeLayout.DEPTH - 0.001)

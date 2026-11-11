extends TestCase
## The colour of each unit, in the sheets, cards and rows that show it.

const Type := UnitType.Value


func test_keeps_the_hue_the_flutter_squads_were_given_where_it_was_apart() -> void:
	assert_eq(UnitColors.of(Type.SCOUT), AbyssArmyColors.SCOUT)
	assert_eq(UnitColors.of(Type.GUARDIAN), AbyssArmyColors.GUARDIAN)
	assert_eq(UnitColors.of(Type.DOME_BREAKER), AbyssArmyColors.DOME_BREAKER)
	assert_eq(UnitColors.of(Type.ABYSS_ADMIRAL), AbyssArmyColors.ABYSS_ADMIRAL)
	assert_eq(UnitColors.of(Type.SABOTEUR), AbyssArmyColors.SABOTEUR)


func test_the_harpoonist_is_told_from_the_dome_breaker() -> void:
	assert_ne(UnitColors.of(Type.HARPOONIST), AbyssArmyColors.HARPOONIST)
	assert_true(UnitColors.of(Type.HARPOONIST) != UnitColors.of(Type.DOME_BREAKER))


func test_no_two_units_share_a_colour() -> void:
	var seen: Array[Color] = []
	for type: UnitType.Value in Type.values():
		assert_false(seen.has(UnitColors.of(type)), str(type))
		seen.append(UnitColors.of(type))
	assert_eq(seen.size(), 6)

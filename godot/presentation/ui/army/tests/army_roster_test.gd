extends TestCase
## test/presentation/widgets/army/army_roster_test.dart.

const Scout := UnitType.Value.SCOUT
const Guardian := UnitType.Value.GUARDIAN


func test_a_locked_unit_is_locked_whatever_its_count() -> void:
	var roster := ArmyRoster.new(2, {Guardian: 40})
	assert_true(roster.is_locked(Guardian))
	assert_eq(roster.count_of(Guardian), 40)
	assert_false(roster.is_locked(Scout))


func test_the_barracks_level_unlocks_the_units_of_the_rules() -> void:
	var roster := ArmyRoster.new(2)
	assert_eq(roster.unlocked(), [UnitType.Value.SCOUT, UnitType.Value.HARPOONIST,
		UnitType.Value.ABYSS_ADMIRAL] as Array[UnitType.Value])
	assert_eq(roster.unlock_level_of(Guardian), 3)


func test_counts_none_for_a_type_it_does_not_hold() -> void:
	assert_eq(ArmyRoster.new(1, {Scout: 3}).count_of(UnitType.Value.SABOTEUR), 0)


func test_only_an_unlocked_unit_is_shown_recruitable() -> void:
	var roster := ArmyRoster.new(1, {}, {Scout: true, Guardian: true})
	assert_true(roster.can_recruit(Scout))
	assert_false(roster.can_recruit(Guardian))
	assert_false(roster.can_recruit(UnitType.Value.HARPOONIST))

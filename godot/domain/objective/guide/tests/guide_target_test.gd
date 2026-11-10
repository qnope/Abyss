extends TestCase
## test/domain/objective/guide/guide_target_test.dart: what the halo of the
## guide surrounds, and the area of the screen it lies in. The named
## constructors are `for_building`... (guide_target.gd says why).

const Area := GuideArea.Value
const BARRACKS := BuildingType.Value.BARRACKS
const LABORATORY := BuildingType.Value.LABORATORY
const SCOUT := UnitType.Value.SCOUT
const MILITARY := TechBranch.Value.MILITARY
const EXPLORER := TechBranch.Value.EXPLORER


func test_each_target_lies_in_the_area_of_the_screen_to_open() -> void:
	assert_eq(GuideTarget.for_building(BARRACKS).area, Area.BASE)
	assert_eq(GuideTarget.for_map().area, Area.MAP)
	assert_eq(GuideTarget.for_unit(SCOUT).area, Area.ARMY)
	assert_eq(GuideTarget.for_unlock({MILITARY: true}).area, Area.RESEARCH)
	assert_eq(GuideTarget.for_research({MILITARY: true}).area, Area.RESEARCH)
	assert_null(GuideTarget.for_end_turn().area)


func test_a_building_target_surrounds_its_card_only() -> void:
	var target := GuideTarget.for_building(BARRACKS)
	assert_true(target.is_building(BARRACKS))
	assert_false(target.is_building(LABORATORY))
	assert_false(target.is_unit(SCOUT))
	assert_false(target.end_turn)


func test_a_unit_target_surrounds_its_card_only() -> void:
	var target := GuideTarget.for_unit(SCOUT)
	assert_true(target.is_unit(SCOUT))
	assert_false(target.is_unit(UnitType.Value.HARPOONIST))
	assert_false(target.is_building(BARRACKS))


func test_an_unlock_target_surrounds_the_medallions_of_its_branches() -> void:
	var target := GuideTarget.for_unlock({MILITARY: true})
	assert_true(target.is_branch(MILITARY))
	assert_false(target.is_branch(EXPLORER))
	assert_false(target.is_tech_node(MILITARY, 1))


func test_a_research_target_surrounds_the_first_node_of_its_branches() -> void:
	var target := GuideTarget.for_research({EXPLORER: true})
	assert_true(target.is_tech_node(EXPLORER, 1))
	assert_false(target.is_tech_node(EXPLORER, 2))
	assert_false(target.is_tech_node(MILITARY, 1))
	assert_false(target.is_branch(EXPLORER))


func test_the_end_of_the_turn_surrounds_the_next_turn_button() -> void:
	assert_true(GuideTarget.for_end_turn().end_turn)


func test_targets_compare_by_value_whatever_the_order_of_the_branches() -> void:
	var both := GuideTarget.for_unlock({MILITARY: true, EXPLORER: true})
	var reversed := GuideTarget.for_unlock({EXPLORER: true, MILITARY: true})
	assert_true(both.equals(reversed))
	assert_eq(both.hash_code(), reversed.hash_code())
	assert_false(GuideTarget.for_unlock({MILITARY: true}).equals(GuideTarget.for_research({MILITARY: true})))
	assert_false(GuideTarget.for_building(BARRACKS).equals(GuideTarget.for_building(LABORATORY)))


## Not in the Dart file: the areas under their Dart names, in the Dart
## order; branches told apart by their number too; no target equals another
## kind of object.
func test_the_areas_have_the_dart_names_and_a_target_equals_only_a_target() -> void:
	assert_eq(DartEnum.names(Area), PackedStringArray(["base", "map", "army", "research"]))
	var one := GuideTarget.for_unlock({MILITARY: true})
	assert_false(one.equals(GuideTarget.for_unlock({MILITARY: true, EXPLORER: true})))
	assert_false(one.equals(GuideTarget.for_unlock({EXPLORER: true})))
	assert_false(one.equals("unlock"))

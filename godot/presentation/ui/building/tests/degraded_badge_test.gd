extends BuildingTestCase
## The marker of a building whose headquarters is too low, short and detailed
## (degraded_badge_test.dart).

const Type := BuildingType.Value


func test_the_short_marker_only_says_degraded() -> void:
	var badge := DegradedBadge.new(6, Type.BARRACKS)
	mount(badge)
	assert_eq(badge.label.text, "Dégradé")
	assert_false(badge.effect_label.visible)
	assert_no_raw_keys()


func test_the_detailed_marker_says_the_level_missing_and_the_effect() -> void:
	var badge := DegradedBadge.new(6, Type.BARRACKS, true)
	mount(badge)
	assert_eq(badge.label.text, "Dégradé : le QG doit être au niveau 6")
	assert_true(badge.effect_label.visible)
	assert_eq(badge.effect_label.text, BuildingDegradationTexts.degraded_effect(Type.BARRACKS))
	assert_no_raw_keys()


func test_follows_the_language() -> void:
	var badge := DegradedBadge.new(6, Type.BARRACKS, true)
	mount(badge)
	use_language("en")
	assert_ne(badge.label.text, "Dégradé : le QG doit être au niveau 6")
	assert_eq(badge.effect_label.text, BuildingDegradationTexts.degraded_effect(Type.BARRACKS))


func test_a_notice_is_made_for_a_degraded_building_only() -> void:
	set_levels({Type.HEADQUARTERS: 1, Type.BARRACKS: 3})
	var notice := DegradedNotice.of(Type.BARRACKS, human.buildings)
	assert_not_null(notice)
	assert_true(notice.detailed)
	assert_eq(notice.required_headquarters, 6)
	assert_null(DegradedNotice.of(Type.HEADQUARTERS, human.buildings))
	notice.free()

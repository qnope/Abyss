extends BuildingTestCase
## The banners over the base: the worksites free this turn, the rampart of
## the citadel (worksite_badge_test.dart, base_shield_badge_test.dart,
## base_hud_test.dart).

const Type := BuildingType.Value


func _banners() -> BaseBanners:
	var banners := BaseBanners.new(human)
	mount(banners)
	return banners


func test_tells_the_worksites_free_and_the_next_one() -> void:
	set_levels({Type.HEADQUARTERS: 2})
	var badge := WorksiteBadge.new(human.worksite, human.buildings, true)
	mount(badge)
	assert_not_null(find_text("Chantiers libres ce tour : 1/1 · +1 au QG 5", badge))
	assert_eq(badge.badge.icon.self_modulate, AbyssColors.BIOLUM_CYAN)


func test_omits_the_next_worksite_unless_asked() -> void:
	set_levels({Type.HEADQUARTERS: 2})
	var badge := WorksiteBadge.new(human.worksite, human.buildings)
	mount(badge)
	assert_not_null(find_text("Chantiers libres ce tour : 1/1", badge))
	assert_null(find_text("Chantiers libres ce tour : 1/1 · +1 au QG 5", badge))


func test_warns_when_no_worksite_is_left() -> void:
	set_levels({Type.HEADQUARTERS: 2})
	human.worksite.upgrades = 1
	var banners := _banners()
	assert_not_null(find_text("Chantiers libres ce tour : 0/1", banners))
	assert_eq(banners.worksite_badge.badge.icon.self_modulate, AbyssColors.WARNING)


func test_does_not_offer_a_next_worksite_at_the_top() -> void:
	set_levels({Type.HEADQUARTERS: 10})
	var badge := WorksiteBadge.new(human.worksite, human.buildings, true)
	mount(badge)
	assert_null(find_text(" · ", badge))


func test_shows_the_rampart_once_the_citadel_stands() -> void:
	var banners := _banners()
	assert_false(banners.shield_badge.visible)
	set_levels({Type.CORAL_CITADEL: 3})
	banners.refresh()
	assert_true(banners.shield_badge.visible)
	assert_not_null(find_text("Rempart de la base : 120 PV, DEF 7", banners))


func test_lets_the_touches_through_to_the_world() -> void:
	var banners := _banners()
	assert_eq(banners.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(banners.worksite_badge.badge.mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_follows_the_language() -> void:
	set_levels({Type.HEADQUARTERS: 2, Type.CORAL_CITADEL: 3})
	var banners := _banners()
	use_language("en")
	assert_not_null(find_text("Free worksites this turn: 1/1", banners))

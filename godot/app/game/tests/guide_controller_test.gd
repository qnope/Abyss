extends UiTestCase
## The guide's rings in the world: the first advice rings the headquarters, a
## unit rings its squad, a cell rings the map, and a silent guide rings nothing.

var _world: WorldHost
var _scope: GuideScope
var _controller: GuideController


func _on(id: ObjectiveId.Value, tutorial := true) -> void:
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_scope = GuideScope.new(GuideSamples.guide_game(id, tutorial))
	_controller = GuideController.new(_scope, _world)


func _point(target: GuideTarget) -> void:
	_scope.advice = GuideAdvice.new(GuideGoalMet.new(), target)
	_scope.changed.emit()


func test_the_first_advice_rings_the_headquarters_with_its_name() -> void:
	_on(ObjectiveId.Value.HQ_LEVEL_1)
	var ring := _world.base.guide
	assert_true(ring.visible)
	assert_eq(ring.caption.text, BuildingTexts.display_name(BuildingType.Value.HEADQUARTERS))
	assert_true(ring.radius > 0.0)
	assert_false(_world.parade.guide.visible)
	assert_false(_world.map.guide.visible)


func test_following_the_advice_moves_the_ring() -> void:
	_on(ObjectiveId.Value.HQ_LEVEL_1)
	var first := _world.base.guide.position
	_point(GuideTarget.for_building(BuildingType.Value.BARRACKS))
	assert_ne(_world.base.guide.position, first)
	assert_eq(_world.base.guide.caption.text, BuildingTexts.display_name(BuildingType.Value.BARRACKS))
	_point(GuideTarget.for_end_turn())
	assert_false(_world.base.guide.visible)


func test_a_unit_is_ringed_on_the_parade_ground() -> void:
	_on(ObjectiveId.Value.HQ_LEVEL_1)
	_point(GuideTarget.for_unit(UnitType.Value.SCOUT))
	assert_true(_world.parade.guide.visible)
	assert_eq(_world.parade.guide.position.x, _world.parade.squads[UnitType.Value.SCOUT].position.x)
	assert_false(_world.base.guide.visible)


func test_a_cell_is_aimed_on_the_map() -> void:
	_on(ObjectiveId.Value.HQ_LEVEL_1)
	_point(GuideTarget.for_cell(2, GridPosition.new(3, 4)))
	assert_true(_world.map.guide.has_aim)
	_point(GuideTarget.for_map())
	assert_false(_world.map.guide.has_aim)


func test_a_silent_guide_rings_nothing() -> void:
	_on(ObjectiveId.Value.HQ_LEVEL_1, false)
	assert_false(_world.base.guide.visible)
	assert_false(_world.map.guide.has_aim)


func test_the_ring_has_the_cyan_of_the_interface() -> void:
	assert_eq(WorldPalette.GUIDE, AbyssColors.BIOLUM_CYAN)


func test_closing_puts_the_rings_away_and_stops_listening() -> void:
	_on(ObjectiveId.Value.HQ_LEVEL_1)
	_controller.close()
	assert_false(_world.base.guide.visible)
	_point(GuideTarget.for_building(BuildingType.Value.BARRACKS))
	assert_false(_world.base.guide.visible)

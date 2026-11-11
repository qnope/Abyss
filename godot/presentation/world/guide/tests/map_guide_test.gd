extends MapTestCase
## The ring on the map: around the aimed cell, on its level only.

var _guide: MapGuide


func before_each() -> void:
	_guide = MapGuide.new()
	mounted(_guide)



func test_rings_nothing_without_an_aim() -> void:
	_guide.shown_on(level_of(6, 6, []))
	assert_false(_guide.visible)


func test_rings_the_aimed_cell_on_its_level() -> void:
	var state := level_of(6, 6, [])
	_guide.aim(state.level, 2, 3)
	assert_false(_guide.visible, "no level shown yet")
	_guide.shown_on(state)
	assert_true(_guide.visible)
	var at := MapGrid.at(2, 3, 6, 6)
	assert_eq(_guide.position.x, at.x)
	assert_eq(_guide.position.z, at.z)
	assert_eq(_guide.radius, MapGrid.CELL * MapGuide.SHARE)


func test_leaves_the_ring_on_another_level() -> void:
	var state := level_of(6, 6, [])
	_guide.shown_on(state)
	_guide.aim(state.level + 1, 2, 3)
	assert_false(_guide.visible)
	_guide.aim(state.level, 2, 3)
	assert_true(_guide.visible)


func test_release_takes_the_aim_away() -> void:
	var state := level_of(6, 6, [])
	_guide.shown_on(state)
	_guide.aim(state.level, 1, 1)
	_guide.release()
	assert_false(_guide.has_aim)
	assert_false(_guide.visible)

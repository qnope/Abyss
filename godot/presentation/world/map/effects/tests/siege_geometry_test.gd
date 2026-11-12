extends TestCase
## test/presentation/widgets/map/effects/story/siege_geometry_test.dart.

var _base := SiegeGeometry.new(Vector2i(3, 4), 10, 10)
var _volcano := SiegeGeometry.new(Vector2i(3, 4), 10, 10, 2)


func _away(geometry: SiegeGeometry, position: Vector3) -> float:
	return Vector2(position.x - geometry.center().x, position.z - geometry.center().z).length()


func test_a_place_is_besieged_from_its_middle_across_its_corners() -> void:
	assert_eq(_base.center(), MapGrid.at(3, 4, 10, 10))
	assert_almost_eq(_base.radius(), MapGrid.CELL * sqrt(0.5), 1e-9)
	assert_eq(_volcano.center(), MapGrid.at(3, 4, 10, 10) + Vector3(0.5, 0.0, 0.5) * MapGrid.CELL)
	assert_almost_eq(_volcano.radius(), 2.0 * MapGrid.CELL * sqrt(0.5), 1e-9)


func test_the_attackers_set_off_from_around_and_halt_by_the_place() -> void:
	var far := _base.radius() + SiegeGeometry.START * MapGrid.CELL
	var halted := _base.radius() + SiegeGeometry.HALT * MapGrid.CELL
	for index in SiegeGeometry.ATTACKERS:
		assert_almost_eq(_away(_base, _base.attacker_at(index, 0.0)), far, 1e-6)
		assert_almost_eq(_away(_base, _base.attacker_at(index, 1.0)), halted, 1e-6)
	var seen: Dictionary[Vector3, bool] = {}
	for index in SiegeGeometry.ATTACKERS:
		seen[_base.attacker_at(index, 1.0)] = true
	assert_eq(seen.size(), SiegeGeometry.ATTACKERS, "each from its own side")


func test_a_lunge_reaches_towards_the_place() -> void:
	var halted := _base.radius() + SiegeGeometry.HALT * MapGrid.CELL
	var lunged := _away(_base, _base.attacker_at(0, 1.0, 1.0))
	assert_almost_eq(lunged, halted - SiegeGeometry.HALT * MapGrid.CELL * SiegeGeometry.LUNGE_REACH, 1e-6)


func test_pushed_back_they_go_away_and_breaking_in_they_go_to_the_place() -> void:
	var halted := _base.radius() + SiegeGeometry.HALT * MapGrid.CELL
	assert_almost_eq(_away(_base, _base.attacker_at(1, 1.0, 0.0, 1.0)),
		halted + SiegeGeometry.PUSH * MapGrid.CELL, 1e-6)
	assert_almost_eq(_away(_base, _base.attacker_at(1, 1.0, 0.0, 0.0, 1.0)), 0.0, 1e-6)

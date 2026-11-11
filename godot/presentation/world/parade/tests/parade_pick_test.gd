extends TestCase
## What a ray meets on the parade ground: the nearest box, or nothing.

const NEAR := 1
const FAR := 2


func _boxes() -> Dictionary[int, AABB]:
	return {
		NEAR: AABB(Vector3(-1.0, 0.0, 1.0), Vector3(2.0, 2.0, 2.0)),
		FAR: AABB(Vector3(-1.0, 0.0, 5.0), Vector3(2.0, 2.0, 2.0)),
	}


func test_picks_the_nearest_box_the_ray_meets() -> void:
	assert_eq(ParadePick.pick(_boxes(), Vector3(0.0, 1.0, -5.0), Vector3.BACK), NEAR)
	assert_eq(ParadePick.pick(_boxes(), Vector3(0.0, 1.0, 20.0), Vector3.FORWARD), FAR)


func test_picks_nothing_when_the_ray_misses() -> void:
	assert_eq(ParadePick.pick(_boxes(), Vector3(8.0, 1.0, -5.0), Vector3.BACK), ParadePick.NONE)
	assert_eq(ParadePick.pick({}, Vector3.ZERO, Vector3.BACK), ParadePick.NONE)


func test_the_barracks_is_not_a_unit() -> void:
	for type: UnitType.Value in UnitType.Value.values():
		assert_ne(type as int, ParadePick.BARRACKS)
		assert_ne(type as int, ParadePick.NONE)

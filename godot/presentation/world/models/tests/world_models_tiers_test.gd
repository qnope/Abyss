extends TestCase
## A model of tiers shows the ones its level has risen to.

const Type := BuildingType.Value

var _made: Array[Node3D] = []


func after_each() -> void:
	for node in _made:
		node.free()


func test_shows_the_tiers_a_level_has_risen_to() -> void:
	for level: int in [1, 3, 4, 7, 8, 12]:
		assert_eq(_shown(_make(Type.ALGAE_FARM, level)), BuildingTier.of_level(level), "level %d" % level)


func test_every_building_has_three_tiers() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		assert_eq(ModelTiers.count(_make(type, 1)), 3, str(type))


func test_the_parts_under_no_tier_are_always_shown() -> void:
	var model := _make(Type.HEADQUARTERS, 1)
	assert_true((model.find_child("Beacon", true, false) as Node3D).visible)
	assert_true((model.find_child("Dish", true, false) as Node3D).visible)
	assert_false((model.find_child("Tier2", true, false) as Node3D).visible)


func _make(type: BuildingType.Value, level: int) -> Node3D:
	var node := WorldModels.building(type, level)
	_made.append(node)
	return node


func _shown(model: Node3D) -> int:
	var shown := 0
	for tier in range(1, 4):
		if (model.find_child("Tier%d" % tier, true, false) as Node3D).visible:
			shown = tier
	return shown

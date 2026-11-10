extends TestCase
## test/domain/map/terrain_type_test.dart: the ground of a cell.


func test_terrain_type_has_only_plain() -> void:
	assert_eq(TerrainType.Value.size(), 1)
	assert_has(TerrainType.Value.values(), TerrainType.Value.PLAIN)


## Not in the Dart file: the names the snapshots and the vectors write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(TerrainType.Value), PackedStringArray(["plain"]))

extends TestCase
## The colours that tell the eleven buildings apart.

## No two buildings are closer than this in red, green and blue.
const MIN_DISTANCE := 0.25


func test_gives_every_building_a_colour() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		assert_ne(WorldPalette.of(type).a, 0.0, str(type))
		assert_ne(WorldPalette.of(type), WorldPalette.DEGRADED)


func test_no_two_buildings_share_a_colour_or_one_too_close() -> void:
	var seen: Dictionary[String, Color] = {}
	for type: BuildingType.Value in BuildingType.Value.values():
		var name := DartEnum.name_of(BuildingType.Value, type)
		var color := WorldPalette.of(type)
		for other in seen:
			var apart := Vector3(color.r - seen[other].r, color.g - seen[other].g,
				color.b - seen[other].b).length()
			assert_true(apart >= MIN_DISTANCE, "%s and %s: %f" % [name, other, apart])
		seen[name] = color

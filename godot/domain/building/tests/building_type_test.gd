extends TestCase
## test/domain/building/building_type_test.dart: the buildings of a base.
## Its Hive round-trip is not ported (saves come later, in data/).

const NAMES: Array[String] = [
	"headquarters", "algaeFarm", "coralMine", "oreExtractor", "solarPanel", "laboratory",
	"barracks", "coralCitadel", "descentModule", "pressureCapsule", "volcanicKernel",
]


func test_building_type_headquarters_exists() -> void:
	assert_eq(DartEnum.name_of(BuildingType.Value, BuildingType.Value.HEADQUARTERS), NAMES[0])


func test_building_type_enum_has_exactly_11_values() -> void:
	assert_eq(BuildingType.Value.size(), 11)


func test_building_type_volcanic_kernel_exists() -> void:
	assert_eq(DartEnum.by_name(BuildingType.Value, "volcanicKernel"), BuildingType.Value.VOLCANIC_KERNEL)


func test_building_type_laboratory_exists() -> void:
	assert_eq(DartEnum.by_name(BuildingType.Value, "laboratory"), BuildingType.Value.LABORATORY)


func test_building_type_barracks_exists() -> void:
	assert_eq(DartEnum.by_name(BuildingType.Value, "barracks"), BuildingType.Value.BARRACKS)


func test_building_type_coral_citadel_exists() -> void:
	assert_eq(DartEnum.by_name(BuildingType.Value, "coralCitadel"), BuildingType.Value.CORAL_CITADEL)


## Not in the Dart file: the names and the order the snapshots write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(BuildingType.Value), PackedStringArray(NAMES))


func test_player_defaults_buildings_contains_volcanic_kernel_at_level_0() -> void:
	var buildings := PlayerDefaults.buildings()
	assert_true(buildings.has(BuildingType.Value.VOLCANIC_KERNEL))
	assert_eq(buildings[BuildingType.Value.VOLCANIC_KERNEL].level, 0)

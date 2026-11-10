extends TestCase
## A Dart enum ported as a GDScript enum still reads and writes the names
## Dart gives its values: the snapshots, the journals and the vectors hold
## them.

enum Sample { HEADQUARTERS, ALGAE_FARM, HQ_LEVEL_1, HQ_LEVEL2, A }


func test_a_value_has_the_name_dart_gives_it() -> void:
	assert_eq(DartEnum.name_of(Sample, Sample.HEADQUARTERS), "headquarters")
	assert_eq(DartEnum.name_of(Sample, Sample.ALGAE_FARM), "algaeFarm")
	assert_eq(DartEnum.name_of(Sample, Sample.A), "a")


func test_a_digit_stays_where_it_is() -> void:
	assert_eq(DartEnum.name_of(Sample, Sample.HQ_LEVEL_1), "hqLevel1")
	assert_eq(DartEnum.name_of(Sample, Sample.HQ_LEVEL2), "hqLevel2")


func test_the_names_come_in_the_order_of_the_declaration() -> void:
	assert_eq(
		DartEnum.names(Sample),
		PackedStringArray(["headquarters", "algaeFarm", "hqLevel1", "hqLevel2", "a"])
	)


func test_a_name_reads_back_as_its_value() -> void:
	for value: Sample in Sample.values():
		assert_eq(DartEnum.by_name(Sample, DartEnum.name_of(Sample, value)), value)
	var farm: Sample = DartEnum.by_name(Sample, "algaeFarm")
	assert_eq(farm, Sample.ALGAE_FARM)


func test_an_unknown_name_reads_as_null() -> void:
	assert_null(DartEnum.by_name(Sample, "ALGAE_FARM"))
	assert_null(DartEnum.by_name(Sample, "algae_farm"))
	assert_null(DartEnum.by_name(Sample, "laboratory"))
	assert_null(DartEnum.by_name(Sample, ""))


func test_a_number_that_is_no_value_has_no_name() -> void:
	expect_error("DartEnum.name_of: 7 is no value")
	assert_eq(DartEnum.name_of(Sample, 7), "")


func test_writes_a_constant_as_dart_writes_a_name() -> void:
	assert_eq(DartEnum.dart_name("CORAL_CITADEL"), "coralCitadel")
	assert_eq(DartEnum.dart_name("IS_O_K"), "isOK")
	assert_eq(DartEnum.dart_name("NONE"), "none")

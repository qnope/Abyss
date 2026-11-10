extends TestCase
## test/domain/map/transition_base_name_test.dart: which base of its type a
## transition base is.

const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE


func test_four_failles_and_three_cheminees_ranked_from_0() -> void:
	assert_eq(_ranks(TransitionBaseName.all_of(FAILLE)), [0, 1, 2, 3])
	assert_eq(_ranks(TransitionBaseName.all_of(CHEMINEE)), [0, 1, 2])
	for name: TransitionBaseName in TransitionBaseName.all_of(CHEMINEE):
		assert_eq(name.type, CHEMINEE)


func test_a_name_is_stored_as_a_code_read_back_as_the_same_name() -> void:
	for type: TransitionBaseType.Value in TransitionBaseType.Value.values():
		for name: TransitionBaseName in TransitionBaseName.all_of(type):
			assert_true(name.equals(TransitionBaseName.parse(name.code())), name.code())
	assert_eq(TransitionBaseName.new(FAILLE, 2).code(), "faille:2")


func test_reads_the_french_names_older_saves_stored() -> void:
	_assert_name(TransitionBaseName.parse("Faille Alpha"), FAILLE, 0)
	_assert_name(TransitionBaseName.parse("Faille Delta"), FAILLE, 3)
	_assert_name(TransitionBaseName.parse("Cheminee Primaire"), CHEMINEE, 0)
	_assert_name(TransitionBaseName.parse("Cheminee Tertiaire"), CHEMINEE, 2)


func test_any_other_text_names_no_known_base() -> void:
	assert_null(TransitionBaseName.parse("Faille Noire"))
	assert_null(TransitionBaseName.parse(""))
	assert_null(TransitionBaseName.parse("faille:x"))
	assert_null(TransitionBaseName.parse("volcan:0"))


## A Dart set holds equal names once: here a set is keyed by their code,
## which the Dart `hashCode` is made of.
func test_the_same_base_is_one_name_whether_parsed_or_built() -> void:
	var names: Dictionary[String, bool] = {}
	for name: TransitionBaseName in [
		TransitionBaseName.parse("Faille Beta"),
		TransitionBaseName.parse("faille:1"),
		TransitionBaseName.new(FAILLE, 1),
		TransitionBaseName.new(CHEMINEE, 1),
	]:
		names[name.code()] = true
	assert_eq(names.size(), 2)
	assert_true(TransitionBaseName.parse("Faille Beta").equals(TransitionBaseName.new(FAILLE, 1)))
	assert_false(TransitionBaseName.new(FAILLE, 1).equals(TransitionBaseName.new(CHEMINEE, 1)))
	assert_false(TransitionBaseName.new(FAILLE, 1).equals(TransitionBaseName.new(FAILLE, 2)))
	assert_false(TransitionBaseName.new(FAILLE, 1).equals("faille:1"))
	assert_eq(str(TransitionBaseName.new(CHEMINEE, 1)), "cheminee:1")


## Not in the Dart file: the other names of the legacy table, the extra
## names of a larger map, the level a name opens and the count of each type.
func test_names_more_bases_on_a_larger_map() -> void:
	_assert_name(TransitionBaseName.parse("Faille Beta"), FAILLE, 1)
	_assert_name(TransitionBaseName.parse("Faille Gamma"), FAILLE, 2)
	_assert_name(TransitionBaseName.parse("Cheminee Secondaire"), CHEMINEE, 1)
	assert_eq(_ranks(TransitionBaseName.all_of(CHEMINEE, 2)), [0, 1, 2, 3, 4])
	assert_eq(TransitionBaseName.count_of(FAILLE), 4)
	assert_eq(TransitionBaseName.count_of(CHEMINEE), 3)
	assert_eq(TransitionBaseName.new(FAILLE, 0).target_level(), 2)
	assert_eq(TransitionBaseName.new(CHEMINEE, 0).target_level(), 3)


## Not in the Dart file: a code is read as `split(':')` and `int.tryParse`
## read it in Dart.
func test_reads_a_code_as_dart_does() -> void:
	_assert_name(TransitionBaseName.parse("faille:7"), FAILLE, 7)
	_assert_name(TransitionBaseName.parse("cheminee: 12 "), CHEMINEE, 12)
	_assert_name(TransitionBaseName.parse("faille:-1"), FAILLE, -1)
	_assert_name(TransitionBaseName.parse("faille:0x10"), FAILLE, 16)
	for stored: String in ["faille", "faille:", "faille:1:2", ":1", "Faille:1", " faille:1"]:
		assert_null(TransitionBaseName.parse(stored), stored)


func _ranks(names: Array[TransitionBaseName]) -> Array:
	return names.map(func(name: TransitionBaseName) -> int: return name.rank)


func _assert_name(name: TransitionBaseName, type: TransitionBaseType.Value, rank: int) -> void:
	assert_not_null(name)
	if name != null:
		assert_eq([name.type, name.rank], [type, rank])

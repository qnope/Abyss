extends TestCase
## test/domain/map/transition_base_test.dart: a Faille or a Cheminée, the
## post that leads from a level to the next.

const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE


func test_transition_base_constructs_with_required_fields() -> void:
	var base := TransitionBase.new(FAILLE, "Faille Alpha")
	assert_eq(base.type, FAILLE)
	assert_eq(base.name, "Faille Alpha")
	assert_null(base.captured_by)


func test_transition_base_is_captured_is_false_when_captured_by_is_null() -> void:
	var base := TransitionBase.new(FAILLE, "Faille Alpha")
	assert_false(base.is_captured())


func test_transition_base_is_captured_is_true_when_captured_by_is_set() -> void:
	var base := TransitionBase.new(CHEMINEE, "Cheminee Beta", "player-1")
	assert_true(base.is_captured())


func test_transition_base_difficulty_is_4_for_faille() -> void:
	assert_eq(TransitionBase.new(FAILLE, "F1").difficulty(), 4)


func test_transition_base_difficulty_is_5_for_cheminee() -> void:
	assert_eq(TransitionBase.new(CHEMINEE, "C1").difficulty(), 5)


func test_transition_base_target_level_is_2_for_faille() -> void:
	assert_eq(TransitionBase.new(FAILLE, "F1").target_level(), 2)


func test_transition_base_target_level_is_3_for_cheminee() -> void:
	assert_eq(TransitionBase.new(CHEMINEE, "C1").target_level(), 3)


func test_transition_base_base_name_reads_the_stored_code_and_older_french_names() -> void:
	var of_code := TransitionBase.new(FAILLE, "cheminee:1").base_name()
	assert_true(TransitionBaseName.new(CHEMINEE, 1).equals(of_code))
	var of_french_name := TransitionBase.new(FAILLE, "Faille Gamma").base_name()
	assert_true(TransitionBaseName.new(FAILLE, 2).equals(of_french_name))
	assert_null(TransitionBase.new(FAILLE, "F1").base_name())


## Not in the Dart file: the pearls of a captured base, and its capture,
## the one field that changes.
func test_a_base_yields_pearls_and_can_be_captured() -> void:
	assert_eq(TransitionBase.new(FAILLE, "F1").pearls_per_turn(), 2)
	assert_eq(TransitionBase.new(CHEMINEE, "C1").pearls_per_turn(), 3)
	var base := TransitionBase.new(FAILLE, "faille:0")
	base.captured_by = "human"
	assert_true(base.is_captured())
	assert_eq(base.captured_by, "human")


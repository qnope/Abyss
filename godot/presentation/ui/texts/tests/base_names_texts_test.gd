extends TextsTestCase
## The names of the posts and of the attackers the reports show
## (transition_base_name_extensions.dart, attacker_name_texts.dart).

const Type := TransitionBaseType.Value


func test_a_faille_is_named_by_its_rank() -> void:
	assert_eq(TransitionBaseNameTexts.label("faille:0"), "Faille Alpha")
	assert_eq(TransitionBaseNameTexts.label("faille:1"), "Faille Bêta")
	TranslationServer.set_locale("en")
	assert_eq(TransitionBaseNameTexts.label("faille:1"), "Beta Rift")
	assert_eq(TransitionBaseNameTexts.label("faille:3"), "Delta Rift")


func test_a_cheminee_is_named_by_its_rank() -> void:
	assert_eq(TransitionBaseNameTexts.label("cheminee:0"), "Cheminée Primaire")
	assert_eq(TransitionBaseNameTexts.label("cheminee:2"), "Cheminée Tertiaire")
	TranslationServer.set_locale("en")
	assert_eq(TransitionBaseNameTexts.label("cheminee:1"), "Secondary Vent")


func test_a_rank_with_no_name_of_its_own_is_numbered() -> void:
	assert_eq(TransitionBaseNameTexts.display_name(TransitionBaseName.new(Type.FAILLE, 4)), "Faille Abyssale 5")
	assert_eq(TransitionBaseNameTexts.display_name(TransitionBaseName.new(Type.CHEMINEE, 3)), "Cheminée du Noyau 4")


func test_an_older_french_name_is_read_as_the_post_it_stands_for() -> void:
	assert_eq(TransitionBaseNameTexts.label("Faille Beta"), "Faille Bêta")


func test_the_volcanic_kernel_is_a_building() -> void:
	assert_eq(TransitionBaseNameTexts.label("volcanicKernel"), "Noyau Volcanique")
	TranslationServer.set_locale("en")
	assert_eq(TransitionBaseNameTexts.label("volcanicKernel"), BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL))


func test_a_text_naming_no_base_is_shown_as_it_is() -> void:
	assert_eq(TransitionBaseNameTexts.label("Nacre"), "Nacre")


func test_the_guardians_are_named_in_the_language_on() -> void:
	assert_eq(AttackerNameTexts.label(LeviathanForce.ATTACKER_NAME), "Le Léviathan")
	TranslationServer.set_locale("en")
	assert_eq(AttackerNameTexts.label(LeviathanForce.ATTACKER_NAME), "The Leviathan")
	assert_eq(AttackerNameTexts.label("Nacre"), "Nacre", "any other player by its own name")

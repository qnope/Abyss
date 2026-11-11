extends TestCase
## lib/presentation/extensions/transition_base_name_extensions.dart
## (`baseNameLabel`): the name of the post above a passage.


func test_names_the_posts_the_game_names_in_the_language_on() -> void:
	assert_eq(PassageName.of("faille:0"), "Faille Alpha")
	assert_eq(PassageName.of("faille:3"), "Faille Delta")
	assert_eq(PassageName.of("cheminee:1"), "Cheminée Secondaire")


func test_numbers_a_post_past_the_named_ones() -> void:
	assert_eq(PassageName.of("faille:5"), "Faille Abyssale 6")
	assert_eq(PassageName.of("cheminee:3"), "Cheminée du Noyau 4")


func test_reads_an_older_french_name() -> void:
	assert_eq(PassageName.of("Faille Alpha"), "Faille Alpha")


func test_keeps_the_text_of_a_name_no_map_generates() -> void:
	assert_eq(PassageName.of("Faille Noire"), "Faille Noire")


func test_a_passage_with_no_name_is_unknown() -> void:
	assert_eq(PassageName.of(null), Texts.t(&"screenUnknownPassage"))

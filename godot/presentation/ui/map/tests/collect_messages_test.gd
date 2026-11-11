extends TestCase
## test/presentation/screens/game/game_screen_collect_messages_test.dart:
## what the dialog that tells a search says, by what was searched.

const Content := CellContentType.Value


func test_titles_what_was_searched() -> void:
	assert_eq(CollectMessages.title_for(Content.RESOURCE_BONUS), "Trésor collecté !")
	assert_eq(CollectMessages.title_for(Content.RUINS), "Ruines fouillées !")
	assert_eq(CollectMessages.title_for(Content.WRECK), "Épave fouillée !")


func test_titles_anything_else_with_the_plain_collection() -> void:
	assert_eq(CollectMessages.title_for(Content.EMPTY), Texts.t(&"screenCollectTitle"))


func test_says_what_an_empty_search_of_ruins_and_a_wreck_found() -> void:
	assert_eq(CollectMessages.empty_message_for(Content.RUINS), "Les ruines étaient vides...")
	assert_eq(CollectMessages.empty_message_for(Content.WRECK), Texts.t(&"screenWreckEmpty"))


func test_says_nothing_particular_of_any_other_empty_search() -> void:
	assert_eq(CollectMessages.empty_message_for(Content.RESOURCE_BONUS), Texts.t(&"screenNothingToCollect"))

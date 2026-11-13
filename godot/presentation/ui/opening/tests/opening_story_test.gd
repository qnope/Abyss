extends UiTestCase
## test/presentation/widgets/opening/opening_story_test.dart: the four cards of
## the plan, in the three languages, with their pictures.

const GUIDE := "res://assets/icons/guide/octopus_archivist.svg"


func test_tells_the_four_cards_of_the_plan_in_french() -> void:
	var pages := OpeningStory.pages()
	var titles := PackedStringArray()
	for page in pages:
		titles.append(page.title)
	assert_eq(titles, PackedStringArray(
		["Le Grand Naufrage", "Les abysses écoutent", "Le Noyau éteint", "Ton but"]))
	assert_eq(pages[0].lines, PackedStringArray([
		"Le monde d'en haut est devenu invivable. Les derniers navires ont coulé leurs dômes jusqu'au récif, là où le jour arrive encore.",
		"Ton dôme vient de s'y poser, au-dessus de la Fosse.",
	]))
	assert_eq(pages[3].lines[1],
		"Rallume-le jusqu'à son dixième feu avant les colonies rivales : dompte le Volcan.")


func test_tells_two_lines_a_card_in_english_and_spanish_too() -> void:
	for code: String in ["en", "es"]:
		use_language(code)
		var pages := OpeningStory.pages()
		assert_eq(pages.size(), 4)
		for page in pages:
			assert_false(page.title.is_empty())
			assert_eq(page.lines.size(), 2)
			assert_false(page.lines[0].is_empty() or page.lines[1].is_empty())
	use_language("en")
	assert_eq(OpeningStory.pages()[0].title, "The Great Sinking")
	use_language("es")
	assert_eq(OpeningStory.pages()[3].title, "Tu meta")


func test_pictures_the_dome_the_swarm_the_core_and_the_archivist() -> void:
	var pages := OpeningStory.pages()
	var dome: Portrait = pages[0].make_picture.call()
	var swarm: Portrait = pages[1].make_picture.call()
	var core: Portrait = pages[2].make_picture.call()
	var archivist: UiIcon = pages[3].make_picture.call()
	assert_eq(dome.display_name, BuildingTexts.display_name(BuildingType.Value.HEADQUARTERS))
	assert_eq(swarm.display_name, MonsterFamilyTexts.label(MonsterFamily.Value.SWARM))
	assert_eq(core.display_name, BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL))
	for picture: Portrait in [dome, swarm, core]:
		assert_not_null(picture.picture_rect, "the render, not initials")
	assert_eq(archivist.icon_path, GUIDE)
	assert_eq(archivist.custom_minimum_size, Vector2.ONE * OpeningStory.PICTURE_SIZE)
	for picture: Control in [dome, swarm, core, archivist]:
		picture.free()

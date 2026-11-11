extends TextsTestCase
## test/presentation/extensions/guide_campaign_texts_test.dart: what the guide
## says past the tutorial chapter.

const Target := AssaultTarget.Value
const Id := ObjectiveId.Value


func _say(message: GuideMessage, locale := "fr") -> String:
	TranslationServer.set_locale(locale)
	return GuideMessageTexts.text(message)


func test_the_admiral_its_barracks_and_its_descent() -> void:
	assert_eq(_say(GuideAdmiralNeedsBarracks.new(Target.FAILLE, 2)),
		"Pour prendre une Faille, il faut un Amiral. Monte la Caserne au niveau 2.")
	assert_eq(_say(GuideAdmiralToRecruit.new(Target.FAILLE)),
		"Recrute un Amiral : il ne se bat pas, mais sans lui la Faille ne se prend pas.")
	assert_eq(_say(GuideAdmiralToSend.new(Target.KERNEL, 3, 2)), "Pour prendre le Noyau, ton Amiral doit descendre au "
		+ "niveau 3. Il est au niveau 2 : envoie-le par ta Cheminée, entourée sur la Carte au niveau 2.")
	assert_true(_say(GuideAdmiralToSend.new(Target.KERNEL, 3, 1)).contains(
		"Il est au niveau 1 : envoie-le par ta Faille"))
	assert_eq(_say(GuideAdmiralToSend.new(Target.CHEMINEE, 2, 1), "en"), "To take the Vent, your Admiral must go down "
		+ "to level 2. He is on level 1: send him through your Rift, highlighted on the Map on level 1.")
	assert_true(_say(GuideAdmiralToSend.new(Target.KERNEL, 3, 2), "es").contains(
		"Está en el nivel 2: envíalo por tu Chimenea"))
	assert_eq(_say(GuideAdmiralNeedsBarracks.new(Target.CHEMINEE, 2), "en"),
		"To take a Vent, you need an Admiral. Raise the Barracks to level 2.")


func test_the_post_to_find() -> void:
	assert_eq(_say(GuidePostToFind.new(Target.FAILLE)), "Explore la Carte pour trouver une Faille, mais n'oublie pas "
		+ "de continuer à améliorer tes bâtiments et ton armée !")
	assert_true(_say(GuidePostToFind.new(Target.CHEMINEE)).begins_with(
		"Explore la Carte au niveau 2 pour trouver une Cheminée"))
	assert_eq(_say(GuidePostToFind.new(Target.KERNEL), "en"), "Explore the Map on level 3 to find the Core, but don't "
		+ "forget to keep upgrading your buildings and your army!")
	assert_true(_say(GuidePostToFind.new(Target.KERNEL), "es").begins_with("Explora el Mapa en el nivel 3"))


func test_the_post_to_assault() -> void:
	assert_eq(_say(GuidePostAssault.new(Target.FAILLE, 14)), "Une Faille ! Ton Amiral doit survivre : couvre-le de "
		+ "Gardiens. Envoie-le avec au moins 14 Harponneurs : tu gagnes 19 fois sur 20.")
	assert_eq(_say(GuidePostAssault.new(Target.FAILLE)),
		"Une Faille ! Ton Amiral doit survivre : couvre-le de Gardiens.")
	assert_eq(_say(GuidePostAssault.new(Target.KERNEL, 0), "en"), "The Core! Your Admiral must survive: cover him with "
		+ "Guardians. Your escort is enough: you win 19 times out of 20.")
	assert_true(_say(GuidePostAssault.new(Target.FAILLE, 1), "es").contains("al menos 1 Arponero:"))


func test_a_victory_where_the_admiral_fell() -> void:
	assert_eq(_say(GuideAdmiralFell.new(Target.FAILLE)), "Victoire, mais ton Amiral est tombé : la Faille n'est pas "
		+ "prise. Couvre-le de Gardiens et recommence.")
	assert_true(_say(GuideAdmiralFell.new(Target.KERNEL)).contains("n'est pas pris."))
	assert_true(_say(GuideAdmiralFell.new(Target.KERNEL), "en").contains("the Core"))


func test_the_passages_and_the_posts_held() -> void:
	assert_true(_say(GuidePassageNeedsHq.new(BuildingType.Value.DESCENT_MODULE, 5)).begins_with(
		"Le Module de descente demande le QG 5"))
	assert_true(_say(GuidePassageNeedsHq.new(BuildingType.Value.PRESSURE_CAPSULE, 8), "en").begins_with(
		"The Pressure Capsule needs Headquarters level 8"))
	assert_eq(_say(GuidePostUndefended.new(TransitionBaseType.Value.FAILLE, 2)), "Ta Faille n'est gardée que par tes "
		+ "unités du niveau 2. Si elle tombe, ton Module est détruit et tes unités d'en bas sont perdues.")
	assert_true(_say(GuidePostUndefended.new(TransitionBaseType.Value.CHEMINEE, 3), "es").contains("Chimenea"))


func test_a_message_of_the_tutorial_has_no_campaign_words() -> void:
	assert_eq(GuideCampaignTexts.text(GuideGoalMet.new()), "")


func test_a_kraken_wave_on_the_kernel() -> void:
	assert_eq(_say(GuideKernelWave.new(4, 12)), "Les Krakens viennent reprendre le Noyau ! Mets au moins 12 unités en "
		+ "garnison avant la fin du tour, sinon le Noyau perd un niveau.")
	assert_true(_say(GuideKernelWave.new(40), "en").begins_with("40 Krakens"))


func test_a_lesson_for_each_step_of_the_rift_the_chimney_and_the_kernel() -> void:
	var steps: Array[Id] = [Id.DESCENT_MODULE, Id.DESCEND_LEVEL_2, Id.HQ_LEVEL_8, Id.PRESSURE_CAPSULE,
		Id.DESCEND_LEVEL_3, Id.HQ_LEVEL_10, Id.KERNEL_LEVEL_1]
	for locale: String in LANGUAGES:
		for id: Id in steps:
			assert_ne(_say(GuideLesson.new(id), locale), "", "%s %s" % [locale, id])
	assert_eq(_say(GuideLesson.new(Id.DESCEND_LEVEL_2)),
		"Envoie des unités au niveau 2 par la Faille. Attention, elles ne remontent pas.")

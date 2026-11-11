extends TextsTestCase
## test/presentation/extensions/guide_message_extensions_test.dart and
## guide_leviathan_text_test.dart: what the guide says.

const Id := ObjectiveId.Value
const Target := AssaultTarget.Value


func _say(message: GuideMessage) -> String:
	return GuideMessageTexts.text(message)


func _in(locale: String, message: GuideMessage) -> String:
	TranslationServer.set_locale(locale)
	return _say(message)


func test_a_lesson_tells_what_the_objective_asks() -> void:
	var words := {
		Id.HQ_LEVEL_1: ["QG", "un seul par tour", "« Tour suivant »"],
		Id.MINES: ["Mine de corail", "Extracteur", "plus cher"],
		Id.HQ_LEVEL_2: ["QG niveau 2", "Caserne", "Laboratoire", "bruit"],
		Id.BARRACKS_AND_SCOUTS: ["2 Éclaireurs", "algues", "bruit"],
		Id.LABORATORY_AND_RESEARCH: ["Une seule recherche par tour", "définitifs"],
		Id.FIRST_RAID: ["2 tours", "Harponneurs", "Citadelle"],
	}
	for id: Id in words:
		var text := _say(GuideLesson.new(id))
		for word: String in words[id]:
			assert_true(text.contains(word), "%s says %s" % [id, word])


func test_every_tutorial_objective_has_a_lesson_in_every_language() -> void:
	for locale: String in LANGUAGES:
		TranslationServer.set_locale(locale)
		for objective in InstallationObjectives.installation_objectives():
			assert_ne(GuideLessonTexts.lesson(objective.id), "", "%s %s" % [locale, objective.id])
		assert_eq(GuideLessonTexts.lesson(Id.TAKE_LAIR), "")


func test_a_lesson_speaks_english_and_spanish() -> void:
	assert_eq(_in("en", GuideLesson.new(Id.BARRACKS_AND_SCOUTS)), "Build the Barracks, then recruit 2 Scouts in the "
		+ "Army tab. Every unit eats algae each turn, and every recruit raises the noise.")
	assert_true(_in("es", GuideLesson.new(Id.HQ_LEVEL_2)).begins_with(
		"El Cuartel General de nivel 2 desbloquea los Barracones"))


func test_what_holds_an_objective_back_in_french() -> void:
	assert_eq(_say(GuideGoalMet.new()), "Bravo, c'est fait ! Termine le tour pour valider l'objectif et toucher ta récompense.")
	assert_true(_say(GuideWorksiteTaken.new()).contains("chantier du tour"))
	assert_true(_say(GuideAlreadyRecruited.new()).contains("déjà recruté"))
	assert_true(_say(GuideExploring.new()).contains("en route"))
	assert_eq(_say(GuideStorm.new(8)), "Une tempête ferme l'exploration jusqu'à la fin du tour 8. "
		+ "Patiente : l'objectif t'attend, termine le tour.")
	assert_true(_say(GuideWreck.new(9, false)).contains("Caserne"))
	assert_true(_say(GuideWreck.new(9, true)).contains("Recrute un Éclaireur"))


func test_what_holds_an_objective_back_in_english_and_spanish() -> void:
	assert_eq(_in("en", GuideExploring.new()), "Your Scout is on its way. End the turn to find out what the tile hides.")
	assert_eq(_in("es", GuideWreck.new(9, true)), "Un pecio se ha hundido cerca de tu base, visible hasta el final "
		+ "del turno 9. Recluta un Explorador en la pestaña Ejército para ir a registrarlo.")


func test_the_raid_names_the_harpoonists_missing() -> void:
	assert_eq(_say(GuideRaidAlert.new(12, 28, 5, 2, true)), "Le raid arrive au tour 12 avec 28 monstres. Aie au moins "
		+ "5 Harponneurs au niveau 1 : il t'en manque 2. Recrute-les dans l'onglet Armée.")
	assert_true(_say(GuideRaidAlert.new(12, 1, 1, 1, true)).ends_with("Recrute-le dans l'onglet Armée."))


func test_once_recruited_the_rest_comes_next_turn_or_hold_on() -> void:
	assert_true(_say(GuideRaidAlert.new(12, 28, 5, 2)).ends_with(
		"Tu as déjà recruté ce tour : recrute-les au prochain tour."))
	assert_true(_say(GuideRaidAlert.new(10, 28, 5, 2, false, true)).ends_with(
		"Tu as déjà recruté ce tour : termine-le et tiens bon."))


func test_a_base_strong_enough_or_a_wave_out_of_reach() -> void:
	assert_eq(_say(GuideRaidAlert.new(12, 28, 5)), "Le raid arrive au tour 12 avec 28 monstres. Ta défense devrait "
		+ "le repousser : termine le tour pour l'attendre.")
	var out_of_reach := _say(GuideRaidAlert.new(12, 400))
	assert_true(out_of_reach.contains("400 monstres") and out_of_reach.contains("autant de Harponneurs"))


func test_the_raid_speaks_english_and_spanish() -> void:
	var alert := GuideRaidAlert.new(12, 28, 5, 1, true)
	assert_eq(_in("en", alert), "The raid arrives on turn 12 with 28 monsters. Have at least 5 Harpooners on level 1: "
		+ "you're 1 short. Recruit it in the Army tab.")
	assert_eq(_in("es", alert), "La incursión llega en el turno 12 con 28 monstruos. Ten al menos 5 Arponeros en el "
		+ "nivel 1: te falta 1. Reclútalo en la pestaña Ejército.")


func test_the_guardians_coming_back_to_the_faille() -> void:
	var intro := ("Le Léviathan revient reprendre sa Faille ! Seules tes unités du niveau 2 la défendent. Si elle "
		+ "tombe, ton Module est détruit et tes unités d'en bas sont perdues.")
	assert_eq(_say(GuideLeviathanReturn.new(2, 0)), intro)
	assert_eq(_say(GuideLeviathanReturn.new(2, 6)), intro + " Envoie 6 Harponneurs de plus.")
	assert_true(_in("en", GuideLeviathanReturn.new(2, 1)).ends_with("Send 1 more Harpooner."))
	assert_true(_in("es", GuideLeviathanReturn.new(2, 3)).begins_with("¡El Leviatán vuelve"))
